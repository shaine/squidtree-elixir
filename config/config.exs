# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :squidtree,
  ecto_repos: [Squidtree.Repo]

# Configures the endpoint
config :squidtree, SquidtreeWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "qnO6EnrvramdPoa7dMqgyggJf3ZkH7lq43i/v23ApQC9cYmzuW+K4Uac4dQ5+bmk",
  render_errors: [view: SquidtreeWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Squidtree.PubSub,
  live_view: [signing_salt: "kDrr+h6B"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
