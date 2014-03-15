MultiTrackRecorder {
  var <buDur, <group, <busses, <path, <>bufDur=12;
  var buffers, recordSynths, startTime;

  *new {
    ^super.newCopyArgs().init;
  }

  init {
    buffers = IdentityDictionary[];
    this.allocBuffers;
  }

  start {
    startTime = SystemClock.seconds;
    busses.keysValuesDo {|name, bus|
      recordSynths.put(
        name,
        Synth(\recordbuf_mono,
          [\inbus, bus, \buf, buffers[name], \startpos, 0],
          group
        )
      );
    };
    "multi track recording started".postln;
  }

  stop {
    buffers.keysValuesDo {|name, buffer|
      buffer.write(
        path ++ "/" ++ Date.getDate ++ "_" ++ name ++ ".aiff",
        numFrames: (SystemClock.seconds - startTime) * Server.default.sampleRate
      );
    };
    "multi track recording stopped".postln;
  }

  /* ------------------------------ private */

  allocBuffers {
    busses.keysDo { |name|
      buffers.put(
        name,
        Buffer.alloc(Server.default, bufDur * 60 * Server.default.sampleRate)
      );
    }
  }

}