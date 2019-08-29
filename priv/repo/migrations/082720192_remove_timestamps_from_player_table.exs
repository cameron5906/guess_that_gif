defmodule Repo.Migrations.RemoveTimestampsFromPlayer do
  use Ecto.Migration

  def change do
    alter table :player do
      remove :inserted_at
      remove :updated_at
    end
  end
end
