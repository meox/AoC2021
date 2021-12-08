defmodule Day08 do
  @moduledoc """
  Documentation for `Day08`.
  """

  def part1() do
    load_input()
    |> Enum.map_reduce(
      0,
      fn [_signals, output], acc ->
        output
        |> Enum.map_reduce(
          acc,
          fn s, c_acc ->
            case discover_by_len(s) do
              {:ok, val} ->
                {val, c_acc + 1}
              {:nope, val} ->
                {val, c_acc}
            end
        end)
    end)
    |> elem(1)
  end

  def part2() do
    load_input()
    |> Enum.map(fn [signals, output] ->
      resolve_map = decrypt_signals(signals)

      output
      |> Enum.map(fn k -> Map.get(resolve_map, k) end)
      |> to_decimal()
    end)
    |> Enum.sum()
  end

  def to_decimal([d0, d1, d2, d3]), do: d0 * 1000 + d1 * 100 + d2 * 10 + d3

  def decrypt_signals(signals) do
    signals
    |> Enum.map(fn s ->
      {_, val} = discover_by_len(s)
      {s, val}
    end)
    |> Enum.map(&calc_possibilities/1)
    |> Enum.reduce(
      %{},
      fn {s, ps}, acc ->
        Map.put(acc, s, ps)
      end
    )
    |> full_decrypt()
  end

  def full_decrypt(resolve_map) do
    step = decrypt_step(resolve_map)
    continue_decrypt(step, is_decrypted(step))
  end

  def continue_decrypt(resolve_map, false), do: full_decrypt(resolve_map)
  def continue_decrypt(resolve_map, true), do: resolve_map

  def is_decrypted(resolve_map) do
    resolve_map
    |> Enum.all?(fn {_k, v} when is_integer(v) -> true; _ -> false end)
  end

  def decrypt_step(resolve_map) do
    %{1 => one, 4 => four, 7 => seven, 8 => eight} = get_key_elements(resolve_map)
    resolve_map
    |> Enum.reduce(
      resolve_map,
      fn
        {_k, v}, acc when is_integer(v) ->
          acc
        {k, vs}, acc when is_list(vs) ->
          left =
            vs
            |> Enum.filter(fn p -> not resolved(p, acc) end)
            |> Enum.filter(
              fn p ->
                # calculate the segments that are on when ps is on
                case includes(p) do
                  [] ->
                    # cannot include 1,4,7
                    !is_in(one, k) and !is_in(four, k) and !is_in(seven, k)
                  inc ->
                    inc
                    |> resolve_includes(resolve_map)
                    |> Enum.all?(fn x -> is_in(x, k) end)
                end
            end)
            |> Enum.filter(fn 2 -> can_be_two(k, four, eight); _ -> true end)
            |> Enum.filter(fn 5 -> can_be_five(k, one, acc); _ -> true end)
            |> zip()

          Map.put(acc, k, left)
     end
    )
  end

  def can_be_two(candidate, four, eight) do
    x = (candidate ++ four) |> Enum.uniq() |> Enum.sort()
    x == Enum.sort(eight)
  end

  def can_be_five(candidate, one, resolve_map) do
    case extract(9, resolve_map) do
      [{nine, 9}] ->
        x = (candidate ++ one) |> Enum.uniq() |> Enum.sort()
        x == Enum.sort(nine)
      _ -> true
    end
  end

  def zip([x]), do: x
  def zip(xs), do: xs

  def resolved(p, resolve_map) do
    resolve_map
    |> Enum.any?(fn
      {_k, v} when is_integer(v) and v == p -> true
      _ -> false
    end)
  end

  def extract(p, resolve_map) do
    resolve_map
    |> Enum.filter(fn
      {_, v} when is_integer(v) and v == p -> true
      _ -> false
    end)
  end

  def get_key_elements(ps_map) do
    ps_map
    |> Enum.reduce(
      %{},
      fn
        {k, v}, acc when v == 1 or v == 4 or v == 7 or v == 8 ->
          Map.put(acc, v, k)
        _, acc ->
          acc
      end
    )
  end

  def is_in(as, bs) do
    Enum.all?(as, & :lists.member(&1, bs))
  end

  def calc_possibilities({s, val}) when is_number(val), do: {s, val}
  def calc_possibilities({s, _}) when length(s) == 6, do: {s, [0, 6, 9]}
  def calc_possibilities({s, _}) when length(s) == 5, do: {s, [2, 3, 5]}

  def includes(0), do: [1, 7]
  def includes(2), do: []
  def includes(3), do: [1, 7]
  def includes(5), do: []
  def includes(6), do: []
  def includes(9), do: [1, 4, 7]

  def resolve_includes(ps, resolve_map) when is_list(ps) do
    resolve_map
    |> Enum.reduce(
      [],
      fn {k, v}, acc ->
        case :lists.member(v, ps) do
          true -> [k | acc]
          false -> acc
        end
      end
    )
  end

  def discover_by_len(segments) when length(segments) == 2, do: {:ok, 1}
  def discover_by_len(segments) when length(segments) == 4, do: {:ok, 4}
  def discover_by_len(segments) when length(segments) == 3, do: {:ok, 7}
  def discover_by_len(segments) when length(segments) == 7, do: {:ok, 8}
  def discover_by_len(segments), do: {:nope, segments}

  def load_simple(), do: load_input("./data/simple.txt")
  def load_input(), do: load_input("./data/input.txt")

  def load_input(filename) do
    {:ok, content} = File.read(filename)

    content
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split(" | ")
      |> Enum.map(
        fn t ->
          t
          |> String.split(" ")
          |> Enum.map(fn s -> s |> String.to_charlist() |> Enum.sort() end)
        end)
    end)
  end
end
