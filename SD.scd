(
[
	/* ---------------------------------------- main ---------------------------------------- */

	SynthDef(\v_control, {arg outbus, amp; Out.kr(outbus, LinExp.kr(amp, 0, 127, -60.dbamp, 1)) }),
	SynthDef(\p_control, {arg outbus, param; Out.kr(outbus, param.lag3(0.03) )}),

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

	SynthDef(\horninfo, {
		arg inbus, outbus, lag=0.02;
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
		arg saxbus, tubbus, outbus;
		var sax, tub, out;
		sax = In.ar(saxbus, 1);
		tub = In.ar(tubbus, 1);

		out = sax + tub;
		Out.ar(outbus, out);
	}),

	/* ------------------------ com --------------------------- */
	[
		[1, 0.5, 0.25, 0.15, 0.09, 0.05], // 0
		[1, 0.5, 0.25, 0.15, 0.09, 0.05].squared, // 1
		Array.geom(6, 1, 0.5) // 2
	].collect {|harmAmps, i|
		SynthDef(("dandan" ++ i).asSymbol, {
			arg outbus,
				amp, freq,
				gp, trigOverlap, trigLFOfreq,
				indexLFOfreq, indexLFOlo, indexLFOhi,
				harmLFOlo, harmLFOfreq;
			var vibrato, trig, index, harmAmpLFOs, grains;

			vibrato = SinOsc.kr(7 + LFDNoise3.kr(2).range(0.9, 1.1), 0, 0.0125) + 1;

			trig = Impulse.kr( (gp.reciprocal * trigOverlap) * LFNoise2.kr(trigLFOfreq).range(0.9, 1.1));

			index = LFNoise2.kr(indexLFOfreq).range(indexLFOlo, indexLFOhi);

			harmAmpLFOs = 6.collect { LFNoise2.kr(harmLFOfreq).range(harmLFOlo.dbamp, 1) };

			grains = 0;
			[ 0.998345, 1, 1.01323 ].do {|offset|
				grains = grains + 
					GrainFM.ar(1, trig, gp,
						offset * freq * vibrato * (1 .. 6),
						offset * freq * vibrato * (1 .. 6),
						index,
						0 /* panning */, -1 /* envbuf */, 128 /* num overlaps*/,
						harmAmps * harmAmpLFOs ).mean;
			};

			grains = LeakDC.ar(grains).softclip(0.1);
			Out.ar(outbus, amp * grains);
		})
	},

	/* ------------------------ tuba --------------------------- */

	SynthDef(\tub_s1, {
		arg hornDataBus, bus, gate=1;
		var pitch, hasPitch, amp, onset, control, synth;
		#pitch, hasPitch, amp, onset = In.kr(hornDataBus, 4);
		synth = Pulse.ar(pitch*[1, 1.01, 0.985, 7.midiratio],
			SinOsc.kr(0.1).range(0.3, 0.7), onset.lag3(0.01)*[1, 0.5, 0.5, 0.25]).mean.tanh;
		synth = synth * (amp > 0);
		control = LinExp.kr(amp.ampdb, -32, -10, pitch*0.75, 20000).max(160);
		synth = MoogFF.ar(synth, control, 3.32);
		synth = LeakDC.ar(synth);
		Out.ar(bus, synth*Linen.kr(gate, 0.05, releaseTime: 0.05, doneAction: 2));
	}),

	SynthDef(\tub_s2, {
		arg hornDataBus, bus, gate=1;
		var pitch, hasPitch, amp, onset, control, synth;
		#pitch, hasPitch, amp, onset = In.kr(hornDataBus, 4);
		control = LinExp.kr(amp.ampdb, -32, -10, 0, 1).max(160);
		synth = VarSaw.ar(pitch, width: control.range(0.4, 0.6)) + SinOsc.ar(pitch/2);
		synth = Decimator.ar(synth, 20000, control.range(1.2, 8));
		synth = MoogLadder.ar(synth, control.range(pitch, 25000), control.range(0.03, 0.1), mul: 0.5);
		Out.ar(bus, synth*Linen.kr(gate, 0.05, releaseTime: 0.05, doneAction: 2));
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

	/* ---------------------------------------- filters ---------------------------------------- */

	// sax wahwahwah
	SynthDef(\sax_f1, {
		arg pbus, bus, gate=1;
		var chain, control;
		chain = In.ar(bus, 1);
		control = LinExp.kr(In.kr(pbus), 0, 127, 80, 20000);
		chain = MoogFF.ar(chain, control, 3.2);
		XOut.ar(bus, Linen.kr(gate, 0.05, releaseTime: 0.05, doneAction: 2), chain);
	}),

].flat.do(_.add);
)
