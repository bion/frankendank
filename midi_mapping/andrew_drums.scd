(
var andrewPadMap = IdentityDictionary[];
~andrew_midi_map["pad"].keysValuesDo {|key, value|
  andrewPadMap.add( value.asSymbol -> key.asInteger );
};

postln("loading midi config: andrew drums");

MIDIdef.noteOn(
  \andrew,
  {|val, num|
    ~drum_trig.(andrewPadMap[num.asSymbol], val, \andrew)
  },
  nil,
  ~andrew_midi_map["pad"]["chan"].asInteger,
  ~mSrc[\andrew]
);

)