(
	var synth, filt, amp_synth, param,
		test_buf, source_path,
		param_bus = Bus.control(s, 1),
		stereo_bus = Bus.audio(s, 1),
		parent_group, synth_group, param_group, filt_group,
		bundles, cond;

	source_path = "~/Documents/EDE/test_samples/scott testing.aiff".standardizePath;
	filt = \shaper;

	param = Env(
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

	Server.default = s = Server.internal;

	s.waitForBoot {
		parent_group = Group(s);
		synth_group = Group(parent_group);
		filt_group = Group(synth_group, \addAfter);
		param_group = Group(synth_group, \addBefore);

		test_buf = Buffer.read(s, source_path);

		"~/Documents/EDE/code/frankendank/SD.scd".standardizePath.load;

		s.sync(cond);

		s.makeBundle(0.4, {
			Synth(\playbuf_simple, [\outbus, stereo_bus, \buf, test_buf], synth_group);

			Synth(\sax_comp, [\bus, stereo_bus], filt_group, \addToHead);

			Synth(\chorus_compress, [\bus, stereo_bus], filt_group);

			Synth(\cynk_lo, [\bus, stereo_bus], filt_group, \addToTail);

			Synth(\control_env_testing, [\env, param, \outbus, param_bus], param_group);
			Synth(\route_m2s_free_on_silence,
				[\inbus, stereo_bus, \outbus, 0], parent_group, \addToTail);
			},
			bundles
		);

	};
)