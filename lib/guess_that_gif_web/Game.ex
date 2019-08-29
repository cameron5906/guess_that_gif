defmodule GuessThatGif.Game do
  use Ecto.Schema

  schema "game" do
    field :join_code, :string
    field :is_active, :boolean
    belongs_to :creator, GuessThatGif.Player
  end
end