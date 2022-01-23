defmodule Day22 do
  @moduledoc """
  Documentation for `Day22`.
  """

  def part1() do
    input()
    |> Enum.filter(
      fn
        {_, {xs, xe}, {ys, ye}, {zs, ze}} when xs < -50 or xe > 50 or ys < -50 or ye > 50 or zs < -50 or ze > 50 -> false
        _ -> true
      end)
    |> num_cuboid()
  end

  def part2() do
    num_cuboid(sample())
  end

  def num_cuboid(list) do
    list
    |> Enum.drop_while(fn
      {:off, _, _} -> true
      _ -> false
    end)
    |> calc_num_cuboid()
  end

  def calc_num_cuboid(list) do
    list
    |> Enum.reduce(
      [],
      fn
        {:on, _x, _y, _z} = e, acc ->
          [e | acc]

        {:off, _x, _y, _z} = off, acc ->
          case get_intersects(off, acc) do
            {_, []} ->
              acc
            _ ->
              [off | acc]
          end
          #   {non_intersects, intersects} ->
          #     non_intersects ++ consume_off(off, intersects)
          # end
      end
    )
    |> Enum.reverse()
    |> IO.inspect()
    |> count_cube_on()
  end

  def clusterize(list) do
    Enum.slice()
  end

  def count_cube_on(list) do
    list
    |> Enum.reduce(
      MapSet.new(),
      fn {status, {x_s, x_e}, {y_s, y_e}, {z_s, z_e}}, acc ->
        x_s..x_e
        |> Enum.reduce(
          acc,
          fn x, acc ->
            y_s..y_e
            |> Enum.reduce(
              acc,
              fn y, acc ->
                Enum.reduce(
                  z_s..z_e,
                  acc,
                  fn z, acc -> update_cube_status(status, {x, y, z}, acc) end
                )
              end
            )
          end
        )
      end
    )
    |> MapSet.size()
  end

  def update_cube_status(:on, k, cube_set), do: MapSet.put(cube_set, k)
  def update_cube_status(:off, k, cube_set), do: MapSet.delete(cube_set, k)

  def consume_off(off, intersects) when is_list(intersects) do
    Enum.flat_map(intersects, &consume_single_off(off, &1))
  end

  # remove extra on Z
  def consume_single_off(
        {:off, x0, y0, {z_s0, z_e0}},
        {:on, _x1, _y1, {z_s1, _z_e1}} = cube_on
      )
      when z_s0 < z_s1 and z_e0 >= z_s1 do
    consume_single_off({:off, x0, y0, {z_s1, z_e0}}, cube_on)
  end

  def consume_single_off(
        {:off, x0, y0, {z_s0, z_e0}},
        {:on, _x1, _y1, {_z_s1, z_e1}} = cube_on
      )
      when z_e0 > z_e1 and z_s0 <= z_e1 do
    consume_single_off({:off, x0, y0, {z_s0, z_e1}}, cube_on)
  end

  # remove extra on Y
  def consume_single_off(
        {:off, x0, {y_s0, y_e0}, z0},
        {:on, _x1, {y_s1, _y_e1}, _z1} = cube_on
      )
      when y_s0 < y_s1 and y_e0 >= y_s1 do
    consume_single_off({:off, x0, {y_s1, y_e0}, z0}, cube_on)
  end

  def consume_single_off(
        {:off, x0, {y_s0, y_e0}, z0},
        {:on, _x1, {_y_s1, y_e1}, _z1} = cube_on
      )
      when y_e0 > y_e1 and y_s0 <= y_e1 do
    consume_single_off({:off, x0, {y_s0, y_e1}, z0}, cube_on)
  end

  # remove extra on X
  def consume_single_off(
        {:off, {x_s0, x_e0}, y0, z0},
        {:on, {x_s1, _x_e1}, _y1, _z1} = cube_on
      )
      when x_s0 < x_s1 and x_e0 >= x_s1 do
    consume_single_off({:off, {x_s1, x_e0}, y0, z0}, cube_on)
  end

  def consume_single_off(
        {:off, {x_s0, x_e0}, y0, z0},
        {:on, {_x_s1, x_e1}, _y1, _z1} = cube_on
      )
      when x_e0 > x_e1 and x_s0 <= x_e1 do
    consume_single_off({:off, {x_s0, x_e1}, y0, z0}, cube_on)
  end

  # off cube wrap on cube
  def consume_single_off(
        {:off, {x_s0, x_e0}, {y_s0, y_e0}, {z_s0, z_e0}},
        {:on, {x_s1, x_e1}, {y_s1, y_e1}, {z_s1, z_e1}}
      )
      when x_s1 >= x_s0 and x_e1 <= x_e0 and
             y_s1 >= y_s0 and y_e1 <= y_e0 and
             z_s1 >= z_s0 and z_e1 <= z_e0,
      do: []

  # x in common
  def consume_single_off(
        {:off, {x_s, x_e}, {y_s0, y_e0}, {z_s0, z_e0}},
        {:on, {x_s, x_e}, {y_s1, y_e1}, {z_s1, z_e1}}
      )
      when y_s0 >= y_s1 and y_e0 <= y_e1 do
    [
      {:on, {x_s, x_e}, {y_s1, y_s0 - 1}, {z_s1, z_e1}},
      {:on, {x_s, x_e}, {y_e0 + 1, y_e1}, {z_s1, z_e1}},
      {:on, {x_s, x_e}, {y_s0, y_e0}, {z_e0 + 1, z_e1}},
      {:on, {x_s, x_e}, {y_s0, y_e0}, {z_s1, z_s0 - 1}}
    ]
    |> remove_invalid()
  end

  # y in common
  def consume_single_off(
        {:off, {x_s0, x_e0}, {y_s, y_e}, {z_s0, z_e0}},
        {:on, {x_s1, x_e1}, {y_s, y_e}, {z_s1, z_e1}}
      )
      when x_s0 >= x_s1 and x_e0 <= x_e1 do
    [
      {:on, {x_s1, x_s0 - 1}, {y_s, y_e}, {z_s1, z_e1}},
      {:on, {x_e0 + 1, x_e1}, {y_s, y_e}, {z_s1, z_e1}},
      {:on, {x_s1, x_e1}, {y_s, y_e}, {z_s1, z_s0 - 1}},
      {:on, {x_s1, x_e1}, {y_s, y_e}, {z_e1 + 1, z_e0}}
    ]
    |> remove_invalid()
  end

  def consume_single_off(cube_off, cube_on), do: [cube_off, cube_on]

  def remove_invalid(list) do
    list
    |> Enum.filter(fn {_, {x_s, x_e}, {y_s, y_e}, {z_s, z_e}} ->
      x_s <= x_e and y_s <= y_e and z_s <= z_e
    end)
  end

  def get_intersects(off, list) do
    m =
      list
      |> Enum.filter(fn
        {:on, _, _, _} -> true
        _ -> false
      end)
      |> Enum.map(&{&1, intersect?(off, &1)})
      |> Enum.group_by(fn {_off, x} -> x end, fn {off, _} -> off end)

    {Map.get(m, false, []), Map.get(m, true, [])}
  end

  def intersect?({:off, x0, y0, z0}, {:on, x1, y1, z1}) do
    intersect_on_axis?(x0, x1) and intersect_on_axis?(y0, y1) and intersect_on_axis?(z0, z1)
  end

  def intersect_on_axis?({_s0, e0}, {s1, _e1}) when e0 < s1, do: false
  def intersect_on_axis?({s0, _e0}, {_s1, e1}) when s0 > e1, do: false
  def intersect_on_axis?(_, _), do: true

  def input(), do: load_input("./data/input.txt")
  def sample(), do: load_input("./data/sample.txt")

  def load_input(filename) do
    {:ok, content} = File.read(filename)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_command/1)
  end

  def parse_command("on " <> coordinates) do
    {a, b, c} = parse_coordinates(coordinates)
    {:on, a, b, c}
  end

  def parse_command("off " <> coordinates) do
    {a, b, c} = parse_coordinates(coordinates)
    {:off, a, b, c}
  end

  def parse_coordinates(coordinates) do
    ["x=" <> xs, "y=" <> ys, "z=" <> zs] = String.split(coordinates, ",", trim: true)
    {parse_range(xs), parse_range(ys), parse_range(zs)}
  end

  def parse_range(rs) do
    [a, b] = String.split(rs, "..")
    start = String.to_integer(a)
    stop = String.to_integer(b)
    {start, stop}
  end
end
