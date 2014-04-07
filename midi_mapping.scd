/*
  sax preamp gain: 3

  FCB1010 notes:
  buttons are type: program, src: big int, chan: 0, num: button#
  pedals are type: control, src: same big int, chan: 0, ccNum: (a: 27, b: 7), val: 0-127
  MIDIFunc.cc args: [val, ccNum, chan, srcID

  USB2.0-MIDI notes:
  buttons are type program, for button labeled '1':
  MIDIdef.program(\whodunnit, {|...args| args.postln; "this one".postln;}, 0, -1815496440, {|val| val==0});

nano pad nums:
39, 48, 45, 43, 51, 49

36, 38, 40, 42, 44, 46

*/
(
var map_dic_sax = {|num| IdentityDictionary[\instr -> \sax, \num -> num] };
var map_dic_tub = {|num| IdentityDictionary[\instr -> \tub, \num -> num] };
var loopFilters, harmonyController, andrewPadMap,

saxLoops = 4.collect {|i|
  HerLoop(
    \sax,
    s,
    ~clock,
    ~buss[\sax_agg],
    ~record_loop_g,
    ~loop_filt_buss[\sax].index + i,
    ~play_loop_g)
},

tubaLoops = 4.collect {|i|
  HerLoop(
    \tuba,
    s,
    ~clock,
    ~buss[\tub_agg],
    ~record_loop_g,
    ~loop_filt_buss[\tub].index + i,
    ~play_loop_g)
};

// ****************************** VAR END

// ****************************** nil-guard ~mSrc values

[\sax, \tuba, \bcr, \drums, \drum_pad].do {|instr|
  ~mSrc[instr] = ~mSrc[instr] ? 1;
};

// ****************************** DRUMS

MIDIdef.program(
  \drums_switch,
  {|val|
    ~current_set = val;
    postln("CURRENT DRUM SAMPLE SET: " ++ val);
  },
  0,
  ~mSrc[\drums_switch]
);

MIDIdef.noteOn(
  \drum_pad,
  {|val, num|
    ~drum_trig.(("drum_" ++ num).asSymbol, val, \mars)
  },
  nil,
  0,
  ~mSrc[\drum_pad]
);

andrewPadMap = IdentityDictionary[];
~andrew_midi_map["pad"].keysValuesDo {|key, value|
  andrewPadMap.add( value.asSymbol -> key.asInteger );
};

MIDIdef.noteOn(
  \andrew,
  {|val, num|
    ~drum_trig.(andrewPadMap[num.asSymbol], val, \andrew)
  },
  nil,
  0,
  ~mSrc[\andrew]
);

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

// two dimensional array stores button# and function pairings
// loop over pairs to instantiate MIDIFuncs using uid
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
    ~dry_horn.(\tub);
    ~h_synth.(\tub_subbass);
  }],
  [7, {
    ~dry_horn.(\tub);
    ~h_synth.(\tub_s1);
  }],
  [8, {
    ~dry_horn.(\tub);
    ~h_synth.(\tub_s2);
  }],
  [9,{ ~reset_all.(\tub) }],

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
    ~dry_horn.(\tub);
    ~h_synth.(\tub_s2);
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

MIDIdef.cc(\sax_volume, {|val| ~p_synths[\sax_v].set(\amp, val) }, 7, 0, ~mSrc[\sax]);

MIDIdef.cc(\tub_volume, {|val| ~p_synths[\tub_v].set(\amp, val) }, 7, 0, ~mSrc[\tuba]);

MIDIdef.cc(\sax_param, {|val| ~p_synths[\sax_p].set(\param, val) }, 27, 0, ~mSrc[\sax]);

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

// BCR2000

~loop_filt_controllers = IdentityDictionary[];

loopFilters = (
  sax: [
    \amp_filt,
    \DFM1_hi,
    \DFM1_lo,
    \decimator
  ],
  tub: [
    \amp_filt,
    \DFM1_hi,
    \DFM1_lo,
    \decimator
  ]
);

[(1..32), (33..64)].flop.do {|pair, i|
  var knobControlNum = pair[0];
  var toggleControlNum = pair[1];
  var instr, controller, name;
  var loopNum = (i / 8).floor;
  var filtNum = i % 4;

  if ((i % 8) < 4) { instr = "sax" } { instr = "tub" };
  // e.g. sax_loop_0_filt_0
  name = instr ++ "_loop_" ++ loopNum ++ "_filt_" ++ filtNum;

  controller = LoopFilterController(
    name,
    loopFilters[instr.asSymbol][filtNum],
    instr,
    ~loop_filt_buss[instr.asSymbol].index + loopNum,
    ~filt_loop_g
  );

  ~loop_filt_controllers[name.asSymbol] = controller;

  MIDIdef.cc(asSymbol(name ++ "_knob"),
    { |val|
      controller.setKnobVal(val);
    },
    knobControlNum,
    0,
    ~mSrc[\bcr]
  );

  MIDIdef.cc(asSymbol(name ++ "_toggle"),
    { |val|
      if (val != 0) { controller.activate } { controller.deactivate };
    },
    toggleControlNum,
    0,
    ~mSrc[\bcr]
  );
};

// ****************************** FINGER PADS

[
  39, 48, 45, 43,
  36, 38, 40, 42
].do {|num, index|
  MIDIdef.noteOn(asSymbol("chordSetSelector_" ++ index),
    {
      ~chordSelector.setChordSlot(index);
    },
    num,
    0,
    ~mSrc[\fingerPads]
  );
};

// ****************************** BREATH CONTROLLER

if (~mSrc[\breath].notNil) {
  MIDIdef.cc(\breathController,
    { |val|
      if (val < 64) { val = val } { val = 64 };
      ~harmonyController.setAmp(val);
    },
    2,
    0,
    ~mSrc[\breath]
  );
};

"MIDI MAPPING LOADED".postln;
)
