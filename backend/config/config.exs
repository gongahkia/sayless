import Config

# Configure the Phoenix endpoint.
# The `url` and `secret_key_base` will be overridden in environment-specific configs.
config :say_less, SayLessWeb.Endpoint,
  server: [port: 4000],
  url: [host: "localhost", port: 4000],
  render_errors: [
    formats: [json: SayLessWeb.V1.ErrorView], # Use our custom error view for JSON
    layouts: false
  ],
  pubsub_server: SayLess.PubSub,
  live_view: [signing_salt: "some-long-and-random-string"]

# Configure Phoenix to use the Jason library for all JSON encoding and decoding.
# This is the corrected line.
config :phoenix, :json_library, Jason

# Import the configuration specific to the current environment.
# For example, when running `mix phx.server`, this will import `config/dev.exs`.
import_config "#{Mix.env()}.exs"
