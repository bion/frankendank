(
	var uid = ~mSrc[\drums], drum_trig;

	load(~maindir ++ "/instr/drum_sample_map.scd");

	~drum_funcs = IdentityDictionary[
		\basic_sample -> {|action|
			Synth(\basic_sample,
				[ \buf, action[\buffer]
					\bus, ~buss[action[\register]] ],
				~playbuf_g )},
	];

	~sample_sets = [
		\1 = IdentityDictionary[
			\drum_0 -> \kick_synth_1,
			\drum_1  -> \kick_synth_2,
			\drum_2  -> \snare_1,
			\drum_3  -> \snare_2,
			\drum_4  -> \clap_1,
			\drum_5  -> \pop_1,
			\drum_6  -> \snick_1,
			\drum_7  -> \snick_2
		];
	];

	drum_trig = {|pad_midi_number|
		var pad_id = pad_midi_number % 8,
			set_number = (pad_number / 8).floor,
			action_id = ~sample_sets[set_number][pad_id],
			action = ~drums[action_id];
		~drum_funcs[action[\function]].(action);
	};

	127.do {|i|
		MIDIdef.noteOn(i.asSymbol, drum_trig.(("pad_"++i).asSymbol), i, 0, uid );
	};

)
