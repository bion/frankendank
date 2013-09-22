(
var uid = ~mSrc[\tuba];
var toggle_filt, ints_to_names = Array.newClear(100),
	map_dic = {|num| IdentityDictionary[\inst -> \tub, \num -> num] };

~p_synths.add(
	\tub_v -> Synth(\v_control, 
		[\outbus, ~buss[\tub_v], \amp, 0], ~in_g),

	\tub_p -> Synth(\p_control, 
		[\outbus, ~buss[\tub_p], \param, 0], ~in_g),

	\tub_info -> Synth(\horninfo,
		[\inbus, ~id_bus_map[\tub], \outbus, ~buss[\tub_info] ], ~in_g),

	\tub_in -> Synth(\route_mono,
		[\inbus, ~id_bus_map[\tub], \outbus, ~buss[\tub_eq] ], ~in_g),

	\tub_eq -> Synth(\tub_eq, 
		[\inbus, ~buss[\tub_eq], \outbus, ~buss[\tub_agg]], ~eq_g),
	);

// two dimensional array stores button# and function pairings
// loop over pairs to instantiate MIDIFuncs using uid
[
	[0, {arg ...args; args.postln; ~loop_touch.(map_dic.(0));}],
	[1, {~loop_touch.(map_dic.(1));}],
	[2, {~loop_touch.(map_dic.(2));}],
	[3, {~loop_touch.(map_dic.(3));}],
	// clear loop id must be a single string char
	[4, {~clear_loop.(\tub);}],

	// other
	[5, { ~h_filt.(\tub_f1) }],
	[6, { ~h_synth.(\tub_s1) }],
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

)
