defmodule Repo.Migrations.AddGameCreatorRef do
  use Ecto.Migration

  def change do
    alter table "game" do
      add :creator_id, references(:player), null: false
    end
  end
end
