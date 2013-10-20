(
~shaper_buf_1 = CtkBuffer.new(size:1024)
	.fillWithEnv(env:
		Env(
			[-1, -0.1, -0.8, 0, 0.8, 0.1, 1],
			[1, 1, 1, 1, 1, 1].normalizeSum,
			[-3, 3, 6, -6, 1, -1]),
			wavetable: 1
		).load;
~expoatt_buf_1 = CtkBuffer.new(size:1024)
	.fillWithEnv(env:
		Env(
			[0, 1, 0],
			[0.05, 0.95],
			\sin
		),
		wavetable: 1
	).load;
[
	/* ---------------------------------------- main ---------------------------------------- */

	SynthDef(\v_control, {arg outbus, amp; Out.kr(outbus, LinExp.kr(amp, 0, 127, -60.dbamp, 1)) }),
	SynthDef(\p_control, {arg outbus, param; Out.kr(outbus, param.lag3(0.03) )}),

	SynthDef(\control_env_testing, {arg outbus;
		var env;
		env = Control.names([\env]).kr(Env.newClear(64));
		Out.kr(outbus, EnvGen.kr(env, doneAction: 14));
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
		RecordBuf.ar(In.ar(inbus, 1) * env, buf, startpos);
	}),

	SynthDef(\route_mono, {
		arg inbus, outbus;
		Out.ar(outbus, In.ar(inbus, 1) );
	}),

	SynthDef(\route_m2s, {
		arg inbus, outbus;
		Out.ar(outbus, In.ar(inbus, 1) !2)
	}),

	SynthDef(\route_m2s_free_on_silence, {
		arg inbus, outbus;
		var in = In.ar(inbus, 1);
		DetectSilence.ar(in, time: 2.0, doneAction: 14);
		in = Compander.ar(in, in, 0.5, 1.0, 0.05, 0.002, 0.01);
		Out.ar(outbus, in ! 2)
	}),

	SynthDef(\horninfo, {
		arg inbus, outbus, lag=0.005;
		var in, pitch, hasPitch, amp, onset;
		in = In.ar(inbus, 1);
		#pitch, hasPitch = Tartini.kr(in).lag3(lag);
		amp = Amplitude.kr(in).lag3(lag);
		amp = amp * (amp > 0.025);
		onset = Coyote.kr(in);
		Out.kr(outbus, [pitch, hasPitch, amp, onset]);
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

	SynthDef(\agg, {
		arg sax_bus, tub_bus, out_bus,
			d_low_bus, d_med_bus, d_hi_bus,
			drums_mon_bus, tub_mon_bus, sax_mon_bus, com_mon_bus,
			metranome_bus;
		var sax, tub, out,
			d_low, d_med, d_hi;

		sax = In.ar(sax_bus, 1);
		tub = In.ar(tub_bus, 1);

		d_low = In.ar(d_low_bus, 1);
		d_med = In.ar(d_med_bus, 1);
		d_hi = In.ar(d_hi_bus, 1);

		tub = Compander.ar(tub, d_low, 0.75, 1, 1/10, 0.002, \tub_relax.kr(0.02, 0.03));
		sax = Compander.ar(sax, d_med+d_hi, 0.75, 1, 1/10, 0.002, 0.02);

		out = [tub, sax, d_low, d_med, d_hi];
		Out.ar(out_bus, out.sum);

		[drums_mon_bus, tub_mon_bus, sax_mon_bus, com_mon_bus].do {|bus|
			Out.ar(bus, out);
		};
	}),

	SynthDef(\mon, {
		arg inbus, outbus, metranome_bus,
			drum_scale=1, sax_scale=1, tub_scale=1, com_scale=1, met_scale=1;
		var drum, sax, tub, com, out;
		#drum, tub, sax, com = In.ar(inbus, 5);

		out = (drum * drum_scale)
			+ (tub * tub_scale)
			+ (sax * sax_scale)
			+ (com * com_scale)
			+ (In.ar(metranome_bus, 1) * met_scale);
		Out.ar(outbus, out);
	}),

	/* ------------------------ com --------------------------- */

	SynthDef(\dirt_rhode, {
		arg freq, bus, amp_bus, gate=1,
			vib_rate = 11, vib_width = 0.005;
		var sig, env, vib, warm = LFNoise2.kr(vib_rate).range(0.9, 1.1);

		vib_rate = vib_rate * LFDNoise3.kr(2).range(0.9, 1.1);
		vib = SinOsc.kr(vib_rate, 0, vib_width) + LFNoise2.kr(1/vib_rate, vib_width/2) + 1;

		freq = freq * vib;
		sig = Pulse.ar(
			freq * [1, 33.5.midiratio],
			[0.2, 0.1, 0.5]*warm,
			[0.7, 0.3, 0.1]
			).mean;
		sig = MoogFF.ar(sig, freq * 5.75 * warm, 3.1);

		sig = GrainIn.ar(1, Impulse.kr(vib_rate * 1.5 * warm),
			vib_rate.reciprocal,
			sig, envbufnum: ~expoatt_buf_1);

		sig = Integrator.ar(sig, 0.8);

		sig = sig * In.kr(amp_bus, 1) * 4;

		Out.ar(bus, sig * Linen.kr(gate, 0.05, releaseTime: 0.05, doneAction: 2));
	}),

	SynthDef(\fank, {
		arg freq, bus, amp_bus, gate=1,
			vib_rate = 11, vib_width = 0.0125;
		var sig, vib, amp;
		vib_rate = vib_rate * LFDNoise3.kr(2).range(0.9, 1.1);
		vib = SinOsc.kr(vib_rate, 0, vib_width) + LFNoise2.kr(1/vib_rate, vib_width/2) + 1;
		freq = freq + vib;
		amp = In.kr(amp_bus, 1);
		sig = Pulse.ar(freq,
			[
				SinOsc.kr(vib_rate).range(0.2, 0.3),
				SinOsc.kr(vib_rate).range(0.4, 0.5),
				SinOsc.kr(vib_rate).range(0.1, 0.2)
			],
			mul: 0.2
		).mean +
			SinOsc.ar(-7.midiratio * freq, 0, -8.dbamp * 0.2) +
			SinOsc.ar(2 * freq, 0, -8.dbamp * 0.2);

		sig = MoogFF.ar(sig, freq * LinExp.kr(amp, 0, 1, 0.5, 10), 0.2, mul: 2) + sig;
		
		sig = sig * amp * 0.5;

		Out.ar(bus, sig*Linen.kr(gate, 0.05, releaseTime: 0.05, doneAction: 2));
	}),

	/* ------------------------ tuba --------------------------- */

	SynthDef(\tuba_in, {
		arg inbus, outbus, amp=1;
		var in = In.ar(inbus, 1), out;
		out = Compander.ar(in, in, 0.2, 1, 0.25, 0.05, 0.05);
		out = PitchShift.ar(out, 0.15, 0.5, 0, 0.02, 2);
		Out.ar(outbus, amp * out );
	}),

	SynthDef(\tub_s1, {
		arg hornDataBus, pedal_amp_bus, bus, gate=1;
		var pitch, hasPitch, amp, onset, control, synth, out_amp, out;
		#pitch, hasPitch, amp, onset = In.kr(hornDataBus, 4);
		synth = Pulse.ar(pitch*[1, 1.01, 0.985, 7.midiratio],
			SinOsc.kr(0.1).range(0.3, 0.7), [1, 0.5, 0.5, 0.25]).mean.tanh;
		synth = synth * (amp > 0);
		control = LinExp.kr(amp.ampdb, -32, -10, pitch * 0.75, 20000).max(160);
		synth = MoogFF.ar(synth, control, 3.32);
		synth = LeakDC.ar(synth);
		out_amp = In.kr(pedal_amp_bus, 1);
		out = out_amp * synth;
		Out.ar(bus, out * Linen.kr(gate, 0.05, releaseTime: 0.05, doneAction: 2));
	}),

	SynthDef(\tub_s2, {
		arg hornDataBus, pedal_amp_bus, bus, gate=1;
		var pitch, hasPitch, amp, onset, control, synth, out_amp, out;
		#pitch, hasPitch, amp, onset = In.kr(hornDataBus, 4);
		control = LinExp.kr(amp.ampdb, -32, -10, 0, 1).max(160);
		synth = VarSaw.ar(pitch, width: control.range(0.4, 0.6)) + SinOsc.ar(pitch * 0.5);
		synth = synth * (amp > 0);
		synth = Decimator.ar(synth, 20000, control.range(1.2, 8));
		synth = MoogLadder.ar(synth, control.range(pitch, 20000), control.range(0.03, 0.1), mul: 0.5);
		out_amp = In.kr(pedal_amp_bus, 1);
		out = out_amp * synth;
		Out.ar(bus, out * Linen.kr(gate, 0.05, releaseTime: 0.05, doneAction: 2));
	}),

	/* ------------------------------- tuba filters --------------------------------- */

	SynthDef(\tub_comp, {
		arg bus, gate=1;
		var chain;
		chain = In.ar(bus, 1);
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
		arg inbus, outbus, amp=1;
		Out.ar(outbus, amp * In.ar(inbus, 1) );
	}),

	// sax wahwahwah
	SynthDef(\sax_wah, {
		arg pbus, bus, gate=1;
		var chain, control;
		chain = In.ar(bus, 1);
		control = LinExp.kr(In.kr(pbus).lag3(0.03), 0, 127, 80, 20000);
		chain = MoogFF.ar(chain, control, 3.2);
		XOut.ar(bus, Linen.kr(gate, 0.05, releaseTime: 0.05, doneAction: 2), chain);
	}),

	SynthDef(\sax_chorus, {
		arg pbus, bus, gate=1;
		var in, chain, control, noise=LFNoise2.kr(4.dup(3));
		in = In.ar(bus, 1);
		chain = DelayN.ar(in, 0.14, noise.range(0.075, 0.13));
		chain = PitchShift.ar(chain, 0.15, noise.range(0.99, 1.01), 0, 0.005);
		chain = ([in]++chain).mean;
		XOut.ar(bus, Linen.kr(gate, 0.05, releaseTime: 0.05, doneAction: 2), chain);
	}),

	SynthDef(\sax_shaper, {
		arg bus, buf, gate=1;
		var in, chain;
		in = In.ar(bus, 1);
		chain = Shaper.ar(buf, in*2);
		chain = chain * 0.25;
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
			PitchShift.ar(fb * 0.9 + in, 0.15, [-24, -12, -5, 0, 7, 12, 24].midiratio, 0, 0.004).mean;
		}, 0.02);
		XOut.ar(bus, Linen.kr(gate, 0.05, releaseTime: 0.05, doneAction: 2), chain);
	}),

	/* ------------------------------- general filters --------------------------------- */

	SynthDef(\cynk_broad, {
		arg bus, gate=1;
		var layer1, layer2, in, chain;
		in = In.ar(bus, 1);
		chain = Fb({|fb|
			PitchShift.ar(fb * 0.9 + in, 0.15, [-24, -12, -5, 0, 7, 12, 24].midiratio, 0, 0.004).mean;
		}, 0.02);
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
		}, 0.02);
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
	})

].do(_.add);
)
