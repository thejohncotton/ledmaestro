defmodule MidiWled.MidiInputHandler do
  @moduledoc false
  alias MidiWled.Mappings

  require Logger

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, opts},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  # Client implementation
  #######################

  def register, do: GenServer.cast(__MODULE__, {:register})

  # Server implementation
  #######################

  def init(:ok), do: {:ok, {%{}, %{}}}

  def handle_info({_pid, []}, state) do
    # Ignore empty messages
    {:noreply, state}
  end

  #  {_pid [{{_, effect, 100}, _timestamp}]}
  # def handle_info({_pid, [{{_, effect, 100}, _timestamp}]} = msg, state) do
  #   MidiWled.post(1, effect)
  #   IO.puts("Logging things:  " <> inspect(msg))
  #   {:noreply, state}
  # end
  def handle_info({_pid, [_ | _]} = msg, state) do
    Mappings.midi_to_wled(msg)
    # IO.puts("Logging things:  " <> inspect(msg))

    {:noreply, state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  def terminate(reason, _), do: Logger.error(reason)

  # Private implementation
  ########################

  def do_update_listeners(listeners, pid) do
    Enum.reduce(listeners, %{}, fn {input, listeners}, acc ->
      Map.put(acc, input, do_find_new_listeners(listeners, pid))
    end)
  end

  def do_find_new_listeners(listeners, pid) do
    Enum.reject(listeners, &(&1 == pid))
  end
end
