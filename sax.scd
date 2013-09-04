/*
sax preamp gain: 3
LOOP CLEAR NOT WORKING

FCB1010 notes:
buttons are type: program, src: big int, chan: 0, num: button#
pedals are type: control, src: same big int, chan: 0, ccNum: (a: 27, b: 7), val: 0-127
MIDIFunc.cc args: [val, ccNum, chan, srcID

USB2.0-MIDI notes:
buttons are type program, for button labeled '1':
MIDIdef.program(\whodunnit, {arg ...args; args.postln; "this one".postln;}, 0, -1815496440, {arg val; val==0});
*/
(
var uid = ~mSrc[\fcb];
var toggle_filt, ints_to_names = Array.newClear(100),
	map_dic = {|num| IdentityDictionary[\inst -> \sax, \num -> num] };

// two dimensional array stores button# and function pairings
// loop over pairs to instantiate MIDIFuncs using uid
[
	// looping
	[0, {arg ...args; args.postln; ~loop_touch.(map_dic.(0));}],
	[1, {~loop_touch.(map_dic.(1));}],
	[2, {~loop_touch.(map_dic.(2));}],
	[3, {~loop_touch.(map_dic.(3));}],
	// clear loop id must be a single string char
	[4, {~clear_loop.(\sax);}],

	// other
	[5, { ~h_filt.(\sax_f1) }],
	[6, { ~h_synth.(\sax_s1) }],
].do {arg pair;
	MIDIdef.program(
		("sax_"++pair[0]).asSymbol,
		pair[1],
		0,
		uid,
		{arg val; val==pair[0]}
	);
};

MIDIdef.cc(\sax_volume, {arg val; ~p_synths[\sax_v].set(\amp, val) }, 7, 0, uid);
MIDIdef.cc(\sax_param, {arg val; ~p_synths[\sax_p].set(\param, val) }, 27, 0, uid);
"SAX LOADED".postln;
)
