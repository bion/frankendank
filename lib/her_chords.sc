HerChords {
  classvar voicingRatios;

  *at { |key|
    var value = chords[key];
    if (value.isNil) { Error("HerChords doesn't contain key: " ++ key).throw };
    ^value;
  }

  *at { |voicing, key, octave|
    var
  }

  *add { |key, value|
    chords[key] = value;
    ^this;
  }

  *initClass {
    /* assumes tonic is c */
    var rawChords = IdentityDictionary[
      \Cm11 -> [[\g, 3], [\d, 4], [\ef, 4], [\bf4], [\f, 5]],
      \C7s9f13 -> [[\e, 4], [\af, 4], [\bf, 4], [\ds, 5]],
      \Cmaj9 -> [[\d, 4], [\e, 4], [\g, 4], [\b, 4]],
      \C7sus -> [[\bf, 3], [\c, 4], [\f4]],
      \Cm6 -> [[\ef, 4], [\g, 4], [\a, 4], [\d, 5]],
      \Cmaj7 -> [[\g, 3], [\b, 3], [\e, 4]],
      \Cm9 -> [[\d, 4], [\ef, 4], [\g, 4]],
      \C -> [[\g, 3], [\e, 4], [\c, 5]],
      \C7 -> [[\g, 3], [\bf, 3], [\e, 4]],
      \C13 -> [[\e, 4], [\a, 4], [\bf, 4], [\d, 5]],
      \Cdim7 -> [[\fs, 3], [\c, 4], [\ef, 4], [\a, 4]],
      \Caug -> [[\gs, 4], [\c, 4], [\e, 4]]
    ];

    chords.keysValuesChange {|key, pitchArray| pitchArray.collect({|pc| pc.freq}) }
  }

}
