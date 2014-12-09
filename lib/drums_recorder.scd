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
var addRecordCollectionForAction;

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

    tracks.keysValuesDo {|sampleName, recordCollection|
      recordCollection[\events].do {|event|
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
      \scale -> scale,
      \time -> SystemClock.seconds
    ];

    if (tracks[name].isNil) { addRecordCollectionForAction.value(action) };

    tracks[name][\events] = tracks[name][\events].add(event);
  }
};

addRecordCollectionForAction = {|action|
  var relativePath = [
    "samples/drum/",
    action.register,
    "/",
    action.name,
    ".aiff"
  ].join;

  tracks[action.name] = IdentityDictionary[
    \events -> [],
    \relativePath -> relativePath
  ];
};

(
  startRecording: startRecording,
  stopRecording: stopRecording,
  archive: archive,
  record: record
)
