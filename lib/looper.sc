Looper {
  var <server, <instr, <clock, <recordBus, <recordGroup, <playBus,
  <playGroup, <numLoops=4, <maxDur=60;
  var resetLoopBool = false;
  var loops;

  *new { |server, instr, clock, recordBus,
    recordGroup, playBus, playGroup numLoops, maxDur|
    ^super.newCopyArgs(instr, numLoops, maxDur).init;
  }

  init {
    loops = Array.newClear(numLoops);
    numLoops.do {|i|
      loops[i] = IdentityDictionary[
        \buffer ->      Buffer.alloc(server, maxDur * server.sampleRate, 1),
        \next_action -> \record,
        \dur ->         0.0, // loop dur or record touch time
        \recording ->   false,
        \synth ->       nil,
        \responder ->   false,
        \last_touch ->  clock.beats
      ];
    }
  }

  // ****************************** public

  touch { |num|
    var offset = clock.beats - clock.beats.round * clock.beatDur;
    var loopInstance = loops[num], doubleTap;

    postln("LOOP TOUCH " ++ instr ++ " " ++ num);

    doubleTap = (clock.beats - loopInstance[\last_touch]) < 1.5;

    if (resetLoopBool || doubleTap) {
      this.clearLoop(loopInstance);
      ("LOOP " ++ instr ++ " " ++ num ++ " CLEARED");
    } {
      this.perform(loopInstance[\nextAction], loopInstance, offset);
    };

    loopInstance[\lastTouch] = clock.beats;
  }

  resetAll { |instr|
    loops.do { |loopInstance, i|
      if (loopInstance[\synth].notNil) {
        this.stopLoop(loopInstance);
      };
      loopInstance[\next_action] = \record;
      loopInstance[\dur] = 0.0;
      instr ++ " LOOP RESET";
    };
  }

  toggleReset {
    if (resetLoopBool) {
      resetLoopBool = false;
    } {
      resetLoopBool = true;
    };
  }

  // ****************************** private

  clearLoop { |loopInstance|
    if (loopInstance[\synth].notNil) { this.stopLoop(loopInstance) };
    loopInstance[\nextAction] = \record;
    loopInstance[\dur] = 0.0;
    resetLoopBool = false;
  }

  record { |loopInstance, offset|
    if (offset < 0) {
      fork {
        offset.abs.wait;
        this.addRecordSynth(loopInstance);
      }
    } {
      this.addRecordSynth(loopInstance, offset);
    }
  }

  addRecordSynth { |loopInstance, offset|
    loopInstance[\dur] = clock.beats;
    server.makeBundle(0.008, {
      loopInstance[\recording] = Synth(\recordbuf_mono,
        [ \inbus,    recordBus,
          \startpos, offset * server.sampleRate,
          \buf,      loopInstance[\buffer] ],
        recordGroup, \addToHead);
    });
    loopInstance[\nextAction] = \stopRecording;
    postln("RECORDING " ++ instr ++ ", OFFSET: " ++ offset);
  }

  stopRecording { |loopInstance, offset|
    var dur, recordSurplus = 0;
    fork {
      if (offset < 0.0) {offset.abs.wait; offset=0.0};
      dur = clock.beats - loopInstance[\dur];
      loopInstance[\dur] = dur.round;
      this.playLoop(loopInstance, offset);
      loopInstance[\recording].set(\gate, -1.01);
      loopInstance[\next_action] = \stopLoop;
      postln("STOPPED " ++ instr ++ " RECORDING, OFFSET: " ++ offset);
    }
  }

  playLoop { |loopInstance, offset|
    if (offset < 0.0) { fork {
      offset.abs.wait;
      this.addLoopSynth.(loopInstance);
    }} {
      this.addLoopSynth.(loopInstance, offset);
    };
  }

  addLoopSynth { |loopInstance, offset=0|
    var synth;

    server.makeBundle(0.005, {
      synth = Synth(\playbuf_mono,
        [ \outbus,   playBus,
          \amp,      1,
          \buf,      loopInstance[\buffer],
          \dur,      loopInstance[\dur] * clock.beatDur - offset - 0.005,
          \startpos, offset * server.sampleRate],
        playGroup, \addToTail).onFree({loopInstance[\synth] = nil});
    });

    loopInstance.putAll(IdentityDictionary[
      \synth -> synth,
      \responder -> OSCFunc(
        { this.playLoop(loopInstance, clock.beats - clock.beats.round * clock.beatDur) },
        '/n_end', server.addr, nil, [synth.nodeID]
      ).oneShot,
    ]);
    loopInstance[\next_action] = \stopLoop;
    postln("STARTED LOOPING " ++ instr ++ ", OFFSET: " ++ offset);
  }

  stopLoop { |loopInstance, offset|
    loopInstance[\responder].free;
    loopInstance[\synth].set(\gate, -1.03);
    loopInstance.put( \synth -> nil );
    loopInstance[\next_action] = \playLoop;
    postln("KILLED LOOP " ++ instr);
  }

}