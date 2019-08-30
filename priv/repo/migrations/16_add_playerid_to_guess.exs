defmodule Repo.Migrations.AddPlayerIDToGuess do
    use Ecto.Migration
  
    def change do
      alter table "guess" do
        add :player_id, references(:player)
      end
    end
  end
  