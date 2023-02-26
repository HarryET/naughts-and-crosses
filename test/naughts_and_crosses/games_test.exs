defmodule NaughtsAndCrosses.GamesTest do
  use NaughtsAndCrosses.DataCase

  alias NaughtsAndCrosses.Games

  describe "games" do
    alias NaughtsAndCrosses.Games.Game

    import NaughtsAndCrosses.GamesFixtures

    @invalid_attrs %{crosses: nil, naught: nil}

    test "list_games/0 returns all games" do
      game = game_fixture()
      assert Games.list_games() == [game]
    end

    test "get_game!/1 returns the game with given id" do
      game = game_fixture()
      assert Games.get_game!(game.id) == game
    end

    test "create_game/1 with valid data creates a game" do
      valid_attrs = %{crosses: "7488a646-e31f-11e4-aace-600308960662", naught: "7488a646-e31f-11e4-aace-600308960662"}

      assert {:ok, %Game{} = game} = Games.create_game(valid_attrs)
      assert game.crosses == "7488a646-e31f-11e4-aace-600308960662"
      assert game.naught == "7488a646-e31f-11e4-aace-600308960662"
    end

    test "create_game/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Games.create_game(@invalid_attrs)
    end

    test "update_game/2 with valid data updates the game" do
      game = game_fixture()
      update_attrs = %{crosses: "7488a646-e31f-11e4-aace-600308960668", naught: "7488a646-e31f-11e4-aace-600308960668"}

      assert {:ok, %Game{} = game} = Games.update_game(game, update_attrs)
      assert game.crosses == "7488a646-e31f-11e4-aace-600308960668"
      assert game.naught == "7488a646-e31f-11e4-aace-600308960668"
    end

    test "update_game/2 with invalid data returns error changeset" do
      game = game_fixture()
      assert {:error, %Ecto.Changeset{}} = Games.update_game(game, @invalid_attrs)
      assert game == Games.get_game!(game.id)
    end

    test "delete_game/1 deletes the game" do
      game = game_fixture()
      assert {:ok, %Game{}} = Games.delete_game(game)
      assert_raise Ecto.NoResultsError, fn -> Games.get_game!(game.id) end
    end

    test "change_game/1 returns a game changeset" do
      game = game_fixture()
      assert %Ecto.Changeset{} = Games.change_game(game)
    end
  end
end
