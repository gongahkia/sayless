import Config

# Configure the development endpoint.
# `secret_key_base` should be unique and long for security.
config :say_less, SayLessWeb.Endpoint,
  # This secret is for development only. Production should have its own.
  secret_key_base: "aVeryLongAndRandomStringForDevelopmentThatIsAtLeast64BytesLong",
  http: [port: 4000],
  # Enables live reloading of code in development for a faster workflow.
  code_reloader: true,
  debug_errors: true,
  check_origin: false,
  watchers: [
    node: ["esbuild.js", "--watch", cd: Path.expand("../assets", __DIR__)]
  ]

# Configure your application's custom keys.
# This is where we securely load the Gemini API key from an environment variable.
# To run the app, you will need to set this variable in your shell:
# export GEMINI_API_KEY="your_actual_api_key_here"
config :say_less,
  gemini_api_key: System.get_env("GEMINI_API_KEY")

# Configure the logger to show more detailed information in development.
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]
