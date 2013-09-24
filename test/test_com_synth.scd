(
	var synth, amp_synth, chord, amp,
		amp_bus = Bus.control(s, 1),
		stereo_bus = Bus.audio(s, 1),
		parent_group, synth_group, amp_group, filt_group,
		bundles, cond;

	synth = \dirty_rhode;

	chord = [
		PC(\bf, 3),
		PC(\df, 4), // 7
		PC(\ef, 4), // 1
		PC(\g,  4), // 3
		PC(\bf, 4), // 5
		PC(\ef, 5)
	];

	amp = Env(
		[0,
			1, 0.1, 0, 0,
			1, 0, 0,
			1, 0.2, 0,
			0, 1, 0] * (-2.dbamp),
		[
			0.03, 0.1, 0.1, 0.9,
			0.03, 0.7, 0.9,
			0.1, 0.35, 1.75,
			0.5, 6, 10],
		\sin
	);

	cond = Condition.new;

	Server.default = s = Server.local;
	s.waitForBoot {
		parent_group = Group(s);
		synth_group = Group(parent_group);
		filt_group = Group(synth_group, \addAfter);
		amp_group = Group(synth_group, \addBefore);

		"~/Documents/EDE/code/frankendank/SD.scd".standardizePath.load;

		s.sync(cond);

		bundles = chord.collect {arg pc;
			s.makeBundle(false, {
				Synth(synth, [\freq, pc.freq, \bus, stereo_bus, \amp_bus, amp_bus], synth_group);
			});
		};

		bundles = bundles.inject([], {
			arg a, b;
			a ++ b;
		});

		s.makeBundle(0.4, {
			Synth(\general_chorus, [\bus, stereo_bus], filt_group);
			// Synth(\shaper, [\bus, stereo_bus, \buf, ~shaper_buf_1], filt_group, \addToTail);

			Synth(\control_env_testing, [\env, amp, \outbus, amp_bus], amp_group);
			Synth(\route_m2s_free_on_silence,
				[\inbus, stereo_bus, \outbus, 0], parent_group, \addToTail);
		}, bundles);
	};
)
