defmodule Repo.Migrations.RemoveUsernameFieldFromQuery do
    use Ecto.Migration
  
    def change do
      alter table "query" do
        remove :username
      end
    end
  end
  