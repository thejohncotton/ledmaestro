defmodule MidiWled.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    children = [
      # Start Finch
      {Finch,
       name: MidiWled.Finch,
       pools: %{
         :default => [size: 32],
         "http://wled1.local" => [size: 32, count: 127],
         "http://wled2.local" => [size: 32, count: 127],
         "http://wled3.local" => [size: 32, count: 127],
         "http://wled4.local" => [size: 32, count: 127]
       }}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MidiWled.Supervisor]
    # Hacky, start our midi service
    MidiWled.start()
    Supervisor.start_link(children, opts)
  end
end
