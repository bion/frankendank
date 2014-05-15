(
postln("loading midi config: finger pads");

MIDIdef.cc(\setFreqLag,
  { |val|
    ~harmonyController.setFreqLag(val);
  },
  1,
  0,
  ~mSrc[\fingerPads]
);

[
  39, 48, 45, 43,
  36, 38, 40, 42
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

MIDIdef.noteOn(\trigSample,
  {
    ~sampleController.playSample;
  },
  49,
  0,
  ~mSrc[\fingerPads]
);

MIDIdef.noteOn(\prevSample,
  {
    ~sampleController.previous;
  },
  44,
  0,
  ~mSrc[\fingerPads]
);

MIDIdef.noteOn(\trigSample,
  {
    ~sampleController.next;
  },
  46,
  0,
  ~mSrc[\fingerPads]
);

)
