defmodule NaughtsAndCrossesWeb.GameLive.Show do
  use NaughtsAndCrossesWeb, :live_view

  alias NaughtsAndCrosses.Games
  alias NaughtsAndCrosses.Games.Game
  alias NaughtsAndCrosses.Repo

  @impl true
  def mount(%{"id" => id} = _params, %{"user_id" => user_id} = _session, socket) do
    NaughtsAndCrossesWeb.Endpoint.subscribe("game:#{id}")
    NaughtsAndCrossesWeb.Endpoint.subscribe("rematches")

    {:ok, socket |> assign(:user_id, user_id) |> assign(:line, false)}
  end

  @impl true
  def handle_params(%{"id" => id}, uri, socket) do
    me = socket.assigns[:user_id]

    %URI{
      path: path
    } = URI.parse(uri)

    with %Game{} = game <- Games.get_game(id) do
      {:noreply,
       socket
       |> assign(:page_title, "Play Game")
       |> assign(:game, game)
       |> assign(:playing, game.naught == me || game.crosses == me)
       |> assign(:can_join, game.naught != me && game.crosses != me)
       |> assign(
         :piece,
         if game.naught == me do
           :naught
         else
           if game.crosses == me do
             :cross
           else
             nil
           end
         end
       )
       |> assign(
         :my_go,
         if game.naught == me && game.next == :naught do
           true
         else
           if game.crosses == me && game.next == :cross do
             true
           else
             false
           end
         end
       )
       |> assign(:me, me)
       |> assign(:__path__, path)}
    else
      e ->
        IO.inspect(e)
        {:noreply, socket |> put_flash(:error, "Failed to find game") |> redirect(to: ~p"/")}
    end
  end

  @impl true
  def handle_info(%{event: "put_flash", payload: %{msg: msg, type: type} = _} = _, socket) do
    {:noreply, socket |> put_flash(type, msg)}
  end

  @impl true
  def handle_info(%{event: "redirect", payload: %{to: to, prev: from} = _} = _, socket) do
    if socket.assigns[:__path__] == from do
      {:noreply, redirect(socket, to: to)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info(%{event: "game_update", payload: payload} = _, socket) do
    me = socket.assigns[:user_id]
    game = payload.game

    {:noreply,
     socket
     |> assign(:game, game)
     |> assign(:playing, game.naught == me || game.crosses == me)
     |> assign(:can_join, game.naught != me && game.crosses != me)
     |> assign(
       :piece,
       if game.naught == me do
         :naught
       else
         if game.crosses == me do
           :cross
         else
           nil
         end
       end
     )
     |> assign(
       :my_go,
       if game.naught == me && game.next == :naught do
         true
       else
         if game.crosses == me && game.next == :cross do
           true
         else
           false
         end
       end
     )}
  end

  @impl true
  def handle_event("warn-wait", _params, socket) do
    {:noreply, socket |> put_flash(:warning, "It's not your turn yet.")}
  end

  @impl true
  def handle_event("rematch", _params, socket) do
    current_game = socket.assigns[:game]

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
             crosses: current_game.naught,
             naught: current_game.crosses,
             next: :naught,
             rows: rows,
             winner: :none
           }
           |> Repo.insert() do
      NaughtsAndCrossesWeb.Endpoint.broadcast_from(
        self(),
        "rematches",
        "redirect",
        %{
          prev: ~p"/games/#{current_game.id}",
          to: ~p"/games/#{game.id}"
        }
      )

      {:noreply, redirect(socket, to: ~p"/games/#{game.id}")}
    else
      e ->
        IO.inspect(e)
        {:noreply, socket |> put_flash(:error, "Failed to start a re-match.")}
    end
  end

  @impl true
  def handle_event("claim", %{"row" => row, "col" => col}, socket) do
    me = socket.assigns[:me]
    piece = socket.assigns[:piece]
    game = Games.get_game!(socket.assigns[:game].id)
    playing = socket.assigns[:playing]
    my_go = socket.assigns[:my_go]

    if game.winner != :none do
      {:noreply, socket |> put_flash(:error, "This game is already over")}
    else
      if playing == false && game.next != :none do
        if game[game.next] == nil do
          opts =
            case game.next do
              :naught -> %{naught: me}
              :cross -> %{crosses: me}
            end

          {:ok, new_game} =
            Game.changeset(game, opts)
            |> Repo.update()

          NaughtsAndCrossesWeb.Endpoint.broadcast_from(
            self(),
            "game:#{game.id}",
            "game_update",
            %{
              game: new_game
            }
          )

          {:noreply,
           place(
             new_game,
             me,
             game.next,
             row,
             col,
             socket
             |> put_flash(:info, "You have joined this game as #{Atom.to_string(game.next)}")
           )}
        else
          {:noreply, socket |> put_flash(:warning, "You cannot play in this game")}
        end
      else
        if my_go == true do
          {:noreply,
           place(
             game,
             me,
             piece,
             row,
             col,
             socket
           )}
        else
          {:noreply, socket |> put_flash(:warning, "It's not your turn yet.")}
        end
      end
    end
  end

  defp place(game, me, piece, row, col, socket) do
    {row_i, _} = Integer.parse(row)
    {col_i, _} = Integer.parse(col)

    updated_rows =
      Enum.map(game.rows, fn row ->
        %{
          id: row.id,
          pos: row.pos,
          cols:
            Enum.map(row.cols, fn col ->
              case col.pos == col_i && row.pos == row_i do
                true ->
                  %{
                    id: col.id,
                    pos: col.pos,
                    status: piece
                  }

                false ->
                  %{
                    id: col.id,
                    pos: col.pos,
                    status: col.status
                  }
              end
            end)
        }
      end)

    next =
      case piece do
        :naught -> :cross
        :cross -> :naught
      end

    case game
         |> Game.changeset(%{next: next})
         |> Ecto.Changeset.put_embed(:rows, updated_rows)
         |> Repo.update() do
      {:ok, new_game} ->
        NaughtsAndCrossesWeb.Endpoint.broadcast_from(self(), "game:#{game.id}", "game_update", %{
          game: new_game
        })

        check_for_winner(
          new_game,
          me,
          socket
          |> assign(:game, new_game)
          |> assign(:playing, new_game.naught == me || new_game.crosses == me)
          |> assign(:can_join, game.naught != me && game.crosses != me)
          |> assign(
            :piece,
            if new_game.naught == me do
              :naught
            else
              if new_game.crosses == me do
                :cross
              else
                nil
              end
            end
          )
          |> assign(
            :my_go,
            if new_game.naught == me && new_game.next == :naught do
              true
            else
              if new_game.crosses == me && new_game.next == :cross do
                true
              else
                false
              end
            end
          )
        )

      {:error, err} ->
        IO.inspect(err)
        socket |> put_flash(:error, "Failed to place!")
    end
  end

  defp check_for_winner(game, me, socket) do
    winner = NaughtsAndCrosses.Gamehelper.get_winner(Enum.map(game.rows, fn row -> row.cols end))

    IO.inspect(winner)

    case winner do
      :none ->
        socket

      :naught ->
        case game
             |> Game.changeset(%{next: :none, winner: :naught})
             |> Repo.update() do
          {:ok, new_game} ->
            NaughtsAndCrossesWeb.Endpoint.broadcast_from(
              self(),
              "game:#{game.id}",
              "game_update",
              %{
                game: new_game
              }
            )

            NaughtsAndCrossesWeb.Endpoint.broadcast_from(
              self(),
              "game:#{game.id}",
              "put_flash",
              %{
                msg: "Naughts Won!",
                type: :info
              }
            )

            socket
            |> assign(:game, new_game)
            |> assign(:playing, new_game.naught == me || new_game.crosses == me)
            |> assign(:can_join, game.naught != me && game.crosses != me)
            |> assign(
              :piece,
              if new_game.naught == me do
                :naught
              else
                if new_game.crosses == me do
                  :cross
                else
                  nil
                end
              end
            )
            |> assign(
              :my_go,
              false
            )
            |> put_flash(:info, "Naughts Won!")

          {:error, err} ->
            IO.inspect(err)
            socket |> put_flash(:error, "Failed to save winner; Naughts won.")
        end

      :cross ->
        case game
             |> Game.changeset(%{next: :none, winner: :cross})
             |> Repo.update() do
          {:ok, new_game} ->
            NaughtsAndCrossesWeb.Endpoint.broadcast_from(
              self(),
              "game:#{game.id}",
              "game_update",
              %{
                game: new_game
              }
            )

            NaughtsAndCrossesWeb.Endpoint.broadcast_from(
              self(),
              "game:#{game.id}",
              "put_flash",
              %{
                msg: "Crosses Won!",
                type: :info
              }
            )

            socket
            |> assign(:game, new_game)
            |> assign(:playing, new_game.naught == me || new_game.crosses == me)
            |> assign(:can_join, game.naught != me && game.crosses != me)
            |> assign(
              :piece,
              if new_game.naught == me do
                :naught
              else
                if new_game.crosses == me do
                  :cross
                else
                  nil
                end
              end
            )
            |> assign(
              :my_go,
              false
            )
            |> put_flash(:info, "Crosses Won!")

          {:error, err} ->
            IO.inspect(err)
            socket |> put_flash(:error, "Failed to save winner; Crosses won.")
        end

      :tie ->
        case game
             |> Game.changeset(%{next: :none, winner: :tie})
             |> Repo.update() do
          {:ok, new_game} ->
            NaughtsAndCrossesWeb.Endpoint.broadcast_from(
              self(),
              "game:#{game.id}",
              "game_update",
              %{
                game: new_game
              }
            )

            NaughtsAndCrossesWeb.Endpoint.broadcast_from(
              self(),
              "game:#{game.id}",
              "put_flash",
              %{
                msg: "It is a tie!",
                type: :info
              }
            )

            socket
            |> assign(:game, new_game)
            |> assign(:playing, new_game.naught == me || new_game.crosses == me)
            |> assign(:can_join, game.naught != me && game.crosses != me)
            |> assign(
              :piece,
              if new_game.naught == me do
                :naught
              else
                if new_game.crosses == me do
                  :cross
                else
                  nil
                end
              end
            )
            |> assign(
              :my_go,
              false
            )
            |> put_flash(:info, "It is a tie!")

          {:error, err} ->
            IO.inspect(err)
            socket |> put_flash(:error, "Failed to save winner; Crosses won.")
        end
    end
  end
end
