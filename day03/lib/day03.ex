defmodule Day03 do
  @moduledoc """
  Documentation for `Day03`.
  """

  @num_cols 12

  def life_support_rating() do
    input = load_input()
    oxygen_generator_rating(input) * co2_scrubber_rating(input)
  end

  def oxygen_generator_rating(input) do
    [code] =
      0..(@num_cols - 1)
      |> Enum.reduce(
        input,
        fn
          _, acc when length(acc) == 1 ->
            acc

          idx, acc ->
            most_common = calc_most_common(idx, acc, 1)

            acc
            |> Enum.filter(fn s ->
              digit = s |> String.at(idx) |> String.to_integer()
              digit == most_common
            end)
        end
      )

    convert(code)
  end

  def co2_scrubber_rating(input) do
    [code] =
      0..(@num_cols - 1)
      |> Enum.reduce(
        input,
        fn
          _, acc when length(acc) == 1 ->
            acc

          idx, acc ->
            less_common = calc_least_common(idx, acc, 0)

            acc
            |> Enum.filter(fn s ->
              digit = s |> String.at(idx) |> String.to_integer()
              digit == less_common
            end)
        end
      )

    convert(code)
  end

  def calc_power_consumption() do
    input = load_input()

    gamma_digits =
      0..(@num_cols - 1)
      |> Enum.map(fn idx -> calc_most_common(idx, input, 1) end)

    epsilon_digits = complement(gamma_digits)

    to_num(gamma_digits) * to_num(epsilon_digits)
  end

  defp calc_least_common(index, input, default) do
    {zero, one} = calc_recurrent(index, input)

    cond do
      zero == one ->
        default

      zero < one ->
        0

      true ->
        1
    end
  end

  defp calc_most_common(index, input, default) do
    {zero, one} = calc_recurrent(index, input)

    cond do
      zero == one ->
        default

      zero > one ->
        0

      true ->
        1
    end
  end

  defp calc_recurrent(index, input) do
    input
    |> Enum.map(&String.at(&1, index))
    |> Enum.reduce(
      {0, 0},
      fn
        "0", {nx, ny} -> {nx + 1, ny}
        "1", {nx, ny} -> {nx, ny + 1}
      end
    )
  end

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

  defp convert(s) do
    s
    |> String.split("")
    |> Enum.filter(fn
      "" -> false
      _ -> true
    end)
    |> Enum.map(&String.to_integer/1)
    |> to_num()
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
