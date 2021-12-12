defmodule Day13 do
  @moduledoc """
  Documentation for `Day13`.
  """

  def sample(), do: load_input("./data/sample.txt")
  def input(), do: load_input("./data/input.txt")

  def load_input(filename) do
    {:ok, content} = File.read(filename)
  end
end
