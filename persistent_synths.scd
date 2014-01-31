(
[

  // ****************************************** MONITORING

  [\sax_mon, Synth(\mon,
    [ \main, \met, \sax, \tub, \drum, \com ].collect({|input|
      [asSymbol(input++"_scale"), ~monitor_levels[\sax][input]]
    }).flat ++
    [
      \metranome_bus, ~buss[\metranome],
      \inbus, ~buss[\sax_mon],
      \outbus, ~id_bus_map[\sax_mon_out],
    ],
    ~out_g )],

  [\tub_mon, Synth(\mon,
    [ \main, \met, \sax, \tub, \drum, \com ].collect({|input|
      [asSymbol(input++"_scale"), ~monitor_levels[\tub][input]]
    }).flat ++
    [
      \metranome_bus, ~buss[\metranome],
      \inbus, ~buss[\tub_mon],
      \outbus, ~id_bus_map[\tub_mon_out],
    ],
    ~out_g )],

  [\drums_mon, Synth(\mon,
    [ \main, \met, \sax, \tub, \drum, \com ].collect({|input|
      [asSymbol(input++"_scale"), ~monitor_levels[\drums][input]]
    }).flat ++
    [
      \metranome_bus, ~buss[\metranome],
      \inbus, ~buss[\drums_mon],
      \outbus, ~id_bus_map[\drums_mon_out],
    ],
    ~out_g )],

  [\com_mon, Synth(\mon,
    [ \main, \met, \sax, \tub, \drum, \com ].collect({|input|
      [asSymbol(input++"_scale"), ~monitor_levels[\com][input]]
    }).flat ++
    [
      \metranome_bus, ~buss[\metranome],
      \inbus, ~buss[\sax_mon],
      \outbus, ~id_bus_map[\com_mon_out],
    ],
    ~out_g )],

  [\nugs_mon, Synth(\mon,
    [ \main, \met, \sax, \tub, \drum, \com ].collect({|input|
      [asSymbol(input++"_scale"), ~monitor_levels[\nugs][input]]
    }).flat ++
    [
      \metranome_bus, ~buss[\metranome],
      \inbus, ~buss[\nugs_mon],
      \outbus, ~id_bus_map[\nugs_mon_out],
    ],
    ~out_g )],

  // ****************************************** HORNS

  [\sax_info, Synth(\sax_info, [\inbus, ~id_bus_map[\sax], \outbus, ~buss[\sax_info] ], ~in_g)],

  [\tub_info, Synth(\tuba_info, [\inbus, ~id_bus_map[\tub], \outbus, ~buss[\tub_info] ], ~in_g)],

  [\sax_in, Synth(\sax_in, [\inbus, ~id_bus_map[\sax], \outbus, ~buss[\sax_eq] ], ~in_g)],

  [\tub_in, Synth(\tuba_in, [\inbus, ~id_bus_map[\tub], \outbus, ~buss[\tub_eq] ], ~in_g)],

  [\sax_eq, Synth(\sax_eq, [\inbus, ~buss[\sax_eq], \outbus, ~buss[\sax_agg] ], ~eq_g)],

  [\tub_eq, Synth(\tub_eq, [\inbus, ~buss[\tub_eq], \outbus, ~buss[\tub_agg]], ~eq_g)],

  [\tub_v, Synth(\v_control, [\outbus, ~buss[\tub_v], \amp, 127], ~in_g)],

  [\sax_v, Synth(\v_control, [\outbus, ~buss[\sax_v], \amp, 0], ~in_g)],

  [\tub_p, Synth(\p_control_lag, [\outbus, ~buss[\tub_p], \param, 0], ~in_g)],

  [\sax_p, Synth(\p_control_lag, [\outbus, ~buss[\sax_p], \param, 0], ~in_g)],


  // ****************************************** LOOPING

  [\sax, \tub].collect {|instr|
    4.collect {|i|
      [asSymbol(instr ++ "_loop_route_" ++ i), Synth(\route_mono,
        [\inbus, ~loop_filt_buss[instr], \outbus, ~buss[asSymbol(isntr ++ "_agg")]],
        ~route_loop_g)]
    },
  },

  // ****************************************** CORE

  [\beat_dur, Synth(\p_control,
    [\outbus, ~buss[\beat_dur], \value, ~clock.beatDur], ~data_g)],

  [\agg, Synth(\agg,
    [
      \sax_bus,       ~buss[\sax_agg],
      \tub_bus,       ~buss[\tub_agg],
      \com_bus,       ~buss[\com_agg],

      \d_low_bus,     ~buss[\d_low_bus],
      \d_med_bus,     ~buss[\d_med_bus],
      \d_hi_bus,      ~buss[\d_hi_bus],

      \drums_mon_bus, ~buss[\drums_mon],
      \nugs_mon_bus,  ~buss[\nugs_mon],
      \tub_mon_bus,   ~buss[\tub_mon],
      \sax_mon_bus,   ~buss[\sax_mon],
      \com_mon_bus,   ~buss[\com_mon],

      \metranome_bus, ~buss[\metranome],
      \sample_bus,    ~buss[\sample],

      \outbus,        ~buss[\one_out]
    ],
    ~agg_g
  )],

  [\out_left, Synth(\route_mono,
    [\inbus, ~buss[\one_out], \outbus, ~id_bus_map[\main_out_0]], ~out_g)],

  [\ambient_in, Synth(\route_mono,
    [\inbus, ~id_bus_map[\ambient], \outbus, ~buss[\one_out]], ~record_g)]

].flat.do {|pair| ~p_synths.add(pair[0] -> pair[1]) };

"PERSISTENT SYNTHS LOADED".postln;
)
