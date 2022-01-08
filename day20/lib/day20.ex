defmodule Day20 do
  @moduledoc """
  Documentation for `Day20`.
  """

  def part1 do
    {iea, src_img} = input()

    src_img
    |> transform(iea)
    |> transform(iea)
    |> count_light()
  end

  def count_light(image) do
    image
    |> Enum.reduce(
      0,
      fn
        {_, 1}, acc ->
          acc + 1

        {_, 0}, acc ->
          acc
      end
    )
  end

  def transform(image, iea) do
    rimage = rescale(image)

    rimage
    |> Enum.reduce(
      %{},
      fn {p, _}, new_image ->
        idx = index(rimage, p)
        Map.put(new_image, p, iea[idx])
      end
    )
  end

  def rescale(image) do
    image
    |> Enum.reduce(
      %{},
      fn {p, _}, acc ->
        p
        |> ns()
        |> Enum.reduce(
          acc,
          fn {r, c}, acc ->
            v = Map.get(image, {r, c}, 0)
            Map.put(acc, {r, c}, v)
          end
        )
      end
    )
  end

  def image_size(image) do
    image
    |> Enum.reduce(
      {0, 0},
      fn
        {{r, c}, 1}, {max_r, max_c} when r > max_r and c > max_c ->
          {r, c}

        {{r, c}, 1}, {max_r, max_c} when r > max_r and c <= max_c ->
          {r, max_c}

        {{r, c}, 1}, {max_r, max_c} when r <= max_r and c > max_c ->
          {max_r, c}

        {{_r, _c}, _}, {max_r, max_c} ->
          {max_r, max_c}
      end
    )
  end

  def ns({r, c}) do
    [
      {r - 1, c - 1},
      {r - 1, c},
      {r - 1, c + 1},
      {r, c - 1},
      {r, c},
      {r, c + 1},
      {r + 1, c - 1},
      {r + 1, c},
      {r + 1, c + 1}
    ]
  end

  def index(image, {r, c}) do
    ns({r, c})
    |> Enum.map(&Map.get(image, &1, 0))
    |> Integer.undigits(2)
  end

  def show(image) do
    {max_r, max_c} = image_size(image)

    0..max_r
    |> Enum.reduce(
      [],
      fn r, acc ->
        row =
          0..max_c
          |> Enum.reduce(
            [],
            fn c, acc ->
              case Map.get(image, {r, c}) do
                0 -> ['.' | acc]
                1 -> ['#' | acc]
              end
            end
          )

        [row |> Enum.reverse() |> Enum.join("") | acc]
      end
    )
    |> Enum.reverse()
    |> Enum.join("\n")
    |> IO.puts()

    image
  end

  def input(), do: load_input("./data/input.txt")
  def sample(), do: load_input("./data/sample.txt")

  def load_input(filename) do
    {:ok, content} = File.read(filename)

    [iea | images] = String.split(content, "\n", trim: true)

    {_, image} =
      images
      |> Enum.reduce(
        {0, %{}},
        fn line, {row_index, image} ->
          {_, new_image} =
            line
            |> String.split("", trim: true)
            |> Enum.reduce(
              {0, image},
              fn
                ".", {col_index, image} ->
                  {col_index + 1, Map.put(image, {row_index, col_index}, 0)}

                "#", {col_index, image} ->
                  {col_index + 1, Map.put(image, {row_index, col_index}, 1)}
              end
            )

          {row_index + 1, new_image}
        end
      )

    {parse_iea(iea), image}
  end

  defp parse_iea(iea) do
    iea
    |> String.split("", trim: true)
    |> Enum.reduce(
      {0, %{}},
      fn
        ".", {idx, acc} -> {idx + 1, Map.put(acc, idx, 0)}
        "#", {idx, acc} -> {idx + 1, Map.put(acc, idx, 1)}
      end
    )
    |> elem(1)
  end
end
