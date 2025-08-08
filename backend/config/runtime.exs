import Config

# This file is loaded at runtime for all environments.
# It's the perfect place to load secrets from a .env file for development
# or from OS environment variables for production.

if config_env() == :dev do
  # --- Development Environment Logic ---
  # Construct the full path to the .env file in your `backend` directory.
  dotenv_path = Path.expand("../.env", __DIR__)

  if File.exists?(dotenv_path) do
    # Use Dotenvy.parse to read the file directly into a map.
    # This is more reliable than loading into the OS environment.
    env_vars = Dotenvy.parse(dotenv_path)

    # Get the specific key we need from the parsed map.
    gemini_key = Map.get(env_vars, "GEMINI_API_KEY")

    # Set the application configuration ONLY if the key was found.
    if gemini_key do
      config :say_less, :gemini_api_key, gemini_key
    end
  else
    # This warning helps if the .env file is missing.
    IO.puts(:stderr, "[Warning] .env file not found at #{dotenv_path}")
  end
end

if config_env() == :prod do
  # --- Production Environment Logic ---
  # In production, we read directly from OS environment variables.
  gemini_key = System.get_env("GEMINI_API_KEY") ||
    raise "Environment variable GEMINI_API_KEY is missing for production."

  config :say_less, :gemini_api_key, gemini_key

  # Configure the Phoenix endpoint for production.
  secret_key_base = System.get_env("SECRET_KEY_BASE") ||
    raise "Environment variable SECRET_KEY_BASE is missing."

  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  # Note: The application name is :say_less, not :backend.
  config :say_less, SayLessWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [ip: {0, 0, 0, 0, 0, 0, 0, 0}, port: port],
    secret_key_base: secret_key_base

  # Enable the server if the PHX_SERVER env var is set.
  if System.get_env("PHX_SERVER") do
    config :say_less, SayLessWeb.Endpoint, server: true
  end
end
