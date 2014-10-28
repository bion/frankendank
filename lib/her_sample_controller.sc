HerSampleController {
  var <playBus, <playGroup, clock;
  var <playingBool=false, <currentSet, synth;

  *new {arg ...args;

    args.do {|prop|
      if (args.size != 4 || prop.isNil) {
        var message = "Cannot create HerSampleController with nil property, dumping args: ";
        message = message ++ args.asString;
        Error(message);
      }
    };

    ^super.newCopyArgs(*args)
  }

  changeSet {|set|
    currentSet = set;
  }

  sampleTrig {|index|
    var offset = (clock.beats - clock.beats.round) * clock.beatDur; // negative if before beat
    var thisSample = currentSet[index];

    if (offset < 0.0) { fork {
      offset.abs.wait;
      this.startSampleSynth;
    }} {
      this.startSampleSynth(offset);
    };

    Routine.run({
      wait(thisSample.duration * clock.beatDur + offset);
      // if it's the same sample, play it again
      if (thisSample == samples[currentIndex] && playingBool && thisSample.loopable) {
        this.sampleTrig;
      };
    });
  }

  sampleStop {|index|
    synth.free;
    playingBool = false;
    postln("freed sample synth");
  }

  startSampleSynth {|offset=0|
    var thisSample = samples[currentIndex];

    if (thisSample[\loopable]) {
      thisSample[\looping] = true;
      clock.schedAbs(thisSample.duration, {this.});
    };

    Server.default.makeBundle(0.005, {
      synth = Synth(\playbuf_mono,
        [ \outbus,   playBus,
          \amp,      1,
          \buf,      thisSample.buffer,
          \dur,      thisSample.duration,
          \startpos, offset * Server.default.sampleRate],
        playGroup, \addToTail);
    });
    postln("playing " ++ thisSample.name);
  }
}
