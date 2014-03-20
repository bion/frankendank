HerHarmonyController {
  var <group, <bus, <currentSynth, <>beatDurBus;
  var <>amp=1, <currentChord, synth;

  *new { |group, bus, currentSynth, beatDurBus|
    ^super.newCopyArgs(group, bus, currentSynth, beatDurBus).init;
  }

  init {
    currentChord = HerChords.at(\Xopen, PC(\c, 4));
    synth = Synth(currentSynth, [\bus, bus, \freqs, currentChord, \beat_dur_bus, beatDurBus], group);
  }

  setAmp { |amp|
    synth.set(\amp, amp);
  }

  setSynth { |synth|
    synth.free;
    synth = Synth(currentSynth,
      [
        \bus, bus,
        \freqs, currentChord
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

    synth.set(\freq_lag_param, lag);
  }

}
