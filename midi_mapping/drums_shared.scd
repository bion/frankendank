"loading midi config drums shared...".post;

MIDIdef.program(
  \drums_switch,
  {|val|
    ~current_set = val;
    ~pSynths[\mars_kick_player].set(\buf, ~mars_sample_sets[~current_set][8]);
    postln("CURRENT DRUM SAMPLE SET: " ++ val);
  },
  0,
  ~mSrc[\drums_switch]
);

"done".postln;
