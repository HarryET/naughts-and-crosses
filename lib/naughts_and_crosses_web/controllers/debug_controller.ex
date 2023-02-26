defmodule NaughtsAndCrossesWeb.DebugController do
  use NaughtsAndCrossesWeb, :controller

  alias NaughtsAndCrosses.Games.Game
  alias NaughtsAndCrosses.Games

  def index(conn, _params) do
    render(conn, :index, user_id: get_session(conn, :user_id), keys: [:user_id], line: true)
  end

  def game(conn, %{"id" => id} = _params) do
    me = get_session(conn, :user_id)

    with %Game{} = game <- Games.get_game(id) do
      render(conn, :index,
        user_id: me,
        playing: game.naught == me || game.crosses == me,
        my_go: false,
        game_id: game.id,
        next: Atom.to_string(game.next),
        keys: [:user_id, :game_id, :playing, :my_go, :next],
        line: false
      )
    else
      e ->
        IO.inspect(e)

        render(conn, :index,
          user_id: me,
          error: e,
          keys: [:user_id, :error],
          line: false
        )
    end
  end
end

defmodule NaughtsAndCrossesWeb.DebugHTML do
  use NaughtsAndCrossesWeb, :html

  embed_templates "debug/*"
end
