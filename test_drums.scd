s.boot;
~paths = "/Users/bionjohnson/Dropbox/Electric Band Shared Music/drum samples/big kicks 2/*".pathMatch;
(
~samples = ~paths.collect {|path|
  Buffer.read(s, path);
};
)

(
a = ~samples[128];
a.postln;
play {
  b = PlayBuf.ar(1, a, BufRateScale.ir(a), doneAction: 2) *
  EnvGen.kr(Env([0, 1, 1, 0], [0.01, 1, 0.02].normalizeSum, \sin), a.duration);
  b!2;
}
)
