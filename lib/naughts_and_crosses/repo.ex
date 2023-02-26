defmodule NaughtsAndCrosses.Repo do
  use Ecto.Repo,
    otp_app: :naughts_and_crosses,
    adapter: Ecto.Adapters.SQLite3
end
