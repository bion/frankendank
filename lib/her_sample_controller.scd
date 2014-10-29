var clock;
var sampleSets;
var currentSetIndex=0;
var currentSet;
var synth, sampleTrig, changeSet, sampleStop;
var nextSampleSet, previousSampleSet;

nextSampleSet = {|obj|
  var nextSet;

  if (sampleSets.size > (currentSetIndex + 1)) {
    nextSet = sampleSets[currentSetIndex + 1];
    changeSet(obj, nextSet);
  }
};

previousSampleSet = {|obj|
  var nextSet;

  if ((currentSetIndex - 1) != -1) {
    nextSet = sampleSets[currentSetIndex - 1];
    changeSet(obj, nextSet);
  }
};

changeSet = {|obj, set|
  currentSet.do {|sample|
    if (sample.playingSynth.isPlaying) { sample.kill };
  };

  currentSet = set;
};

sampleTrig = {|obj, index|
  var offset = (clock.beats - clock.beats.round) * clock.beatDur; // negative if before beat
  var sample = currentSet[index];

  sample.commandQueue = sample.commandQueue.add(
    (
      name: \start,
      arguments: [max(offset, 0), clock]
    )
  );

  if (sample.beatSynced && sample.queued.not && (offset < 0) && sample.looping.not) { fork{
    sample.queued = true;
    offset.abs.wait;
    sample.queued = false;
    sample.execute;
  }} {
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

  currentSet = sampleSets[currentSetIndex];

  (
    changeSet: changeSet,
    sampleTrig: sampleTrig,
    sampleStop: sampleStop,
    nextSampleSet: nextSampleSet,
    previousSampleSet: previousSampleSet
  )
};
