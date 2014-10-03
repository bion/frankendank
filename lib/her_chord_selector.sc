HerChordSelector {
  var <view, <numberText, <>schema, harmonyController;
  var currentGroup, currentIndex;

  *new { |view, numberBox, schema, harmonyController|
    ^super.newCopyArgs(view, numberBox, schema, harmonyController).init;
  }

  init {
    var prevKeyDownFunc = view.keyDownAction, index;
    currentIndex = 0;
    currentGroup = schema[currentIndex];
  }

  setGroup {|index|
    currentIndex = index;
    if (schema[index].size > 0) {
      currentGroup = schema[index];
      if (numberText.notNil) { numberText.string_(index + 1) };
      this.setChordSlot(0);
    }
  }

  nextGroup {
    var canIncrement = schema.size != (currentIndex + 1);
    if (canIncrement) {
      this.setGroup(currentIndex + 1);
    };
  }

  previousGroup {
    var canDecrement = -1 != (currentIndex - 1);
    if (canDecrement) {
      this.setGroup(currentIndex - 1);
    };
  }

  setChordSlot {|index|
    if (currentGroup.size > index) {
      harmonyController.setChord(currentGroup[index]);
    };
  }
}
