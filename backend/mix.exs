defmodule SayLess.MixProject do
  use Mix.Project

  def project do
    [
      app: :say_less,
      version: "0.1.0",
      elixir: "~> 1.14",
      # This is the key change: we point the compiler to the correct source directory.
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

  # We tell the compiler to look in the `say_less` and `say_less_web` directories.
  defp elixirc_paths(_), do: ["say_less", "say_less_web"]

  defp deps do
    [
      {:phoenix, "~> 1.7.12"},
      {:jason, "~> 1.4"},
      {:httpoison, "~> 2.0"},
      {:plug_cowboy, "~> 2.5"}
    ]
  end

  defp aliases do
    []
  end
end
