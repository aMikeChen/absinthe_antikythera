defmodule Absinthe.Antikythera.MixProject do
  use Mix.Project

  def project do
    [
      app: :absinthe_antikythera,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:absinthe, "~> 1.4.0"},
      {:absinthe_relay, "~> 1.4"},
      {:croma, "0.10.2"}
    ]
  end
end
