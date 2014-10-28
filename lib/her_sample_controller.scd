var playBus, playGroup, clock;
var currentSet, synth, sampoleTrig, changeSet, sampleStop;

  changeSet = {|obj, set|
    currentSet = set;
  };

  sampleTrig = {|obj, index|
    var offset = (clock.beats - clock.beats.round) * clock.beatDur; // negative if before beat
    var sample = currentSet[index];

    if (offset < 0.0) { fork {
      offset.abs.wait;
      startSampleSynth.value(sample);
    }} {
      startSampleSynth.value(sample, offset);
    };
  };

  sampleStop = {|obj, index|
    sample = currentSet[index];
    sample.kill;
    postln("stopped sample: " ++ sample.name);
  }

  privateStartSampleSynth = {|sample, offset=0|
    var sample = currentSet[sample, index];

    if (sample[\loopable]) {
      sample[\looping] = true;
      clock.schedAbs(sample.duration, {this.});
    };

    Server.default.makeBundle(0.005, {
      synth = Synth(\playbuf_mono,
        [ \outbus,   playBus,
          \amp,      1,
          \buf,      sample.buffer,
          \dur,      sample.duration,
          \startpos, offset * Server.default.sampleRate],
        playGroup, \addToTail);
    });
    postln("playing " ++ sample.name);
  }

{arg ...args;
  #playBus, playGroup, clock = args;
  (
    changeSet: changeSet,
    sampleTrig: sampleTrig,
    sampleStop: sampleStop
  )
};
