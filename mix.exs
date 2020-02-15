defmodule SpandexRedix.MixProject do
  use Mix.Project

  def project do
    [
      app: :spandex_redix,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Tracing integration between redix and spandex",
      package: package(),
      name: "SpandexRedix",
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      maintainers: ["Thiago Santos"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/thiamsantos/spandex_redix"}
    ]
  end

  defp docs do
    [
      main: "SpandexRedix",
      source_url: "https://github.com/thiamsantos/spandex_redix"
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:spandex, "~> 2.2", optional: true},
      {:mox, "~> 0.5", only: :test},
      {:ex_doc, "~> 0.21.3", only: :dev, runtime: false}
    ]
  end
end
