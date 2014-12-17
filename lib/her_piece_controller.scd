var setList = loadRelative("../config/setlist.scd")[0];
var controllers;
var currentIndex;
var nextPiece;
var previousPiece;
var setPieceAtIndex;

nextPiece =  {
  var canIncrement = setList.size != (currentIndex + 1);
  if (canIncrement) {
    setPieceAtIndex.value(currentIndex + 1);
  };
};

previousPiece = {
  var canDecrement = -1 != (currentIndex - 1);
  if (canDecrement) {
    setPieceAtIndex.value(currentIndex - 1);
  };
};

setPieceAtIndex = { |index|
  var pieceName = setList[index];
  currentIndex = index;
  postln("Setting piece to " ++ pieceName);
  controllers.do {|controller|
    controller.update(pieceName);
  };
};

{
  arg ...args;
  #controllers = args;

  currentIndex = 0;
  setPieceAtIndex.value(currentIndex);

  (
    nextPiece: nextPiece,
    previousPiece: previousPiece
  )
};
