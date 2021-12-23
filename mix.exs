defmodule CommandedJson.MixProject do
  use Mix.Project

  def project do
    [
      app: :commanded_json,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {CommandedJson.Application, []},
      extra_applications: [:logger, :runtime_tools, :crypto]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.3"},
      {:commanded, "~> 1.3"},
      {:commanded_eventstore_adapter, "~> 1.2"},
      {:benchee, "~> 1.0"}
    ]
  end
end
