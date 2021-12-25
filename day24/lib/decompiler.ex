defmodule Decompiler do

  # w: [d1, ..., d14]
  def run(program) do
    program
    |> decompose()
    |> Enum.map(&push_z_optimization/1)
    |> Enum.map(&reduce_block/1)
  end

  def push_z_optimization([
    {:add, :x, :z},
    {:mod, :x, 26},
    {:div, :z, 1},
    {:add, :x, n}
    | rest
  ]) when n >= 10 do
    [{:add, :y, a}, {:add, :y, b}] =
      rest
      |> drop_mul()
      |> Enum.filter(fn {:add, :y, _} -> true; _ -> false end)
    {:push_z, {:add, a, b}}
  end
  def push_z_optimization(block), do: block

  def reduce_block([
    {:add, :x, :z},
    {:mod, :x, 26},
    {:div, :z, 26},
    {:add, :x, n},
    {:eql, :x, rif}
    | rest
  ]) when n < 10 do
    [{:add, :y, a}, {:add, :y, b}] =
      rest
      |> drop_mul()
      |> Enum.filter(fn {:add, :y, _} -> true; _ -> false end)

    {:eq, {:pop_z, n}, rif, {:push_z, {:add, a, b}}}
  end

  def reduce_block(block), do: block

  def decompose(program) do
    {_, c, acc, _} =
      program
      |> Enum.reduce(
        {0, [], [], 0},
        fn
          {:inp, _}, {0, current, acc, k} ->
            {1, current, acc, k}
          {:inp, _}, {_n, current, acc, k} ->
            {0, [], [Enum.reverse(current) | acc], k + 1}
          {:add, r, :w}, {n, current, acc, k} ->
            d = String.to_atom("d#{k}")
            {n + 1, [{:add, r, d} | current], acc, k}
          {:eql, r, :w}, {n, current, acc, k} ->
            d = String.to_atom("d#{k}")
            {n + 1, [{:eql, r, d} | current], acc, k}
          {:mul, :x, 0}, backlog ->
            backlog
          i, {n, current, acc, k} ->
            {n + 1, [i | current], acc, k}
        end
      )

    [Enum.reverse(c) | acc]
    |> Enum.reverse()
  end

  def drop_mul(list) do
    list
    |> Enum.drop_while(fn {:mul, :y, 0} -> false; _ -> true end)
    |> Enum.drop(1)
    |> Enum.drop_while(fn {:mul, :y, 0} -> false; _ -> true end)
  end
end
