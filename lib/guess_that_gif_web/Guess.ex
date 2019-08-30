defmodule GuessThatGif.Guess do
    use Ecto.Schema
  
    schema "guess" do
        field :game_code, :string
        field :correct_answer, :string
        field :guess, :string
        field :inserted_on, :time
        field :guessed_on, :utc_datetime
        
        belongs_to :player, GuessThatGif.Player
    end
  end