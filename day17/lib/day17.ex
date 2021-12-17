defmodule Day17 do
  @moduledoc """
  Documentation for `Day17`.
  """

  def input(), do: parse_input("target area: x=265..287, y=-103..-58")

  def parse_input("target area: " <> s) do
    #target area: x=265..287, y=-103..-58
    ["x=" <> rx, "y=" <> ry] = String.split(s, ", ")
    x = rx |> String.split("..") |> Enum.map(&String.to_integer/1)
    y = ry |> String.split("..") |> Enum.map(&String.to_integer/1)
    {x, y}
  end
end
