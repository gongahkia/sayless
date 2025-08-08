# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration

import Config

# Configures the endpoint
config :say_less, SayLessWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [json: SayLessWeb.V1.ErrorView], # We will need to re-add this custom view
    layout: false
  ],
  pubsub_server: SayLess.PubSub, # Changed from Backend.PubSub
  live_view: [signing_salt: "jmJxfmdT"]

# Configures Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
