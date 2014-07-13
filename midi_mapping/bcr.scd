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
),

harmonySynths = (
  105: \com_fank,
  106: \com_dirt_rhode
);

postln("loading midi config: bcr");

MIDIdef.cc(\setHarmonySynth,
  { |val, num|
    ~harmonyController.setSynth(harmonySynths[num]);
  },
  harmonySynths.keys.asArray,
  0,
  ~mSrc[\bcr]
);

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