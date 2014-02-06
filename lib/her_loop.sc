HerLoop {
  var <name, <instr, <server, <clock, <recordBus, <recordGroup,
  <playBus, <playGroup, <maxDur=60;
  var buffer, nextAction, duration, recording, <synth, responder, lastTouchBeat;
  classvar resetBools, loops;

  *initClass {
    resetBools = IdentityDictionary[\sax -> false, \tuba -> false];
    loops = IdentityDictionary[\sax -> LinkedList.new, \tuba -> LinkedList.new];
  }

  *new {
    |name, instr, server, clock, recordBus, recordGroup, playBus, playGroup, maxDur=60|

    new = super.newCopyArgs(
      name, instr, server, clock, recordBus, recordGroup, playBus, playGroup, maxDur
    ).init;

    loops[instr].add(new);

    ^new;
  }

  *toggleReset { |instr|
    var thisResetBool = resetBools[instr];
    if (thisResetBool) {
      thisResetBool = false;
    } {
      thisResetBool = true;
    };
  }

  *resetAll { |instr|
    loops[instr].do { |herLoop|
      if (herLoop.synth.notNil) { this.stopLoop };
      herLoop.reset;
      postln(name ++ " LOOP RESET");
    };
  }

  // ****************************** public

  touch { |num|
    var offset = (clock.beats - clock.beats.round) * clock.beatDur;
    var doubleTap;

    postln("LOOP TOUCH " ++ instr ++ " " ++ num);

    doubleTap = (clock.beats - lastTouchBeat) < 1.5;

    if (resetBool || doubleTap) {
      this.reset;
      resetBools[instr] = false;
      ("LOOP " ++ instr ++ " " ++ num ++ " CLEARED");
    } {
      this.perform(nextAction, offset);
    };

    lastTouchBeat = clock.beats;
  }

  // ****************************** private

  init {
    buffer =         Buffer.alloc(server, maxDur * server.sampleRate, 1);
    nextAction =     \record;
    duration =       0.0; // loop dur or record touch time
    recording =      false;
    synth =          nil;
    responder =      false;
    lastTouchBeat =  clock.beats;
  }

  resetBool {
    ^resetBools[instr];
  }

  reset {
    if (synth.notNil) { this.stopLoop };
    nextAction = \record;
    duration = 0.0;
    resetBool = false;
  }

  record { |offset|
    if (offset < 0) {
      fork {
        offset.abs.wait;
        this.addRecordSynth;
      }
    } {
      this.addRecordSynth(offset);
    }
  }

  addRecordSynth { |offset|
    duration = clock.beats;
    server.makeBundle(0.008, {
      recording = Synth(\recordbuf_mono,
        [ \inbus,    recordBus,
          \startpos, offset * server.sampleRate,
          \buf,      buffer ],
        recordGroup, \addToHead);
    });
    nextAction = \stopRecording;
    postln("RECORDING " ++ name ++ ", OFFSET: " ++ offset);
  }

  stopRecording { |offset|
    var dur, recordSurplus = 0;
    fork {
      if (offset < 0.0) {offset.abs.wait; offset=0.0};
      dur = clock.beats - duration;
      dur = dur.round;
      this.playLoop(offset);
      recording.set(\gate, -1.01);
      nextAction = \stopLoop;
      postln("STOPPED " ++ name ++ " RECORDING, OFFSET: " ++ offset);
    }
  }

  playLoop { |offset|
    if (offset < 0.0) { fork {
      offset.abs.wait;
      this.addLoopSynth;
    }} {
      this.addLoopSynth(offset);
    };
  }

  addLoopSynth { |offset=0|
    server.makeBundle(0.005, {
      synth = Synth(\playbuf_mono,
        [ \outbus,   playBus,
          \amp,      1,
          \buf,      buffer,
          \dur,      duration * clock.beatDur - offset - 0.005,
          \startpos, offset * server.sampleRate],
        playGroup, \addToTail).onFree({synth = nil});
    });

    responder = OSCFunc(
      { this.playLoop(clock.beats - clock.beats.round * clock.beatDur) },
      '/n_end', server.addr, nil, [synth.nodeID]
    ).oneShot;

    nextAction = \stopLoop;
    postln("STARTED LOOPING " ++ name ++ ", OFFSET: " ++ offset);
  }

  stopLoop { |offset|
    responder.free;
    synth.set(\gate, -1.03);
    synth = nil;
    nextAction = \playLoop;
    postln("KILLED LOOP " ++ name);
  }

}