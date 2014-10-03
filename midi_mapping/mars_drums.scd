"loading midi config mars drums...";

MIDIdef.noteOn(
  \drum_pad,
  {|val, num|
    ~drum_trig.(("drum_" ++ num).asSymbol, val, \mars)
  },
  nil,
  0,
  ~mSrc[\drum_pad]
);

"done".postln;