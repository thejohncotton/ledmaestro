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
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:styler, "~> 0.8", only: [:dev, :test], runtime: false},
      {:portmidi, git: "https://github.com/Kovak/ex-portmidi/", tag: "5.1.2"},
      # {:portmidi, "5.1.1"},
      {:jason, "~> 1.2"},
      {:finch, "~> 0.13"}
    ]
  end
end
