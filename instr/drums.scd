(
  var switch_uid = ~mSrc[\drums], pad_uid;

  ~current_set = 0;

  load(~maindir ++ "/instr/drum_sample_map.scd");

  ~p_synths.add(
    \drums_mon -> Synth(\mon,
      [
        \drum_scale, 1,
        \sax_scale, 1,
        \tub_scale, 1,
        \com_scale, 1,
        \met_scale, 1,
        \metranome_bus, ~buss[\metranome],
        \inbus, ~buss[\drums_mon],
        \outbus, ~id_bus_map[\drums_mon_out],
      ],
      ~out_g ),
  );

  ~drum_funcs = IdentityDictionary[
    \basic_sample -> {|action|
      ~buss[action[\register]].postln;
      s.makeBundle(0.025, {
        Synth(\playbuf_simple,
          [ \buf, action[\buffer],
            \amp, 0.125,
            \bus, ~buss[action[\register]] ],
          ~playbuf_g )
        })
      },
  ];

  ~sample_sets = [
    IdentityDictionary[ // 0
      \drum_0 -> \Kick1,
      \drum_1 -> \Kick2,
      \drum_2 -> \Snare1,
      \drum_3 -> \Clap1,
      \drum_4 -> \Whip,
      \drum_5 -> \Hat1,
      \drum_6 -> \Hat2,
      \drum_7 -> \Cymbal1
    ],
    IdentityDictionary[ // 1
      \drum_0 -> \Kick3,
      \drum_1 -> \Kick4,
      \drum_2 -> \Clap2,
      \drum_3 -> \Snap1,
      \drum_4 -> \Whip,
      \drum_5 -> \Snare1,
      \drum_6 -> \Hat3,
      \drum_7 -> \Cymbal1
    ]
  ];

  ~drum_trig = {arg pad_midi_number;
    var action_id, action;
			pad_midi_number.postln;
      action_id = ~sample_sets[~current_set][pad_midi_number];
      action = ~drums[action_id];
    ~drum_funcs[action[\function]].(action);
  };

  MIDIIn.program = {|src, chan, prog|
    if (src == switch_uid) {
      case
        { prog == 0 } { ~current_set = 0; postln("CURRENT_SAMPLE_SET: " ++ ~current_set);}
        { prog == 1 } { ~current_set = 1; postln("CURRENT_SAMPLE_SET: " ++ ~current_set);}
        { prog == 2 } { ~current_set = 2; postln("CURRENT_SAMPLE_SET: " ++ ~current_set);}
        { prog == 3 } { ~current_set = 3; postln("CURRENT_SAMPLE_SET: " ++ ~current_set);}
        { prog == 4 } { ~current_set = 4; postln("CURRENT_SAMPLE_SET: " ++ ~current_set);}
        { prog == 5 } { ~current_set = 5; postln("CURRENT_SAMPLE_SET: " ++ ~current_set);}
        { prog == 6 } { ~current_set = 6; postln("CURRENT_SAMPLE_SET: " ++ ~current_set);}
        { prog == 7 } { ~current_set = 7; postln("CURRENT_SAMPLE_SET: " ++ ~current_set);}
        { prog == 8 } { ~current_set = 8; postln("CURRENT_SAMPLE_SET: " ++ ~current_set);}
        { prog == 9 } { ~current_set = 9; postln("CURRENT_SAMPLE_SET: " ++ ~current_set);}
        { prog == 10 } { ~current_set = 10; postln("CURRENT_SAMPLE_SET: " ++ ~current_set);}
        { prog == 11 } { ~current_set = 11; postln("CURRENT_SAMPLE_SET: " ++ ~current_set);};
    };
  };

  127.do {|i|
    MIDIdef.noteOn(i.asSymbol,
      {~drum_trig.(("drum_"++i).asSymbol)}, i, 0,  ~mSrc[\drum_pad]);
  };

)
