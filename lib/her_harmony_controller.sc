HerHarmonyController {
  var <group, <bus, <currentChord, <currentSynth;
  var <>amp=1, synth;

  *new { |group, bus, currentChord, currentSynth|
    ^super.newCopyArgs(group, bus, currentChord, currentSynth).init;
  }

  init {
    synth = Synth(currentSynth, [\bus, bus, \freqs, HerChords.at(\Xopen, PC(\a, 4))], group);
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

  setChord { |chordVoicing, chordPC|
    currentChord = HerChords.at(chordVoicing, chordPC);
    synth.set(\freqs, currentChord);
  }

}
