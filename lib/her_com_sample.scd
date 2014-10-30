var mainPath = "../samples/com/".resolveRelative;

{ arg playGroup, playBus;
  var startFunc,
      killFunc,
      playAgainIfLoopingFunc,
      execute;

  "Loading lib/com_sample...".post;

  execute = {|obj|
    var hasKill = obj.commandQueue.any({|item| item.name == \kill});
    var hasStart = obj.commandQueue.any({|item| item.name == \start});

    if (hasKill && hasStart) {
      if (obj.playingSynth.isPlaying) { obj.kill };
    } {
      obj.commandQueue.do {|command|
        obj.performList(command.name, command.arguments);
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

  "done".postln;

  {|name, loopable, beatSynced|
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
};
