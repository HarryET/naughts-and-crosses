defmodule NaughtsAndCrosses.Gamehelper do
  alias NaughtsAndCrosses.Games.GameCol
  alias NaughtsAndCrosses.ListHelper

  def get_lines(board) do
    board ++
      ListHelper.get_columns(board) ++
      [ListHelper.get_diagonal_1(board)] ++
      [ListHelper.get_diagonal_2(board)]
  end

  def get_winner(board) do
    board
    |> get_lines
    |> Enum.map(&get_line_winner(&1))
    |> Enum.reduce(&if &1 in [:naught, :cross], do: &1, else: if(&2 == :tie, do: &1, else: &2))
  end

  defp get_line_winner([%GameCol{status: :empty} | _]) do
    :none
  end

  defp get_line_winner([head | tail]) do
    cond do
      Enum.all?(tail, &(&1.status == head.status)) -> head.status
      Enum.all?(tail, &(&1.status != :empty)) -> :tie
      true -> :none
    end
  end
end
