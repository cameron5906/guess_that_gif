defmodule Repo.Migrations.AddPlayerTable do
    use Ecto.Migration

    def up do
      create table "player" do
        add :username, :string, size: 30
        add :password, :string
        add :total_correct_guesses, :integer
        add :total_wrong_guesses, :integer
        add :total_times_won, :integer
        add :games_played, :integer

        timestamps()
      end
    end

    def down do
      drop table "player"
    end
end
