defmodule Day10 do
  @moduledoc """
  Documentation for `Day10`.
  """

  def part1(input) do
    input
    |> Enum.reduce(
      0,
      fn line, acc ->
        score =
          line
          |> parse()
          |> score_syntax_error()

        score + acc
      end
    )
  end

  def part2(input) do
    scores =
      input
      |> Enum.map(&parse/1)
      |> Enum.filter(fn
        [] ->
          false

        {:expected, _, _} ->
          false

        _ ->
          true
      end)
      |> Enum.map(fn incomplete ->
        incomplete
        |> Enum.map(&closing/1)
        |> auto_complete_score()
      end)
      |> Enum.sort()

    Enum.at(scores, trunc(length(scores) / 2))
  end

  def auto_complete_score(ps) do
    ps
    |> Enum.reduce(
      0,
      fn
        ")", acc ->
          acc * 5 + 1

        "]", acc ->
          acc * 5 + 2

        "}", acc ->
          acc * 5 + 3

        ">", acc ->
          acc * 5 + 4
      end
    )
  end

  def closing("("), do: ")"
  def closing("["), do: "]"
  def closing("{"), do: "}"
  def closing("<"), do: ">"

  def score_syntax_error({:expected, _, ")"}), do: 3
  def score_syntax_error({:expected, _, "]"}), do: 57
  def score_syntax_error({:expected, _, "}"}), do: 1197
  def score_syntax_error({:expected, _, ">"}), do: 25137
  def score_syntax_error(_), do: 0

  def parse(line) do
    line
    |> String.split("", trim: true)
    |> Enum.reduce_while(
      [],
      fn
        ch, stack when ch in ["(", "[", "{", "<"] ->
          {:cont, [ch | stack]}

        _, [] ->
          {:halt, {:error, :not_completed}}

        ")", ["(" | rest] ->
          {:cont, rest}

        "]", ["[" | rest] ->
          {:cont, rest}

        "}", ["{" | rest] ->
          {:cont, rest}

        ">", ["<" | rest] ->
          {:cont, rest}

        ch, ["(" | _] ->
          {:halt, {:expected, ")", ch}}

        ch, ["[" | _] ->
          {:halt, {:expected, "]", ch}}

        ch, ["{" | _] ->
          {:halt, {:expected, "}", ch}}

        ch, ["<" | _] ->
          {:halt, {:expected, ">", ch}}
      end
    )
  end

  def load_sample(), do: load_input("./data/sample.txt")
  def load_input(), do: load_input("./data/input.txt")

  def load_input(filename) do
    {:ok, content} = File.read(filename)

    content
    |> String.split("\n", trim: true)
  end
end
