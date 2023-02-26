defmodule NaughtsAndCrosses.GamesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `NaughtsAndCrosses.Games` context.
  """

  @doc """
  Generate a game.
  """
  def game_fixture(attrs \\ %{}) do
    {:ok, game} =
      attrs
      |> Enum.into(%{
        crosses: "7488a646-e31f-11e4-aace-600308960662",
        naught: "7488a646-e31f-11e4-aace-600308960662"
      })
      |> NaughtsAndCrosses.Games.create_game()

    game
  end
end
