(
if (~config_loaded_flag.isNil) { Error("load config before SD").throw };

loadRelative("./sd_support.scd");
[
  /* ---------------------------------------- main ---------------------------------------- */

  SynthDef(\v_control, {arg outbus, amp;
    var off = amp > 2;
    Out.kr(outbus, (LinExp.kr(amp, 0, 127, -40.dbamp, 1) * off).lag3(0.01));
  }),

  SynthDef(\p_control_lag, {arg outbus, param; Out.kr(outbus, param.lag3(0.01) )}),

  SynthDef(\p_control, {arg outbus, param; Out.kr(outbus, param )}),

  SynthDef(\metronome_sine, {
    arg outbus, amp;
    var out, env;
    env = EnvGen.kr(Env.perc(0.001, 0.05, amp, -4), doneAction: 2);
    out = SinOsc.ar(1800, 0, env);
    Out.ar(outbus, out);
  }),

  SynthDef(\drumTrigListener, {
    arg inbus, outbus;
    var in, trig;
    in = In.ar(inbus, 1);
    in = LPF.ar(in, 400);
    trig = Coyote.kr(in);
    Out.kr(outbus, trig);
  }),

  SynthDef(\triggeredPlayBuf, {
    arg trigbus, outbus, buf, amp=1;
    var trig, out;
    trig = In.kr(trigbus, 1);
    out = PlayBuf.ar(1, buf, BufRateScale.kr(buf), loop: 0, trigger: trig);
    Out.ar(outbus, out * amp);
  }),

  SynthDef(\control_env_testing, {arg outbus;
    var env;
    env = Control.names([\env]).kr(Env.newClear(64));
    Out.kr(outbus, EnvGen.kr(env, doneAction: 14));
  }),

  SynthDef(\playbuf_stereo_to_mono_to_mons, {
    arg buf, sax_mon, tub_mon, drums_mon, nugs_mon, com_mon, amp;
    var out;
    out = PlayBuf.ar(2, buf, BufRateScale.ir(buf), loop: 1) * amp;
    [sax_mon, tub_mon, drums_mon, nugs_mon, com_mon].do {|bus|
      Out.ar(bus, out);
    };
  }),

  SynthDef(\playbuf_mono, {
    arg outbus, buf, dur, startpos=0, amp=1, gate=1;
    Out.ar(outbus,
      Linen.kr(gate, releaseTime: 0.02, doneAction: 2) *
      EnvGen.kr(Env([0, 1, 1, 0], [0.01, 1, 0.01].normalize), amp,
        timeScale: dur, doneAction: 2) *
      PlayBuf.ar(1, buf, BufRateScale.ir(buf), startPos: startpos, doneAction: 2));
  }),

  SynthDef(\playbuf_simple, {
    arg outbus, buf, amp=1;
    Out.ar(outbus, PlayBuf.ar(1, buf, BufRateScale.ir(buf), doneAction: 2)*amp);
  }),

  SynthDef(\recordbuf_mono, {
    arg inbus, buf, startpos, gate=1;
    var env = Linen.kr(gate, 0.01, releaseTime: 0.01, doneAction: 2);
    RecordBuf.ar(In.ar(inbus, 1) * env, buf, startpos, recLevel: 0.dbamp, preLevel: 0);
  }),

  SynthDef(\route_mono, {
    arg inbus, outbus;
    Out.ar(outbus, In.ar(inbus, 1) );
  }),

  SynthDef(\route_mono_amp, {
    arg inbus, outbus, amp=1;
    Out.ar(outbus, In.ar(inbus, 1) * amp.lag(0.05) );
  }),

  (1..8).collect {|i|
    SynthDef(asSymbol("route_mono_to_" ++ i), {
      arg inbus;
      Out.ar(\outbusses.ir(8 ! i), In.ar(inbus, 1));
    })
  },

  SynthDef(\route_4_chans_to_mono, {
    arg inbusses, outbus;
    Out.ar( outbus, In.ar(inbusses, 4).sum );
  }),

  SynthDef(\sax_loop_sum, {
    arg inbusses, outbus;
    var out, ins, ons;
    ins = In.ar(inbusses, 4);
    ons = 4.collect {|i| Amplitude.kr(ins[i]) > 0 };
    out = ins.sum * ((ons.sum + 0.1).reciprocal.lag3(0.01));
    out = Compander.ar(out, out, 0.25, 1, 1/3, 0.002, 0.02);
    Out.ar( outbus, out );
  }),

  SynthDef(\route_m2s, {
    arg inbus, outbus;
    Out.ar(outbus, In.ar(inbus, 1) ! 2)
  }),

  SynthDef(\route_m2s_free_on_silence, {
    arg inbus, outbus;
    var in = In.ar(inbus, 1);
    DetectSilence.ar(in, time: 5.0, doneAction: 14);
    in = Compander.ar(in, in, 0.5, 1.0, 0.05, 0.002, 0.01);
    Out.ar(outbus, in ! 2)
  }),

  SynthDef(\sax_info, {
    arg inbus, outbus, lag=0.05;
    var in, pitch, hasPitch, amp, onset;
    in = In.ar(inbus, 1);
    #pitch, hasPitch = Tartini.kr(in);
    amp = Amplitude.kr(in);
    amp = amp * (amp > ~sax_gate_thresh).lag3(~horn_gate_lag);
    onset = Coyote.kr(in);
    Out.kr(outbus, [pitch.lag3(lag), hasPitch, amp.lag3(0.015) * 0.5, onset]);
  }),

  SynthDef(\tuba_info, {
    arg inbus, outbus, lag=0.0001;
    var in, pitch, hasPitch, amp, onset;
    in = In.ar(inbus, 1);
    #pitch, hasPitch = Tartini.kr(in);
    amp = Amplitude.kr(in);

    amp = amp * (amp > ~tuba_gate_thresh).lag3(~horn_gate_lag);
    onset = Coyote.kr(in);
    Out.kr(outbus, [pitch.lag3(0.001), hasPitch, amp.lag3(0.025) * 0.5, onset]);
  }),

  SynthDef(\sax_eq, {
    arg inbus, outbus;
    var in, out;
    in = In.ar(inbus, 1);
    Out.ar(outbus, in);
  }),

  SynthDef(\tub_eq, {
    arg inbus, outbus, vbus;
    var in, out;
    in = In.ar(inbus, 1);
    Out.ar(outbus, in);
  }),

  SynthDef(\com_eq, {
    arg inbus, outbus, vbus;
    var in, out;
    in = In.ar(inbus, 1);
    Out.ar(outbus, in);
  }),

  SynthDef(\agg, {
    arg drums_low_record_bus, drums_med_record_bus, drums_hi_record_bus,
    computer_record_bus, sax_record_bus, tuba_record_bus,
    sax_bus, tub_bus, com_bus, d_low_bus, d_med_bus, d_hi_bus,
    metronome_bus, sample_bus,
    drums_mon_bus, tub_mon_bus, sax_mon_bus, com_mon_bus, nugs_mon_bus,
    outbus;
    var sax, tuba, com, out, metronome, sample,
      d_low, d_med, d_hi;

    sax = In.ar(sax_bus, 1);
    tuba = In.ar(tub_bus, 1);
    com = In.ar(com_bus, 1);

    d_low = In.ar(d_low_bus, 1);
    d_med = In.ar(d_med_bus, 1);
    d_hi = In.ar(d_hi_bus, 1);

    metronome = In.ar(metronome_bus, 1);
    sample = In.ar(sample_bus, 1);

    tuba = Compander.ar(tuba, tuba, -50.dbamp, 1, 1/6, 0.002, \tub_relax.kr(0.1, 0.03)) * 6.dbamp;
    tuba = Compander.ar(tuba, d_low, -36.dbamp, 1, 1/2.5, 0.002, \tub_relax.kr(0.1, 0.03));

    Out.ar(outbus, [tuba, sax, com, d_low, d_med, d_hi, sample].sum);

    [drums_mon_bus, nugs_mon_bus, tub_mon_bus, sax_mon_bus, com_mon_bus].do {|bus|
      Out.ar(bus, [tuba, sax, com, sample, d_low + d_med + d_hi]);
    };

    Out.ar(tuba_record_bus, tuba);
    Out.ar(sax_record_bus, sax);
    Out.ar(computer_record_bus, com);
    Out.ar(drums_hi_record_bus, d_hi);
    Out.ar(drums_med_record_bus, d_med);
    Out.ar(drums_low_record_bus, d_low);
  }),

  SynthDef(\mon, {
    arg inbus, outbus, metronome_bus, main_scale, sample_scale=1,
      drum_scale=1, sax_scale=1, tub_scale=1, com_scale=1, met_scale=1;
    var drums, sax, tuba, com, out, sample,
      instr, metronome;

    #tuba, sax, com, sample, drums = In.ar(inbus, 5);
    metronome = In.ar(metronome_bus, 1) * met_scale;

    instr = (drums * drum_scale)
      + (sample * sample_scale)
      + (tuba * tub_scale)
      + (sax * sax_scale)
      + (com * com_scale);

    out = instr + metronome;
    Out.ar(outbus, out * main_scale);
  }),

  /* ------------------------ com --------------------------- */

  SynthDef(\com_dandan, {
    arg bus, amp, gate = 1, freqLagParam = 0.03, beatDur=1,
    gp = 0.12, envBuf, harm_amp_lag = 0.2,
    harmLFOfreq = 5, harmLFOlo = -0.01,
    indexLFOfreq = 0.2, indexLFOlo = 0.5, indexLFOhi = 5;

    var sig, index, harmAmpLFOs, harmAmps, freqs, silencers, freqLag,
    vib, rand, vibosc, vibwth, vibamp, vibeRate = 6.5, vibeWidth = 0.0125,
    trigLFOfreq = 0.25, trigLFOMul = 1.5, trigLFOrange = 20, trigOverlap = 3.5;

    envBuf = ~ugen_support[\sin_buf_1];

    freqLag = freqLagParam * beatDur;

    freqs = \freqs.kr([1, 1, 1, 1, 1]).lag(freqLag);
    silencers = freqs.collect { |freq| freq > 9.0; };

    vibamp = 1;
    vibwth = vibeWidth * vibamp;
    vibosc = SinOsc.kr(vibeRate + LFDNoise3.kr(2).range(0.9, 1.1), 0, vibwth);
    rand = LFNoise1.kr(1/6.5, vibwth);
    vib = vibosc + rand + 1;

    index = LFNoise2.kr(indexLFOfreq).range(indexLFOlo, indexLFOhi);

    harmAmps = \harmAmpArray.kr(7.collect { 0 }).lag(harm_amp_lag);
    harmAmpLFOs = 7.collect { LFNoise2.kr(harmLFOfreq).range(harmLFOlo.dbamp, 1) };

    sig = freqs.collect({
      arg freq, i;
      var trig;

      trig = Impulse.kr(
        (gp.reciprocal * trigOverlap) * (
          LFNoise2.kr(trigLFOfreq)
          .range(trigLFOrange / 2 * 0.01.neg, trigLFOrange / 2 * 0.01)
          * trigLFOMul + 1
        )
      );

      GrainFM.ar(1, trig, gp,
        freq * vib * (1 .. 7),
        freq * vib * (1 .. 7), index,
        0, envBuf, 128,
        harmAmps * harmAmpLFOs,
        mul: silencers[i]
      ).mean;
    }).sum * 0.0125;

    sig = LeakDC.ar(sig) * amp;
    Out.ar(bus, sig.softclip * Linen.kr(gate, 0.05, releaseTime: 0.05, doneAction: 2));
  }),

  SynthDef(\com_fank, {
    arg bus, amp, vib_rate = 11, freqLagParam = 0.03, beatDur=1, vib_width = 0.00125, gate=1;
    var sig, vib, freqs, silencers, ampMul, freq_lag;

    freq_lag = beatDur * freqLagParam;

    // TODO wire up controller for this
    // freq_lag = 0.1;

    freqs = \freqs.kr([1, 1, 1, 1, 1]).lag(freq_lag);

    silencers = freqs.collect { |freq| freq > 9.0; };

    vib_rate = vib_rate * LFDNoise3.kr(2).range(0.9, 1.1);
    vib = SinOsc.kr(vib_rate, 0, vib_width) + LFNoise2.kr(1/vib_rate, vib_width/2) + 1;
    freqs = freqs * vib;

    sig = freqs.collect({|freq, i|
      var thisSig;
      thisSig = Pulse.ar(freq,
      [
        SinOsc.kr(vib_rate).range(0.2, 0.3),
        SinOsc.kr(vib_rate).range(0.4, 0.5),
        SinOsc.kr(vib_rate).range(0.1, 0.2)
      ],
      mul: 0.2 * silencers[i]).mean +
      SinOsc.ar(-7.midiratio * freq, 0, -8.dbamp * 0.2) +
      SinOsc.ar(2 * freq, 0, -8.dbamp * 0.2);

      MoogFF.ar(thisSig, freq * 10, 0.2, mul: 2) + thisSig;
    }).sum;

    ampMul = LinExp.kr(amp, 0, 64, -60.dbamp, -4.dbamp).lag3(0.002) * (amp > 0);
    sig = sig * ampMul * 0.25;

    Out.ar(bus, sig.softclip * Linen.kr(gate, 0.05, releaseTime: 0.05, doneAction: 2));
  }),

  SynthDef(\com_dirt_rhode, {
    arg bus, amp, vib_rate = 11, freqLagParam=0.03, beatDur=1, vib_width = 0.00125, gate=1;
    var sig, env, vib, warm = LFNoise2.kr(vib_rate).range(0.9, 1.1);
    var silencers, freqs, ampMul, detuneMuls, freq_lag;

    freq_lag = beatDur * freqLagParam;

    freqs = \freqs.kr([1, 1, 1, 1, 1]).lag(freq_lag);

    silencers = freqs.collect { |freq| freq > 9.0; };

    vib_rate = vib_rate * LFDNoise3.kr(2).range(0.9, 1.1);
    vib = SinOsc.kr(vib_rate, 0, vib_width) + LFNoise2.kr(1/vib_rate, vib_width/2) + 1;
    freqs = freqs * vib;

    sig = freqs.collect {|freq, i|
      MoogFF.ar(
        Pulse.ar(
          freq * [1.00121312, 0.99843, 1, 33.5.midiratio],
          [0.2, 0.1, 0.5]*warm,
          [0.7, 0.3, 0.1],
          silencers[i]
        ).mean,
        freq * 5.75 * warm,
        0.2
      );
    }.mean;

    sig = LeakDC.ar(sig);

    sig = AudioMSG.ar(sig, 8);

    ampMul = LinExp.kr(amp, 0, 127, -60.dbamp, -4.dbamp).lag3(0.002) * (amp > 0);

    sig = sig * ampMul;

    Out.ar(bus, sig.softclip * Linen.kr(gate, 0.05, releaseTime: 0.05, doneAction: 2));
  }),

  /* ------------------------ tuba --------------------------- */

  SynthDef(\tuba_in, {
    arg inbus, outbus, amp=1;
    var out = In.ar(inbus, 1);
    out = LPF.ar(out, 400);
    out = Compander.ar(out, out, -24.dbamp, 1, 0.25, 0.05, 0.05, 1);
    Out.ar(outbus, amp * out);
  }),

  SynthDef(\tub_subbass, {
    arg hornDataBus, pedal_amp_bus, bus, gate=1;
    var pitch, hasPitch, amp, onset, control, synth, out;
    #pitch, hasPitch, amp, onset = In.kr(hornDataBus, 4);

    synth = SinOsc.ar(pitch.lag3(0.0015) * 0.5, 0, amp * 0.25);

    synth = synth * (amp > 0).lag3(~horn_gate_lag);

    out = synth * In.kr(pedal_amp_bus, 1);
    Out.ar(bus, out * Linen.kr(gate, 0.05, releaseTime: 0.05, doneAction: 2));
  }),

  SynthDef(\tub_s1, {
    arg hornDataBus, pedal_amp_bus, bus, gate=1;
    var pitch, hasPitch, amp, onset, control, synth, out;
    #pitch, hasPitch, amp, onset = In.kr(hornDataBus, 4);

    synth = Pulse.ar(
        pitch * [1, 1.0008564, 0.998432, 2] * 0.5,
        SinOsc.kr(0.1).range(0.3, 0.7),
        [1, 0.5, 0.5, 0.125]
      ).mean;

    synth = synth * (amp > 0).lag3(~horn_gate_lag);

    control = LinExp.kr(amp.ampdb, -52, -20, pitch * 1.2, 15000).max(160);

    synth = MoogFF.ar(synth, control, 0.25);

    synth = LeakDC.ar(synth);

    out = Compander.ar(synth, synth, -42.dbamp, 1, 1/6, 0.002, 0.02);

    out = synth * In.kr(pedal_amp_bus, 1);

    Out.ar(bus, out * Linen.kr(gate, 0.05, releaseTime: 0.05, doneAction: 2));
  }),

  SynthDef(\tub_s2, {
    arg hornDataBus, pedal_amp_bus, bus, gate=1;
    var pitch, hasPitch, amp, onset, synth, out_amp, out, lowpass_control;
    var sawControl, decBitControl, controlAmp, delayControl;
    #pitch, hasPitch, amp, onset = In.kr(hornDataBus, 4);
    controlAmp = amp.lag3(0.01);

    sawControl = LinExp.kr(controlAmp, -32.dbamp, -10.dbamp, 0.35, 0.85).lag3(0.05);
    synth = VarSaw.ar(pitch * [0.9983291, 1, 1.001213], 0, width: sawControl).mean;

    synth = synth * (amp > 0).lag3(~horn_gate_lag);

    synth = Integrator.ar(synth, 0.72, -16.dbamp);

    out = synth * In.kr(pedal_amp_bus, 1) * 1.5;
    Out.ar(bus, out * Linen.kr(gate, 0.05, releaseTime: 0.05, doneAction: 2));
  }),

  SynthDef(\tub_s3, {
    arg hornDataBus, pedal_amp_bus, bus, gate=1;
    var signal, filtC1, filtC2, attackTime = 0.2, amp, out,
    modFreqEnv, mod, controlAmp, onset, pitch, hasPitch,
    fadeEnv, att, cancel;

    #pitch, hasPitch, amp, onset = In.kr(hornDataBus, 4);

    fadeEnv = EnvGen.kr(
      Env([1, -1], [0.15], \lin),
      gate: onset
    );

    att = Decay.kr(onset, 0.25);

    controlAmp = amp.lag3(0.02);

    signal = VarSaw.ar(
        [1.00432123, 1, 1.001231, 0.99123, 0.9992131] * pitch,
        0,
        [0.3, 0.7]
    ).mean;

    out = signal;

    out = signal * Slew.kr(amp, 10000, 1000);

    out = AudioMSG.ar(out, 0.453245/3);

    out = Compander.ar(out, out, 0.0575, 1, 1/10, 0.002, 0.05) * 16;

    Out.ar(bus, out * Linen.kr(gate, 0.05, releaseTime: 0.05, doneAction: 2));
  }),

  /* ------------------------------- tuba filters --------------------------------- */

  SynthDef(\tub_comp, {
    arg bus, gate=1;
    var chain = In.ar(bus, 1);
    chain = Compander.ar(chain, chain,
      thresh: -16.dbamp,
      slopeBelow: 1,
      slopeAbove: 0.25,
      clampTime: 0.05,
      relaxTime: 0.05
    );
    XOut.ar(bus, Linen.kr(gate, 0.05, releaseTime: 0.05, doneAction: 2), chain);
  }),

  /* ------------------------ sax --------------------------- */

  SynthDef(\sax_s1, {
    arg hornDataBus, bus, gate=1;
    var chain, in;
    in = In.ar(bus, 1);
    chain = Compander.ar(in, in, 0.5, 1, 1/10, 0.001, 0.02, 4);
    chain = FFT(LocalBuf(2**9), chain);
    chain = PV_MagAbove(chain, 50);
    chain = PV_SpectralEnhance(chain, 2, 2, 0.85);
    chain = IFFT(chain);
    chain = Integrator.ar(chain, 0.8);
    chain = LPF.ar(chain, 3200) + HPF.ar(chain, 3200).tanh;
    Out.ar(bus, chain*Linen.kr(gate, 0.05, releaseTime: 0.05, doneAction: 2));
  }),

  /* ------------------------------- sax filters --------------------------------- */

  SynthDef(\sax_in, {
    arg inbus, outbus, contactGateBus, amp=4;
    var in, gate, micGate, contactGate;
    in = In.ar(inbus, 1);
    micGate = Amplitude.kr(in).lag3(~horn_gate_lag) > ~sax_gate_thresh;
    contactGate = Amplitude.kr(In.ar(contactGateBus, 1)).lag3(~horn_gate_lag) > -62.dbamp;

    in = in * micGate * contactGate;
    in = HPF.ar(in, 240, 0.5);
    Out.ar(outbus, amp * in );
  }),

  SynthDef(\sax_bladunner, {
    arg bus, gate=1;
    var in, chain;
    in = In.ar(bus, 1);
    chain = GVerb.ar(in, 16, 0.84, damping: 0.5, inputbw: 0.9, spread: 0,
      drylevel: -12.dbamp, earlyreflevel: 0.dbamp, taillevel: -6.dbamp).mean;
    chain = FFT(LocalBuf(2**10), chain, 0.25);
    chain = PV_SpectralEnhance(chain, 2, 2, 0.4);
    chain = IFFT(chain);
    chain = Integrator.ar(chain, 0.8) * (-18.dbamp);
    XOut.ar(bus, Linen.kr(gate, 0.05, releaseTime: 0.05, doneAction: 2), chain);
  }),

  SynthDef(\sax_nother, {
    arg bus, pbus, gate=1;
    var in, chain, control;
    in = In.ar(bus, 1);

    chain = FFT(LocalBuf(2**10), in, 0.25);
    chain = PV_MagNoise(chain);
    chain = IFFT(chain) * 1.5;

    control = In.kr(pbus, 1);
    control = LinLin.kr(control, 0, 127, -1, 1);
    chain = XFade2.ar(in, chain, control);

    XOut.ar(bus, Linen.kr(gate, 0.05, releaseTime: 0.05, doneAction: 2), chain);
  }),

  SynthDef(\sax_8vdown, {
    arg bus, gate=1, info_bus;
    var in, chain, saw;
    in = In.ar(bus, 1);

    chain = PitchShift.ar(in, 0.2, [1, 0.5], 0.0, 0.004, [0.0625, 1]);
    chain[0] = CombC.ar(chain[0], 0.001, 0.0006, 0.01);
    chain[0] = Shaper.ar(~ugen_support[\shaper_buf_1], chain[0] * 40) / 40;

    XOut.ar(bus, Linen.kr(gate, 0.05, releaseTime: 0.05, doneAction: 2), chain.sum);
  }),

  // sax wahwahwah
  SynthDef(\sax_wah, {
    arg pbus, bus, gate=1;
    var chain, control;
    chain = In.ar(bus, 1);
    control = LinExp.kr(In.kr(pbus).lag3(0.01), 0, 127, 400, 3000);
    chain = MoogFF.ar(chain, control, 1.2, 0, 4.5.dbamp);
    XOut.ar(bus, Linen.kr(gate, 0.05, releaseTime: 0.05, doneAction: 2), chain);
  }),

  SynthDef(\sax_chorus, {
    arg bus, maxdelay=0.05, gate=1;
    var in, chorus, chain;
    in = In.ar(bus, 1);
    chorus = Array.fill(8, {|i|
      DelayC.ar(in, maxdelay,
        LFNoise1.kr([0.1, 0.2412, 0.331, 0.46767].wrapAt(i)).range(0.001, maxdelay))
    });
    chain = (chorus + in).mean;
    XOut.ar(bus, Linen.kr(gate, 0.05, releaseTime: 0.05, doneAction: 2), chain);
  }),

  SynthDef(\sax_shaper, {
    arg bus, buf, gate=1;
    var in, chain;
    in = In.ar(bus, 1);
    chain = Compander.ar(in, in, -32.dbamp, 1, 1/10, 0.02, 0.002) * 40;
//    chain = Shaper.ar(~ugen_support[\shaper_buf_1], chain);
    chain = chain.distort;
    chain = chain * 0.125;
    XOut.ar(bus, Linen.kr(gate, 0.05, releaseTime: 0.05, doneAction: 2), chain);
  }),

  SynthDef(\sax_comp, {
    arg bus, gate=1;
    var chain;
    chain = In.ar(bus, 1);
    chain = Compander.ar(chain, chain,
      thresh: -16.dbamp,
      slopeBelow: 0.5,
      slopeAbove: 4,
      clampTime: 0.002,
      relaxTime: 0.01
    );
    XOut.ar(bus, Linen.kr(gate, 0.05, releaseTime: 0.05, doneAction: 2), chain);
  }),

  SynthDef(\sax_cynk_broad, {
    arg bus, gate=1;
    var layer1, layer2, in, chain;
    in = In.ar(bus, 1);
    chain = Fb({|fb|
      PitchShift.ar(fb * 0.9 + in, 0.085, [-24, -12, -5, 0, 7, 12, 24].midiratio, 0, 0.002).mean;
    }, 0.0005);
    chain = chain * 2;
    XOut.ar(bus, Linen.kr(gate, 0.05, releaseTime: 0.05, doneAction: 2), chain);
  }),

  SynthDef(\sax_reverb, {
    arg bus, gate=1, pbus;
    var in, chain, delay;
    in = In.ar(bus, 1);
    delay = In.kr(pbus, 1) / 127 * 4;
    delay = LinLin.kr(In.kr(pbus, 1), 0, 127, 0.3, 4);
    chain = GVerb.ar(in, 80, delay, 0.5, 0.5, 0, 0)[0] * (delay > 0.2);
    chain = chain * (delay > 0.32);
    chain = chain + in;
    XOut.ar(bus, Linen.kr(gate, 0.05, releaseTime: 0.05, doneAction: 2), chain);
  }),

  /* ------------------------------- loop filters --------------------------------- */

  SynthDef(\amp_filt, {
    arg bus, param, gate=1;
    var chain, amp;
    amp = LinExp.kr(param, 0, 127, 1, -46.dbamp);
    chain = amp * In.ar(bus, 1);
    XOut.ar(bus, Linen.kr(gate, 0.05, releaseTime: 0.05, doneAction: 2), chain);
  }),

  SynthDef(\DFM1_hi, {
    arg bus, param, gate=1;
    var chain, freq;
    chain = In.ar(bus, 1);
    freq = LinExp.kr(param, 0, 127, 20, 10000);
    chain = DFM1.ar(chain, freq, 0.1, 1, 1.0);
    XOut.ar(bus, Linen.kr(gate, 0.05, releaseTime: 0.05, doneAction: 2), chain);
  }),

  SynthDef(\DFM1_lo, {
    arg bus, param, gate=1;
    var chain, freq;
    chain = In.ar(bus, 1);
    freq = LinExp.kr(param, 0, 127, 10000, 20);
    chain = DFM1.ar(chain, freq, 0.1, 1, 0.0);
    XOut.ar(bus, Linen.kr(gate, 0.05, releaseTime: 0.05, doneAction: 2), chain);
  }),

  SynthDef(\integrator, {
    arg bus, param, gate=1;
    var chain, fac;
    chain = In.ar(bus, 1);
    fac = LinLin.kr(param, 0, 127, 0.5, 0.9);
    chain = Integrator.ar(chain, fac);
    XOut.ar(bus, Linen.kr(gate, 0.05, releaseTime: 0.05, doneAction: 2), chain);
  }),

  SynthDef(\decimator, {
    arg bus, param, gate=1;
    var chain, bits, ampComp;
    chain = In.ar(bus, 1);
    bits = LinLin.kr(param, 0, 127, 31, 2);
    ampComp = LinExp.kr(param, 0, 127, 1, -15.dbamp);
    chain = Decimator.ar(chain, 44100, bits, mul: ampComp);
    XOut.ar(bus, Linen.kr(gate, 0.05, releaseTime: 0.05, doneAction: 2), chain);
  }),

  /* ------------------------------- general filters --------------------------------- */

  SynthDef(\cynk_broad, {
    arg bus, gate=1;
    var layer1, layer2, in, chain;
    in = In.ar(bus, 1);
    chain = Fb({|fb|
      PitchShift.ar(fb * 0.9 + in, 0.15, [-24, -12, -5, 0, 7, 12, 24].midiratio, 0, 0.004).mean;
    }, 0.005);
    XOut.ar(bus, Linen.kr(gate, 0.05, releaseTime: 0.05, doneAction: 2), chain);
  }),

  SynthDef(\cynk_hi, {
    arg bus, gate=1;
    var layer1, layer2, in, chain;
    in = In.ar(bus, 1);
    chain = Fb({|fb|
      PitchShift.ar(fb * 0.9 + in, 0.15, [0, 7, 12, 24].midiratio, 0, 0.004).mean;
    }, 0.02);
    XOut.ar(bus, Linen.kr(gate, 0.05, releaseTime: 0.05, doneAction: 2), chain);
  }),

  SynthDef(\cynk_lo, {
    arg bus, gate=1;
    var layer1, layer2, in, chain;
    in = In.ar(bus, 1);
    chain = Fb({|fb|
      PitchShift.ar(fb * 0.9 + in, 0.15, [-24, -12, -7, 0].midiratio, 0, 0.004).mean;
    }, 0.002);
    XOut.ar(bus, Linen.kr(gate, 0.05, releaseTime: 0.05, doneAction: 2), chain);
  }),

  SynthDef(\general_chorus, {
    arg pbus, bus, gate=1;
    var in, chain, control, noise=LFNoise2.kr(4.dup(3));
    in = In.ar(bus, 1);
    chain = PitchShift.ar(in, 0.15, noise.range(0.999, 1.001), 0, 0.005);
    chain = ([in]++chain).mean;
    XOut.ar(bus, Linen.kr(gate, 0.05, releaseTime: 0.05, doneAction: 2), chain);
  }),

  SynthDef(\chorus_compress, {
    arg bus, gate=1;
    var in = In.ar(bus, 1), chain;
    chain = Array.fill(4, {
      var max_delay = rrand(0.01, 0.03);
      DelayC.ar(in, max_delay, LFDNoise3.kr(Rand(0.1, 0.6), 0.25 * max_delay, 0.75 * max_delay));
    });
    chain = Compander.ar(4 * (in + chain), in, 0.4, 1, 8);
    chain = chain * 0.125;
    XOut.ar(bus, Linen.kr(gate, 0.05, releaseTime: 0.05, doneAction: 2), chain);
  }),

  SynthDef(\shaper, {
    arg bus, buf, gate=1;
    var in, chain;
    in = In.ar(bus, 1);
    chain = Shaper.ar(buf, in);
    XOut.ar(bus, Linen.kr(gate, 0.05, releaseTime: 0.05, doneAction: 2), chain);
  }),

  SynthDef(\distort, {
    arg bus, buf, gate=1;
    var in, chain;
    in = In.ar(bus, 1);
    chain = Shaper.ar(buf, in);
    XOut.ar(bus, Linen.kr(gate, 0.05, releaseTime: 0.05, doneAction: 2), chain);
  }),

  SynthDef(\dissonance, {
    arg bus, diss=1, gate=1;
    var in, chain;
    in = In.ar(bus, 1);
    chain = Array.fill(24, {
      arg i;
      var centerFreq = (36+(i*4)).midicps,
        modFreq = 2.27*(centerFreq**4.77);
        ((1.0-diss) + (diss*SinOsc.kr(modFreq*0.5, 2pi.rand)))*BPF.ar(in, centerFreq, 0.29)
    }).sum;
    chain = LeakDC.ar(chain);
    chain = Compander.ar(chain, chain, -4.dbamp, 1, 1/3, 0.002, 0.04);
    XOut.ar(bus, Linen.kr(gate, 0.05, releaseTime: 0.05, doneAction: 2), chain);
  }),

  /* ------------------------------- test ugens --------------------------------- */

  SynthDef(\mouse_x_out, {|outbus, lo, hi, warp=0| Out.kr(outbus, MouseX.kr(lo, hi, warp))}),

  SynthDef(\control_stub, {|bus, value| Out.kr(bus, value) })

].flat.do(_.add);

"SD loaded".postln;
)
