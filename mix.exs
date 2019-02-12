defmodule Telnet.MixProject do
  use Mix.Project

  def project do
    [
      app: :telnet,
      version: "1.0.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Telnet.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:distillery, "~> 2.0", runtime: false},
      {:jason, "~> 1.1"},
      {:libcluster, "~> 3.0"},
      {:sentry, "~> 7.0"},
      {:telemetry, "~> 0.3"},
    ]
  end
end
