defmodule OneBillion do
  @chunk_size 100_000

  def measure(function) do
    function
    |> :timer.tc()
    |> elem(0)
    |> Kernel./(1_000_000)
  end

  # use MIX_ENV=prod mix "escript.build" to generate binary
  def main(_args) do
    initialize_results_table()
    parent = self()

    stream_measurements_line_by_line()
    |> Flow.from_enumerable()
    |> Flow.map(&Station.parse_station_and_measurement/1)
    |> Flow.partition()
    |> Flow.reduce(&initalize_ets/0, &reduce_station_reading/2)
    |> Flow.on_trigger(fn ets ->
      :ets.give_away(ets, parent, [])
      {[ets], :new_reduce_state_which_wont_be_used}
    end)
    |> Enum.to_list()
    |> Enum.each(&prepare_result/1)

    generate_results()
  end

  defp initialize_results_table do
    :ets.new(:station_results, [:named_table, :ordered_set])
  end

  defp stream_measurements_line_by_line do
    File.stream!("measurements.txt", read_ahead: @chunk_size)
  end

  defp initalize_ets do
    :ets.new(:stations, [:set])
  end

  defp reduce_station_reading([station, measurement], ets) do
    case :ets.lookup(ets, station) do
      [] ->
        %{
          min: measurement,
          max: measurement,
          sum: measurement,
          count: 1
        }
        |> update_ets_state(ets, station)

      [{_, state}] ->
        Station.update_state(state, measurement)
        |> update_ets_state(ets, station)
    end

    ets
  end

  defp update_ets_state(state, ets, station) do
    :ets.insert(ets, {station, state})
  end

  defp prepare_result(ets) do
    :ets.foldl(
      fn {station, state}, acc ->
        update_station_result_state(station, state)
        acc
      end,
      nil,
      ets
    )

    :ets.delete(ets)
  end

  defp generate_results do
    :ets.foldl(
      fn {station, state}, acc ->
        state
        |> Map.put(:name, station)
        |> Station.prepare_result()
        |> update_results_state(station)

        acc
      end,
      nil,
      :station_results
    )

    # To print fold station_results ets table
  end

  defp update_station_result_state(station, state) do
    case lookup_results(station) do
      [] ->
        update_results_state(state, station)

      [{_, state2}] ->
        Station.merge_states(state, state2)
        |> update_results_state(station)
    end
  end

  defp update_results_state(state, station) do
    :ets.insert(:station_results, {station, state})
  end

  defp lookup_results(station) do
    :ets.lookup(:station_results, station)
  end
end
