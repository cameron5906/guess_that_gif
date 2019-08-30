defmodule Repo.Migrations.AddPlayerSession do
    use Ecto.Migration
  
    def change do
      alter table "player" do
        add :session, :string
      end
    end
  end
  