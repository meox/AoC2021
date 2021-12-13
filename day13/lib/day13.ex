defmodule Day13 do
  @moduledoc """
  Documentation for `Day13`.
  """

  def cut_horizontal(dots, y_ref) do
    dots
    |> Enum.map(fn {x, y} -> {x, rem(y, y_ref)} end)
  end

  def show(dots) do
    {mx, my} = grid_size(dots)
    m = Enum.reduce(dots, %{}, fn [x, y], acc -> Map.put(acc, [x, y], "#") end)
    0..my
    |> Enum.map(
      fn y ->
        0..mx
        |> Enum.map(&  Map.get(m, [&1, y], "."))
        |> Enum.join("")
      end
    )
    |> Enum.join("\n")
    |> IO.puts()
  end

  def grid_size(dots) do
    dots
      |> Enum.reduce(
        {0, 0},
        fn
          [x, y], {mx, my} when x > mx and y > my ->
            {x, y}
          [x, y], {mx, my} when x > mx and y <= my ->
            {x, my}
          [x, y], {mx, my} when x <= mx and y > my ->
            {mx, y}
          _, {mx, my} ->
            {mx, my}
        end
      )
  end
  def sample(), do: load_input("./data/sample.txt")
  def input(), do: load_input("./data/input.txt")

  def load_input(filename) do
    {:ok, content} = File.read(filename)

    lines =
      content
      |> String.split("\n", trim: true)
      |> Enum.filter(& &1 != "")

    {folds, dots} = Enum.split_with(lines, & String.contains?(&1, "fold"))
    {parse_folds(folds), parse_dots(dots)}
  end

  def parse_folds(fs) do
    fs
    |> Enum.map(fn "fold along " <> cmd ->
      [axes, v] = String.split(cmd, "=", trim: true)
      {String.to_atom(axes), String.to_integer(v)}
    end)
  end

  def parse_dots(ds) do
    ds
    |> Enum.map(
      fn d ->
        d
        |> String.split(",", trim: true)
        |> Enum.map(&String.to_integer/1)
      end)
  end
end
