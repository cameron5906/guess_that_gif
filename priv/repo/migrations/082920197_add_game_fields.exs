defmodule Repo.Migrations.AddGameFieldsGifUrlGifTimeout do
  use Ecto.Migration

  def up do
    alter table "game" do
      add :gif_url, :string
      add :gif_timeout, :integer
    end
  end

  def down do
    remove :gif_url
    remove :gif_timeout
  end
end
