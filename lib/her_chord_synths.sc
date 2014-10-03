HerSynthBase {
  var <group, <bus;
  var <synth;

  *new { |group, bus|
    ^super.newCopyArgs(group, bus).init;
  }

  start {
    synth.run(true);
  }

  stop {
    synth.set(\amp, 0);
    synth.run(false);
  }

  setAmp { |val|
    synth.set(\amp, val);
  }

  setFreqs { |val|
    synth.set(\freqs, val);
  }

  setBeatDur { |val|
    synth.set(\beatDur, val);
  }

  setFreqLag { |val|
    synth.set(\freqLagParam, val);
  }
}

HerSynthDanDan : HerSynthBase {
  var harms, lastHarmVal = 0,
      indexPositionSpec, indexPosition = 0,
      vibratoWidthSpec, vibratoWidth = 0;

  setBright { |val|
    var highestIndex = round(this.specVal(val) * 6).asInt;
    var newHarms = harms.copyRange(0, highestIndex);
    lastHarmVal = val;
    while { newHarms.size < 7 } { newHarms = newHarms.add(0) };
    synth.set(\harmAmpArray, newHarms);
  }

  setIndexPosition { |val|
    indexPosition = indexPositionSpec.map(this.specVal(val));
    synth.set(\index, indexPosition);
  }

  setVibratoWidth { |val|
    vibratoWidth = vibratoWidthSpec.map(this.specVal(val));
    synth.set(\vibwth, vibratoWidth);
  }

  start {
    this.setVibratoWidth(vibratoWidth);
    this.setIndexPosition(indexPosition);
    this.setBright(lastHarmVal);

    synth.run(true);
  }

  // **************** private

  init {
    harms = [0.1, 0.5, 0.2, 0.3, 0.2, 0.1, 0.1];

    indexPositionSpec = ControlSpec(0.01, 8, \lin);
    indexPosition = indexPositionSpec.map(this.specVal(0));

    vibratoWidthSpec = ControlSpec(0.0, 0.07, \lin);
    vibratoWidth = vibratoWidthSpec.map(this.specVal(0));

    synth = Synth.newPaused(\com_dandan, [\bus, bus], group);

    ^this;
  }

  specVal { |val|
    ^(val / 128);
  }
}

HerSynthFank : HerSynthBase {
  init {
    synth = Synth.newPaused(\com_fank, [\bus, bus], group);
    ^this;
  }
}

HerSynthDirtRhode : HerSynthBase {
  init {
    synth = Synth.newPaused(\com_dirt_rhode, [\bus, bus], group);
    ^this;
  }
}
