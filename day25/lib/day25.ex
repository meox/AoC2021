defmodule Day25 do
  @moduledoc """
  Documentation for `Day25`.
  """

  def part1() do
    {n, _} = steps(input())
    n
  end

  def steps(%Grid{} = grid) do
    steps(grid, 1)
  end
  def steps(grid, n) do
    case step(grid) do
      {:ok, grid} ->
        steps(grid, n + 1)
      {:nop, grid} ->
        {n, grid}
    end
  end

  @spec step(%Grid{}) :: {:ok, %Grid{}} | {:nop, %Grid{}} 
  def step(%Grid{} = grid) do
    # move left cucumbers
    cleft = select(grid, :left)

    :a = :b


    tmp_grid = move_cucumbers(cleft, grid)

    csouth = select(tmp_grid, :south)
    new_grid = move_cucumbers(csouth, tmp_grid)

    case Enum.count(cleft) + Enum.count(csouth) do
      v when v > 0 ->
        {:ok, new_grid}
      _ ->
        {:nop, grid}
    end
  end

  def move_cucumbers(cs, grid) do
    cs
    |> Enum.reduce(
      grid,
      fn pos, grid ->
        move(pos, grid)
      end
    )
  end

  def select(%Grid{grid: grid, max_row: mr, max_col: mc}, :left) do
    (mc - 1)..0
    |> Enum.reduce(
      [],
      fn c, acc ->
        0..(mr - 1)
        |> Enum.reduce(
          acc,
          fn r, acc ->
            case Map.get(grid, {r, c}) do
              :left ->
                acc
                |> can_move?({r, c}, grid, mc, :left)
              _ ->
                acc
            end
          end
        )
      end
    )
  end

  def select(%Grid{grid: grid, max_row: mr, max_col: mc}, :south) do
    (mr - 1)..0
    |> Enum.reduce(
      [],
      fn r, acc ->
        0..(mc - 1)
        |> Enum.reduce(
          acc,
          fn c, acc ->
            case Map.get(grid, {r, c}) do
              :south ->
                acc
                |> can_move?({r, c}, grid, mr, :south)
              _ ->
                acc
            end
          end
        )
      end
    )
  end

  def can_move?(acc, {r, c}, grid, mc, :left) do
    next_p = {r, rem(c + 1, mc)}
    case Map.get(grid, next_p) do
      nil ->
        [{r, c} | acc]
      _ ->
        acc
    end
  end

  def can_move?(acc, {r, c}, grid, mr, :south) do
    next_p = {rem(r + 1, mr), c}
    case Map.get(grid, next_p) do
      nil ->
        [{r, c} | acc]
      _ ->
        acc
    end
  end

  def move({_r, _c} = p, %Grid{grid: grid} = gr) do
    move(Map.get(grid, p), p, gr)
  end

  def move(nil, _, gr), do: gr
  def move(:left, {r, c}, %Grid{max_col: mc} = gr) do
    next_p = {r, rem(c + 1, mc)}
    check_move({r, c}, next_p, gr, :left)
  end
  def move(:south, {r, c}, %Grid{max_row: mr} = gr) do
    next_p = {rem(r + 1, mr), c}
    check_move({r, c}, next_p, gr, :south)
  end

  def check_move(pos, next_p, %Grid{grid: grid} = gr, cucumber) do
    case Map.get(grid, next_p) do
      nil ->
        new_grid =
          grid
          |> Map.put(next_p, cucumber)
          |> Map.put(pos, nil)
        %Grid{gr | grid: new_grid}
      _ ->
        gr
    end
  end

  def input(), do: load_input("./data/input.txt")
  def sample(), do: load_input("./data/sample2.txt")

  def load_input(filename) do
    {:ok, content} = File.read(filename)

    {max_row, max_col, grid} =
      content
      |> String.split("\n", trim: true)
      |> Enum.reduce(
        {0, 0, %{}},
        fn line, {r, _, acc} ->
          {max_col, new_acc} =
            line
            |> String.to_charlist()
            |> Enum.map(fn
              ?. -> nil
              ?> -> :left
              ?v -> :south
            end)
            |> Enum.reduce(
              {0, acc},
              fn v, {c, acc} ->
                {c + 1, Map.put(acc, {r, c}, v)}
              end
            )
          {r + 1, max_col, new_acc}
        end
      )

    %Grid{grid: grid, max_row: max_row, max_col: max_col}
  end
end

