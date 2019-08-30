defmodule Repo.Migrations.AddGuessTime do
    use Ecto.Migration
  
    def change do
      alter table "guess" do
        add :guessed_on, :utc_datetime
      end
    end
  end
  