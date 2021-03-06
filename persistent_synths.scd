"Loading persistent synths...".postln;
{
  var outputChannelNames = [\sax, \drums, \nugs, \com];
  var inputChannelNames = [\main, \met, \bass, \sax, \drum, \com];

  "Loading Monitor synths...".post;

  outputChannelNames.do({ |outputChannelName|
    var synthName = asSymbol(outputChannelName ++ "_mon");
    var synth, inputChannelArguments, otherArguments, arguments;
    var thisMonitorLevels = ~monitorLevels[outputChannelName];

    inputChannelArguments = inputChannelNames.collect({ |inputChannelName|
      var argumentName = asSymbol(inputChannelName ++ "_scale");

      [argumentName, thisMonitorLevels[inputChannelName]];
    }).flat;

    otherArguments = [
      \metronome_bus, ~buss[\metronome],
      \inbus, ~buss[\monitor],
      \outbus, ~id_bus_map[asSymbol(outputChannelName ++ "_mon_out")]
    ];

    arguments = inputChannelArguments ++ otherArguments;

    synth = Synth(\mon, arguments, ~out_g);
    ~pSynths.put(synthName, synth);
  });

  "done".postln;
}.value;

~pSynths.putPairs(flat([

  // ****************************************** HORNS

  \sax_info, Synth(\sax_info, [\inbus, ~id_bus_map[\sax], \outbus, ~buss[\sax_info] ], ~in_g),

  \sax_in, Synth(\sax_in, [\inbus, ~id_bus_map[\sax], \contactGateBus, ~id_bus_map[\sax_contact_in], \outbus, ~buss[\sax_eq] ], ~in_g),

  \sax_eq, Synth(\sax_eq, [\inbus, ~buss[\sax_eq], \outbus, ~buss[\sax_agg] ], ~eq_g),

  \sax_v, Synth(\v_control, [\outbus, ~buss[\sax_v], \amp, 0], ~in_g),

  \sax_p, Synth(\p_control_lag, [\outbus, ~buss[\sax_p], \param, 0], ~in_g),

  // ****************************************** CORE

  \agg, Synth(\agg,
    [
      \sax_bus,       ~buss[\sax_agg],
      \bass_bus,       ~buss[\bass_agg],
      \com_bus,       ~buss[\com_agg],

      \d_low_bus,     ~buss[\d_low_bus],
      \d_med_bus,     ~buss[\d_med_bus],
      \d_hi_bus,      ~buss[\d_hi_bus],

      \monitor_bus,   ~buss[\monitor],

      \sax_record_bus,       ~multi_record_buss[\sax],
      \bass_record_bus,      ~multi_record_buss[\bass],
      \sample_record_bus,    ~multi_record_buss[\sample],
      \computer_record_bus,  ~multi_record_buss[\computer],

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

  // only one com loop
  \com_loop_sum,
  Synth(\route_mono_amp,
    [\inbus, ~loop_filt_buss[\com], \outbus, ~loop_filt_buss[\com_loops]],
    ~sum_loop_g),

  \sax_loops_route,
  Synth(\route_mono_amp,
    [\inbus, ~loop_filt_buss[\sax_loops], \outbus, ~buss[\sax_agg]],
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

"Loaded persistent synths".postln;
