defmodule Day04 do
  @moduledoc """
  Documentation for `Day04`.
  """

  def check_winner_last() do
    {random, tables} = load_input()

    main = self()
    control_pid = spawn(fn -> controller(main, length(tables), 0, 0, :next) end)

    players =
      tables
      |> Enum.map(fn table ->
        spawn(fn -> player(control_pid, table, []) end)
      end)

    {marked, table} =
      random
      |> Enum.reduce(
        nil,
        fn number, acc ->
          players |> Enum.each(fn player -> send(player, {:number, number}) end)

          receive do
            {:win, msg} ->
              msg

            :next ->
              acc
          end
        end
      )

    stop_players(players)
    unmarked_sum(table) * Enum.at(marked, length(marked) - 1)
  end

  def check_winner() do
    {random, tables} = load_input()

    main = self()
    control_pid = spawn(fn -> controller(main, length(tables), 0, 0, :next) end)

    players =
      tables
      |> Enum.map(fn table ->
        spawn(fn -> player(control_pid, table, []) end)
      end)

    {marked, table} =
      random
      |> Enum.reduce_while(
        [],
        fn number, acc ->
          players |> Enum.each(fn player -> send(player, {:number, number}) end)

          receive do
            {:win, msg} ->
              {:halt, msg}

            :next ->
              {:cont, acc}

            msg ->
              IO.inspect(msg)
          end
        end
      )

    stop_players(players)
    unmarked_sum(table) * Enum.at(marked, length(marked) - 1)
  end

  defp unmarked_sum(table) do
    table
    |> Enum.reduce(0, fn row, acc -> acc + sum_unmarked(row) end)
  end

  defp sum_unmarked(row) do
    row
    |> Enum.filter(fn
      :x -> false
      _ -> true
    end)
    |> Enum.sum()
  end

  defp controller(main, num_players, arrived, winner, state) when arrived == num_players do
    send(main, state)
    controller(main, num_players - winner, 0, 0, :next)
  end

  defp controller(main, num_players, arrived, winner, state) do
    receive do
      {:win, _} = msg ->
        controller(main, num_players, arrived + 1, winner + 1, msg)

      :nope ->
        controller(main, num_players, arrived + 1, winner, state)
    end
  end

  def player(controller, table, marked) do
    receive do
      {:number, number} ->
        {c_marked, new_table} = mark_table(number, table)
        new_marked = marked ++ c_marked

        case check_win(new_table) do
          true ->
            send(controller, {:win, {new_marked, new_table}})

          false ->
            send(controller, :nope)
            player(controller, new_table, new_marked)
        end

      :stop ->
        :stopped
    end
  end

  defp check_win(table) do
    check_rows(table) or check_cols(table)
  end

  def check_rows(table) do
    table
    |> Enum.any?(fn
      [:x, :x, :x, :x, :x] -> true
      _ -> false
    end)
  end

  def check_cols(table) do
    0..4
    |> Enum.any?(fn index ->
      table
      |> Enum.all?(fn
        row -> Enum.at(row, index) == :x
      end)
    end)
  end

  def mark_table(number, table) do
    {new_marked, new_table} =
      table
      |> Enum.reduce(
        {[], []},
        fn row, {marked, new_table} ->
          {new_marked, new_row} =
            row
            |> Enum.reduce(
              {marked, []},
              fn
                ^number, {marked_row, new_row} ->
                  {[number | marked_row], [:x | new_row]}

                n, {marked_row, new_row} ->
                  {marked_row, [n | new_row]}
              end
            )

          {new_marked, [Enum.reverse(new_row) | new_table]}
        end
      )

    {new_marked, Enum.reverse(new_table)}
  end

  defp stop_players(players) do
    players
    |> Enum.each(fn p -> send(p, :stop) end)
  end

  defp load_input() do
    {:ok, fd} = File.open("./data/input.txt", [:read])
    random = IO.read(fd, :line)
    # separator
    IO.read(fd, :line)
    tables = IO.read(fd, :all)
    :ok = File.close(fd)
    {parse_random(random), parse_tables(tables)}
  end

  defp parse_random(r) do
    r
    |> String.trim()
    |> String.split(",")
    |> Enum.filter(fn
      "" -> false
      _ -> true
    end)
    |> Enum.map(&String.to_integer/1)
  end

  defp parse_tables(tables) do
    {last, all_tables} =
      tables
      |> String.split("\n")
      |> Enum.reduce(
        {[], []},
        fn
          "", {current, all} ->
            {[], [Enum.reverse(current) | all]}

          line, {current, all} ->
            {[parse_line(line) | current], all}
        end
      )

    Enum.reverse([Enum.reverse(last) | all_tables])
  end

  defp parse_line(line) do
    line
    |> String.split(" ")
    |> Enum.filter(fn
      "" -> false
      " " -> false
      _ -> true
    end)
    |> Enum.map(&String.to_integer/1)
  end
end
