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

  def application do
    [
      mod: {SayLess.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(_), do: ["say_less", "say_less_web"]

  defp deps do
    [
      {:phoenix, "~> 1.7.12"},
      # This is the key fix. By explicitly listing phoenix_pubsub, we ensure
      # it's compiled before our application tries to use it.
      {:phoenix_pubsub, "~> 2.1"},
      {:jason, "~> 1.4"},
      {:httpoison, "~> 2.0"},
      {:plug_cowboy, "~> 2.5"}
    ]
  end

  defp aliases do
    []
  end
end
