HerSampleController {
  var <samples, <playBus, <playGroup, clock;
  var <playingBool=false, currentIndex=0;

  *new {arg ...args;

    args.do {|prop|
      if (args.size < 4 || prop.isNil) {
        var message = "Cannot create HerSampleController with nil property, dumping args: ";
        message = message ++ args.asString;
        Error(message);
      }
    };

    ^super.newCopyArgs(
      args[0], args[1], args[2], args[3]
    )
  }

  playSample {
    var offset = (clock.beats - clock.beats.round) * clock.beatDur; // negative if before beat
    var thisSample = samples[currentIndex];

    if (offset < 0.0) { fork {
      offset.abs.wait;
      this.startSampleSynth;
    }} {
      this.startSampleSynth(offset);
    };

    Routine.run({
      wait(thisSample.duration * clock.beatDur + offset);
      // if it's the same sample, play it again
      if (thisSample == samples[currentIndex] && playingBool) {
        this.playSample;
      };
    });
  }

  startSampleSynth {|offset=0|
    var thisSample = samples[currentIndex], synth;
    Server.default.makeBundle(0.005, {
      synth = Synth(\playbuf_mono,
        [ \outbus,   playBus,
          \amp,      1,
          \buf,      thisSample.buffer,
          \dur,      thisSample.duration,
          \startpos, offset * Server.default.sampleRate],
        playGroup, \addToTail);
    });
  }

  next {
    if (currentIndex < (samples.size - 1)) {
      currentIndex = currentIndex + 1
    };
  }

  previous {
    if (currentIndex > 0) {
      currentIndex = currentIndex + 1
    };
  }

}