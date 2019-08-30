defmodule GuessThatGif.Game do
  use Ecto.Schema

  schema "game" do
    field :join_code, :string
    field :is_active, :boolean
    field :gif_url, :string
    field :gif_timeout, :integer
    field :status, :string
    belongs_to :creator, GuessThatGif.Player
  end
end
