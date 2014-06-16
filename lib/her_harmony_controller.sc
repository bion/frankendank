HerHarmonyController {
  var <group, <bus, <currentSynth, <>beatDur;
  var <>amp=1, <currentChord, <synth, freqLag;

  *new { |group, bus, currentSynth, beatDurBus|
    ^super.newCopyArgs(group, bus, currentSynth, beatDurBus).init;
  }

  init {
    currentChord = HerChords.at(\Xopen, PC(\c, 4));
    synth = Synth(currentSynth, [\bus, bus, \freqs, currentChord, \beat_dur, beatDur], group);
  }

  setAmp { |amp|
    synth.set(\amp, amp);
  }

  setSynth { |newSynthName| // symbol
    currentSynth = newSynthName;
    postln("current synth now: " ++ currentSynth);
    synth.free;
    synth = Synth(currentSynth,
      [
        \bus, bus,
        \freqs, currentChord,
        \bear_dur, beatDur
      ],
      group
    );
  }

  setChord { |chord|
    currentChord = HerChords.at(chord.voicing, chord.pitchClass);
    (5 - currentChord.size).do {|val|
      currentChord = currentChord.add(1);
    };
    synth.set(\freqs, currentChord);
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

    if (lag != freqLag) {
      synth.set(\freq_lag_param, lag);
      freqLag = lag;
      postln("freqLag is: " ++ lag);
    };
  }

}
