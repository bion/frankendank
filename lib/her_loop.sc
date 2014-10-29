HerLoop {
  var <instr, <server, <clock, <recordBus, <recordGroup,
  <playBus, <playGroup, <maxDur=60;
  var buffer, nextAction, duration, recording, <synth, responder, lastTouchBeat;
  classvar resetBools, loops, persistentSynths;

  *initClass {
    loops = IdentityDictionary.new;
    resetBools = IdentityDictionary.new;
  }

  *setPersistentSynths { |dict|
    persistentSynths = dict;
  }

  *new {
    |instr, server, clock, recordBus, recordGroup, playBus, playGroup, maxDur=60|
    var new;

    new = super.newCopyArgs(
      instr, server, clock, recordBus, recordGroup, playBus, playGroup, maxDur
    ).init;

    if (loops[instr].isNil) {
      loops[instr]      = LinkedList.new;
      resetBools[instr] = false;
    };

    loops[instr].add(new);

    ^new;
  }

  *toggleReset { |instr|
    if (resetBools[instr]) {
      resetBools[instr] = false;
    } {
      resetBools[instr] = true;
    };
    postln("toggled " ++ instr ++ " reset to " ++ resetBools[instr]);
  }

  *resetAll { |instr|
    var theseLoops = loops[instr];
    if (theseLoops.notNil) {
      theseLoops.do { |herLoop|
        if (herLoop.synth.notNil) { herLoop.stopLoop };
        herLoop.reset;
        postln(instr ++ " loop reset");
      };
    } {
      postln("----------------------------------------");
      postln("unrecognized instr for loops reset");
      postln("----------------------------------------");
    };
  }

  *toggleMuteAll { |instr|
    var key, synth;
    key = asSymbol(instr ++ "_loops_route");
    synth = persistentSynths[key];

    synth.get(\amp, { |ampVal|
      synth.set(\amp, ampVal.round.asInt.bitXor(1)); // probably not the best idea
    });
  }

  *releaseAll {
    // TODO
  }

  // ****************************** public

  touch {
    var offset = (clock.beats - clock.beats.round) * clock.beatDur;
    var doubleTap;

    postln("loop touch " ++ instr);

    doubleTap = (clock.beats - lastTouchBeat) < 1.5;

    if (this.resetBool || doubleTap) {
      this.reset;
      resetBools[instr] = false;
      postln(instr ++ " loop cleared");
    } {
      this.perform(nextAction, offset);
    };

    lastTouchBeat = clock.beats;
  }

  // ****************************** private

  init {
    buffer        =  Buffer.alloc(server, maxDur * server.sampleRate, 1);
    nextAction    =  \record;
    duration      =  0.0; // loop dur or record touch time
    recording     =  false;
    synth         =  nil;
    responder     =  false;
    lastTouchBeat =  clock.beats;
  }

  resetBool {
    ^resetBools[instr];
  }

  reset {
    if (synth.notNil) { this.stopLoop };
    nextAction = \record;
    buffer.zero;
    duration = 0.0;
  }

  record { |offset=0.0|
    if (offset < 0) {
      fork { // TODO lock this fork
        offset.abs.wait;
        this.addRecordSynth;
      }
    } {
      this.addRecordSynth(offset);
    }
  }

  addRecordSynth { |offset=0.0|
    duration = clock.beats;
    server.makeBundle(0.005, {
      recording = Synth(\recordbuf_mono,
        [ \inbus,    recordBus,
          \startpos, offset * server.sampleRate,
          \buf,      buffer ],
        recordGroup, \addToHead);
    });
    nextAction = \stopRecording;
    postln("recording " ++ instr ++ ", offset: " ++ offset);
  }

  stopRecording { |offset=0.0|
    fork {
      if (offset < 0.0) {offset.abs.wait; offset=0.0};
      duration = (clock.beats - duration).round;
      this.playLoop(offset);
      recording.set(\gate, -1.01);
      nextAction = \stopLoop;
      postln("stopped " ++ instr ++ " recording, offset: " ++ offset);
    }
  }

  playLoop { |offset=0.0|
    if (offset < 0.0) { fork {
      offset.abs.wait;
      this.addLoopSynth;
    }} {
      this.addLoopSynth(offset);
    };
  }

  addLoopSynth { |offset=0|
    var loopDur = duration * clock.beatDur - offset - 0.005;
    postln("loopDur: " ++ loopDur);
    server.makeBundle(0.005, {
      synth = Synth(\playbuf_mono,
        [ \outbus,   playBus,
          \amp,      1,
          \buf,      buffer,
          \dur,      loopDur,
          \startpos, offset * server.sampleRate],
        playGroup, \addToTail).onFree({synth = nil});
    });

    responder = OSCFunc(
      { this.playLoop(clock.beats - clock.beats.round * clock.beatDur) },
      '/n_end', server.addr, nil, [synth.nodeID]
    ).oneShot;

    nextAction = \stopLoop;
    postln("started looping " ++ instr ++ ", offset: " ++ offset);
  }

  stopLoop { |offset=0.0|
    responder.free;
    synth.set(\gate, -1.03);
    synth = nil;
    nextAction = \playLoop;
    postln("killed " ++ instr ++ " loop ");
  }

}
