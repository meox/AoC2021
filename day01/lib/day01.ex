defmodule Day01 do
  @moduledoc """
  Documentation for `Day01`.
  """

  def count_increment3() do
    input = load_input()

    [
      input,
      Stream.drop(input, 1),
      Stream.drop(input, 2)
    ]
    |> Stream.zip()
    |> Stream.map(fn {x, y, z} -> x + y + z end)
    |> count_increment()
  end

  def count_increment(input) do
    input
    |> Stream.zip(Stream.drop(input, 1))
    |> Stream.map(fn
      {x, y} when x < y -> :inc
      {x, x} -> :no_change
      _ -> :dec
    end)
    |> Stream.filter(fn
      :inc -> true
      _ -> false
    end)
    |> Enum.count()
  end

  def load_input() do
    {:ok, content} = File.read("./data/input.txt")

    content
    |> String.split()
    |> Enum.filter(fn
      "" -> false
      _ -> true
    end)
    |> Enum.map(&String.to_integer/1)
  end
end
