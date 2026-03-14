import Config

# This file is loaded at runtime for all environments.
# It's the perfect place to load secrets from a .env file for development
# or from OS environment variables for production.

if config_env() == :dev do
  dotenv_path = Path.expand("../.env", __DIR__)

  if File.exists?(dotenv_path) do
    env_vars =
      File.read!(dotenv_path)
      |> String.split("\n", trim: true)
      |> Enum.reject(&(&1 == "" || String.starts_with?(&1, "#")))
      |> Enum.map(&String.split(&1, "=", parts: 2))
      |> Enum.into(%{}, fn [key, value] ->
        cleaned_value = value |> String.trim() |> String.trim("\"") |> String.trim("'")
        {key, cleaned_value}
      end)

    gemini_key = Map.get(env_vars, "GEMINI_API_KEY")
    tmdb_key = Map.get(env_vars, "TMDB_API_KEY")

    if gemini_key do
      config :say_less, :gemini_api_key, gemini_key
    end

    if tmdb_key do
      config :say_less, :tmdb_api_key, tmdb_key
    end
  else
    IO.puts(:stderr, "[Warning] .env file not found at #{dotenv_path}")
  end
end

if config_env() == :prod do
  gemini_key = System.get_env("GEMINI_API_KEY") ||
    raise "Environment variable GEMINI_API_KEY is missing for production."

  tmdb_key = System.get_env("TMDB_API_KEY") ||
    raise "Environment variable TMDB_API_KEY is missing for production."

  config :say_less, :gemini_api_key, gemini_key
  config :say_less, :tmdb_api_key, tmdb_key

  secret_key_base = System.get_env("SECRET_KEY_BASE") ||
    raise "Environment variable SECRET_KEY_BASE is missing."

  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :say_less, SayLessWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [ip: {0, 0, 0, 0, 0, 0, 0, 0}, port: port],
    secret_key_base: secret_key_base

  if System.get_env("PHX_SERVER") do
    config :say_less, SayLessWeb.Endpoint, server: true
  end
end
