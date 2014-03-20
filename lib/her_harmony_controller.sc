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
    (5 - currentChord.size).do {|val|
      currentChord = currentChord.add(1);
    };
    synth.set(\freqs, currentChord);
  }

}
