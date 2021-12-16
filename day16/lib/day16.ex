defmodule Day16 do
  @moduledoc """
  Documentation for `Day16`.
  """

  def part1() do
    input = input()
    {_, compiled} = parse(input, [])

    sum_versions(compiled)
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

  def parse(body, acc, max_packets) when max_packets > 0 and length(acc) >= max_packets, do: {body, acc}

  def parse(<<version::3, 4::3, rest::bitstring>>, acc, _max_packets), do: parse_literal(version, rest, 0, acc)

  def parse(<<version::3, op::3, 0::1, bl::15, packets::bits-size(bl), rest::bitstring>>, acc, _max_packets) do
    parse_operator(version, op, :total_bits, packets, rest, acc)
  end

  def parse(<<version::3, op::3, 1::1, num_packets::11, rest::bitstring>>, acc, _max_packets) do
    parse_operator(version, op, :num_packets, num_packets, rest, acc)
  end

  def parse(body, acc, _max_packets), do: {body, acc}

  def parse_literal(version, <<1::1, bits::4, rest::bitstring>>, literal_acc, acc) do
    parse_literal(version, rest, bits + literal_acc * 16, acc)
  end

  def parse_literal(version, <<0::1, bits::4, rest::bitstring>>, literal_acc, acc) do
    v = bits + literal_acc * 16
    parse(rest, [{:literal, version, v} | acc])
  end

  def parse_operator(version, op, :total_bits, packets, rest, acc) do
    {_, parsed} = parse(packets, [])
    new_acc = [{:operator, version, op, parsed} | acc]
    parse(rest, new_acc)
  end

  def parse_operator(version, op, :num_packets, num_packets, rest, acc) do
    {rest, packets} = parse(rest, [], num_packets)
    new_acc = [{:operator, version, op, packets} | acc]
    parse(rest, new_acc)
  end

  def input(), do: load_input("./data/input.txt")

  def sample(), do: load_input("./data/sample.txt")

  def load_input(filename) do
    {:ok, content} = File.read(filename)

    chunks = for <<x::binary-2 <- content>>, do: x

    chunks
    |> Enum.map(
      fn x ->
        {n, ""} = Integer.parse(x, 16)
        <<n::8>>
      end
    )
    |> :erlang.iolist_to_binary()
  end
end
