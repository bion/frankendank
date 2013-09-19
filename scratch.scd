SynthDef(\dandan, {
	|outBus, amp, pPos, pSpread, freq, envBuf, freqMul,
	env, dur, trigLFOfreq = 0.2, trigOverlap = 3.5,
	trigLFOrange = 20, trigLFOMul, gp = 0.12,
	vibeRate = 6.5, vibeWidth = 0.0125,
	harmLFOfreq = 0.5, harmLFOlo = -0.01,
	indexLFOfreq = 0.2, indexLFOlo = 0.5, indexLFOhi = 5|
	var grains, trig, pan, index, harmAmpLFOs, harmAmps,
		vib, rand, vibosc, vibwth, vibamp;

	vibamp = EnvGen.kr(Env([0.001, 1, 1, 0.001], [0.6, dur - 0.7, 0.1], \exp));
	vibwth = vibeWidth * vibamp;
	vibosc = SinOsc.kr(vibeRate + LFDNoise3.kr(2).range(0.9, 1.1), 0, vibwth);
	rand = LFNoise1.kr(1/6.5, vibwth);
	vib = vibosc + rand + 1;

	trig = Impulse.kr(
		(gp.reciprocal * trigOverlap) * (
			LFNoise2.kr(trigLFOfreq)
				.range(trigLFOrange / 2 * 0.01.neg, trigLFOrange / 2 * 0.01)
			* trigLFOMul + 1
		 )
	);

	pan = (TRand.kr(-1, 1, trig) * pSpread) + pPos;

	index = LFNoise2.kr(indexLFOfreq).range(indexLFOlo, indexLFOhi);

	harmAmps = Control.names(\harmAmpArray).kr(7.collect { 0 });
	harmAmpLFOs = 7.collect { LFNoise2.kr(harmLFOfreq).range(harmLFOlo.dbamp, 1) };

	grains = GrainFM.ar(2, trig, gp,
		freq * vib * (1 .. 7) * freqMul,
		freq * vib * (1 .. 7) * freqMul, index,
		pan, envBuf, 128,
		harmAmps * harmAmpLFOs ).mean;

	grains = LeakDC.ar(grains);
	OffsetOut.ar(outBus, env * amp * grains);
}),
