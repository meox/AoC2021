defmodule Day24 do
  @moduledoc """
  Documentation for `Day24`.
  """

  def part1() do
    program = input()

    solutions()
    |> Enum.reduce(
      0,
      fn input, max ->
        %Context{:z => 0} = alu(program, %Context{:input => input})
        case Integer.undigits(input) do
          v when v > max ->
            v
          _ ->
            max
        end
      end
    )
  end

  def part2() do
    program = input()

    solutions()
    |> Enum.reduce(
      nil,
      fn input, min ->
        %Context{:z => 0} = alu(program, %Context{:input => input})
        case Integer.undigits(input) do
          v when min == :nil ->
            v
          v when v < min ->
            v
          _ ->
            min
        end
      end
    )
  end

  def solutions() do
    # this equations has been calculated using the Decompiler and by hand
    # d3 - 5 = d4
    # d6 - 4 = d7
    # d8 + 2 = d9
    # d5 + 8 = d10
    # d2 + 5 = d11
    # d1 - 2 = d12
    # d0 + 6 = d13
    for d0 <- 1..3, d1 <- 3..9, d2 <- 1..4, d3 <- 6..9, d5 <- 1..1, d6 <- 5..9, d8 <- 1..7 do
      [d0, d1, d2, d3, d3-5, d5, d6, d6 - 4, d8, d8+2, d5+8, d2+5, d1-2, d0+6]
    end
  end

  def alu(program, %Context{} = ctx) do
    program
    |> Enum.reduce(
      ctx,
      fn instr, ctx ->
        exec(instr, ctx)
      end
    )
  end

  def exec({:inp, a}, %Context{:input => [i | is]} = ctx) do
     Map.put(%Context{ctx | :input => is}, a, i)
  end
  def exec({:add, _a, 0}, %Context{} = ctx), do: ctx
  def exec({:add, a, b}, %Context{} = ctx) do
    {a_val, b_val} = {Map.get(ctx, a), get_b(b, ctx)}
    Map.put(ctx, a, a_val + b_val)
  end
  def exec({:mul, a, 0}, %Context{} = ctx), do: Map.put(ctx, a, 0)
  def exec({:mul, _a, 1}, %Context{} = ctx), do: ctx
  def exec({:mul, a, b}, %Context{} = ctx) do
    {a_val, b_val} = {Map.get(ctx, a), get_b(b, ctx)}
    Map.put(ctx, a, a_val * b_val)
  end
  def exec({:div, _a, 1}, %Context{} = ctx), do: ctx
  def exec({:div, a, b}, %Context{} = ctx) do
    {a_val, b_val} = {Map.get(ctx, a), get_b(b, ctx)}
    Map.put(ctx, a, trunc(a_val / b_val))
  end
  def exec({:mod, a, b}, %Context{} = ctx) do
    {a_val, b_val} = {Map.get(ctx, a), get_b(b, ctx)}
    Map.put(ctx, a, rem(a_val, b_val))
  end
  def exec({:eql, a, b}, %Context{} = ctx) do
    {a_val, b_val} = {Map.get(ctx, a), get_b(b, ctx)}
    eq = case a_val == b_val do true -> 1; _ -> 0 end
    Map.put(ctx, a, eq)
  end

  def get_b(x, _ctx) when is_number(x), do: x
  def get_b(x, ctx) when is_atom(x), do: Map.get(ctx, x)


  def input(), do: load_input("./data/input.txt")
  def sample(), do: load_input("./data/sample.txt")

  def load_input(filename) do
    {:ok, content} = File.read(filename)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_instruction/1)
  end

  def parse_instruction(line) do
    line
    |> String.split(" ", trim: true)
    |> parse()
  end

  def parse(["inp", a]), do: {:inp, String.to_atom(a)}
  def parse(["add", a, b]), do: {:add, String.to_atom(a), parse_b(b)}
  def parse(["mul", a, b]), do: {:mul, String.to_atom(a), parse_b(b)}
  def parse(["div", a, b]), do: {:div, String.to_atom(a), parse_b(b)}
  def parse(["mod", a, b]), do: {:mod, String.to_atom(a), parse_b(b)}
  def parse(["eql", a, b]), do: {:eql, String.to_atom(a), parse_b(b)}

  def parse_b("w"), do: :w
  def parse_b("x"), do: :x
  def parse_b("y"), do: :y
  def parse_b("z"), do: :z
  def parse_b(n), do: String.to_integer(n)
end
