(
var uid = ~mSrc[\tuba];
var toggle_filt, ints_to_names = Array.newClear(100),
	map_dic = {|num| IdentityDictionary[\inst -> \tub, \num -> num] },
	toggle_relax;

[
	[\tub_mon, Synth(\mon,
		[
			\drum_scale, 1,
			\sax_scale, 1,
			\tub_scale, 1,
			\com_scale, 1,
			\met_scale, 1,
			\metranome_bus, ~buss[\metranome],
			\inbus, ~buss[\tub_mon],
			\outbus, 4,
		],
		~out_g )],

	[\tub_v, Synth(\v_control, [\outbus, ~buss[\tub_v], \amp, 0], ~in_g)],

	[\tub_p, Synth(\p_control, [\outbus, ~buss[\tub_p], \param, 0], ~in_g)],

	[\tub_info, Synth(\horninfo, [\inbus, ~id_bus_map[\tub], \outbus, ~buss[\tub_info] ], ~in_g)],

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
	[5, { ~h_synth.(\tub_s1) }],
	[6, { ~h_synth.(\tub_s2) }],

	[11,{ toggle_relax.() }]
].do {arg pair;
	MIDIdef.program(
		("tub_"++pair[0]).asSymbol,
		pair[1],
		0,
		uid,
		{arg val; val==pair[0]}
	);
};

MIDIdef.cc(\tub_volume, {arg val; ~p_synths[\tub_v].set(\amp, val) }, 7, 0, uid);
MIDIdef.cc(\tub_param, {arg val; ~p_synths[\tub_p].set(\param, val) }, 27, 0, uid);

toggle_relax = {
	var responder = MIDIdef(\tub_relax);
	if(responder.enabled, { 
		responder.disable;
		MIDIdef(\tub_param).enable;
	}, {
		responder.enable;
		MIDIdef(\tub_param).disable;
	});
};

MIDIdef.cc(\tub_relax, {arg val;
	var relax = val * 127.reciprocal * ~tempo;
	~p_synths[\agg].set(\tub_relax, relax);
	}, 27, 0, uid).disable;

)
