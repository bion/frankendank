HerChords {
  classvar chords;

  *at { |key|
    var value = chords[key];
    if (value.isNil) { Error("HerChords doesn't contain key: " ++ key).throw };
    ^value;
  }

  *add { |key, value|
    chords[key] = value;
    ^this;
  }

  *initClass {
    chords = IdentityDictionary[
      \default -> [PC(\fs, 3), PC(\e, 3), PC(\cs, 3), PC(\a, 2)]
    ];
    chords.keysValuesChange {|key, pitchArray| pitchArray.collect({|pc| pc.freq}) }
  }

}
