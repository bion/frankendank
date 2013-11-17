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
~h_filt.(\sax_nother)
~h_filt.(\sax_delay)
~h_filt.(\sax_bladunner)
s.queryAllNodes
s.makeGui
MIDIClient.init
MIDIdef.trace(true);
CtkBuffer
Quarks.gui
CmdPeriod.run

(
  ~h_filt.(\sax_chorus);
  // ~h_filt.(\sax_shaper);
  // ~h_filt.(\sax_comp);
)

[\sax, \tuba, \drums, \com].do {|instr|
  make button
  specify states
  if (~mSrc[instr]) {

  } {

  }
};

s.boot
(
play{
  a = In.ar(8, 1);
  PitchShift.ar(a, 0.12, 11.midiratio, 0.0, 0.0002) + a;
}
)
