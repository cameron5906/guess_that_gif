defmodule Repo.Migrations.AddGameFieldsGifUrlGifTimeout do
  use Ecto.Migration

  def change do
    alter table "game" do
      add :gif_url, :string
      add :gif_timeout, :integer
    end
  end
end
