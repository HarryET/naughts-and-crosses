defmodule NaughtsAndCrosses.Games.GameCol do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  embedded_schema do
    field :pos, :integer

    field(:status, Ecto.Enum, values: [:naught, :cross, :empty])
  end

  def changeset(board, attrs) do
    board
    |> cast(attrs, [:id, :pos, :status])
  end
end

defmodule NaughtsAndCrosses.Games.GameRow do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID

  embedded_schema do
    field :pos, :integer

    embeds_many :cols, NaughtsAndCrosses.Games.GameCol
  end

  def changeset(board, attrs) do
    board
    |> cast(attrs, [:id, :pos])
    |> cast_embed(:cols)
  end
end

defmodule NaughtsAndCrosses.Games.Game do
  @behaviour Access

  use Ecto.Schema
  import Ecto.Changeset

  schema "games" do
    field :crosses, :integer
    field :naught, :integer

    field :next, Ecto.Enum, values: [:naught, :cross, :none]
    field :winner, Ecto.Enum, values: [:naught, :cross, :tie, :none]

    embeds_many :rows, NaughtsAndCrosses.Games.GameRow

    timestamps()
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:id, :naught, :crosses, :next])
    |> cast_embed(:rows)
    |> validate_required([:next])
  end

  def fetch(term, key) do
    term
    |> Map.from_struct()
    |> Map.fetch(key)
  end

  def get(term, key, default) do
    term
    |> Map.from_struct()
    |> Map.get(key, default)
  end

  def get_and_update(data, key, function) do
    data
    |> Map.from_struct()
    |> Map.get_and_update(key, function)
  end

  def pop(data, key) do
    data
    |> Map.from_struct()
    |> Map.pop(key)
  end
end
