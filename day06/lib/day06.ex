defmodule Day06 do
  @moduledoc """
  Documentation for `Day06`.
  """

  def total_lantern_fish(days) do
    load_input()
    |> Enum.frequencies()
    |> simulate(days)
    |> Map.values()
    |> Enum.sum()
  end

  def simulate(freq, 0), do: freq

  def simulate(freq, days) do
    {num_expired, rest} = Map.pop(freq, 0, 0)

    rest
    |> Enum.reduce(
      %{},
      fn {k, v}, acc ->
        Map.put(acc, k - 1, v);
      end
    )
    |> Map.update(8, num_expired, fn v -> v + num_expired end)
    |> Map.update(6, num_expired, fn v -> v + num_expired end)
    |> simulate(days - 1)
  end

  def load_input() do
    {:ok, content} = File.read("./data/input.txt")
    content
    |> String.trim()
    |> String.split(",")
    |> Enum.filter(fn "" -> false; _ -> true end)
    |> Enum.map(&String.to_integer/1)
  end
end
