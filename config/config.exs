# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :guess_that_gif,
  ecto_repos: [GuessThatGif.Repo]

# Configures the endpoint
config :guess_that_gif, GuessThatGifWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "ZTUmpsjuDTRGyF4M7lZ2aWwDr9tc9BweNgHaSrRP2h9h+j5a26qQE6qZhMD54208",
  render_errors: [view: GuessThatGifWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: GuessThatGif.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
