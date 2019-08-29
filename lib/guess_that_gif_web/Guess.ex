defmodule GuessThatGif.Guess do
    use Ecto.Schema
  
    schema "guess" do
        field :game_code, :string
        field :correct_answer, :string
        field :guess, :string
        field :inserted_on, :time
        
        belongs_to :game, GuessThatGif.Game
        belongs_to :player, GuessThatGif.Player
    end
  end