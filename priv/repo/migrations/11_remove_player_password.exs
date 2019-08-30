defmodule Repo.Migrations.RemovePlayerPassword do
    use Ecto.Migration
  
    def change do
      alter table "player" do
        remove :password
      end
    end
  end
  