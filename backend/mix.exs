defmodule SayLess.MixProject do
  use Mix.Project

  def project do
    [
      app: :say_less,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # This function defines the main application module.
  # Phoenix applications have a "supervisor" that starts all necessary processes.
  def application do
    [
      mod: {SayLess.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile for different environments.
  # For :test, it includes test-specific helpers.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # These are the project's dependencies.
  # `mix deps.get` will fetch these from the Hex package manager.
  defp deps do
    [
      {:phoenix, "~> 1.7.12"},
      {:jason, "~> 1.4"}, # A fast Elixir JSON library [11][17]
      {:httpoison, "~> 2.0"}, # HTTP client for making requests to external APIs [4]
      {:plug_cowboy, "~> 2.5"}
    ]
  end

  # Aliases provide shortcuts for common tasks.
  defp aliases do
    [
      # setup: ["deps.get"], # Example alias
      # test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
