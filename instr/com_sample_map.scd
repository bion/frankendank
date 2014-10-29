var mainPath = "../samples/com/".resolveRelative,
    playBus,
    playGroup,
    clock,
    sampleFrom,
    startFunc,
    killFunc,
    playAgainIfLoopingFunc,
    execute;

"Loading com sample map...".post;

playAgainIfLoopingFunc = {|obj|
  {
    if (obj.looping) {
      startFunc.value(obj, 0);
    };
  };
};

execute = {|obj|
  var hasKill = obj.commandQueue.any({|item| item.name == \kill});
  var hasStart = obj.commandQueue.any({|item| item.name == \start});

  if (hasKill && hasStart) {
    if (obj.playingSynth.isPlaying) { obj.kill };
  } {
    obj.commandQueue.do {|command|
      obj.perform(command.name, *(command.arguments));
    };
  };

  obj.commandQueue = [];
};

startFunc = {|obj, offset=0|
  Server.default.makeBundle(0.005, {
    obj.playingSynth = Synth(\playbuf_mono,
      [ \outbus,   playBus,
        \amp,      1,
        \buf,      obj.buffer,
        \dur,      obj.buffer.duration - offset,
        \startpos, offset * Server.default.sampleRate ],
      playGroup, \addToTail);
  });

  NodeWatcher.register(obj.playingSynth, true);

  if (obj.loopable) {
    fork {
      obj.looping = true;
      wait(obj.buffer.duration - offset);
      if (obj.looping) { startFunc.value(obj, 0) };
    };
  };

  postln("playing " ++ obj.name);
};

killFunc = {|obj|
  obj.playingSynth.free;
  if (obj.loopable) { obj.looping = false };
};

sampleFrom = {|name, loopable, beatSynced|
  (
    name: name,
    commandQueue: [],
    loopable: loopable,
    looping: false,
    playingSynth: nil,
    start: startFunc,
    kill: killFunc,
    execute: execute,
    buffer: Buffer.read(s, (mainPath ++ name ++ ".aiff")),
    beatSynced: beatSynced,
    queued: false
  )
};

"done".postln;

{arg ...args;
  var sampleSets;
  #clock, playGroup, playBus = args;

  sampleSets = IdentityDictionary[
    \jon1 -> [
      sampleFrom.value("HER1JONSample1", false, false),
      sampleFrom.value("HER1JONSample1wPickup", false, true),
      sampleFrom.value("HER1JONSample2", false, true),
      sampleFrom.value("HER1JONSample3", true, true),
      sampleFrom.value("HER1JONSample4", false, true)
    ]
  ];

  // TODO consolidate the setlist
  [
    \jon1
  ].collect {|setName| sampleSets[setName] };
};
