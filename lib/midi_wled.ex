defmodule MidiWled do
  @moduledoc """
  MidiWled keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  # @color_values %{red: "FF0000", blue: "0000FF", green: "00FF00", white: "FFFFFF"}
  @light_1_url "http://wled1.local/json"
  @light_2_url "http://wled2.local/json"
  @light_3_url "http://wled3.local/json"
  @light_4_url "http://wled4.local/json"

  def initialize_lights do
    IO.puts("Checking lights on the local network...")

    [1, 2, 3]
    |> Enum.map(&get(&1))
    |> Enum.each(fn light ->
      case light do
        {:ok, _light} -> IO.puts("connected")
        _ -> IO.puts("not connected")
      end
    end)
  end

  def start do
    IO.puts("Starting...")
    Process.sleep(2000)
    IO.puts("Checking available devices...")

    device_map = PortMidi.Devices.list()
    _device_list = Map.get(device_map, :input, [])

    Enum.each(device_map.input, &IO.puts(inspect(&1.name)))

    case Map.get(device_map, :input) do
      [device | _] ->
        IO.puts("Connecting to #{inspect(device.name)}")

        case PortMidi.open(:input, device.name) do
          {:ok, pid} ->
            IO.puts("Listening to #{inspect(device.name)}")
            {:ok, handler_pid} = MidiWled.MidiInputHandler.start_link()
            PortMidi.listen(pid, handler_pid)
            pid

          _ ->
            IO.puts("Error connecting to #{inspect(device.name)}")
        end

      _ ->
        IO.puts("No devices found, please connect a midi device.")
    end
  end

  def post(1, fx) do
    :post
    |> Finch.build(@light_1_url, [], body(fx))
    |> Finch.request(MidiWled.Finch)
  end

  def post(2, fx) do
    :post
    |> Finch.build(@light_2_url, [], body(fx))
    |> Finch.request(MidiWled.Finch)
  end

  def post(3, fx) do
    :post
    |> Finch.build(@light_3_url, [], body(fx))
    |> Finch.request(MidiWled.Finch)
  end

  def post(4, fx) do
    :post
    |> Finch.build(@light_4_url, [], body(fx))
    |> Finch.request(MidiWled.Finch)
  end

  def post_color(1, color) do
    :post
    |> Finch.build(@light_1_url, [], color_body(color))
    |> Finch.request(MidiWled.Finch)
  end

  def post_color(2, color) do
    :post
    |> Finch.build(@light_2_url, [], color_body(color))
    |> Finch.request(MidiWled.Finch)
  end

  def post_color(3, color) do
    :post
    |> Finch.build(@light_3_url, [], color_body(color))
    |> Finch.request(MidiWled.Finch)
  end

  def post_color(4, color) do
    :post
    |> Finch.build(@light_4_url, [], color_body(color))
    |> Finch.request(MidiWled.Finch)
  end

  def post_brightness(1, brightness) do
    :post
    |> Finch.build(@light_1_url, [], brightness_body(brightness))
    |> Finch.request(MidiWled.Finch)
  end

  def post_brightness(2, brightness) do
    :post
    |> Finch.build(@light_2_url, [], brightness_body(brightness))
    |> Finch.request(MidiWled.Finch)
  end

  def post_brightness(3, brightness) do
    :post
    |> Finch.build(@light_3_url, [], brightness_body(brightness))
    |> Finch.request(MidiWled.Finch)
  end

  def post_brightness(4, brightness) do
    :post
    |> Finch.build(@light_4_url, [], brightness_body(brightness))
    |> Finch.request(MidiWled.Finch)
  end

  def get(1) do
    :get
    |> Finch.build(@light_1_url)
    |> Finch.request(MidiWled.Finch)
  end

  def get(2) do
    :get
    |> Finch.build(@light_2_url)
    |> Finch.request(MidiWled.Finch)
  end

  def get(3) do
    :get
    |> Finch.build(@light_3_url)
    |> Finch.request(MidiWled.Finch)
  end

  defp brightness_body(brightness) do
    Jason.encode_to_iodata!(%{bri: brightness})
  end

  defp color_body(color) do
    Jason.encode_to_iodata!(%{
      on: true,
      transition: 7,
      ps: -1,
      pl: -1,
      nl: %{on: false, dur: 60, mode: 1, tbri: 0, rem: -1},
      udpn: %{send: false, recv: true},
      lor: 0,
      mainseg: 0,
      seg: [
        %{
          id: 0,
          start: 0,
          stop: 299,
          len: 299,
          grp: 1,
          spc: 0,
          of: 0,
          on: true,
          frz: false,
          bri: 255,
          cct: 127,
          col: [
            [color.red, color.green, color.blue],
            [color.red, color.green, color.blue],
            [color.red, color.green, color.blue]
          ],
          sel: true,
          rev: false,
          mi: false
        }
      ]
    })
  end

  defp body(-1) do
    Jason.encode_to_iodata!(%{on: false})
  end

  defp body(fx) do
    Jason.encode_to_iodata!(%{
      on: true,
      transition: 7,
      ps: -1,
      pl: -1,
      nl: %{on: false, dur: 60, mode: 1, tbri: 0, rem: -1},
      udpn: %{send: false, recv: true},
      lor: 0,
      mainseg: 0,
      seg: [
        %{
          id: 0,
          start: 0,
          stop: 299,
          len: 299,
          grp: 1,
          spc: 0,
          of: 0,
          on: true,
          frz: false,
          bri: 255,
          cct: 127,
          fx: fx,
          sx: 128,
          ix: 128,
          pal: 0,
          sel: true,
          rev: false,
          mi: false
        }
      ]
    })
  end
end
