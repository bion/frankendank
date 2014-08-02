HerControlSwitcher {
  var <synth, <param, action;
  var currentVal, currentControl, controls;

  *new {|synth, param, action|
    ^super.newCopyArgs(synth, param, action).init;
  }

  init {
    currentVal = 0;
  }

  tryControl {|name, inVal|
    if ((currentControl == name) || (currentVal < inVal)) {
      currentControl = \one;
      action.(inVal);
    };
  }
}
