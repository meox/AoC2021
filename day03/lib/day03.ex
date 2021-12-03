defmodule Day03 do
  @moduledoc """
  Documentation for `Day03`.
  """

  def calc_power_consumption() do
    num_cols = 12
    input = load_input()

    gamma_digits =
      0..(num_cols - 1)
      |> Enum.map(fn idx -> calc_most_common(idx, input) end)

    epsilon_digits = complement(gamma_digits)

    to_num(gamma_digits) * to_num(epsilon_digits)
  end

  defp calc_most_common(index, input) do
    {zero, one} =
      input
      |> Enum.map(&String.at(&1, index))
      |> Enum.reduce(
        {0, 0},
        fn
          "0", {nx, ny} -> {nx + 1, ny}
          "1", {nx, ny} -> {nx, ny + 1}
        end
      )

    max_common(zero, one)
  end

  defp max_common(zero, one) when zero > one, do: 0
  defp max_common(_, _), do: 1

  defp complement(xs) when is_list(xs) do
    xs
    |> Enum.map(fn
      0 -> 1
      1 -> 0
    end)
  end

  defp to_num(digits) do
    digits
    |> Enum.reverse()
    |> to_num(0, 0)
  end

  defp to_num([], _i, acc), do: :erlang.trunc(acc)

  defp to_num([x | xs], i, acc) do
    n = x * :math.pow(2, i)
    to_num(xs, i + 1, acc + n)
  end

  defp load_input() do
    {:ok, content} = File.read("./data/input.txt")

    content
    |> String.split("\n")
    |> Enum.filter(fn
      "" -> false
      _ -> true
    end)
  end
end
