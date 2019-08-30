defmodule Repo.Migrations.AddGameStatus do
    use Ecto.Migration
  
    def change do
      alter table "game" do
        add :status, :string
      end
    end
  end
  