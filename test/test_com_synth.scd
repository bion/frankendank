(
	var synth, amp_synth, chord, amp,
		amp_bus = Bus.control(s, 1),
		stereo_bus = Bus.audio(s, 1),
		parent_group, synth_group, amp_group,
		bundles;

	synth = \dirty_rhode;

	chord = [
		PC(\df, 3), // 7
		PC(\ef, 3), // 1
		PC(\g, 3), // 3
		PC(\bf, 3), // 5
	];

	amp = Env(
		[0, 1, 0.2, 0, 0, 1, 0] * (-2.dbamp),
		[0.06, 0.2, 0.1, 0.5, 1, 2],
		\sin
	);

	Server.default = s = Server.local;
	s.waitForBoot {
		parent_group = Group(s);
		synth_group = Group(parent_group);
		amp_group = Group(synth_group, \addBefore);

		"~/Documents/EDE/code/frankendank/SD.scd".standardizePath.load;

		bundles = chord.collect {arg pc;
			s.makeBundle(false, {
				Synth(synth, [\freq, pc.freq, \bus, stereo_bus, \amp_bus, amp_bus], synth_group);
			});
		};

		bundles = bundles.inject([], {
			arg a, b;
			a ++ b;
		});

		s.makeBundle(0.2, {
			Synth(\control_env_testing, [\env, amp, \outbus, amp_bus], amp_group);
			Synth(\route_m2s_free_on_silence,
				[\inbus, stereo_bus, \outbus, 0], parent_group, \addToTail);
		}, bundles);
	};
)
