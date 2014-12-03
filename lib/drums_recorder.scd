var startRecording;
var stopRecording;
var render;
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

render = {|basePath|
  block {|break|
    var drumsPath = basePath ++ "/drums";
    if (tracks.size == 0) { break.value };

    tracks.keysValuesChange {|sampleName, event|
      event[\time] = event[\time] - startTime;
      event;
    };

    tracks.writeArchive(drumsPath);
  };
};

record = {|action, scale|
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
  render: render,
  record: record
)
