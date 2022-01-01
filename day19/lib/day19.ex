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
      r1: :B, # A
      r2: :C, # B
      r3: :C, # C
      r4: :B, # D
      r5: :D, # A
      r6: :D, # B
      r7: :A, # C
      r8: :A  # D
    }
  end
end
