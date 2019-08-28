defmodule GuessThatGif.Game do
  use Ecto.Schema

  schema "game" do
    field :creator, :string
    field :join_code, :string
    field :is_active, :boolean
  end
end
