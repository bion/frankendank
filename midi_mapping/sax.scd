(

postln("loading midi config: sax");

var saxLoops = 4.collect {|i|
  HerLoop(
    \sax,
    s,
    ~clock,
    ~buss[\sax_agg],
    ~record_loop_g,
    ~loop_filt_buss[\sax].index + i,
    ~play_loop_g)
};

[
  // looping
  [0, { saxLoops[0].touch }],
  [1, { saxLoops[1].touch }],
  [2, { saxLoops[2].touch }],
  [3, { saxLoops[3].touch }],
  // clear loop id must be a single string char
  [4, { HerLoop.toggleReset(\sax) }],

  // other
  [5, {
    ~dry_horn.(\sax);
  }],
  [6, {
    ~dry_horn.(\sax);
    ~h_filt.(\sax_reverb);
  }],
  [7, {
    ~dry_horn.(\sax);
    ~h_filt.(\sax_shaper);
    ~h_filt.(\sax_chorus);
  }],
  [8, {
    ~dry_horn.(\sax);
    ~h_filt.(\sax_shaper);
    ~h_filt.(\sax_8vdown);
  }],
  // [8, { ~h_filt.(\sax_cynk_broad) }],
  [9, { ~reset_all.(\sax) }]
].do {|pair|
  MIDIdef.program(
    ("sax_"++pair[0]).asSymbol,
    pair[1],
    0,
    ~mSrc[\sax],
    pair[0]
  );
};

MIDIdef.cc(\sax_volume, {|val| ~p_synths[\sax_v].set(\amp, val) }, 7, 0, ~mSrc[\sax]);

MIDIdef.cc(\sax_param, {|val| ~p_synths[\sax_p].set(\param, val) }, 27, 0, ~mSrc[\sax]);

)