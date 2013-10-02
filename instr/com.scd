(

	/* each group is an IdentityDictionary[
		\uses_chord -> boolean,
		\chord_synths -> [synth, synth, synth],
		\fx_synths -> [one, two, three]
	]
	*/

	~p_synths.add(
		\breath_p -> Synth(\p_control,
			[\outbus, ~buss[\breath_p], \param, 0], ~in_g)
	);

	~com_synths_groups = [];

	MIDIdef.cc(\breath_p, {
		arg num;
		~p_synths[\breath_p].set(\param, num);
	}, srcID: ~mSrc[\breath]);

)
