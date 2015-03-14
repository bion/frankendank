var protos = "../protos.scd".loadRelative[0];
var schema;
var bassline;

schema = (
  barsInForm: 4,
  beatsPerBar: 4
);

bassline = (
  parent: protos.noteProto,
  action: \basic_synth,
  synthName: \bass_s1,
  envCurve: -3,
  cutOffFreq: 200,
  notes: [
    (
      pitch: PC(\a, 4),
      times: [(bars: [1, 2, 3, 4], beats: [2, 2.5])]
    )
  ]
);
bassline.linkNotes;

(
  name: \mits,
  gestures: [bassline],
  schema: schema
);
