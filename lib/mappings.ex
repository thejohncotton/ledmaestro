defmodule MidiWled.Mappings do
  @moduledoc """
  Hard coded mappings for early versions of the application.
  The initial build is going to map some a midi note pitch key down press to a wled effect
  with the naive options of 1 light fixture per octave, currently 4 lights max.
  i.e. -> this is off now but whatever
  {#PID<0.454.0>, [{{157, 5, 100}, 617869}]} => %{light: 1, effect: 1}
  {#PID<0.454.0>, [{{157, 6, 100}, 668795}]} => %{light: 1, effect: 2}
  {#PID<0.454.0>, [{{157, 16, 100}, 668795}]} => %{light: 1, effect: 11}
  {#PID<0.454.0>, [{{157, 17, 100}, 711619}]} => %{light: 2, effect: 1}
  {#PID<0.454.0>, [{{157, 18, 100}, 711619}]} => %{light: 2, effect: 2}
  {#PID<0.454.0>, [{{157, 28, 100}, 711619}]} => %{light: 2, effect: 11}
  {#PID<0.454.0>, [{{157, 29, 100}, 711619}]} => %{light: 3, effect: 1}
  {#PID<0.454.0>, [{{157, 30, 100}, 711619}]} => %{light: 3, effect: 2}
  {#PID<0.454.0>, [{{157, 40, 100}, 711619}]} => %{light: 3, effect: 11}
  {#PID<0.454.0>, [{{157, 41, 100}, 711619}]} => %{light: 4, effect: 1}
  {#PID<0.454.0>, [{{157, 42, 100}, 711619}]} => %{light: 4, effect: 2}
  {#PID<0.454.0>, [{{157, 52, 100}, 711619}]} => %{light: 4, effect: 11}

  In addition to the note mappings will be knob mappings i.e. cc1, cc2, cc3, cc4 which will map to
  a color in a spectrum.
  i.e.
  {#PID<0.454.0>, [{{189, 1, 0}, 832997}]} => %{light: 1, color: 1}
  {#PID<0.454.0>, [{{189, 1, 127}, 867936}]} => %{light: 1, color: 127}
  {#PID<0.454.0>, [{{189, 2, 0}, 914216}]} => %{light: 2, color: 1}
  {#PID<0.454.0>, [{{189, 2, 127}, 961991}]} => %{light: 2, color: 127}
  {#PID<0.454.0>, [{{189, 3, 0}, 914216}]} => %{light: 3, color: 1}
  {#PID<0.454.0>, [{{189, 3, 127}, 961991}]} => %{light: 3, color: 127}
  {#PID<0.454.0>, [{{189, 4, 0}, 914216}]} => %{light: 4, color: 1}
  {#PID<0.454.0>, [{{189, 4, 127}, 961991}]} => %{light: 4, color: 127}

  In a future state these will be configurable via some user interface.
  In a future state, channel info will be configurable, possibly route one light per midi channel

  Effects:
  1. Off (post with :off)
  2. Solid Color (effect # 0)
  3. 9
  4. 10
  5. 11
  6. 12
  7. 5
  8. 28
  9. 33
  10. 38 o
  11. Strobe (Wavesin)

  Honorable mentions for adding later: 101, Waterfall, 55, 65
  """
  # colors
  @black %{red: 0, green: 0, blue: 0}
  @violet %{red: 195, green: 0, blue: 255}
  @purple %{red: 140, green: 0, blue: 255}
  @indigo %{red: 60, green: 0, blue: 255}
  @blue %{red: 0, green: 0, blue: 255}
  @bluegreen %{red: 0, green: 255, blue: 255}
  @green %{red: 0, green: 255, blue: 0}
  @greenyellow %{red: 100, green: 255, blue: 0}
  @yellow %{red: 255, green: 255, blue: 0}
  @orange %{red: 255, green: 136, blue: 0}
  @pink %{red: 255, green: 0, blue: 255}
  @red %{red: 255, green: 0, blue: 0}
  @white %{red: 255, green: 255, blue: 255}
  # Effects
  # Off (post with :off),
  @effects %{
    off: -1,
    # Solid Color (effect # 0),
    solid: 0,
    rainbow: 9,
    scanner: 40,
    stream_2: 61,
    oscillate: 62,
    random_colors: 5,
    lake: 75,
    meteor: 76,
    aurora: 10,
    # (Gradient)
    strobe: 46
    # TODO: Add 12th effect
  }
  @effect_mappings %{
    1 => @effects.off,
    2 => @effects.solid,
    3 => @effects.rainbow,
    4 => @effects.scanner,
    5 => @effects.stream_2,
    6 => @effects.oscillate,
    7 => @effects.random_colors,
    8 => @effects.lake,
    9 => @effects.meteor,
    10 => @effects.aurora,
    11 => @effects.strobe
    # TODO: add 12th mapping
  }

  def midi_to_wled({pid, messages}) when length(messages) > 1 do
    [message | _] = Enum.reverse(messages)
    midi_to_wled({pid, [message]})
  end

  def midi_to_wled({_pid, [{{189, knob_num, cc_val}, _timestamp}]}) when knob_num in 1..4 do
    # Set in memory color value based on cc_val per light
    # these only match up because the knobs are 1-4
    light_num = knob_num
    color = calculate_color(cc_val)
    MidiWled.post_color(light_num, color)
  end

  def midi_to_wled({_pid, [{{189, knob_number, cc_val}, _timestamp}]}) when knob_number in 5..8 do
    # offset light number from knob number
    light_num = knob_number - 4
    brightness = cc_val |> calculate_brightness() |> IO.inspect(label: "#{__MODULE__}75")
    MidiWled.post_brightness(light_num, brightness)
  end

  ## For The OP-Z the lowest note on the keyboard starts with 17 which is octave 2

  def midi_to_wled({_pid, [{{157, note_val, 100}, _timestamp}]}) when note_val in 17..28 do
    # Send post Req with note_val mapped to an effect, light color or pallette is based on in memory state
    # for light 1
    adjusted_note_val = note_val - 16
    effect = @effect_mappings[adjusted_note_val]
    MidiWled.post(1, effect)
  end

  def midi_to_wled({_pid, [{{157, note_val, 100}, _timestamp}]}) when note_val in 29..40 do
    # Send post Req with note_val mapped to an effect, light color or pallette is based on in memory state
    # for light 2
    adjusted_note_val = note_val - 28
    effect = @effect_mappings[adjusted_note_val]
    MidiWled.post(2, effect)
    IO.puts("handle light 2 octave 3")
  end

  def midi_to_wled({_pid, [{{157, note_val, 100}, _timestamp}]}) when note_val in 41..52 do
    # Send post Req with note_val mapped to an effect, light color or pallette is based on in memory state
    # for light 3
    adjusted_note_val = note_val - 40
    effect = @effect_mappings[adjusted_note_val]
    MidiWled.post(3, effect)
    IO.puts("handle light 3 octave 4")
  end

  def midi_to_wled({_pid, [{{157, note_val, 100}, _timestamp}]}) when note_val in 53..65 do
    # Send post Req with note_val mapped to an effect, light color or pallette is based on in memory state
    # for light 4
    adjusted_note_val = note_val - 52
    effect = @effect_mappings[adjusted_note_val]
    MidiWled.post(4, effect)
    IO.puts("handle light 4 octave 5")
  end

  def midi_to_wled({_pid, [{{157, note_val, 100}, _timestamp}]}) when note_val in 53..64 do
    # Send post Req with note_val mapped to an effect, light color or pallette is based on in memory state
    # for light 5
  end

  def midi_to_wled({_pid, [{{141, note_val, 100}, _timestamp}]}) when note_val in 65..76 do
    # Send post Req with note_val mapped to an effect, light color or pallette is based on in memory state
    # for light 6
  end

  def midi_to_wled({_pid, [{{141, note_val, 100}, _timestamp}]}) when note_val in 77..88 do
    # Send post Req with note_val mapped to an effect, light color or pallette is based on in memory state
    # for light 7
  end

  def midi_to_wled({_pid, [{{141, note_val, 100}, _timestamp}]}) when note_val in 89..100 do
    # Send post Req with note_val mapped to an effect, light color or pallette is based on in memory state
    # for light 8
  end

  def midi_to_wled({_pid, [{{141, note_val, 100}, _timestamp}]}) when note_val in 101..112 do
    # Send post Req with note_val mapped to an effect, light color or pallette is based on in memory state
    # for light 9
  end

  def midi_to_wled({_pid, [{{141, _note_val, _100}, _timestamp}]}) do
    :ok
  end

  def midi_to_wled(_) do
    :ok
  end

  defp calculate_brightness(cc_val) do
    cond do
      cc_val <= 5 -> 5
      cc_val <= 10 -> 15
      cc_val <= 25 -> 25
      cc_val <= 40 -> 80
      cc_val <= 50 -> 100
      cc_val <= 60 -> 180
      cc_val <= 70 -> 195
      cc_val <= 90 -> 210
      cc_val <= 110 -> 220
      true -> 255
    end
  end

  defp calculate_color(cc_val) do
    cond do
      cc_val <= 10 -> @black
      cc_val <= 20 -> @violet
      cc_val <= 30 -> @purple
      cc_val <= 40 -> @indigo
      cc_val <= 50 -> @blue
      cc_val <= 60 -> @bluegreen
      cc_val <= 70 -> @green
      cc_val <= 80 -> @greenyellow
      cc_val <= 90 -> @yellow
      cc_val <= 100 -> @orange
      cc_val <= 110 -> @pink
      cc_val <= 119 -> @red
      true -> @white
    end
  end
end
