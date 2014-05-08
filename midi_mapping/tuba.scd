(
var tubaLoops = 4.collect {|i|
  HerLoop(
    \tuba,
    s,
    ~clock,
    ~buss[\tub_agg],
    ~record_loop_g,
    ~loop_filt_buss[\tub].index + i,
    ~play_loop_g)
};

postln("loading midi config: tuba");

[
  // looping
  [0, { tubaLoops[0].touch }],
  [1, { tubaLoops[1].touch }],
  [2, { tubaLoops[2].touch }],
  [3, { tubaLoops[3].touch }],
  // clear loop id must be a single string char
  [4, { HerLoop.toggleReset(\tuba) }],

  // synths
  [5, { ~dry_horn.(\tub) }],
  [6, {
    // ~dry_horn.(\tub);
    // ~h_synth.(\tub_subbass);
    ~dry_horn.(\tub);
    ~h_synth.(\tub_s1);
  }],
  [7, {
    ~dry_horn.(\tub);
    ~h_synth.(\tub_s2);
  }],
  [8, {
    HerLoop.toggleMuteAll(\tuba);
  }],
  [9,{ ~reset_all.(\tuba) }],

  // looping
  [10, { tubaLoops[0].touch }],
  [11, { tubaLoops[1].touch }],
  [12, { tubaLoops[2].touch }],
  [13, { tubaLoops[3].touch }],
  // clear loop id must be a single string char
  [14, { HerLoop.toggleReset(\tuba) }],

  // synths
  [15, { ~dry_horn.(\tub) }],
  [16, {
    ~dry_horn.(\tub);
    ~h_synth.(\tub_s3);
  }],
  [17, {
    ~dry_horn.(\tub);
    ~h_synth.(\tub_s1);
  }],
  [18, {
    // ~dry_horn.(\tub);
    // ~h_synth.(\tub_s2);
    HerLoop.toggleMuteAll(\tuba);
  }],
  [19,{ ~reset_all.(\tub) }]
].do {|pair|
  MIDIdef.program(
    ("tub_"++pair[0]).asSymbol,
    pair[1],
    0,
    ~mSrc[\tuba],
    pair[0]
  );
};

MIDIdef.cc(\tub_volume, {|val| ~p_synths[\tub_v].set(\amp, val) }, 7, 0, ~mSrc[\tuba]);

MIDIdef.cc(\tub_relax, {|val|
  var relax;
  case
  { val < 10 }
  { relax = 0.05 }

  { val < 64 }
  { relax = 0.5 * ~tempo }

  { val < 129 }
  { relax = ~tempo };

  ~p_synths[\agg].set(\tub_relax, relax);
}, 27, 0, ~mSrc[\tuba]);

)
