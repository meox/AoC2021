defmodule Day19 do
  @moduledoc """
  Documentation for `Day19`.
  """

  def move(:r1, :h1), do: 3
  def move(:r1, :h2), do: 2
  def move(:r1, :h4), do: 2
  def move(:r1, :h6), do: 4
  def move(:r1, :h8), do: 6
  def move(:r1, :h10), do: 8
  def move(:r1, :h11), do: 9

  def input() do
    %{
      # A
      r1: :B,
      # B
      r2: :C,
      # C
      r3: :C,
      # D
      r4: :B,
      # A
      r5: :D,
      # B
      r6: :D,
      # C
      r7: :A,
      # D
      r8: :A
    }
  end
end
