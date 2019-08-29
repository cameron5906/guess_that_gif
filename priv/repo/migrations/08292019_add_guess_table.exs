defmodule Repo.Migrations.AddGuessTable do
    use Ecto.Migration
  
    def up do
      create table "guess" do
        add :username, :string, size: 30
        add :game_code, :string
        add :correct_answer, :string
        add :guess, :string
        add :inserted_on, :time
      end
    end
  
    def down do
      drop table "guess"
    end
  end
  