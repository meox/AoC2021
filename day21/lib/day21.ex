defmodule Day21 do
  @moduledoc """
  Documentation for `Day21`.
  """

  def part1(), do: solve(input())

  def part2() do
    case qplay(sample(), {0, 0}, 1) do
      {a, b} when a > b ->
        a

      {_a, b} ->
        b
    end
  end

  def solve(state) do
    {num_rolled, final_state} = play(0, 0, state)
    score = looser_score(final_state)
    num_rolled * score
  end

  def qplay(state, wstate, k) do
    {qs, wstate1} =
      state
      |> player_qstates(:player1)
      |> Enum.reduce(
        {[], wstate},
        fn state1, {qs_acc, wstate} ->
          case update_winner(state1, wstate, k) do
            {:win, :player1, ws} ->
              {qs_acc, ws}

            {:noop, ws} ->
              {[state1 | qs_acc], ws}
          end
        end
      )

    qs
    |> Enum.reduce(
      wstate1,
      fn state1, c_wstate ->
        state1
        |> player_qstates(:player2)
        |> Enum.reduce(
          c_wstate,
          fn state2, wstate2 ->
            %{player1: {_, _, k1}, player2: {_, _, k2}} = state2

            case update_winner(state2, wstate2, k * mul_factor(k1)) do
              {:win, :player2, ws} ->
                ws

              {:noop, ws} ->
                qplay(state2, ws, k * mul_factor(k1) * mul_factor(k2))
            end
          end
        )
      end
    )
  end

  def update_winner(state, {p1, p2} = wstate, k) do
    case state do
      %{player1: {_, score, nmove}} when score >= 21 ->
        {:win, :player1, {p1 + k * mul_factor(nmove), p2}}

      %{player2: {_, score, nmove}} when score >= 21 ->
        {:win, :player2, {p1, p2 + k * mul_factor(nmove)}}

      _ ->
        {:noop, wstate}
    end
  end

  @qfreq Enum.frequencies(for a <- [1, 2, 3], b <- [1, 2, 3], c <- [1, 2, 3], do: a + b + c)
  def mul_factor(nmove), do: @qfreq[nmove]

  def player_qstates(state, player) do
    {pos, score, _} = state[player]

    [3, 4, 5, 6, 7, 8, 9]
    |> Enum.map(fn nmove ->
      new_pos = board(pos, nmove)
      new_score = score + new_pos
      %{state | player => {new_pos, new_score, nmove}}
    end)
  end

  def play(dice_last, num_rolled, state) do
    {d1, s1} = play_turn(:player1, dice_last, state)

    case s1[:player1] do
      {_, score, _} when score >= 1000 ->
        {num_rolled + 3, s1}

      _ ->
        {d2, s2} = play_turn(:player2, d1, s1)

        case s2[:player2] do
          {_, score, _} when score >= 1000 ->
            {num_rolled + 6, s2}

          _ ->
            play(d2, num_rolled + 6, s2)
        end
    end
  end

  def play_turn(player, dice_last, state) do
    {pos, score, _} = state[player]
    [_, _, dice_last] = moves = det_dice(dice_last)
    nmove = Enum.sum(moves)

    new_pos = board(pos, nmove)
    new_score = score + new_pos

    new_state = %{state | player => {new_pos, new_score, 0}}
    {dice_last, new_state}
  end

  def looser_score(%{player1: {_, s1, _}, player2: {_, s2, _}}) when s1 > s2, do: s2
  def looser_score(%{player1: {_, s1, _}}), do: s1

  def board(pos, 1), do: next_move(pos)

  def board(pos, nmove) do
    board(next_move(pos), nmove - 1)
  end

  def next_move(10), do: 1
  def next_move(n), do: n + 1

  def det_dice(last) do
    1..100
    |> Stream.cycle()
    |> Stream.drop(last)
    |> Enum.take(3)
  end

  def sample() do
    %{player1: {4, 0, 0}, player2: {8, 0, 0}}
  end

  def input() do
    %{player1: {4, 0, 0}, player2: {1, 0, 0}}
  end
end
