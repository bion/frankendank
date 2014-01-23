(
var uid = ~mSrc[\tuba];
var toggle_filt, ints_to_names = Array.newClear(100),
map_dic = {|num| IdentityDictionary[\instr -> \tub, \num -> num] }, toggle_relax;

[
  [\tub_mon, Synth(\mon,
    [ \main, \met, \sax, \tub, \drum, \com ].collect({|input|
      [asSymbol(input++"_scale"), ~monitor_levels[\tub][input]]
    }).flat ++
    [
      \metranome_bus, ~buss[\metranome],
      \inbus, ~buss[\tub_mon],
      \outbus, ~id_bus_map[\tub_mon_out],
    ],
    ~out_g )],

  [\tub_v, Synth(\v_control, [\outbus, ~buss[\tub_v], \amp, 127], ~in_g)],

  [\tub_p, Synth(\p_control_lag, [\outbus, ~buss[\tub_p], \param, 0], ~in_g)],

  [\tub_info, Synth(\tuba_info, [\inbus, ~id_bus_map[\tub], \outbus, ~buss[\tub_info] ], ~in_g)],

  [\tub_in, Synth(\tuba_in, [\inbus, ~id_bus_map[\tub], \outbus, ~buss[\tub_eq] ], ~in_g)],

  [\tub_eq, Synth(\tub_eq, [\inbus, ~buss[\tub_eq], \outbus, ~buss[\tub_agg]], ~eq_g)],

].do {|pair| ~p_synths.add(pair[0] -> pair[1]) };

// two dimensional array stores button# and function pairings
// loop over pairs to instantiate MIDIFuncs using uid
[
  [0, {~loop_touch.(map_dic.(0));}],
  [1, {~loop_touch.(map_dic.(1));}],
  [2, {~loop_touch.(map_dic.(2));}],
  [3, {~loop_touch.(map_dic.(3));}],
  // clear loop id must be a single string char
  [4, {~clear_loop.(\tub);}],

  // synths
  [5, { ~h_synth.(\tub_subbass) }],
  [6, { ~h_synth.(\tub_s1) }],
  [7, { ~h_synth.(\tub_s2) }],
  [8, { toggle_relax.() }],
  [9,{ ~reset_all.(\tub) }]
].do {|pair|
  MIDIdef.program(
    ("tub_"++pair[0]).asSymbol,
    pair[1],
    0,
    uid,
    pair[0]
  );
};

MIDIdef.cc(\tub_volume, {|val| ~p_synths[\tub_v].set(\amp, val) }, 7, 0, uid);

toggle_relax = {
  var responder = MIDIdef(\tub_relax);
  if (responder.enabled) {
    responder.disable;
    MIDIdef(\tub_param).enable;
  } {
    responder.enable;
    MIDIdef(\tub_param).disable;
  };
};

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
}, 27, 0, uid);

"TUBA LOADED".postln;
)
