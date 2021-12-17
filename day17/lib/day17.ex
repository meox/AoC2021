defmodule Day17 do
  @moduledoc """
  Documentation for `Day17`.
  """

  def part1() do
    target = input()
    {[_, max_x], [min_y, _]} = target

    max_vx = max_x
    max_vy = -min_y

    0..max_vx
    |> Enum.reduce(
      [],
      fn vx, acc ->
        0..max_vy
        |> Enum.reduce(
          acc,
          fn vy, acc ->
            ps = probe(vx, vy, target) |> Enum.to_list()
            [{x, y} | _] = Enum.reverse(ps)

            case reached_target?(x, y, target) do
              true ->
                {_, max_h} = Enum.max_by(ps, fn {_, y} -> y end)
                [max_h | acc]

              false ->
                acc
            end
          end
        )
      end
    )
    |> Enum.max()
  end

  def probe(vx, vy, target) do
    Stream.resource(
      fn -> {{0, 0}, {vx, vy}} end,
      fn
        :matched ->
          {:halt, :matched}

        :missed ->
          {:halt, :missed}

        {{x0, y0}, {vx, vy}} ->
          x1 = x0 + vx
          y1 = y0 + vy

          case reached_target?(x1, y1, target) do
            true ->
              {[{x1, y1}], :matched}

            false ->
              new_vy = vy - 1
              new_state = {{x1, y1}, {new_vx(vx), new_vy}}
              next_step?(new_state, vy, target)
          end
      end,
      fn _ -> :ok end
    )
  end

  def next_step?({{x1, y1}, {_vx1, vy1}}, old_vy, {[_xa, _xb], [ya, _yb]})
      when y1 < ya and vy1 < old_vy do
    {[{x1, y1}], :missed}
  end

  def next_step?({{x1, y1}, {_vx, _vy}} = new_state, _old_vy, _target) do
    {[{x1, y1}], new_state}
  end

  def new_vx(0), do: 0
  def new_vx(vx) when vx > 0, do: vx - 1
  def new_vx(vx) when vx < 0, do: vx + 1

  def reached_target?(x, y, {[xa, xb], [ya, yb]})
      when x >= xa and x <= xb and y >= ya and y <= yb do
    true
  end

  def reached_target?(_x, _y, _target), do: false

  def sample(), do: parse_input("target area: x=20..30, y=-10..-5")
  def input(), do: parse_input("target area: x=265..287, y=-103..-58")

  def parse_input("target area: " <> s) do
    ["x=" <> rx, "y=" <> ry] = String.split(s, ", ")
    x = rx |> String.split("..") |> Enum.map(&String.to_integer/1)
    y = ry |> String.split("..") |> Enum.map(&String.to_integer/1)
    {x, y}
  end
end
