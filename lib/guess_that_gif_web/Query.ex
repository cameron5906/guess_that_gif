defmodule GuessThatGif.SearchQuery do
    use Ecto.Schema
  
    schema "query" do
        field :game_code, :string
        field :query, :string
        field :gif, :string
        field :inserted_on, :time
        belongs_to :player, Player
    end
  end
  