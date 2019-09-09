defmodule Repo.Migrations.AddChosenPlayerToGame do
    use Ecto.Migration
  
    def change do
      alter table "game" do
        add :chosen_player, references(:player), null: true
      end
    end
  end
  