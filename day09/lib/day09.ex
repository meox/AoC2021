defmodule Day09 do
  @moduledoc """
  Documentation for `Day09`.
  """

  def part1(table) do
    table
    |> low_points()
    |> Enum.reduce(
      0,
      fn p, acc ->
        risk_level = Map.get(table, p) + 1
        acc + risk_level
      end
    )
  end

  def part2(table) do
    table
    |> low_points()
    |> Enum.map(fn p -> {p, find_basin(p, table) |> Enum.count()} end)
    |> Enum.sort(fn {_p0, s0}, {_p1, s1} -> s0 > s1 end)
    |> Enum.take(3)
    |> Enum.map(fn {_, s} -> s end)
    |> Enum.reduce(1, fn x, acc -> acc * x end)
  end

  def find_basin(low_point, table) do
    h = Map.get(table, low_point)

    os =
      low_point
      |> adjacents(table)
      |> Enum.filter(fn p ->
        hp = Map.get(table, p)
        hp < 9 && hp > h
      end)
      |> Enum.flat_map(fn p -> find_basin(p, table) end)
      |> Enum.uniq()

    [low_point | os]
  end

  def low_points(table) do
    table
    |> Enum.reduce(
      [],
      fn {p, h}, acc ->
        as = adjacents_high(p, table)
        case is_lowpoint(h, as) do
          true ->
            [p | acc]
          false ->
            acc
        end
      end
    )
  end

  def is_lowpoint(h, as) do
    h < Enum.min(as)
  end

  def adjacents_high({x0, y0}, table) do
    [
      {x0-1, y0}, {x0+1, y0},
      {x0, y0-1}, {x0, y0+1}
    ]
    |> Enum.map(fn {x, y} -> Map.get(table, {x, y}) end)
    |> Enum.filter(fn :nil -> false; _ -> true end)
  end

  def adjacents({x0, y0}, table) do
    [
      {x0-1, y0}, {x0+1, y0},
      {x0, y0-1}, {x0, y0+1}
    ]
    |> Enum.filter(fn {x, y} -> Map.get(table, {x, y}) != :nil end)
  end

  def load_sample(), do: load_input("./data/sample.txt")
  def load_input(), do: load_input("./data/input.txt")
  def load_input(filename) do
    {:ok, content} = File.read(filename)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(
      fn line ->
        line
        |> String.split("", trim: true)
        |> Enum.map(&String.to_integer/1)
      end
    )
    |> Enum.reduce(
      {0, %{}},
      fn rows, {y, table} ->
        {_, new_table} =
          rows
          |> Enum.reduce(
            {0, table},
            fn h, {x, table} ->
              {x + 1, Map.put(table, {y, x}, h)}
            end
          )
        {y + 1, new_table}
      end
    )
    |> elem(1)
  end
end
