var startRecording;
var stopRecording;
var record;
var tracks;
var recording = false;

stopRecording = {
  Error("unimplimented").throw;
};

startRecording = {
  tracks = IdentityDictionary[];
  recording = true;
};

record = {|action, scale|
  block {|break|
    var event = IdentityDictionary[\action -> action, \scale -> scale];
    var name = action.name;

    if (recording.not) { break.value };

    if (tracks[name].isNil) { tracks[name] = [] };

    tracks[name] = tracks[name].add(event);
  }
};

(
  startRecording: startRecording,
  stopRecording: stopRecording,
  record: record
)
