var scheduleEvents;
var clock;
var setCurrentPiece;
var pieces;
var currentPiece;

setCurrentPiece = { |pieceName|
  // fuuuuuuuuuuck what to do here
  // schedule the switch for the end of the jam?
  // whatabout switching songs when rehearsing?
  // whatabout being able to start at any time?

  // probably need a 'stop' and 'begin' function...
  // how the hell will those work?

  currentPiece = pieces[pieceName];
};

scheduleEvents = {
  clock.

  1;
};

{ arg ...args;
  var beforeNextBeat;
  #clock, pieces = args;

  beforeNextBeat = clock.beats.ceil + 0.5;
  clock.schedAbs(beforeNextBeat, scheduleEvents);

  (
    update: setCurrentPiece
  );
};
