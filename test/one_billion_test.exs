defmodule OneBillionTest do
  use ExUnit.Case
  doctest OneBillion

  test "greets the world" do
    assert OneBillion.hello() == :world
  end
end
