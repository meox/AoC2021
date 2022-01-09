defmodule Grid do
  defstruct grid: %{}, max_row: 0, max_col: 0
end

defimpl String.Chars, for: Grid do
  def to_string(%Grid{max_row: rows, max_col: cols, grid: grid}) do
    0..(rows - 1)
    |> Enum.map(fn r ->
      0..(cols - 1)
      |> Enum.map(fn c ->
        case Map.get(grid, {r, c}) do
          nil -> "."
          :left -> ">"
          :south -> "v"
        end
      end)
      |> Enum.join("")
    end)
    |> Enum.join("\n")
  end
end
