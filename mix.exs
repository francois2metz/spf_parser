defmodule SpfParser.MixProject do
  use Mix.Project

  def project do
    [
      app: :spf_parser,
      version: "0.1.0",
      elixir: "~> 1.14",
      description: description(),
      package: package(),
      source_url: "https://github.com/francois2metz/spf_parser",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:abnf_parsec, "~> 1.0", runtime: false}
    ]
  end

  defp description() do
    "Parse the Sender Policy Framework (SPF) as defined in the RFC 7208."
  end

  defp package() do
    [
      licenses: ["MIT"],
      links: %{}
    ]
  end
end
