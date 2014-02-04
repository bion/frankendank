(
var basic_sample;

~mSrc[\drums] = ~mSrc[\drums] ? 1;
~mSrc[\drum_pad] = ~mSrc[\drum_pad] ? 1;

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

MIDIdef.program(
    \drumSampleSwitch,
    {|val|
        ~current_set = val;
        postln("CURRENT DRUM SAMPLE SET: " ++ val);
    },
    0,
    ~mSrc[\drums]
);

MIDIdef.noteOn(
    \drumPad,
    {|val, num|
        ~drum_trig.(("drum_" ++ num).asSymbol, val)
    },
    nil,
    0,
    ~mSrc[\drum_pad]
);

)
