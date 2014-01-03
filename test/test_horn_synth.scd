(
  var synth, filt, amp_synth, param,
    test_buf, source_path,
    param_bus = Bus.control(s, 1),
    horn_in = Bus.audio(s, 1),
    stereo_bus = Bus.audio(s, 1),
    info_in_bus = Bus.audio(s, 1),
    info_out_bus = Bus.control(s, 4),
    parent_group, synth_group, param_group, filt_group, in_group,
    bundles, cond;

  // source_path = "~/Dropbox/electric_band_shared_music/raw_horn_samples/tuba_1.aiff".standardizePath;
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
    in_group = Group(parent_group, \addAfter);
    synth_group = Group(in_group, \addAfter);
    filt_group = Group(synth_group, \addAfter);
    param_group = Group(synth_group, \addBefore);

    test_buf = Buffer.read(s, source_path);

    loadRelative("./SD.scd");

    s.sync(cond);

    s.makeBundle(0.4, {
      Synth(\playbuf_simple, [\outbus, horn_in, \buf, test_buf], parent_group);

//      Synth(\tuba_in, [\inbus, horn_in, \outbus, info_in_bus], parent_group, \addToTail);

      Synth(\sax_in, [\inbus, horn_in, \outbus, stereo_bus], parent_group, \addToTail);

      Synth(\horninfo, [\inbus, horn_in, \outbus, info_out_bus], synth_group);

      Synth(\control_stub, [\bus, param_bus, \value, 120], synth_group);

//      Synth(\tub_s2, [\bus, stereo_bus, \hornDataBus, info_out_bus, \pedal_amp_bus, param_bus]);
//      Synth(\tub_subbass, [\bus, stereo_bus, \hornDataBus, info_out_bus, \pedal_amp_bus, param_bus]);

//      Synth(\sax_nother, [\bus, stereo_bus, \pbus, param_bus], filt_group);
//      Synth(\sax_chorus, [\bus, stereo_bus], filt_group);
//      Synth(\sax_shaper, [\bus, stereo_bus, \buf, ~shaper_buf_1], filt_group);
//      Synth(\sax_cynk_broad, [\bus, stereo_bus], filt_group);

      Synth(\route_m2s_free_on_silence,
        [\inbus, stereo_bus, \outbus, 0], filt_group, \addAfter);
      },
      bundles
    );

  };
  s.queryAllNodes;
)
