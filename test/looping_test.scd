s.boot;
s.queryAllNodes;

MIDIIn.doProgramAction(10000, 0, 0); // assign sax
MIDIIn.doProgramAction(20000, 0, 0); // assign tuba
MIDIIn.doProgramAction(30000, 0, 0); // assign drums

(
var source_dir = "~/Dropbox/electric_band_shared_music/raw_horn_samples/".standardizePath;
~sax_buf = Buffer.read(s, source_dir ++ "sax_1.aiff");
~tuba_buf = Buffer.read(s, source_dir ++ "tuba_1.aiff");

~play_tub = {
  b = Synth(\playbuf_simple, [\outbus, ~buss[\tub_spoof], \buf, ~tuba_buf], ~playbuf_g);
};
~play_sax = {
  b = Synth(\playbuf_simple, [\outbus, ~buss[\sax_spoof], \buf, ~sax_buf], ~playbuf_g);
};
)

MIDIIn.doProgramAction(~mSrc[\sax], 0, 0); // touch
MIDIIn.doProgramAction(~mSrc[\sax], 0, 4); // reset
MIDIIn.doProgramAction(~mSrc[\sax], 0, 9); // resetAll

MIDIIn.doProgramAction(~mSrc[\tuba], 0, 0); // touch
MIDIIn.doProgramAction(~mSrc[\tuba], 0, 1); // reset
MIDIIn.doProgramAction(~mSrc[\tuba], 0, 9); // resetAll

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

~play_tub.();
(
var ttnb = ~clock.timeToNextBeat;

~clock.sched(ttnb - 0.1, {
  MIDIIn.doProgramAction(~mSrc[\tuba], 0, 0); // touch
});

~clock.sched(ttnb - 0.1 + 4, {
  MIDIIn.doProgramAction(~mSrc[\tuba], 0, 0); // touch
});
)
b.free;
MIDIIn.doProgramAction(~mSrc[\tuba], 0, 4); // reset
MIDIIn.doProgramAction(~mSrc[\tuba], 0, 0); // touch
