HerHarmonyController {
  var <group, <bus, <currentChord, <currentSynth;
  var <>amp=1, synth;

  *new { |group, bus, currentChord, currentSynth|
    ^super.newCopyArgs(group, bus, currentChord, currentSynth).init;
  }

  init {
    synth = Synth(currentSynth, [\bus, bus, \freqs, HerChords.at(\default)], group);
  }

  setAmp { |amp|
    synth.set(\amp, amp);
  }

  setSynth { |synth|
    synth.free;
    synth = Synth(currentSynth,
      [
        \bus, bus,
        \freqs, HerChords[currentChord]
      ],
      group
    );
  }

  setChord { |newChord|
    currentChord = newChord;
    synth.set(\freqs, HerChords[newChord]);
  }

}
