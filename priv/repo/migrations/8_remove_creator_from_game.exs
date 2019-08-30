defmodule Repo.Migrations.RemoveCreatorFromGame do
    use Ecto.Migration
  
    def change do
      alter table "game" do
        remove :creator
      end
    end
  end
  