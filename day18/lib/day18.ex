defmodule Day18 do
  @moduledoc """
  Documentation for `Day18`.
  """

  def add(s1, s2) do
    [s1, s2]
    |> reduce()
  end

  def reduce(snail) do

  end

  def explode(g) do
    case SnailG.left_most_explode(g) do
      nil ->
        g
      %SnailG{id: id, left: left_orig, right: right_orig} = node ->
        nl = SnailG.next_left(g, node)
        nr = SnailG.next_right(g, node)

        g
        |> Map.delete(id)
        |> Map.put(id, %SnailG{node | val: 0, left: nil, right: nil})
        |> update_node(nl, new_val(nl, g[left_orig]))
        |> update_node(nr, new_val(nr, g[right_orig]))
        |> Map.delete(left_orig)
        |> Map.delete(right_orig)
    end
  end

  def new_val(nil, %SnailG{val: v}), do: v
  def new_val(%SnailG{val: v1}, %SnailG{val: v2}), do: v1 + v2

  def update_node(g, nil, _), do: g
  def update_node(g, %SnailG{id: id} = node, v) do
    Map.put(g, id, %SnailG{node | val: v})
  end

  def parse(snail) do
    {:ok, [res], _, _, _, _} = Snail.Parser.parse(snail)
    res
  end

  def sample() do
    "[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]"
    |> parse()
    |> SnailG.make()
  end

  def input(), do: load_input("./data/input.txt")

  def load_input(filename) do
    {:ok, content} = File.read!(filename)

  end
end
