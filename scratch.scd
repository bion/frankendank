s.boot
s.quit
play{SinOsc.ar}
play{*In.ar(9, 1)};
play{SoundIn.ar}

~h_filt.(\sax_cynk_broad)
~h_filt.(\sax_wah)
~h_filt.(\sax_chorus);
~h_filt.(\sax_shaper);
~h_filt.(\sax_comp);
s.gui
~h_synth.(\tub_s1)
~h_filt.(\sax_s1)
s.queryAllNodes
MIDIClient.init
MIDIdef.trace(true);
CtkBuffer
Quarks.gui
CmdPeriod.run

[\sax, \tuba, \drums, \com].do {|instr|
  make button
  specify states
  if (~mSrc[instr]) {

  } {

  }
};
