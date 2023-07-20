defmodule MidiWled.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    children = [
      # Start Finch
      {Finch, name: MidiWled.Finch}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MidiWled.Supervisor]
    # Hacky, start our midi service
    MidiWled.start()
    Supervisor.start_link(children, opts)
  end
end
