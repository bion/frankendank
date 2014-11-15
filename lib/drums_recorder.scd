var startRecording;
var stopRecording;
var render;
var record;
var tracks;
var renderTrackForEvents;
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

def = SynthDef(\playbuf_simple, {
  |outbus, buf, amp=1|
  Out.ar(outbus, PlayBuf.ar(1, buf, BufRateScale.ir(buf), doneAction: 2)*amp);
});
def = CtkNoteObject(def);

serverOptions = ServerOptions.new
  .memSize_(2**18)
  .numOutputBusChannels_(1)
  .maxNodes_(2**12);

renderTrackForEvents = {|path, events|
  var score = CtkScore.new;

  events.do {|event|
    var ctkBuffer = CtkBuffer(event[\action].buffer.path).addTo(score);
    var time = event[\time] - startTime;
    var note;

    note = def.note(time, ctkBuffer.duration)
      .buf_(ctkBuffer)
      .outbus_(0)
      .amp_(event[\scale]);

    note.addTo(score);
  };

  score.write(
    path: path,
    sampleRate: 44100,
    sampleFormat: \float,
    options: serverOptions
  );
};

render = {|basePath|
  var drumsPath = basePath ++ "drums/";
  drumsPath.mkdir;

  tracks.keysValuesDo {|sampleName, events|
    var trackPath = basePath ++ sampleName ++ ".aiff";
    renderTrackForEvents.value(trackPath, events);
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
