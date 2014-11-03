HerHarmonyController {
  var <synths, <chordSets, <beatDur;
  var <>amp=0, <currentChord, <currentSynthIndex=0, freqLag=0.01, currentSynth;
  var <currentChordSet;

  *new { |synths, chordSets, beatDur|
    ^super.newCopyArgs(synths, chordSets, beatDur).init;
  }

  init {
    // initialize to first chord in first chord group of schema
    currentSynth = synths[0];
    currentSynth.start;
    this.setFreqLag(freqLag);
  }

  setAmp { |amp|
    currentSynth.setAmp(amp);
  }

  setBeatDur { |newBeatDur|
    beatDur = newBeatDur;
    currentSynth.setBeatDur(beatDur);
  }

  incrementSynthIndex {
    if (synths.size > (currentSynthIndex + 1)) {
      this.setSynth(currentSynthIndex + 1);
    }
  }

  decrementSynthIndex {
    if ((currentSynthIndex - 1) != -1) {
      this.setSynth(currentSynthIndex - 1);
    }
  }

  setSynth { |newSynthIndex|
    currentSynth.stop;

    currentSynthIndex = newSynthIndex;
    currentSynth = synths[currentSynthIndex];

    currentSynth.setFreqs(currentChord);
    currentSynth.setBeatDur(beatDur);
    currentSynth.setFreqLag(freqLag);

    currentSynth.start;

    postln("current synth now: " ++ currentSynth.class);
  }

  changeChordSet { |pieceName|
    var chordSet = chordSets[pieceName];
    currentChordSet = chordSet;
    this.setChordAtIndex(0);
  }

  setChordAtIndex { |index|
    if (currentChordSet.size > index) {
      this.setChord(currentChordSet[index]);
    };
  }

  setChord { |chord|
    if (chord.type == \literal) {
      currentChord = chord.pitches.collect {|pitchClass| pitchClass.freq};
    } {
      currentChord = HerChords.at(chord.voicing, chord.pitchClass);
    };

    (10 - currentChord.size).do {|val|
      currentChord = currentChord.add(1);
    };

    currentSynth.setFreqs(currentChord);
  }

  setFreqLag { |val|
    var lag;
    lag = case
    {val < 16}  { lag = 0.01 }
    {val < 32}  { lag = 1/8  }
    {val < 48}  { lag = 1/4  }
    {val < 64}  { lag = 1/2  }
    {val < 80}  { lag = 3/4  }
    {val < 96}  { lag = 1    }
    {val < 112} { lag = 1.5  }
    {val < 128} { lag = 2    };

    currentSynth.setFreqLag(lag);
    freqLag = lag;
    postln("freqLag is: " ++ lag);
  }
}
