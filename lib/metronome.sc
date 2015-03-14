Metronome {
  var <clock, <server, <>outbus, <group, <>synthdef, <>amp;
  var beatSched;

  *new {|clock, server, outbus, group, synthdef, amp|
    ^super.newCopyArgs(
      clock, server, outbus, group, synthdef, amp
    ).init;
  }

  init {
    beatSched = BeatSched(tempoClock: clock);
    this.addDependant(beatSched);
    this.start;
  }

  start {
    beatSched.qsched(1.0,
      {
        var onDownbeat = clock.beatInBar.round == 0,
            freq = if (onDownbeat) {3600} {1800};

        s.makeBundle(0.0, {
          Synth(synthdef, [
            \outbus, outbus,
            \amp, amp,
            \freq, freq
          ], group);
        });

        1.0;
      }
    );
  }

  stop {
    beatSched.clear;
  }
}
