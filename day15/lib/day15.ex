defmodule Day15 do
  @moduledoc """
  Documentation for `Day15`.
  """

  def part1() do
    graph = input()

    source = {0, 0}
    target = {99, 99}
    {dist, prev} = dijkstra(graph, source, target)
    {dist[target], path(source, target, prev)}
  end

  def dijkstra(graph, source, target) do
    {dist, prev, q} =
      graph
      |> Enum.reduce(
        {%{}, %{}, MapSet.new()},
        fn {v, _risk}, {dist, prev, q} ->
          {Map.put(dist, v, :inf), Map.put(prev, v, :undef), MapSet.put(q, v)}
        end
      )

    dist = Map.put(dist, source, 0)
    dijkstra(q, dist, prev, target, graph)
  end

  def dijkstra(q, dist, prev, target, graph) do
    case MapSet.size(q) do
      0 ->
        {dist, prev}
      _ ->
        do_dijkstra(q, dist, prev, target, graph)
    end
  end

  def do_dijkstra(q, dist, prev, target, graph) do
    u = select_min_vertex(q, dist)
    new_q = MapSet.delete(q, u)

    do_dijkstra_from(u, target, new_q, dist, prev, graph)
  end

  def do_dijkstra_from(target, target, _q, dist, prev, _graph) do
    {dist, prev}
  end

  def do_dijkstra_from(u, target, q, dist, prev, graph) do
    {new_dist, new_prev} =
      neighbors(graph, u, q)
      |> Enum.reduce(
        {dist, prev},
        fn v, {dist, prev} ->
          alt = sum(dist[u], distance(graph, v))
          if alt < dist[v] do
            {Map.put(dist, v, alt), Map.put(prev, v, u)}
          else
            {dist, prev}
          end
        end
      )
    do_dijkstra(q, new_dist, new_prev, target, graph)
  end

  def path(source, target, prev) do
    path(source, target, prev, [])
  end

  def path(source, source, _prev, acc), do: [source | acc]
  def path(source, u, prev, acc) do
    add_to_path(prev[u], u, prev, source, acc)
  end

  def add_to_path(nil, _u, _prev, _source, acc), do: acc
  def add_to_path(:undef, _u, _prev, _source, acc), do: acc
  def add_to_path(prev_u, u, prev, source, acc) do
    path(source, prev_u, prev, [u | acc])
  end

  def distance(graph, v) do
    graph[v]
  end

  def sum(:inf, _x), do: :inf
  def sum(_x, :inf), do: :inf
  def sum(x, y), do: x + y

  def select_min_vertex(q, dist) do
    q
    |> Enum.reduce(
      fn a, b ->
        case {dist[a], dist[b]} do
          {:inf, _} ->
            b
          {_, :inf} ->
            a
          {x, y} when x < y ->
            a
          _ ->
            b
        end
    end)
  end

  def neighbors(graph, {r, c}, q) do
    [
      {r, c - 1}, {r, c + 1},
      {r - 1, c}, {r + 1, c}
    ]
    |> Enum.map(& {&1, Map.get(graph, &1)})
    |> Enum.filter(fn {_, nil} -> false; _ -> true end)
    |> Enum.map(& elem(&1, 0))
    |> Enum.filter(& MapSet.member?(q, &1))
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
