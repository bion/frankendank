(
	var uid = ~mSrc[\drum_pad], drum_trig;
	var switch_uid = ~mSrc[\drums];

	~current_set = 0;

	load(~maindir ++ "/instr/drum_sample_map.scd");

	~drum_funcs = IdentityDictionary[
		\basic_sample -> {|action|
			s.makeBundle(0.025, {
				Synth(\playbuf_simple,
					[ \buf, action[\buffer],
						\bus, ~buss[action[\register]] ],
					~playbuf_g )
				})
			},
	];

	~sample_sets = [
		IdentityDictionary[ // 0
			\drum_0 -> \kick_synth_1,
			\drum_1 -> \kick_synth_2,
			\drum_2 -> \snare_1,
			\drum_3 -> \snare_2,
			\drum_4 -> \clap_1,
			\drum_5 -> \pop_1,
			\drum_6 -> \snick_1,
			\drum_7 -> \snick_2
		],
		IdentityDictionary[ // 1
			\drum_0 -> \kick_synth_1,
			\drum_1 -> \kick_synth_2,
			\drum_2 -> \snare_1,
			\drum_3 -> \snare_2,
			\drum_4 -> \clap_1,
			\drum_5 -> \pop_1,
			\drum_6 -> \snick_1,
			\drum_7 -> \snick_2
		]
	];

	drum_trig = {arg pad_midi_number;
		var action_id, action;
			action_id = ~sample_sets[~current_set][pad_midi_number];
			postln("ACTION ID: " ++ action_id);
			action = ~drums[action_id];
			postln("ACTION: " ++ action).postln;
		~drum_funcs[action[\function]].(action);
	};

	/*
	MIDIdef.program(\drum_sample_set, {arg val;
			~current_set=val;
			postln("CURRENT_SAMPLE_SET: " ++ ~current_set);
		},
		0,
		switch_uid
	);
	*/

	MIDIIn.program = {|src, chan, prog|
		if(src == switch_uid, {
			case
				{ prog == 0 } { ~current_set = 0; postln("CURRENT_SAMPLE_SET: " ++ ~current_set);}
				{ prog == 1 } { ~current_set = 1; postln("CURRENT_SAMPLE_SET: " ++ ~current_set);}
				{ prog == 2 } { ~current_set = 2; postln("CURRENT_SAMPLE_SET: " ++ ~current_set);}
				{ prog == 3 } { ~current_set = 3; postln("CURRENT_SAMPLE_SET: " ++ ~current_set);}
				{ prog == 4 } { ~current_set = 4; postln("CURRENT_SAMPLE_SET: " ++ ~current_set);}
				{ prog == 5 } { ~current_set = 5; postln("CURRENT_SAMPLE_SET: " ++ ~current_set);}
				{ prog == 6 } { ~current_set = 6; postln("CURRENT_SAMPLE_SET: " ++ ~current_set);}
				{ prog == 7 } { ~current_set = 7; postln("CURRENT_SAMPLE_SET: " ++ ~current_set);}
				{ prog == 8 } { ~current_set = 8; postln("CURRENT_SAMPLE_SET: " ++ ~current_set);}
				{ prog == 9 } { ~current_set = 9; postln("CURRENT_SAMPLE_SET: " ++ ~current_set);}
				{ prog == 10 } { ~current_set = 10; postln("CURRENT_SAMPLE_SET: " ++ ~current_set);}
				{ prog == 11 } { ~current_set = 11; postln("CURRENT_SAMPLE_SET: " ++ ~current_set);};
		});
	};

	127.do {|i|
		MIDIdef.noteOn(i.asSymbol,
			{drum_trig.(("drum_"++i).asSymbol); postln("DRUM TRIGGED "++i)}, i, 0, uid );
	};

)
