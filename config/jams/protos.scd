var top = (
  parent: currentEnvironment,
  linkNotes: {|self|
    self.notes.collect {|note|
      note.parent = self;
    }
  }
);

(
  noteProto: (
    parent: top,
    duration: 1
  )
);
