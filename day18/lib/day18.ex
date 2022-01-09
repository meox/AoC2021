defmodule Day18 do
  @moduledoc """
  Documentation for `Day18`.
  """

  def part1() do
    input()
    |> add()
    |> SnailG.magnitude()
  end

  def part2() do
    data = input()
    cs = for x <- data, y <- data, do: {x, y}

    cs
    |> Enum.filter(fn {x, y} -> SnailG.to_list(x) != SnailG.to_list(y) end)
    |> Enum.reduce(
      0,
      fn {x, y}, acc ->
        m1 = SnailG.magnitude(add([x, y]))
        m2 = SnailG.magnitude(add([y, x]))
        Enum.max([acc, m1, m2])
      end
    )
  end

  def add(xs) do
    xs
    |> Enum.reduce(fn x, acc ->
      SnailG.add(acc, x)
      |> reduce()
    end)
  end

  def reduce(snail) do
    snail
    |> explode()
    |> explode_continue()
  end

  def debug(snail) do
    IO.inspect(SnailG.to_list(snail), charlists: :as_lists)
    snail
  end

  def explode_continue({:ok, snail}) do
    reduce(snail)
  end

  def explode_continue(r) do
    split_continue(r)
  end

  def split_continue({:ok, snail}) do
    {_, new_snail} = split(snail)
    reduce(new_snail)
  end

  def split_continue({:nop, snail}) do
    case split(snail) do
      {:ok, snail} ->
        reduce(snail)

      {:nop, snail} ->
        snail
    end
  end

  def explode(g) do
    case SnailG.left_most_explode(g) do
      nil ->
        {:nop, g}

      %SnailG{id: id, left: left_orig, right: right_orig} = node ->
        nl = SnailG.next_left(g, node)
        nr = SnailG.next_right(g, node)

        new_g =
          g
          |> Map.delete(id)
          |> Map.put(id, %SnailG{node | val: 0, left: nil, right: nil})
          |> update_node(nl, new_val(nl, g[left_orig]))
          |> update_node(nr, new_val(nr, g[right_orig]))
          |> Map.delete(left_orig)
          |> Map.delete(right_orig)

        {:ok, new_g}
    end
  end

  def split(g) do
    case SnailG.left_most_split(g) do
      nil ->
        {:nop, g}

      %SnailG{id: id, val: v, level: level} = node ->
        l = :erlang.floor(v / 2)
        r = :erlang.ceil(v / 2)

        left_id = make_ref()
        right_id = make_ref()

        left = SnailG.make_val(id, left_id, l, level + 1)
        right = SnailG.make_val(id, right_id, r, level + 1)

        new_g =
          g
          |> Map.put(id, %SnailG{node | left: left_id, right: right_id, val: nil})
          |> Map.put(left_id, left)
          |> Map.put(right_id, right)

        {:ok, new_g}
    end
  end

  def new_val(nil, %SnailG{val: v}), do: v
  def new_val(%SnailG{val: v}, nil), do: v
  def new_val(%SnailG{val: v1}, %SnailG{val: v2}), do: v1 + v2

  def update_node(g, nil, _), do: g

  def update_node(g, %SnailG{id: id} = node, v) do
    Map.put(g, id, %SnailG{node | val: v})
  end

  def parse(snail) do
    {:ok, [res], _, _, _, _} = Snail.Parser.parse(snail)
    res
  end

  def sample(), do: load_input("./data/sample.txt")

  def input(), do: load_input("./data/input.txt")

  def load_input(filename) do
    {:ok, content} = File.read(filename)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(&SnailG.make(parse(&1)))
  end
end
