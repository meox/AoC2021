defmodule Day15 do
  @moduledoc """
  Documentation for `Day15`.
  """

  def part1() do
    input = sample()
    {{max_r, _}, _} = Enum.max_by(input, fn {{r, _c}, _} -> r end)
    {{_, max_c}, _} = Enum.max_by(input, fn {{_r, c}, _} -> c end)

    max_risk = 9 * (max_r + max_c)

    walk(%{}, {0, 0}, {max_r, max_c}, input, [], max_risk)
  end

  def walk(memo, dest, dest, _graph, _path, _max_risk) do
    {memo, 0}
  end

  def walk(memo, pos, dest, graph, path, max_risk) do
    case Map.get(memo, pos) do
      nil ->
        {memo, risk_children} = walk_slow(memo, pos, dest, graph, path, max_risk)
        risk_level = sum(graph[pos], risk_children)
        new_memo = Map.put(memo, pos, risk_level)
        {new_memo, risk_level}
      risk_memo ->
        {memo, risk_memo}
    end
  end

  def walk_slow(memo, pos, dest, graph, path, max_risk) do
    graph
    |> sibilings(pos)
    |> not_visited(path)
    |> Enum.reduce(
      {memo, :undef},
      fn p, {memo, min_risk} ->
        {memo, sub_risk} = walk(memo, p, dest, graph, [p | path], max_risk)
        risk_sib = graph[p]
        new_risk = sum(sub_risk, risk_sib)

        case min_risk do
          :undef ->
            {memo, new_risk}
          min_risk ->
            {memo, min(min_risk, new_risk)}
        end
      end
    )
  end

  def sum(:undef, x), do: x
  def sum(x, :undef), do: x
  def sum(x, y), do: x + y
  def not_visited(points, visited) do
    points
    |> Enum.map(fn p -> {p, Enum.member?(visited, p)} end)
    |> Enum.filter(fn {_, false} -> true; _ -> false end)
    |> Enum.map(& elem(&1, 0))
  end

  def sibilings(graph, {r, c}) do
    [
      {r, c - 1}, {r, c + 1},
      {r - 1, c}, {r + 1, c}
    ]
    |> Enum.map(& {&1, Map.get(graph, &1)})
    |> Enum.filter(fn {_, nil} -> false; _ -> true end)
    |> Enum.sort(fn {_, ra}, {_, rb} -> ra < rb end)
    |> Enum.map(& elem(&1, 0))
  end

  def input(), do: load_input("./data/input.txt")

  def sample(), do: load_input("./data/sample.txt")

  def load_input(filename) do
    {:ok, content} = File.read(filename)

    content
    |> String.split("\n", trim: true)
    |> Enum.filter(&(&1 != ""))
    |> Enum.map(fn line ->
      line
      |> String.split("", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.reduce(
      {0, %{}},
      fn line, {row, acc} ->
        new_acc =
          0..(Enum.count(line) - 1)
          |> Enum.zip(line)
          |> Enum.reduce(
            acc,
            fn {col, risk}, acc ->
              Map.put(acc, {row, col}, risk)
            end
          )

        {row + 1, new_acc}
      end
    )
    |> elem(1)
  end
end
