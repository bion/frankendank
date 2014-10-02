(
var loopFilters = (
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
), comDandanSynth;

// TODO wire up with HerSynthDanDan
// #setBright
// #setIndexPosition

comDandanSynth = ~comSynths[0];
MIDIdef.cc(\dandan_bright,
  { |val|
    comDandanSynth.setBright(val);
  },
  81,
  0,
  ~mSrc[\bcr]
);
MIDIdef.cc(\dandan_index_position,
  { |val|
    comDandanSynth.setIndexPosition(val);
  },
  82,
  0,
  ~mSrc[\bcr]
);
MIDIdef.cc(\dandan_vibrato_width,
  { |val|
    comDandanSynth.setVibratoWidth(val);
  },
  83,
  0,
  ~mSrc[\bcr]
);

postln("loading midi config: bcr");

~loop_filt_controllers = IdentityDictionary[];

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

)
