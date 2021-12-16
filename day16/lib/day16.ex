defmodule Day16 do
  @moduledoc """
  Documentation for `Day16`.
  """

  def part1() do
    input()
    |> parse([])
    |> elem(1)
    |> sum_versions()
  end

  def part2() do
    input()
    |> parse([])
    |> elem(1)
    |> apply()
  end

  def sum_versions(compiled) do
    compiled
    |> Enum.reduce(
      0,
      fn
        {:operator, v, _op, operands}, acc ->
          acc + v + sum_versions(operands)

        {:literal, v, _val}, acc ->
          acc + v
      end
    )
  end

  def parse(body, acc, max_packets \\ -1)

  def parse(body, acc, max_packets) when max_packets > 0 and length(acc) >= max_packets,
    do: {body, acc}

  def parse(<<version::3, 4::3, rest::bitstring>>, acc, max_packets) do
    parse_literal(version, rest, 0, acc, max_packets)
  end

  def parse(
        <<version::3, op::3, 0::1, bl::15, packets::bits-size(bl), rest::bitstring>>,
        acc,
        max_packets
      ) do
    parse_operator(version, op, :total_bits, packets, rest, acc, max_packets)
  end

  def parse(<<version::3, op::3, 1::1, num_packets::11, rest::bitstring>>, acc, max_packets) do
    parse_operator(version, op, :num_packets, num_packets, rest, acc, max_packets)
  end

  def parse(body, acc, _max_packets), do: {body, acc}

  def parse_literal(version, <<1::1, bits::4, rest::bitstring>>, literal_acc, acc, max_packets) do
    parse_literal(version, rest, bits + literal_acc * 16, acc, max_packets)
  end

  def parse_literal(version, <<0::1, bits::4, rest::bitstring>>, literal_acc, acc, max_packets) do
    v = bits + literal_acc * 16
    parse(rest, acc ++ [{:literal, version, v}], max_packets)
  end

  def parse_operator(version, op, :total_bits, packets, rest, acc, max_packets) do
    {_, parsed} = parse(packets, [])

    new_acc = acc ++ [{:operator, version, op, parsed}]
    parse(rest, new_acc, max_packets)
  end

  def parse_operator(version, op, :num_packets, num_packets, rest, acc, max_packets) do
    {new_rest, packets} = parse(rest, [], num_packets)
    new_acc = acc ++ [{:operator, version, op, packets}]
    parse(new_rest, new_acc, max_packets)
  end

  def apply(ops) when is_list(ops) do
    ops
    |> Enum.map(&apply/1)
  end

  def apply({:literal, _ver, _val} = l), do: l

  def apply({:operator, ver, 0, operands}) do
    r =
      operands
      |> Enum.map(&apply(&1))
      |> Enum.map(fn {:literal, _ver, v} -> v end)
      |> Enum.sum()

    {:literal, ver, r}
  end

  def apply({:operator, ver, 1, operands}) do
    r =
      operands
      |> Enum.map(&apply(&1))
      |> Enum.map(fn {:literal, _ver, v} -> v end)
      |> Enum.product()

    {:literal, ver, r}
  end

  def apply({:operator, ver, 2, operands}) do
    r =
      operands
      |> Enum.map(&apply(&1))
      |> Enum.map(fn {:literal, _ver, v} -> v end)
      |> Enum.min()

    {:literal, ver, r}
  end

  def apply({:operator, ver, 3, operands}) do
    r =
      operands
      |> Enum.map(&apply(&1))
      |> Enum.map(fn {:literal, _ver, v} -> v end)
      |> Enum.max()

    {:literal, ver, r}
  end

  def apply({:operator, ver, 5, operands}) do
    [op1, op2] = apply(operands)

    {:literal, _, o1} = apply(op1)
    {:literal, _, o2} = apply(op2)

    {:literal, ver,
     case o1 > o2 do
       true -> 1
       _ -> 0
     end}
  end

  def apply({:operator, ver, 6, operands}) do
    [op1, op2] = apply(operands)

    {:literal, _, o1} = apply(op1)
    {:literal, _, o2} = apply(op2)

    {:literal, ver,
     case o1 < o2 do
       true -> 1
       _ -> 0
     end}
  end

  def apply({:operator, ver, 7, operands}) do
    [op1, op2] = apply(operands)

    {:literal, _, o1} = apply(op1)
    {:literal, _, o2} = apply(op2)

    {:literal, ver,
     case o1 == o2 do
       true -> 1
       _ -> 0
     end}
  end

  def input(), do: load_input("./data/input.txt")

  def sample(), do: load_input("./data/sample.txt")

  def load_input(filename) do
    {:ok, content} = File.read(filename)

    chunks = for <<x::binary-2 <- content>>, do: x

    chunks
    |> Enum.map(fn x ->
      {n, ""} = Integer.parse(x, 16)
      <<n::8>>
    end)
    |> :erlang.iolist_to_binary()
  end
end
