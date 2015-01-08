var gestureLibrary = ~dirToEvent.value(~baseDir ++ "./gestures");
var scheduleEvents;
var stopScheduler;
var clock;
var update;
var pieces;
var currentPiece;
var setPiece;
var nextPieceName;
var baseBar;
var beatInForm;
var currentBeatIsEndOfForm;
var startOnNextBar;
var updatePiece;
var baseBeat = 0;
var playing = false;
var proceed = false;

updatePiece = { |self, pieceName|
  ("updating piece to "  ++ pieceName).postln;
  if (playing) {
    nextPieceName = pieceName;
    proceed = true;
  } {
    setPiece.value(pieceName);
  };
};

startOnNextBar = {
  block { |break|
    var beforeNextBar;

    if (playing) { break.value };

    "Starting scheduler on next bar...".postln;
    playing = true;
    beforeNextBar = clock.nextBar - 0.5;
    clock.schedAbs(beforeNextBar, scheduleEvents);
  };
};

stopScheduler = {
  block { |break|
    if (playing.not) { break.value };

    "Stopping scheduler, clearing clock".postln;
    playing = false;
    clock.clear;
  };
};

setPiece = { |pieceName|
  var newMeter = currentPiece !? {currentPiece.schema.beatsPerbar} ? 4;
  var nextBeat = clock.beats.ceil;
  ("Setting current piece to " ++ pieceName).postln;
  currentPiece = pieces[pieceName];
  baseBeat = nextBeat;

  /*
    schedule updates for
    chords, com samples, drum samples, etc
    on next beat
  */

  if (newMeter != clock.beatsPerBar) {
    ("Setting beats per bar to " ++ newMeter).postln;
    clock.schedAbs(nextBeat, {
      clock.beatsPerBar_(newMeter);
    });
  };
};

beatInForm = {
  var schema = currentPiece.schema;
  (clock.beats.ceil - baseBeat)
  % (schema.barsInForm * schema.beatsPerBar)
};

scheduleEvents = {
  var currentBar;
  var timeToNextBeat = clock.timeToNextBeat;
  var updateToNextPiece =
    proceed // flag to move on
    && (nextPieceName != currentPiece.name) // next piece is different
    &&  beatInForm.value == 0;

  if (updateToNextPiece) {
    setPiece.value(nextPieceName);
  };

  currentBar = (beatInForm.value / currentPiece.schema.beatsPerBar).floor;
  currentPiece.sortedGestures[currentBar][clock.beatInBar.ceil].do { |gesture|
    var offset = timeToNextBeat + gesture.timeInBeat;

    gestureLibrary[gesture.action].value(offset, gesture);
  };

  1; // every beat
};

{ arg ...args;
  #clock, pieces = args;

  (
    updatePiece: updatePiece,
    startOnNextBar: startOnNextBar,
    stopScheduler: stopScheduler
  );
};
