defmodule Day05 do
  @moduledoc """
  Documentation for `Day05`.
  """

  def points_overlap() do
    load_input()
    |> only_horizontal_vertical()
    |> fill_board()
    |> Enum.reduce(0, fn
      {_k, v}, acc when v >= 2 ->
        acc + 1

      _, acc ->
        acc
    end)
  end

  def fill_board(lines) do
    lines
    |> Enum.reduce(
      %{},
      fn line, acc ->
        line
        |> points()
        |> Enum.reduce(acc, fn {x, y}, acc -> Map.update(acc, {x, y}, 1, fn v -> v + 1 end) end)
      end
    )
  end

  def points({{x, y1}, {x, y2}}) when y1 <= y2 do
    y1..y2
    |> Enum.map(fn y -> {x, y} end)
  end

  def points({{x, y1}, {x, y2}}), do: points({{x, y2}, {x, y1}})

  def points({{x1, y}, {x2, y}}) when x1 <= x2 do
    x1..x2
    |> Enum.map(fn x -> {x, y} end)
  end

  def points({{x1, y}, {x2, y}}), do: points({{x2, y}, {x1, y}})

  def only_horizontal_vertical(lines) do
    lines
    |> Enum.filter(fn
      {{x, _}, {x, _}} ->
        true

      {{_, y}, {_, y}} ->
        true

      _ ->
        false
    end)
  end

  def load_input() do
    {:ok, content} = File.read("./data/input.txt")

    content
    |> String.split("\n")
    |> Enum.filter(fn
      "" -> false
      _ -> true
    end)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    [l, r] = String.split(line, " -> ")
    {parse_point(l), parse_point(r)}
  end

  defp parse_point(p) do
    p
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end
end
