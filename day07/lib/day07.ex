defmodule Day07 do
  @moduledoc """
  Documentation for `Day07`.
  """

  def load_input() do
    {:ok, content} = File.read("./data/input.txt")

    content
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end
end
