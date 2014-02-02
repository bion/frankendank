LoopFilterController {
  var <name, <synthDef, <instr, <bus, <group,
  <knobVal, <active, <synth, <group;

  *new {|name, synthDef, instr, bus, group|
    ^super.newCopyArgs(name, synthDef, instr, bus, group).init;
  }

  init {
    knobVal = 0;
    active = false;
  }

  setKnobVal {|val|
    knobVal = val;
    if (active) {
      synth.set(\param, val);
    };
  }

  activate {
    active = true;
    synth = Synth(synthDef, [\param, knobVal, \bus, bus], group, \addToTail);
    postln(name ++ " activated");
  }

  deactivate {
    active = false;
    synth.set(\gate, 0);
    synth = nil;
    postln(name ++ " deactivated");
  }

}
