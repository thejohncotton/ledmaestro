defmodule MidiWled.MixProject do
  use Mix.Project

  def project do
    [
      app: :midi_wled,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {MidiWled.Application, [:start]},
      application: [:portmidi],
      extra_applications: [:logger]
    ]
  end

  def releases do
    [
      example_cli_app: [
        steps: [:assemble, &Burrito.wrap/1],
        burrito: [
          targets: [
            macos: [os: :darwin, cpu: :x86_64],
            linux: [os: :linux, cpu: :x86_64]
          ]
        ]
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:styler, "~> 0.8", only: [:dev, :test], runtime: false},
      {:portmidi, git: "https://github.com/Kovak/ex-portmidi/", tag: "5.1.2"},
      # {:portmidi, "5.1.1"},
      {:jason, "~> 1.2"},
      {:finch, "~> 0.13"},
      {:burrito, github: "burrito-elixir/burrito"}
    ]
  end
end
