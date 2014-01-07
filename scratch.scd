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
~h_synth.(\tub_subbass)
~h_synth.(\tub_s1)
~h_synth.(\tub_s2)
~h_filt.(\sax_s1)
~h_filt.(\sax_nother)
~h_filt.(\sax_nother)
~h_filt.(\sax_delay)
~h_filt.(\sax_bladunner)
s.queryAllNodes
s.makeGui
MIDIClient.init
MIDIdef.trace(true);
MIDIdef.trace(false);
CtkBuffer
Quarks.gui
CmdPeriod.run
~loop_this_jam = false
~loop_this_jam = true
(
    ~change_breath_synth.(
      \com_fank,
      [\bus, ~buss[\com_eq], \amp_bus, ~buss[\breath_v], \freq_lag_bus, ~buss[\freq_lag]],
      ~dirt_rhode_g
    );
)

loadRelative("./instr/"++"drums"++".scd");
