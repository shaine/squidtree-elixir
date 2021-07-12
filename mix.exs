defmodule Squidtree.MixProject do
  use Mix.Project

  def project do
    [
      app: :squidtree,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_paths: ["lib"]
      # test_paths: ["test"]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Squidtree.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:credo, "~> 1.2.0", only: [:dev, :test], runtime: false},
      {:css_colors, "~> 0.2.2"},
      {:earmark, "~> 1.2"},
      # {:ex2ms, "~> 1.0"}, For advanced ETS table queries
      {:gettext, "~> 0.11"},
      {:html_sanitize_ex, "~> 1.3.0-rc3"},
      {:jason, "~> 1.0"},
      {:phoenix, "~> 1.5.3"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_dashboard, "~> 0.2.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:plug_cowboy, "~> 2.0"},
      {:postgrex, ">= 0.0.0"},
      {:slugify, "~> 1.3"},
      {:sobelow, "~> 0.8", only: [:dev, :test]},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:timex, "~> 3.6.2"},
      {:yaml_elixir, "~> 2.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "cmd npm install --prefix assets"],
      test: ["test"],
      validate: ["sobelow --config", "format", "credo --strict", "cmd mix test"]
    ]
  end
end
