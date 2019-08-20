defmodule Airtable.MixProject do
  use Mix.Project

  def project do
    [
      app: :airtable,
      version: "0.2.1",
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Airtable.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  def description do
    """
    An API wrapper for Airtable's REST API to base your specific client on.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE", "test"],
      maintainers: ["Martin Dobberstein (Gutsch)"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/gutschilla/elixir_airtable_client"
      }
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:mojito, "~> 0.3.0"},
      {:jason, "~> 1.1"}
    ]
  end
end
