defmodule Repo.Migrations.RemoveUsernameFieldFromGuess do
    use Ecto.Migration
  
    def change do
      alter table "guess" do
        remove :username
      end
    end
  end
  