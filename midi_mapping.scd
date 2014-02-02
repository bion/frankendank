/*
  sax preamp gain: 3

  FCB1010 notes:
  buttons are type: program, src: big int, chan: 0, num: button#
  pedals are type: control, src: same big int, chan: 0, ccNum: (a: 27, b: 7), val: 0-127
  MIDIFunc.cc args: [val, ccNum, chan, srcID

  USB2.0-MIDI notes:
  buttons are type program, for button labeled '1':
  MIDIdef.program(\whodunnit, {|...args| args.postln; "this one".postln;}, 0, -1815496440, {|val| val==0});
*/
(
var uid_sax = ~mSrc[\sax];
var map_dic_sax = {|num| IdentityDictionary[\instr -> \sax, \num -> num] };
var uid_tub = ~mSrc[\tuba];
var map_dic_tub = {|num| IdentityDictionary[\instr -> \tub, \num -> num] };
var loopFilters;

[
  // looping
  [0, {~loop_touch.(map_dic_sax.(0));}],
  [1, {~loop_touch.(map_dic_sax.(1));}],
  [2, {~loop_touch.(map_dic_sax.(2));}],
  [3, {~loop_touch.(map_dic_sax.(3));}],
  // clear loop id must be a single string char
  [4, {~clear_loop.(\sax);}],

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
    uid_sax,
    pair[0]
  );
};

// two dimensional array stores button# and function pairings
// loop over pairs to instantiate MIDIFuncs using uid
[
  [0, {~loop_touch.(map_dic_tub.(0));}],
  [1, {~loop_touch.(map_dic_tub.(1));}],
  [2, {~loop_touch.(map_dic_tub.(2));}],
  [3, {~loop_touch.(map_dic_tub.(3));}],
  // clear loop id must be a single string char
  [4, {~clear_loop.(\tub);}],

  // synths
  [5, { ~dry_horn.(\tub) }],
  [6, {
    ~dry_horn.(\tub);
    ~h_synth.(\tub_subbass);
  }],
  [7, {
    ~dry_horn.(\tub);
    ~h_synth.(\tub_subbass);
    ~h_synth.(\tub_s1);
  }],
  [8, {
    ~dry_horn.(\tub);
    ~h_synth.(\tub_subbass);
    ~h_synth.(\tub_s2);
  }],
  [9,{ ~reset_all.(\tub) }]
].do {|pair|
  MIDIdef.program(
    ("tub_"++pair[0]).asSymbol,
    pair[1],
    0,
    uid_tub,
    pair[0]
  );
};

MIDIdef.cc(\sax_volume, {|val| ~p_synths[\sax_v].set(\amp, val) }, 7, 0, uid_tub);
MIDIdef.cc(\tub_volume, {|val| ~p_synths[\tub_v].set(\amp, val) }, 7, 0, uid_tub);

MIDIdef.cc(\sax_param, {|val| ~p_synths[\sax_p].set(\param, val) }, 27, 0, uid_tub);
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
}, 27, 0, uid_tub);

// BCR2000

~loop_filt_controllers = IdentityDictionary[];

loopFilters = (
  sax: [
    \amp_filt,
    \DFM1_hi,
    \DFM1_lo,
    \integrator
  ],
  tub: [
    \amp_filt,
    \DFM1_hi,
    \DFM1_lo,
    \integrator
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
    ~loop_filt_buss[instr.asSymbol][loopNum],
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

"MIDI MAPPING LOADED".postln;
)