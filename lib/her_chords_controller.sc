HerChordsController {
  var <group, <bus, <>chords, <currentChord, <currentSynth;
  var <>amp=1, synth;

  *new { |group, bus, chords, currentChord, currentSynth|
    ^super.newCopyArgs(group, bus, chords, currentChord, currentSynth).init;
  }

  init {
    synth = Synth(currentSynth, [\bus, bus], group);
  }

  changeSynth { |synth|
    synth.free;
    synth = Synth(currentSynth,
      [
        \bus, bus,
        \freqs, chords[currentChord]
      ],
      group
    );
  }

  setAmp { |amp|
    synth.set(\amp, amp);
  }

  changeChord { |newChord|
    currentChord = newChord;
    synth.set(\freqs, chords[newChord]);
  }

}
