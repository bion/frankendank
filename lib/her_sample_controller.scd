var clock;
var sampleSets;
var currentSet=[];
var synth, sampleTrig, changeSampleSet, sampleStop;
var nextSampleSet, previousSampleSet;

changeSampleSet = {|obj, pieceName|
  currentSet.do {|sample|
    if (sample.playingSynth.isPlaying) { sample.kill };
  };

  currentSet = sampleSets[pieceName];
};

sampleTrig = {|obj, index|
  var offset = (clock.beats - clock.beats.round) * clock.beatDur; // negative if before beat
  var sample = currentSet[index];
  var delayExecution;

  sample.commandQueue = sample.commandQueue.add(
    (
      name: \start,
      arguments: [max(offset, 0), clock]
    )
  );
  delayExecution =
    sample.beatSynced &&
    sample.looping.not &&
    sample.queued.not &&
    (offset < 0);

  if (delayExecution) {
    fork {
      sample.queued = true; // lock
      offset.abs.wait;
      sample.queued = false;
      sample.execute;
    }
  } {
    sample.execute;
  };
};

sampleStop = {|obj, index|
  var sample = currentSet[index];

  sample.commandQueue = sample.commandQueue.add(
    (
      name: \kill,
      arguments: []
    )
  );

  sample.execute;
  postln("stopped sample: " ++ sample.name);
};

{arg ...args;
  #clock, sampleSets = args;

  (
    update: changeSampleSet,
    sampleTrig: sampleTrig,
    sampleStop: sampleStop
  )
};
