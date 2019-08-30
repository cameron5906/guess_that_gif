defmodule Repo.Migrations.AddQueryTable do
    use Ecto.Migration
  
    def up do
      create table "query" do
        add :username, :string, size: 30
        add :game_code, :string
        add :query, :string
        add :gif, :string
        add :inserted_on, :time
      end
    end
  
    def down do
      drop table "query"
    end
  end
  