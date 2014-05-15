HerChords {
  classvar <voicingRatios, c4Freq;

  *at { |voicing, tonicPitchClass|
    var voicingRatioSet, freqs;
    voicingRatioSet = voicingRatios[voicing];
    if (voicingRatioSet.isNil) { Error("HerChords doesn't contain key: " ++ voicing).throw };
    ^voicingRatioSet.collect {|ratio| tonicPitchClass.freq * ratio };
  }

  *add { |name, rawChord|
    var ratios;

    ratios = rawChord.collect {|freqInfo|
      var pitch, octave, freq;
      #pitch, octave = freqInfo;

      PC(pitch, octave).freq / c4Freq;
    };

    voicingRatios.put(name, ratios);
  }

  *initClass {
    /* assumes key of c */
    var rawChords = IdentityDictionary[
      \Xm11 -> [[\g, 3], [\d, 4], [\ef, 4], [\bf, 4], [\f, 5]],
      \X7s9f13 -> [[\e, 4], [\af, 4], [\bf, 4], [\ds, 5]],
      \Xmaj9 -> [[\d, 4], [\e, 4], [\g, 4], [\b, 4]],
      \X7sus -> [[\bf, 3], [\c, 4], [\f, 4]],
      \Xm6 -> [[\ef, 4], [\g, 4], [\a, 4], [\d, 5]],
      \Xm -> [[\ef, 4], [\g, 4], [\c, 5]],
      \XM -> [[\e, 4], [\g, 4], [\c, 5]],
      \Xmaj7 -> [[\g, 3], [\b, 3], [\e, 4]],
      \Xm9 -> [[\d, 4], [\ef, 4], [\g, 4]],
      \Xopen -> [[\g, 3], [\e, 4], [\c, 5]],
      \X7 -> [[\g, 3], [\bf, 3], [\e, 4]],
      \X13 -> [[\e, 4], [\a, 4], [\bf, 4], [\d, 5]],
      \Xdim7 -> [[\fs, 3], [\c, 4], [\ef, 4], [\a, 4]],
      \Xm7 -> [[\ef, 4], [\g, 4], [\bf, 4]],
      \X7s11 -> [[\e, 4], [\fs, 4], [\bf, 4]],
      \Xaug -> [[\gs, 4], [\c, 4], [\e, 4]]
    ];

    voicingRatios = IdentityDictionary[];
    c4Freq = PC(\c, 4).freq;

    rawChords.keysValuesDo {|name, voicingArray|
      var ratios;

      ratios = voicingArray.collect {|freqInfo|
        var pitch, octave, freq;
        #pitch, octave = freqInfo;

        PC(pitch, octave).freq / c4Freq;
      };

      voicingRatios.put(name, ratios);
    };

  }

}
