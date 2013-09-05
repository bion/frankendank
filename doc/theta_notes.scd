chain = PV_Whiten(chain, trackbuf, relax / (BufSamples.kr(fftbuf) * 0.5), floor, smear);

{
	var trig, pos, starttime = 0;
	trig = Dust.kr(1);
	pos = (starttime + (Sweep.kr(1, 1) - (trig * Line.kr(0, 5, 10))));
}.plot(10)

		msg = AudioMSG.ar(in, index * Amplitude.kr(in)); // 0 < index < 0.5pi
		msg = PitchShift.ar(msg, 0.11, psamt, 0, 0.02) * envgen;

	inputenv = EnvGen.kr(Env([0, 1, 0], [1, 1], \sin, 1), gate, doneAction: 0);
		outenv = EnvGen.kr(Env([1, 1, 1, 0], [1, 5, 5], [0, 0, -4], 1), gate, doneAction: 2);
		src = BBandPass.ar(
			GrayNoise.ar,
			LFNoise2.ar([0.02, 0.03, 0.035]).range(300, 5000),
			0.1).sum;
		src2 = In.ar(inbus, 1) * inputenv;
		input = (src+src2) * inputenv;
		fft = FFT(buffer, input);
		fft2 = FFT(buffer2, src2);
		fft2 = PV_NoiseSynthP(fft2, (1.0 - (Amplitude.kr(src2) * 2)).max(0.5));
		fft = PV_RandWipe(fft2, fft, Amplitude.kr(src2, 0.01, 0.2) * 20);
		ifft = IFFT(fft);
		ifft = Limiter.ar(LeakDC.ar(Balance.ar(ifft, Amplitude.ar(src2))));
		ifft = GVerb.ar(HPF.ar(ifft, 300), 200, 50, 0.9, 0.9);
		ifft = ifft * outenv;

	SynthDef(\harms, {arg outbus, cleanout = 1, routebus, routeout = 1,
			buffer, startpos, fftbuf, envbuf, winrate = 4, windur = 10, rate;
		var pb, out, chain, dell, delr, bfout, env, envgen;
		pb = BufGrainB.ar(Impulse.kr(rate * LFNoise0.kr(1).range(0.9, 1.1)),
			windur * LFNoise0.kr(1).range(0.9, 1.1),
			buffer,
			LFNoise0.kr(1).range(0.9, 1.2),
			(startpos / BufDur.kr(buffer)) * LFNoise0.kr(1).range(1, 1.1),
			envbuf);
		chain = FFT(fftbuf, pb);
		chain = PV_MinMagN(chain, LFNoise1.kr(0.2).range(180, 220));
		chain = PV_BrickWall(chain, 0.1);
		out = IFFT(chain);
		out = out + PitchShift.ar(out, 0.11, [0.5, 0.33, 0.23, 0.14], 0, 0.02).sum;
		#dell, delr = DelayN.ar(out, 0.002, LFNoise1.ar(0.1).range(0.001, 0.002)).dup;
		bfout = BFEncode1.ar(dell, 0.5pi) + BFEncode1.ar(delr, -0.5pi);
		Out.ar(outbus, bfout * cleanout);
		Out.ar(routebus, out * routeout);


			delay = SelectXFocus.ar(partial + LFNoise2.kr(0.1),
			BarkDelay.ar(In.ar(inbus), Array.fill(25, {Rand.new(0.5, 0.9)}),
				Array.fill(25, {Rand.new(0.5, 0.9)}), 1), 4);		bass = RLPF.ar(
			CombC.ar(delay, 0.02, Rand(40, 50.0).dup(4).reciprocal, 25).sum,
			Rand(75, 100), 0.1);
		bass = Compander.ar(bass, bass, -12.dbamp, 1.0, 0.1);


			src = PlayBuf.ar(1, buffer, rate, 1, starttime * BufSampleRate.kr(buffer)); // * srcBoost;
		env = Control.names([\env]).kr(Env.newClear.asArray);
		envgen = EnvGen.kr(env, doneAction: 2, timeScale: dur);
		envTrack = Amplitude.ar(src).max(0.001);
		noise = Resonz.ar(LPF.ar(GrayNoise.ar, 1000 + (4000 * envTrack)) * envTrack,
			centerfreq * [0.49, 0.7, 1, 2.03, 4.2], 0.01).sum;
		Out.ar(outbus, BFEncode1.ar((noise * envgen), loc, 0))


			ps = (PitchShift.ar(In.ar(inbus), winsize,
			XLine.kr(start, end, dur) * [1, 0.5], 0.01, 0.5) * [1, 0.3]).sum;


		// use the viola / viola note as a filter. Spread with stereo spreader, reverb then
	// spatialize
	SynthDef(\violaFilt, {arg inbus, outbus, buffer, specBuffer, freezeWait = 1;
		var in, chain1, chain2, out, revl, revr, l, r;
		in = In.ar(inbus, 1);
		chain1 = FFT(buffer, in);
		chain2 = FFT(specBuffer, in + HPF.ar(in, 500, 24.dbamp));
		chain1 = PV_SpectralMap(chain1, chain2, 0.05, Line.kr(-1, 0.001, freezeWait), 1, -1);
		out = IFFT(chain1) * EnvGen.kr(
			Env([0, 0, 1], [freezeWait, 0.1], \sin));
		#revl, revr = GVerb.ar(out, 140, 8);
		#l, r = Spreader.ar(out);
		out = BFEncodeSter.ar(revl + l, revr + r);
		Out.ar(outbus, out);
		}),



		SynthDef(\violaFiltPast, {arg inbus, pastin, outbus, buffer, specBuffer, freezeWait = 1;
		var in, chain1, chain2, out, revl, revr, l, r, in2;
		in = In.ar(inbus, 1);
		in2 = In.ar(pastin, 1);
		chain1 = FFT(buffer, in);
		chain2 = FFT(specBuffer, in2 + HPF.ar(in2, 500, 24.dbamp));
		chain1 = PV_SpectralMap(chain1, chain2, 0.05, Line.kr(-1, 0.001, freezeWait), 1, -1);
		out = IFFT(chain1) * EnvGen.kr(
			Env([0, 0, 1], [freezeWait, 0.1], \sin));
		#revl, revr = GVerb.ar(out, 140, 8);
		#l, r = Spreader.ar(out);
		out = BFEncodeSter.ar(revl + l, revr + r);
		Out.ar(outbus, out);
		}),



	
