(
var uid = ~mSrc[\jons_board];
var toggle_filt, ints_to_names = Array.newClear(100);

// two dimensional array stores button# and function pairings
// loop over pairs to instantiate MIDIFuncs using uid
[
	// looping
	[0, {~loop_touch.(\t1)}],
	[1, {~loop_touch.(\t2)}],
	[2, {~loop_touch.(\t3)}],
	[3, {~loop_touch.(\t4)}],
	[4, {~clear_loop.(\t)}],

	// other
	[5, {~synth.(\tub_1)}]
].do {arg pair; MIDIdef.cc(pair[0].asSymbol, pair[1], pair[0], 0, uid) };

/*
MIDIdef.cc(\tub_volume, {arg val; ~p_synths[\tub_v].set(\amp, val) }, 7, 0, uid);
MIDIdef.cc(\tub_param, {arg val; ~p_synths[\tub_p].set(\param, val) }, 27, 0, uid);
*/

)