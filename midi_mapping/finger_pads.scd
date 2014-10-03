var comLoop;

"loading midi config finger pads...".post;

MIDIdef.cc(\setFreqLag,
  { |val|
    ~harmonyController.setFreqLag(val);
  },
  1,
  0,
  ~mSrc[\fingerPads]
);

comLoop = HerLoop(
  \com,
  s,
  ~clock,
  ~buss[\com_agg],
  ~record_loop_g,
  ~loop_filt_buss[\com],
  ~play_loop_g
);

MIDIdef.noteOn(\comLoopTouch,
  {
    comLoop.touch;
  },
  43,
  0,
  ~mSrc[\fingerPads]
);

MIDIdef.noteOn(\comLoopToggleReset,
  {
    HerLoop.toggleReset(\com);
  },
  42,
  0,
  ~mSrc[\fingerPads]
);

[
  39, 48, 45,
  36, 38, 40,
].do {|num, index|
  MIDIdef.noteOn(asSymbol("chordSetSelector_" ++ index),
    {
      ~chordSelector.setChordSlot(index);
    },
    num,
    0,
    ~mSrc[\fingerPads]
  );
};

MIDIdef.noteOn(\setHarmonySynthComFank,
  {
    ~harmonyController.setSynth(\com_fank);
  },
  51,
  0,
  ~mSrc[\fingerPads]
);
MIDIdef.noteOn(\setHarmonySynthComDirtRhode,
  {
    ~harmonyController.setSynth(\com_dirt_rhode);
  },
  44,
  0,
  ~mSrc[\fingerPads]
);

MIDIdef.noteOn(\incrementChordGroup,
  {
    ~chordSelector.nextGroup;
  },
  49,
  0,
  ~mSrc[\fingerPads]
);

MIDIdef.noteOn(\decrementChordGroup,
  {
    ~chordSelector.previousGroup;
  },
  46,
  0,
  ~mSrc[\fingerPads]
);

"done".postln;
