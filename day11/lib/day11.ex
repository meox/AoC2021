defmodule Day11 do
  @moduledoc """
  Documentation for `Day11`.
  """

  def part1() do
    load_input()
    |> steps(100)
  end

  def part2() do
    load_input()
    |> steps_until_all_flashed(0)
  end

  def steps_until_all_flashed(table, n) do
    case all_flashes(table) do
      false ->
        {new_table, _} = step(table)
        steps_until_all_flashed(new_table, n + 1)

      true ->
        n
    end
  end

  def all_flashes(table) do
    table
    |> Enum.reduce_while(
      true,
      fn
        {_, 0}, acc ->
          {:cont, acc}

        {_, v}, _acc when v > 0 ->
          {:halt, false}
      end
    )
  end

  def steps(table, n) do
    steps(table, n, 0)
  end

  def steps(table, 0, acc) do
    {table, acc}
  end

  def steps(table, n, acc) do
    {new_table, m} = step(table)
    steps(new_table, n - 1, acc + m)
  end

  def step(table) do
    table
    |> increase_by_one()
    |> flashing([])
  end

  def flashing(table, prev_flashed) do
    octopus_flashing =
      table
      |> over_energy_level()
      |> Enum.filter(&(not Enum.member?(prev_flashed, &1)))

    octopus_flashing
    |> Enum.reduce(
      table,
      fn point, table ->
        point
        |> adjacents(table)
        |> Enum.reduce(
          table,
          fn point, table ->
            Map.update(table, point, 0, fn v -> v + 1 end)
          end
        )
      end
    )
    |> reset_to_zero(octopus_flashing)
    |> next_flashing(prev_flashed ++ octopus_flashing)
  end

  def next_flashing(table, octopus_flashing) do
    count_overloaded = over_energy_level(table) |> Enum.count()

    case count_overloaded do
      0 ->
        {reset_to_zero(table, octopus_flashing), length(octopus_flashing)}

      _ ->
        flashing(table, octopus_flashing)
    end
  end

  def reset_to_zero(table, octopus_flashing) do
    octopus_flashing
    |> Enum.reduce(
      table,
      fn point, table -> Map.put(table, point, 0) end
    )
  end

  def over_energy_level(table) do
    table
    |> Enum.filter(fn {_point, v} -> v > 9 end)
    |> Enum.map(fn {point, _} -> point end)
  end

  def adjacents({x0, y0}, table) do
    ps = for x <- (x0 - 1)..(x0 + 1), y <- (y0 - 1)..(y0 + 1), do: {x, y}

    ps
    |> Enum.filter(fn
      {^x0, ^y0} -> false
      {x, _} when x < 0 -> false
      {_, y} when y < 0 -> false
      _ -> true
    end)
    |> Enum.filter(fn point -> Map.get(table, point) != nil end)
  end

  def increase_by_one(table) do
    table
    |> Enum.reduce(
      %{},
      fn {point, level}, acc ->
        Map.put(acc, point, level + 1)
      end
    )
  end

  def show_table(table) do
    0..9
    |> Enum.map(fn r ->
      0..9
      |> Enum.map(fn c -> Map.get(table, {r, c}) end)
    end)
    |> IO.inspect()

    table
  end

  def load_input(), do: load_input("./data/input.txt")
  def load_sample(), do: load_input("./data/sample.txt")

  def load_input(filename) do
    {:ok, content} = File.read(filename)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split("", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.reduce(
      {0, %{}},
      fn row, {row_index, table} ->
        new_table =
          row
          |> Enum.reduce(
            {0, table},
            fn v, {col_index, table} ->
              {col_index + 1, Map.put(table, {row_index, col_index}, v)}
            end
          )
          |> elem(1)

        {row_index + 1, new_table}
      end
    )
    |> elem(1)
  end
end
