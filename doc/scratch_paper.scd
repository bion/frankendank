s.queryAllNodes

~toggle_loop_jam.()

~h_filt.(\sax_f1)
~h_synth.(\sax_s1)

MIDIClient.sources
MIDIClient.init;
MIDIIn.connectAll;

MIDIdef.all;
MIDIdef.freeAll;

MIDIFunc.trace(true);
MIDIFunc.trace(false);

Platform.userConfigDir;

/* ___________________________________________ horn MIDI spoof */

(
  ~h_filt.(\sax_cynk_broad);
  s.queryAllNodes;
  s.boot
  s.quit
  play { LinExp.kr(SinOsc.kr.range(0, 0.7), -32, -10, .max(160).poll }
  ~pSynths;
)
