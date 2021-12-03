defmodule Day03 do
  @moduledoc """
  Documentation for `Day03`.
  """

  def load_input() do
    {:ok, content} = File.read("./data/input.txt")

    content
    |> String.split("\n")
    |> Enum.map(fn s ->
      String.split(s, "")
    end)
  end
end
