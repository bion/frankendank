(
  var synth, filt, amp_synth, param,
    test_buf, source_path,
    param_bus = Bus.control(s, 1),
    stereo_bus = Bus.audio(s, 1),
    horn_data_bus = Bus.control(s, 4),
    parent_bus = Bus.audio(s, 1),
    parent_group, synth_group, param_group, filt_group, end_group,
    bundles, cond;

  source_path = "~/Dropbox/electric_band_shared_music/raw_horn_samples/sax_1.aiff".standardizePath;

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
    synth_group = Group(parent_group, \addAfter);
    param_group = Group(synth_group, \addBefore);

    filt_group = Group(synth_group, \addAfter);
    end_group = Group(filt_group, \addAfter);

    test_buf = Buffer.read(s, source_path);

    loadRelative("../config/config.scd");
    loadRelative("../SD.scd");

    s.sync(cond);

    s.makeBundle(0.4, {
      Synth(\playbuf_simple, [\outbus, parent_bus, \buf, test_buf], parent_group);
      Synth(\sax_in, [\inbus, parent_bus, \outbus, stereo_bus], synth_group);
      Synth(\sax_info, [\inbus, parent_bus, \outbus, horn_data_bus], synth_group);

      // Synth(\cynk_hi, [\bus, stereo_bus], filt_group, \addToTail);
      Synth(\decimator, [\bus, stereo_bus], filt_group, \addToTail);
      Synth(\dissonance, [\bus, stereo_bus], filt_group, \addToTail);
      Synth(\general_chorus, [\bus, stereo_bus], filt_group, \addToTail);

      // Synth(\sax_8vdown, [\bus, stereo_bus, \info_bus, horn_data_bus], filt_group, \addToTail);

      // Synth(\control_env_testing, [\env, param, \outbus, param_bus], param_group);
      Synth(\route_m2s_free_on_silence,
        [\inbus, stereo_bus, \outbus, 0], end_group, \addToTail);
      },
      bundles
    );

  };
)
