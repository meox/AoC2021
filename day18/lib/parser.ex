defmodule Snail.Parser do
  import NimbleParsec

  # nat    := 0 | 1 | 2 | ...
  # term   := nat | snail
  # snail  := [term, term]

  nat = integer(min: 1)

  defcombinatorp(:term, empty() |> choice([nat, parsec(:snail)]))

  defcombinatorp(
    :snail,
    empty()
    |> ignore(ascii_char([?[]))
    |> parsec(:term)
    |> ignore(ascii_char([?,]))
    |> parsec(:term)
    |> ignore(ascii_char([?]]))
    |> wrap()
  )

  defparsec(:parse, parsec(:snail))
end
