HerChordSelector {
  var <view, <numberText, <>schema, harmonyController;
  var currentGroup;

  *new { |view, numberBox, schema, harmonyController|
    ^super.newCopyArgs(view, numberBox, schema, harmonyController).init;
  }

  init {
    var prevKeyDownFunc = view.keyDownAction, index;

    currentGroup = schema[0];

    view.keyDownAction = {|view, char, modifiers, unicode, keycode, key|

      if (prevKeyDownFunc.notNil) { prevKeyDownFunc.value };

      if ((48 <= unicode) && (unicode <= 57)) {
        this.setGroupWithKey(unicode);
      };

      index = switch (unicode,
        113, {0},
        119, {1},
        101, {2},
        114, {3},
        97,  {4},
        115, {5},
        100, {6},
        102, {7}
      );

      if (index.notNil) {
        this.setChordSlot(index);
      };
    };
  }

  setGroupWithKey {|unicode|
    var index = unicode % 12 - 1;

    if (index == -1) {index = 9};

    if (schema[index].size > 0) {
      currentGroup = schema[index];

      if (numberText.noNil) { numberText.string_(index + 1) };

      this.setChordSlot(0);
    }
  }

  setChordSlot {|index|
    if (currentGroup.size > index) {
      harmonyController.setChord(currentGroup[index]);
    };
  }

}
