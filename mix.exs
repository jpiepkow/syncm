defmodule SyncM.MixProject do
  use Mix.Project

  def project do
    [
      app: :sync_m,
      version: "0.1.1",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description:
        "SyncM helps by setting up an interface to dynamically sync mnesia across nodes. Mnesia nodes are added to 
        the schema dynamically when started and copy over existing tables from another node member.",
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {SyncM.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
  defp package do
    [
      maintainers: ["Jordan Piepkow"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/jpiepkow/syncm"}
    ]
  end
end
