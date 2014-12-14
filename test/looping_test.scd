s.boot;
s.queryAllNodes;

MIDIIn.doProgramAction(10000, 0, 0); // assign sax
MIDIIn.doProgramAction(30000, 0, 0); // assign drums

(
var source_dir = "~/Dropbox/electric_band_shared_music/raw_horn_samples/".standardizePath;
~sax_buf = Buffer.read(s, source_dir ++ "sax_1.aiff");

~play_sax = {
  b = Synth(\playbuf_simple, [\outbus, ~buss[\sax_spoof], \buf, ~sax_buf], ~playbuf_g);
};
)

MIDIIn.doProgramAction(~mSrc[\sax], 0, 0); // touch
MIDIIn.doProgramAction(~mSrc[\sax], 0, 4); // reset
MIDIIn.doProgramAction(~mSrc[\sax], 0, 9); // resetAll

// before / before
~play_sax.();
(
var ttnb = ~clock.timeToNextBeat;

~clock.sched(ttnb - 0.1, {
  MIDIIn.doProgramAction(~mSrc[\sax], 0, 0); // touch
});

~clock.sched(ttnb - 0.1 + 4, {
  MIDIIn.doProgramAction(~mSrc[\sax], 0, 0); // touch
});
)

b.free;
MIDIIn.doProgramAction(~mSrc[\sax], 0, 4); // reset
MIDIIn.doProgramAction(~mSrc[\sax], 0, 0); // touch

// before / after
~play_sax.();
(
var ttnb = ~clock.timeToNextBeat;

~clock.sched(ttnb - 0.1, {
  MIDIIn.doProgramAction(~mSrc[\sax], 0, 0); // touch
});

~clock.sched(ttnb + 0.1 + 4, {
  MIDIIn.doProgramAction(~mSrc[\sax], 0, 0); // touch
});
)
b.free;
MIDIIn.doProgramAction(~mSrc[\sax], 0, 4); // reset
MIDIIn.doProgramAction(~mSrc[\sax], 0, 0); // touch

// after / before
~play_sax.();
(
var ttnb = ~clock.timeToNextBeat;

~clock.sched(ttnb + 0.1, {
  MIDIIn.doProgramAction(~mSrc[\sax], 0, 0); // touch
});

~clock.sched(ttnb - 0.1 + 4, {
  MIDIIn.doProgramAction(~mSrc[\sax], 0, 0); // touch
});
)
b.free;
MIDIIn.doProgramAction(~mSrc[\sax], 0, 4); // reset
MIDIIn.doProgramAction(~mSrc[\sax], 0, 0); // touch

// after / after
~play_sax.();
(
var ttnb = ~clock.timeToNextBeat;

~clock.sched(ttnb + 0.1, {
  MIDIIn.doProgramAction(~mSrc[\sax], 0, 0); // touch
});

~clock.sched(ttnb + 0.1 + 4, {
  MIDIIn.doProgramAction(~mSrc[\sax], 0, 0); // touch
});
)
b.free
MIDIIn.doProgramAction(~mSrc[\sax], 0, 4); // reset
MIDIIn.doProgramAction(~mSrc[\sax], 0, 0); // touch

MIDIIn.doProgramAction(~mSrc[\sax], 0, 9); // resetAll
