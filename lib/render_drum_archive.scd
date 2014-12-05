var addNotesToScore;
var loadBuffer;
var def;
var addNotesToScore;
var serverOptions;

serverOptions = ServerOptions()
  .memSize_(2**18)
  .numOutputBusChannels_(1)
  .maxNodes_(2**12);

def = SynthDef(\playBuffer, {
    |amp, rate, buf, outbus|
    var sig;
    sig = PlayBuf.ar(1, buf, BufRateScale.ir(buf) * rate);
    Out.ar(outbus, sig * amp ! 2);
  });

def = CtkNoteObject(def);

loadBuffer = {|path, score|
  var buffer = CtkBuffer(path);
  score.add(buffer);
  buffer;
};

addNotesToScore = {|noteRecords, buffer, score|
  noteRecords.do {|event|
    var time = event[\time];
    var scale = event[\scale];
    var note;

    note = def.note(time, buffer.duration)
      .rate_(1)
      .buf_(buffer)
      .outbus_(0)
      .amp_(scale);

    note.addTo(score);
  };
};

{|name, samplePath, noteRecords, drumArchivePath|
  var score = CtkScore.new;
  var buffer = loadBuffer.value(samplePath, score);

  addNotesToScore.value(noteRecords, buffer, score);

  score.write(
    path: (drumArchivePath ++ ".aiff"),
    sampleRate: 44100,
    sampleFormat: \float,
    options: serverOptions
  );
};
