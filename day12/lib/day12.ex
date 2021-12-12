defmodule Day12 do
  @moduledoc """
  Documentation for `Day12`.
  """

  def part1() do
    visit('start', 'end', input(), &valid_path?/1)
    |> Enum.filter(fn path ->
      path
      |> Enum.filter(&is_lower/1)
      |> Enum.count()
    end)
    |> Enum.count()
  end

  def part2() do
    visit('start', 'end', input(), &valid_path2?/1)
    |> Enum.count()
  end

  def visit(start_node, end_node, graph, valid_path_cb) do
    visit_path(start_node, end_node, graph, valid_path_cb, [start_node], [])
  end

  def visit_path(end_node, end_node, _graph, _vcb, path, paths), do: [path | paths]

  def visit_path(start_node, end_node, graph, valid_path_cb, path, valid_paths) do
    graph
    |> nears(start_node)
    |> Enum.reduce(
      valid_paths,
      fn node, valid_paths ->
        new_path = [node | path]

        case valid_path_cb.(new_path) do
          true ->
            visit_path(node, end_node, graph, valid_path_cb, new_path, valid_paths)

          false ->
            valid_paths
        end
      end
    )
  end

  def valid_path?(path) do
    path
    |> Enum.filter(&is_lower/1)
    |> Enum.frequencies()
    |> Enum.all?(fn {_, v} -> v == 1 end)
  end

  def valid_path2?(path) do
    {lowers, start_c, end_c} =
      path
      |> Enum.reduce(
        {[], 0, 0},
        fn
          'start', {lowers, s, e} ->
            {lowers, s + 1, e}

          'end', {lowers, s, e} ->
            {lowers, s, e + 1}

          v, {lowers, s, e} = acc ->
            case is_lower(v) do
              true ->
                {[v | lowers], s, e}

              false ->
                acc
            end
        end
      )

    start_c == 1 and end_c <= 1 and
      (
        freq =
          lowers
          |> Enum.frequencies()
          |> Enum.filter(fn
            {_, v} when v == 1 -> false
            _ -> true
          end)

        match?([], freq) or match?([{_, 2}], freq)
      )
  end

  def nears(graph, node), do: graph[node]

  def is_lower(s) do
    Enum.all?(s, fn
      c when c in ?a..?z -> true
      _ -> false
    end)
  end

  def sample(), do: load_input("./data/sample.txt")
  def input(), do: load_input("./data/input.txt")

  def load_input(filename) do
    {:ok, content} = File.read(filename)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split("-", trim: true)
      |> Enum.map(&String.to_charlist/1)
    end)
    |> Enum.reduce(
      %{},
      fn [a, b], g ->
        nears = Map.get(g, a, [])
        g1 = Map.put(g, a, [b | nears])
        nears = Map.get(g1, b, [])
        Map.put(g1, b, [a | nears])
      end
    )
  end
end
