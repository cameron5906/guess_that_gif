defmodule Repo.Migrations.AddGameTable do
  use Ecto.Migration

  def up do
    create table "game" do
      add :creator, :string, size: 30
      add :join_code, :string
      add :is_active, :boolean
    end
  end

  def down do
    drop table "game"
  end
end
