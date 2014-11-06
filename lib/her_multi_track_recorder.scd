var group, busses;
var bufDur = 12;
var startTime;
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

stop = {
  var outputDirName;

  recordSynths.do(_.free);
  "multi track recording stopped".postln;

  outputDirName = path ++ "/" ++ Date.getDate.asString.replace(" ", "_");
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
    start: start,
    stop: stop;
  );
};
