defmodule Day09 do
  @moduledoc """
  Documentation for `Day09`.
  """

  def load_input() do
    {:ok, content} = File.load("./dat/input.txt")

    content
    |> String.split("\n", trim: true)

  end

end
