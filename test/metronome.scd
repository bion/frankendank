s.boot

SynthDef(\test, {|outbus, amp| var out = Decay.ar(SinOsc.ar, 0.2, amp); DetectSilence.ar(Decay.ar(SinOsc.ar, 0.2, amp), 0.01, doneAction: 2); Out.ar(outbus, out)}).add;

a = TempoClock(2);
b = 0;
c = Group.new(s);
m = Metronome(a, s, b, c, \test, 1);

m.stop;
m.start;

a.tempo_(0.5);
a.tempo_(3);
