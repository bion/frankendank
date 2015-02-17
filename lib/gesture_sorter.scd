var gestureSpecStrategyLibrary;
var convenienceArgExpander = "./convenience_arg_expander.scd".loadRelative[0];
var sortGesture;
var sort;
var expandNote;
var resolveNoteTimes;
var initializeGestureContainer;
var cascadeDefaultsInProperty;
var cascadeDefaults;

sort = { |self, piece|
  var sortedGestures = initializeGestureContainer.value(piece.schema);

  /* this is nil when evaluated in a var dec in the top scope... fml */
  gestureSpecStrategyLibrary = ~dirToEvent.value(~baseDir ++ "/lib/gesture_specs");

  piece.gestures.do { |gesture|
    sortGesture.value(gesture, sortedGestures);
  };

  piece.sortedGestures = sortedGestures;
  piece;
};

initializeGestureContainer = { |schema|
  schema.barsInForm.collect({
    schema.beatsPerBar.collect({ [] });
  });
};

sortGesture = { |gesture, sortedGestures|
  var gestureSpecStrategy = gestureSpecStrategyLibrary[gesture.action];

  gesture.notes.do { |note|
    var noteTimes = resolveNoteTimes.value(note);
    var expandedNote = expandNote.value(note, gesture, gestureSpecStrategy);

    noteTimes.do { |time|
      var gestureRecord = expandedNote.copy;
      gestureRecord.timeInBeat = time.beat % 1;

      sortedGestures[time.bar - 1][time.beat.floor - 1] =
        sortedGestures[time.bar - 1][time.beat - 1].add(gestureRecord);
    };
  };
};

resolveNoteTimes = { |note|
  var noteTimes = [];
  // I guess this is why it should only be done once at startup
  note.times.do { |time|
    time.bars.do { |barNum|
      time.beats.do { |beatNum|
        var explicitTime = (bar: barNum, beat: beatNum);
        noteTimes = noteTimes.add(explicitTime);
      };
    };
  };

  noteTimes;
};

expandNote = { |note, gesture, gestureSpec|
  var expandedNote = ();
  var argSources = [
    note,
    gesture,
    gestureSpec
  ];

  convenienceArgExpander.value(note);
  convenienceArgExpander.value(gesture);

  /* everything below here should be in a strategy pattern */
  expandedNote.synthArgs = gestureSpec.synthArgs.keys.collect({ |argName|
    var argSources = [note, gesture, gestureSpec];
    var argVal = cascadeDefaultsInProperty.value(\synthArgs, argName, argSources);

    [argName, argVal];
  }).asArray.flatten;

  expandedNote.addAction = cascadeDefaults.value(\addAction, argSources);
  expandedNote.synthName = cascadeDefaults.value(\synthName, argSources);
  expandedNote.target = cascadeDefaults.value(\target, argSources);
  expandedNote.action = cascadeDefaults.value(\action, argSources);
  /* /strategy for basic_synth */

  expandedNote;
};

cascadeDefaultsInProperty = { |prop, key, sources|
  var return;

  sources.do { |source|
    var props = source[prop];
    if (props.notNil) {
      return = return ? props[key];
    };
  };

  return;
};

cascadeDefaults = { |key, sources|
  var return;

  sources.do { |source|
    return = return ? source[key];
  };

  return;
};

(
  sort: sort
);
