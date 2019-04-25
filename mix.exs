defmodule Shopify.Mixfile do
  use Mix.Project

  @version "0.1.0"

  def project do
    [app: :shopify,
     version: @version,
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger, :oauth2]]
  end

  defp deps do
    [
      {:bypass, "~> 0.6.0", only: :test},
      {:oauth2, "~> 0.9"},
      {:poison, "~> 3.0"},
    ]
  end
end
