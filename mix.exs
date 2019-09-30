defmodule EslScrapingBench.MixProject do
  use Mix.Project

  def project do
    [
      app: :esl_scraping_bench,
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
      {:benchee, "~> 1.0.1"},
      {:floki, "~> 0.22.0"},
      {:meeseeks, "~> 0.14.0"}
    ]
  end
end
