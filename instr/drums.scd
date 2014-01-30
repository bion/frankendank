(
var switch_uid = ~mSrc[\drums], pad_uid,
basic_sample;

~current_set = 0;

loadRelative("./drum_sample_map.scd");
~sample_sets = Object.readArchive("../archive/drum_sample_sets".resolveRelative);

basic_sample = {| action, val |
  s.makeBundle(0.0, {
    Synth(\playbuf_simple,
      [ \buf, action[\buffer],
        \amp, 0.25 * (val / 127.0 + -24.dbamp),
        \bus, ~buss[action[\register]] ],
      ~playbuf_g )
  })
};

~drum_funcs = IdentityDictionary[
  \basic_sample -> basic_sample
];

~drum_trig = {|pad_midi_number, val|
  var action_id, action;
  action_id = ~sample_sets[~current_set][pad_midi_number];
  action = ~drums[action_id];
  ~drum_funcs[action[\function]].(action, val);
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
    {| val |
      "drumtrig".postln;
      ~drum_trig.(("drum_"++i).asSymbol, val)
    },
    i, 0,  ~mSrc[\drum_pad]);
};

)
