~top = (
  parent: currentEnvironment,
  linkNotes: {|self|
    self.notes.collect {|note|
      note.parent = self;
    }
  }
);

~noteProto = (
  parent: ~top,
  duration: 1
);

~bassline = (
  parent: ~noteProto,
  action: \basicSynth,
  synth: \bass_s1,
  curve: -3,
  notes: [
    (
      pitch: PC(\a, 4),
      beats: [2, 2.5]
    )
  ]
);

~bassline.linkNotes;
