(

postln("loading midi config: drums shared");

MIDIdef.program(
  \drums_switch,
  {|val|
    ~current_set = val;
    ~p_synths[\marsKickPlayer].set(\buf, ~mars_sample_sets[~current_set][8]);
    postln("CURRENT DRUM SAMPLE SET: " ++ val);
  },
  0,
  ~mSrc[\drums_switch]
);

)