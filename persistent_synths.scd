~pSynths.putPairs(flat([

  // ****************************************** MONITORING

  ["sax", "tub", "drums", "nugs", "com"].collect({|instr|
    [
      asSymbol(instr ++ "_mon"),
      Synth(\mon,
        [ \main, \met, \sax, \tub, \drum, \com ].collect({|input|
          [asSymbol(input++"_scale"), ~monitorLevels[asSymbol(instr)][input]]
        }).flat ++
        [
          \metronome_bus, ~buss[\metronome],
          \inbus, ~buss[\monitor],
          \outbus, ~id_bus_map[asSymbol(instr ++ "_mon_out")]
        ],
        ~out_g
      )
    ]
  }),

  // ****************************************** HORNS

  \sax_info, Synth(\sax_info, [\inbus, ~id_bus_map[\sax], \outbus, ~buss[\sax_info] ], ~in_g),

  \tub_info, Synth(\tuba_info, [\inbus, ~id_bus_map[\tub], \outbus, ~buss[\tub_info] ], ~in_g),

  \sax_in, Synth(\sax_in, [\inbus, ~id_bus_map[\sax], \contactGateBus, ~id_bus_map[\sax_contact_in], \outbus, ~buss[\sax_eq] ], ~in_g),

  \tub_in, Synth(\tuba_in, [\inbus, ~id_bus_map[\tub], \outbus, ~buss[\tub_eq] ], ~in_g),

  \sax_eq, Synth(\sax_eq, [\inbus, ~buss[\sax_eq], \outbus, ~buss[\sax_agg] ], ~eq_g),

  \tub_eq, Synth(\tub_eq, [\inbus, ~buss[\tub_eq], \outbus, ~buss[\tub_agg]], ~eq_g),

  \tub_v, Synth(\v_control, [\outbus, ~buss[\tub_v], \amp, 127], ~in_g),

  \sax_v, Synth(\v_control, [\outbus, ~buss[\sax_v], \amp, 0], ~in_g),

  \tub_p, Synth(\p_control_lag, [\outbus, ~buss[\tub_p], \param, 0], ~in_g),

  \sax_p, Synth(\p_control_lag, [\outbus, ~buss[\sax_p], \param, 0], ~in_g),

  // ****************************************** CORE

  \agg, Synth(\agg,
    [
      \sax_bus,       ~buss[\sax_agg],
      \tub_bus,       ~buss[\tub_agg],
      \com_bus,       ~buss[\com_agg],

      \d_low_bus,     ~buss[\d_low_bus],
      \d_med_bus,     ~buss[\d_med_bus],
      \d_hi_bus,      ~buss[\d_hi_bus],

      \monitor_bus,   ~buss[\monitor],

      \tuba_record_bus,      ~multi_record_buss[\tuba],
      \sax_record_bus,       ~multi_record_buss[\sax],
      \computer_record_bus,  ~multi_record_buss[\computer],
      \drums_hi_record_bus,  ~multi_record_buss[\drums_hi],
      \drums_med_record_bus, ~multi_record_buss[\drums_med],
      \drums_low_record_bus, ~multi_record_buss[\drums_low],

      \sample_bus,    ~buss[\sample],

      \outbus,        ~buss[\one_out]
    ],
    ~agg_g
  ),

  \out_left, Synth(\route_mono,
    [\inbus, ~buss[\one_out], \outbus, ~id_bus_map[\main_out_0]], ~out_g),

// ****************************************** LOOPING

  \sax_loop_sum,
  Synth(\sax_loop_sum,
    [\inbusses, ~loop_filt_buss[\sax], \outbus, ~loop_filt_buss[\sax_loops]],
    ~sum_loop_g),

  \tub_loop_sum,
  Synth(\route_4_chans_to_mono,
    [\inbusses, ~loop_filt_buss[\tub], \outbus, ~loop_filt_buss[\tub_loops]],
    ~sum_loop_g),

  // only one com loop
  \com_loop_sum,
  Synth(\route_mono_amp,
    [\inbus, ~loop_filt_buss[\com], \outbus, ~loop_filt_buss[\com_loops]],
    ~sum_loop_g),

  \sax_loops_route,
  Synth(\route_mono_amp,
    [\inbus, ~loop_filt_buss[\sax_loops], \outbus, ~buss[\sax_agg]],
    ~route_loop_g),

  \tub_loops_route,
  Synth(\route_mono_amp,
    [\inbus, ~loop_filt_buss[\tub_loops], \outbus, ~buss[\tub_agg]],
    ~route_loop_g),

  \com_loops_route,
  Synth(\route_mono_amp,
    [\inbus, ~loop_filt_buss[\com_loops], \outbus, ~buss[\com_agg]],
    ~route_loop_g),

// ****************************************** ANALOG TRIGGERS

  \kick_drum_listener,
  Synth(\drumTrigListener,
    [\inbus, ~id_bus_map[\mars_kick_in], \outbus, ~buss[\mars_kick_trig]],
    ~in_g),

  \mars_kick_player,
  Synth(\triggeredPlayBuf,
    [
      \trigbus, ~buss[\mars_kick_trig],
      \outbus, ~buss[\low],
      \buf, ~mars_sample_sets[~current_set][8]
    ],
    ~synth_g)

]));

"PERSISTENT SYNTHS LOADED".postln;
