"loading midi config com samples...".post;

[
  39, 48, 45, 43, 51
].do {|num, index|
  MIDIdef.noteOn(asSymbol("sampleTrig_" ++ index),
    {
      ~samplesController.sampleTrig(index);
    },
    num,
    0,
    ~mSrc[\samples]
  );
};

[
  36, 38, 40, 42, 44
].do {|num, index|
  MIDIdef.noteOn(asSymbol("sampleStop_" ++ index),
    {
      ~samplesController.sampleStop(index);
    },
    num,
    0,
    ~mSrc[\samples]
  );
};

MIDIdef.noteOn(\incrementPiece,
  {
    ~pieceController.nextPiece;
  },
  49,
  0,
  ~mSrc[\samples]
);

MIDIdef.noteOn(\decrementPiece,
  {
    ~pieceController.previousPiece;
  },
  46,
  0,
  ~mSrc[\samples]
);

"done".postln;
