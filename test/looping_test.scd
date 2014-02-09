(
var source_dir = "~/Dropbox/electric_band_shared_music/raw_horn_samples/".standardizePath;
~sax_buf = Buffer.read(s, source_dir ++ "sax_1.aiff");
~tuba_buf = Buffer.read(s, source_dir ++ "tuba_1.aiff");
)

b = Synth(\playbuf_simple, [\outbus, ~buss[\tub_spoof], \buf, ~tuba_buf], ~playbuf_g);
b = Synth(\playbuf_simple, [\outbus, ~buss[\sax_spoof], \buf, ~sax_buf], ~playbuf_g);
a.free;
b.free;

MIDIIn.doProgramAction(~mSrc[\sax], 0, 0); // touch
MIDIIn.doProgramAction(~mSrc[\sax], 0, 4); // reset
MIDIIn.doProgramAction(~mSrc[\sax], 0, 9); // resetAll

MIDIIn.doProgramAction(~mSrc[\tuba], 0, 0); // touch
MIDIIn.doProgramAction(~mSrc[\tuba], 0, 1); // reset
MIDIIn.doProgramAction(~mSrc[\tuba], 0, 9); // resetAll
