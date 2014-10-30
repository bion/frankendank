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
      ~harmonyController.setChordAtIndex(index);
    },
    num,
    0,
    ~mSrc[\fingerPads]
  );
};

MIDIdef.noteOn(\incrementComSynth,
  {
    ~harmonyController.incrementSynthIndex;
  },
  51,
  0,
  ~mSrc[\fingerPads]
);
MIDIdef.noteOn(\decrementComSynth,
  {
    ~harmonyController.decrementSynthIndex;
  },
  44,
  0,
  ~mSrc[\fingerPads]
);

MIDIdef.noteOn(\incrementPiece,
  {
    ~pieceController.nextPiece;
  },
  49,
  0,
  ~mSrc[\fingerPads]
);

MIDIdef.noteOn(\decrementPiece,
  {
    ~pieceController.previousPiece;
  },
  46,
  0,
  ~mSrc[\fingerPads]
);

"done".postln;
