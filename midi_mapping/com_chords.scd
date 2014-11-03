var comLoop;

"loading midi config com chords...".post;

MIDIdef.cc(\setFreqLag,
  { |val|
    ~harmonyController.setFreqLag(val);
  },
  1,
  0,
  ~mSrc[\chords]
);

[
  39, 48, 45, 43, 51,
  36, 38, 40, 42, 44
].do {|num, index|
  MIDIdef.noteOn(asSymbol("chordSetSelector_" ++ index),
    {
      ~harmonyController.setChordAtIndex(index);
    },
    num,
    0,
    ~mSrc[\chords]
  );
};

MIDIdef.noteOn(\incrementComSynth,
  {
    ~harmonyController.incrementSynthIndex;
  },
  49,
  0,
  ~mSrc[\chords]
);

MIDIdef.noteOn(\decrementComSynth,
  {
    ~harmonyController.decrementSynthIndex;
  },
  46,
  0,
  ~mSrc[\chords]
);

"done".postln;
