defmodule Day02 do
  @moduledoc """
  Documentation for `Day02`.
  """

  def part1() do
    %{x: x, depth: d} = calc_final_position(load_input())
    x * d
  end

  def part2() do
    %{x: x, depth: d} = calc_final_position_fixed(load_input())
    x * d
  end

  @spec calc_final_position(any) :: any
  def calc_final_position_fixed(input) do
    input
    |> Enum.reduce(
      %{x: 0, depth: 0, aim: 0},
      fn
        ({:up, v}, %{x: x, aim: aim, depth: d}) ->
          %{x: x, aim: aim - v, depth: d}
        ({:down, v}, %{x: x, aim: aim, depth: d}) ->
          %{x: x, aim: aim + v, depth: d}
        ({:forward, v}, %{x: x, aim: aim, depth: d}) ->
          %{x: x + v, aim: aim, depth: d + aim*v}
      end
    )
  end

  def calc_final_position(input) do
    input
    |> Enum.reduce(
      %{x: 0, depth: 0},
      fn
        ({:up, v}, %{x: x, depth: d}) ->
          %{x: x, depth: d - v}
        ({:down, v}, %{x: x, depth: d}) ->
          %{x: x, depth: d + v}
        ({:forward, v}, %{x: x, depth: d}) ->
          %{x: x + v, depth: d}
      end
    )
  end

  def load_input() do
    {:ok, content} = File.read("./data/input.txt")
    content
    |> String.split("\n")
    |> Enum.filter(fn("") -> false; (_) -> true end)
    |> Enum.map(fn(cmd) ->
      [action, val] = String.split(cmd)
      val_num = String.to_integer(val)
      case {action, val_num} do
        {"down", x} ->
          {:down, x}
        {"up", x} ->
          {:up, x}
        {"forward", x} ->
          {:forward, x}
      end
    end)
  end
end
