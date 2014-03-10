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
      \default -> [PC(\fs, 4), PC(\e, 4), PC(\cs, 4), PC(\a, 3)]
    ];
    chords.keysValuesChange {|key, pitchArray| pitchArray.collect({|pc| pc.freq}) }
  }

}
