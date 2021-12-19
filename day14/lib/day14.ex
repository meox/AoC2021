defmodule Day14 do
  @moduledoc """
  Documentation for `Day14`.
  """

  def part1(), do: part(10)
  def part2(), do: part(40)

  def part(n) do
    {template, rules} = input()

    {state, _} =
      template
      |> Enum.frequencies()
      |> step(template, rules, 0, n, %{})

    {{_, a}, {_, b}} = Enum.min_max_by(state, fn {_, v} -> v end)
    b - a
  end

  def step(state, _template, _rules, max_level, max_level, memo), do: {state, memo}

  def step(state, template, rules, level, max_level, memo) do
    template
    |> Enum.zip(Enum.drop(template, 1))
    |> Enum.reduce(
      {state, memo},
      fn {x, y}, {state, memo} ->
        case Map.get(memo, {level, x, y}) do
          nil ->
            case Map.get(rules, [x, y]) do
              nil ->
                {state, memo}

              v ->
                {m, new_memo} =
                  %{}
                  |> Map.put(v, 1)
                  |> step([x, v], rules, level + 1, max_level, memo)

                {m, new_memo} = step(m, [v, y], rules, level + 1, max_level, new_memo)
                {sum(state, m), Map.put(new_memo, {level, x, y}, m)}
            end

          memo_state ->
            {sum(memo_state, state), memo}
        end
      end
    )
  end

  def sum(memo_state, state) do
    memo_state
    |> Enum.reduce(
      state,
      fn {k, v}, acc ->
        Map.update(acc, k, v, &(&1 + v))
      end
    )
  end

  def input(), do: load_input("./data/input.txt")

  def sample(), do: load_input("./data/sample.txt")

  def load_input(filename) do
    {:ok, content} = File.read(filename)

    lines =
      content
      |> String.split("\n", trim: true)
      |> Enum.filter(&(&1 != ""))

    [template | rules] = lines
    {parse_template(template), parse_rules(rules)}
  end

  defp parse_template(template) do
    template
    |> String.to_charlist()
    |> Enum.map(&(&1 - ?0))
  end

  defp parse_rules(rules) do
    rules
    |> Enum.map(fn line ->
      [a, [b]] =
        line
        |> String.split(" -> ", trim: true)
        |> Enum.map(&String.to_charlist/1)
        |> Enum.map(fn list -> Enum.map(list, &(&1 - ?0)) end)

      {a, b}
    end)
    |> Enum.into(%{})
  end
end
