defmodule Repo.Migrations.AddGameIDToPlayer do
    use Ecto.Migration
  
    def change do
      alter table "player" do
        add :game, :integer
      end
    end
  end
  