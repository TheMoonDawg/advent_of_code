defmodule Aoc.MixProject do
  use Mix.Project

  def project do
    [
      app: :aoc,
      version: "0.2.0",
      elixir: "~> 1.19.3",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [{:nx, "~> 0.10"}]
  end
end
