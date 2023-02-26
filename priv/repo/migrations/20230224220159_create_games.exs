defmodule NaughtsAndCrosses.Repo.Migrations.CreateGames do
  use Ecto.Migration

  @default_rows for x <- 1..3,
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

  def change do
    create table(:games) do
      add :naught, :integer
      add :crosses, :integer

      add :next, :string
      add :winner, :string

      add :rows, {:array, :map}, default: @default_rows

      timestamps()
    end
  end
end
