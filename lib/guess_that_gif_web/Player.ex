defmodule GuessThatGif.Player do
  use Ecto.Schema

  schema "player" do
    field :username, :string
    field :total_correct_guesses, :integer
    field :total_wrong_guesses, :integer
    field :total_times_won, :integer
    field :games_played, :integer
    field :game, :integer
  end
end
