HerChordSelector {
  var <view, <numberText, <>schema, harmonyController;
  var currentGroup;

  *new { |view, numberBox, schema, harmonyController|
    ^super.newCopyArgs(view, numberBox, schema, harmonyController).init;
  }

  setChordSlot {|index|
    if (currentGroup.size > index) {
      harmonyController.setChord(currentGroup[index]);
    };
  }

}
