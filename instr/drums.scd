(
	var uid = ~mSrc[\drums], drum_trig;
	var switch_uid = ~mSrc[\drum_switch], 

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
		IdentityDictionary[
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

	MIDIdef.program(\drum_sample_set, {arg val;
			~current_set=val;
			postln("CURRENT_SAMPLE_SET: " ++ ~current_set);
		},
		0,
		switch_uid
	);

	127.do {|i|
		MIDIdef.noteOn(i.asSymbol,
			{drum_trig.(("drum_"++i).asSymbol); postln("DRUM TRIGGED "++i)}, i, 0, uid );
	};

)
