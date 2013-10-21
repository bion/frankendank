(
	/* each group is an
	IdentityDictionary[
		\synth_name -> \name,
		\uses_chord -> boolean,
		\chord_synths -> [synth, synth, synth],
		\fx_synths -> [one, two, three],
		\args -> [\bus, ~buss[\whatev], \freq, some_freq],
		\target -> ~synth_group,
		\add_message -> \addToTail
	]
	*/

	[
		[\com_mon, Synth(\mon,
			[
				\drum_scale, 1,
				\sax_scale, 1,
				\tub_scale, 1,
				\com_scale, 1,
				\met_scale, 1,
				\metranome_bus, ~buss[\metranome],
				\inbus, ~buss[\sax_mon],
				\outbus, 7,
			],
			~out_g )],

		[\breath_p, Synth(\v_control, [\outbus, ~buss[\breath_v], \param, 0], ~in_g)]

	].do {|pair| ~p_synths.add(pair[0] -> pair[1]) };

	~com_synths_groups = [];
	~current_breath_synth = nil;

	~change_breath_synth = {|synth_name, args|
		remove_these = [];
		~com_synths_groups.do {|synth_dict, i|
			if(synth_dict[\uses_chord], {
				synth_dict[\chord_synths].do {_.free};
				synth_dict[\fx_synths].do {_.free};
				remove_these.add(i);
			});
		};

		remove_these.do {|i| ~com_synths_groups.removeAt(index) };

		~com_synths_groups.add(
			IdentityDictionary[
				\name -> synth_name,
				\uses_chord -> true,
				\chord_synths -> [],
				\fx_synths -> [],
				\args -> args,
				\target -> ~synth_g,
				\add_message -> \addToTail
			];
		);
		~current_breath_synth = synth_name;
		~update_synths_with_chord.(~current_chord);
	};

	MIDIdef.cc(\breath_p, {|num|
		~p_synths[\breath_p].set(\param, num);
	}, srcID: ~mSrc[\breath]);

	MIDIdef.cc(\next_jam, {
		~toggle_loop_jam.value;
	}, srcID: ~mSrc[\com], ccNum: 20, chan: 0);

	MIDIdef.cc(\dirt_rhode, {
		~change_breath_synth.(
			\dirt_rhode,
			[\bus, ~buss[\com_eq], \amp_bus, ~buss[\breath_v]]
		);
	}, srcID: ~mSrc[\com], ccNum: 50, chan: 9);

	MIDIdef.cc(\fank, {
	}, srcID: ~mSrc[\com], ccNum: 36, chan: 9);

)
