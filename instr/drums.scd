var basic_sample, reversed_sample;

~current_set = 0;

loadRelative("./drum_sample_map.scd");
loadRelative("./andrew_sample_sets.scd");

~mars_sample_sets = Object.readArchive("../archive/drum_sample_sets".resolveRelative);

 basic_sample = {|action, val|
  var scale = val.linexp(0, 128, -22.dbamp, 1) * 0.25;
  var busName = asSymbol("d_" ++ action.register ++ "_bus");

  s.makeBundle(0.0, {
    Synth(\playbuf_simple,
      [ \buf, action.buffer,
        \amp, scale,
        \outbus, ~buss[busName] ],
      ~playbuf_g );
  });

};

reversed_sample = {|action, val|
  var offset = ~clock.beatDur - action.buffer.duration;

  fork {
    offset.wait;
    basic_sample.(action, val);
  };
};

~drum_funcs = IdentityDictionary[
  \basic_sample -> basic_sample,
  \reversed_sample -> reversed_sample
];

~drum_trig = {|pad_midi_number, val, set|
  var action_id, action;

  if (set == \mars) {
    action_id = ~mars_sample_sets[~current_set][pad_midi_number];
  } {
    action_id = ~andrew_sample_sets[~current_set][pad_midi_number];
  };

  action = ~drum_samples[action_id];
  ~drum_funcs[action.playFunction].(action, val);
};
