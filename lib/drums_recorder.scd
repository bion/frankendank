var startRecording;
var stopRecording;
var archive;
var record;
var tracks;
var recording = false;
var serverOptions;
var def;
var startTime;
var time;

startRecording = {
  recording = true;
  tracks = IdentityDictionary[];
  startTime = SystemClock.seconds;
};

stopRecording = {
  recording = false;
};

archive = {|self, basePath|
  block {|break|
    var drumsPath = basePath ++ "/drums";
    if (tracks.size == 0) { break.value };

    tracks.keysValuesDo {|sampleName, events|
      events.do {|event|
        event[\time] = event[\time] - startTime;
      };
    };

    File.use(drumsPath, "w", {|f| f.write(tracks.asCompileString)});
  };
};

record = {|self, action, scale|
  block {|break|
    var name = action.name;
    var event;

    if (recording.not) { break.value };

    event = IdentityDictionary[
      \action -> action,
      \scale -> scale,
      \time -> SystemClock.seconds
    ];

    if (tracks[name].isNil) { tracks[name] = [] };

    tracks[name] = tracks[name].add(event);
  }
};

(
  startRecording: startRecording,
  stopRecording: stopRecording,
  archive: archive,
  record: record
)
