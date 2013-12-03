s.boot;

~buf = Buffer.read(s, "~/dev/frankendank/samples/drum/low/Kick1.aiff".standardizePath);

(
	play{
		var input, trig, play, amp;
		input = In.ar(10)*50;
		amp = Max.kr(input).poll;
		trig = Coyote.kr(input);
		LinExp.kr(amp, 0.05, 1.0, -12.dbamp, 12.dbamp) * PlayBuf.ar(1, ~buf, BufRateScale.ir(~buf), trig, 0, 0);
	};
)
