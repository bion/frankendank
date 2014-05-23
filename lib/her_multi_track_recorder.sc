HerMultiTrackRecorder {
  var <group, <path, <busses, <>bufDur;
  var buffers, recordSynths, startTime;

  *new { | group, path, busses, bufDur=12 |
    ^super.newCopyArgs(group, path, busses, bufDur).init;
  }

  init {
    recordSynths = IdentityDictionary[];
    this.allocBuffers;
    ^this;
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
      var outputFileName;

      recordSynths[name].free;
      postln("freed record synth for " ++ name);

      outputFileName = path ++ "/" ++ Date.getDate ++ "_" ++ name ++ ".aiff";

      postln("writing " ++ name ++ " buff to " ++ outputFileName);

      buffer.write(
        outputFileName,
        "aiff",
        "float",
        (SystemClock.seconds - startTime) * Server.default.sampleRate
      );
    };

    "multi track recording stopped".postln;
  }

  /* ------------------------------ private */

  allocBuffers {
    buffers = IdentityDictionary[];
    busses.keysDo { |name|
      buffers.put(
        name,
        Buffer.alloc(Server.default, bufDur * 60 * Server.default.sampleRate)
      );
    }
  }

}
