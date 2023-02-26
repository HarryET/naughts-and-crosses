defmodule NaughtsAndCrossesWeb.Router do
  use NaughtsAndCrossesWeb, :router

  def ensure_user_identifier(conn, _opts) do
    if get_session(conn, :user_id) do
      conn
    else
      {:ok, account} =
        %NaughtsAndCrosses.Accounts.User{}
        |> NaughtsAndCrosses.Repo.insert()

      put_session(conn, :user_id, account.id)
    end
  end

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {NaughtsAndCrossesWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug :ensure_user_identifier
  end

  scope "/", NaughtsAndCrossesWeb do
    pipe_through(:browser)

    get("/debug", DebugController, :index)

    get("/", PageController, :home)

    get("/games/new", GamesController, :new)
    live("/games/:id", GameLive.Show, :show)
    get "/games/:id/debug", DebugController, :game
  end
end
