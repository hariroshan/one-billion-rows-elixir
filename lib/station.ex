defmodule Station do

  def parse_station_and_measurement(input) do
    parse_station(input, input, 0)
  end

  def update_state(%{min: mini, max: maxi, sum: total_sum, count: count} = state, measurement) do
    %{
      state
      | min: min(mini, measurement),
        max: max(maxi, measurement),
        sum: total_sum + measurement,
        count: count + 1
    }
  end

  def merge_states(%{min: mini1, max: maxi1, sum: total_sum1, count: count1}, %{
        min: mini2,
        max: maxi2,
        sum: total_sum2,
        count: count2
      }) do
    %{
      min: min(mini1, mini2),
      max: max(maxi1, maxi2),
      sum: total_sum1 + total_sum2,
      count: count1 + count2
    }
  end

  def prepare_result(%{name: station, min: mini, max: maxi, sum: sum, count: count}) do
    station <>
      "=" <>
      :erlang.float_to_binary(mini, decimals: 1) <>
      "/" <>
      :erlang.float_to_binary(sum / count, decimals: 1) <>
      "/" <>
      :erlang.float_to_binary(maxi, decimals: 1)
  end


  defp parse_station(bin, <<";",_rest::binary>>, count) do
    <<station::binary-size(count), ";", rest::binary>> = bin
    [station, parse_measurement(rest) / 10]
  end

  defp parse_station(bin, <<_c,rest::binary>>, count) do
    parse_station(bin, rest, count + 1)
  end

  defmacrop char_to_num(c) do
    quote do
      (unquote(c) - ?0)
    end
  end

  # Refer this
  # https://github.com/IceDragon200/1brc_ex/blob/59f01abae69f092de39c5fe14e17f697b9d31b13/src/1brc.workers.blob.maps.chunk_to_worker.exs
  defp parse_measurement(<<?-, d2, d1, ?., d01, "\n", _rest::binary>>) do
    -(char_to_num(d2) * 100 + char_to_num(d1) * 10 + char_to_num(d01))
  end

  defp parse_measurement(<<?-, d1, ?., d01, "\n", _rest::binary>>) do
    -(char_to_num(d1) * 10 + char_to_num(d01))
  end

  defp parse_measurement(<<d2, d1, ?., d01, "\n", _rest::binary>>) do
    char_to_num(d2) * 100 + char_to_num(d1) * 10 + char_to_num(d01)
  end

  defp parse_measurement(<<d1, ?., d01, "\n", _rest::binary>>) do
    char_to_num(d1) * 10 + char_to_num(d01)
  end
end
