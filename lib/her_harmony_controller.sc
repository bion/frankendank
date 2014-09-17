HerHarmonyController {
  var <synths, <chordSchema, <beatDur;
  var <>amp=0, <currentChord, <currentSynthIndex=0, freqLag=0.01, currentSynth;

  *new { |synths, chordSchema, beatDur|
    ^super.newCopyArgs(synths, chordSchema, beatDur).init;
  }

  init {
    // initialize to first chord in first chord group of schema
    this.setChord(chordSchema[0][0]);
    this.setFreqLag(freqLag);
  }

  setAmp { |amp|
    currentSynth.setAmp(amp);
  }

  setBeatDur { |newBeatDur|
    beatDur = newBeatDur;
    currentSynth.setBeatDur(beatDur);
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

  setChord { |chord|
    currentChord = HerChords.at(chord.voicing, chord.pitchClass);
    (5 - currentChord.size).do {|val|
      currentChord = currentChord.add(1);
    };
    currentSynth.setFreq(currentChord);
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

    synth.setFreqLag(lag);
    freqLag = lag;
    postln("freqLag is: " ++ lag);
  }
}
