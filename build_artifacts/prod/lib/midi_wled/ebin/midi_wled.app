{application,midi_wled,
             [{applications,[kernel,stdlib,elixir,logger,portmidi,jason,finch,
                             burrito]},
              {description,"midi_wled"},
              {modules,['Elixir.MidiWled','Elixir.MidiWled.Application',
                        'Elixir.MidiWled.Mappings',
                        'Elixir.MidiWled.MidiInputHandler']},
              {registered,[]},
              {vsn,"0.1.0"},
              {mod,{'Elixir.MidiWled.Application',[start]}}]}.
