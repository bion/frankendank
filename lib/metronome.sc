Metronome {
  var <clock, <server, <>outbus, <group, <>synthdef, <>amp;
  var beatSched;

  *new {|clock, server, outbus, group, synthdef, amp|

    ^super.newCopyArgs(
      clock, server, outbus, group, synthdef, amp
    ).init
  }

  init {
    beatSched = BeatSched(tempoClock: clock);
    this.addDependant(beatSched);
    this.start;
  }

  start {
    beatSched.qsched(1.0,
      {
        Synth(synthdef, [\outbus, outbus, \amp, amp], group);
        1.0;
      }
    );
  }

  stop {
    beatSched.clear;
  }

}
