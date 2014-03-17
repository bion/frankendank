HerHarmonyController {
  var <group, <bus, <currentSynth;
  var <>amp=1, <currentChord, synth;

  *new { |group, bus, currentSynth|
    ^super.newCopyArgs(group, bus, currentSynth).init;
  }

  init {
    currentChord = HerChords.at(\Xopen, PC(\c, 4));
    synth = Synth(currentSynth, [\bus, bus, \freqs, currentChord], group);
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
    synth.set(\freqs, currentChord);
  }

}
