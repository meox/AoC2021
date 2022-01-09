defmodule Day15 do
  @moduledoc """
  Documentation for `Day15`.
  """

  def part1() do
    graph = sample()

    source = {0, 0}
    target = {9, 9}
    dist = dijkstra(graph, source, target)
    dist[target]
  end

  def part2() do
    graph = magnify(input(), 100)

    source = {0, 0}
    target = {499, 499}
    dist = dijkstra(graph, source, target)
    dist[target]
  end

  def dijkstra(graph, {r0, c0} = source, {rf, cf} = target) do
    q = MapSet.new(for a <- r0..rf, b <- c0..cf, do: {a, b})
    dist = Map.put(%{}, source, 0)
    dijkstra(q, dist, target, graph)
  end

  def dijkstra([], dist, _target, _graph), do: dist

  def dijkstra(q, dist, target, graph) do
    u = select_min_vertex(q, dist)
    new_q = MapSet.delete(q, u)
    do_dijkstra_from(u, target, new_q, dist, graph)
  end

  def do_dijkstra_from(target, target, _q, dist, _graph), do: dist

  def do_dijkstra_from(u, target, q, dist, graph) do
    new_dist =
      neighbors(u, q)
      |> Enum.reduce(
        dist,
        fn v, dist ->
          distance = graph[v]
          alt = sum(dist[u], distance)

          if alt != nil && alt < dist[v] do
            Map.put(dist, v, alt)
          else
            dist
          end
        end
      )

    dijkstra(q, new_dist, target, graph)
  end

  def sum(nil, _x), do: nil
  def sum(_x, nil), do: nil
  def sum(x, y), do: x + y

  def select_min_vertex(q, dist) do
    dist
    |> Enum.reduce(
      {nil, nil},
      fn {v, d}, {cv, min} ->
        if d < min and MapSet.member?(q, v) do
          {v, d}
        else
          {cv, min}
        end
      end
    )
    |> elem(0)
  end

  def neighbors({r, c}, q) do
    [
      {r, c + 1},
      {r + 1, c},
      {r - 1, c},
      {r, c - 1}
    ]
    |> Enum.filter(&MapSet.member?(q, &1))
  end

  def magnify(graph, real) do
    final = real * 5

    for r <- 0..(final - 1), c <- 0..(final - 1), into: %{} do
      {a, dr} = {rem(r, real), div(r, real)}
      {b, dc} = {rem(c, real), div(c, real)}

      risk = next(graph[{a, b}], dr + dc)
      {{r, c}, risk}
    end
  end

  def next(v, 0), do: v
  def next(9, n) when n > 0, do: next(1, n - 1)
  def next(v, n), do: next(v + 1, n - 1)

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
