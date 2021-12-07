defmodule Day07 do
  @moduledoc """
  Documentation for `Day07`.
  """

  def calc_min_cost_basic(input) do
    input
    |> calc_cost_basic()
    |> select_less_expensive()
  end

  def calc_min_cost_adaptive(input) do
    input
    |> calc_cost_adaptive()
    |> select_less_expensive()
  end

  def select_less_expensive(costs) do
    costs
    |> Enum.reduce(fn
      {pos, fuel}, {_, min_fuel} when fuel <= min_fuel ->
        {pos, fuel}

      _, acc ->
        acc
    end)
  end

  def calc_cost(input, fuel_cost_fun) do
    freq = Enum.frequencies(input)
    {begin, final} = Enum.min_max(input)

    begin..final
    |> Enum.map(fn pos ->
      {pos, fuel_cost_fun.(pos, freq)}
    end)
  end

  def calc_cost_basic(input) do
    calc_cost(input, &calc_move_basic/2)
  end

  def calc_cost_adaptive(input) do
    calc_cost(input, &calc_move_adaptive/2)
  end

  def calc_move_basic(pos, freq) do
    freq
    |> Enum.reduce(
      0,
      fn {crab_pos, num}, acc ->
        acc + abs(crab_pos - pos) * num
      end
    )
  end

  def calc_move_adaptive(pos, freq) do
    freq
    |> Enum.reduce(
      0,
      fn {crab_pos, num}, acc ->
        num_steps = abs(crab_pos - pos)
        fuel = trunc(num_steps * (num_steps + 1) / 2)
        acc + fuel * num
      end
    )
  end

  def load_input() do
    {:ok, content} = File.read("./data/input.txt")

    content
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end
end
