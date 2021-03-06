var group, busses;
var bufDur = 12; // in minutes
var startTime;
var start;
var allocBuffers;
var stop;
var recordingsDir = "../recordings".resolveRelative;
var recordSynths = IdentityDictionary[];
var buffers = IdentityDictionary[];

start = {
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
};

stop = {|self, outputDirName|
  recordSynths.do(_.free);
  "multi track recording stopped".postln;

  post("Writing multitracks to " ++ outputDirName ++ "...");

  outputDirName.mkdir;

  buffers.keysValuesDo {|name, buffer|
    var outputFileName;

    outputFileName = outputDirName ++ "/" ++ name ++ ".aiff";

    buffer.write(
      outputFileName,
      "aiff",
      "float",
      (SystemClock.seconds - startTime) * Server.default.sampleRate
    );
  };

  "done".postln;
};

allocBuffers = {
  busses.keysDo { |name|
    buffers.put(
      name,
      Buffer.alloc(Server.default, bufDur * 60 * Server.default.sampleRate)
    );
  }
};

{ arg ...args;
  #group, busses = args;

  allocBuffers.value;

  (
    startRecording: start,
    stopRecordingAndRender: stop;
  );
};
