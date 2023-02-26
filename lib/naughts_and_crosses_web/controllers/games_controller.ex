defmodule NaughtsAndCrossesWeb.GamesController do
  use NaughtsAndCrossesWeb, :controller

  alias NaughtsAndCrosses.Games.Game
  alias NaughtsAndCrosses.Repo

  def new(conn, _params) do
    rows =
      for x <- 1..3,
          do: %{
            pos: x,
            cols:
              for(
                y <- 1..3,
                do: %{
                  pos: y,
                  status: :empty
                }
              )
          }

    with {:ok, game} <-
           %Game{
             crosses: get_session(conn, :user_id),
             next: :naught,
             rows: rows,
             winner: :none
           }
           |> Repo.insert() do
      redirect(conn, to: ~p"/games/#{game.id}")
    else
      e ->
        IO.inspect(e)
        conn |> put_flash(:error, "Failed to create a new game.") |> redirect(to: ~p"/")
    end
  end
end
