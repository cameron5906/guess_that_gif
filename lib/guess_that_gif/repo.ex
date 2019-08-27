defmodule GuessThatGif.Repo do
  use Ecto.Repo,
    otp_app: :guess_that_gif,
    adapter: Ecto.Adapters.Postgres
end
