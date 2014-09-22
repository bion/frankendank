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
    synth.set(\freq_lag_param, val);
  }
}

HerSynthDanDan : HerSynthBase {
  var brightHarms, darkHarms;
  var brightLFOLevelSpec, brightLFOFreqSpec;
  var indexHalfWidthSpec, indexPositionSpec, lfoFreqSpec;
  var indexLFOwidth, indexPosition;

  init {
    brightHarms = (1..7).reverse / 7;
    darkHarms = ((1..7).reverse / 7) ** 6;

    brightLFOLevelSpec = ControlSpec(-60, 0, \exponential);
    lfoFreqSpec = ControlSpec(0.01, 100, \lin);
    indexHalfWidthSpec = ControlSpec(0.01, 10, \lin);
    indexPositionSpec = ControlSpec(0.01, 20, \lin);

    indexLFOwidth = indexHalfWidthSpec.map(this.specVal(0));
    indexPosition = indexPositionSpec.map(this.specVal(0));

    synth = Synth.newPaused(\com_dandan, [\bus, bus], group);

    ^this;
  }

  setBright { |val|
    synth.set(\harmAmpArray, blend(darkHarms, brightHarms, this.specVal(val)));
  }

  setBrightLFOLevel { |val|
    synth.set(\harmLFOlo, brightLFOLevelSpec.map(this.specVal(val)));
  }

  setBrightLFOFreq { |val|
    synth.set(\harmLFOfreq, lfoFreqSpec.map(this.specVal(val)));
  }

  setIndexWidth { |val|
    indexLFOwidth = indexHalfWidthSpec.map(this.specVal(val));
    this.setIndexLFOBounds;
  }

  setIndexPosition { |val|
    indexPosition = indexPositionSpec.map(this.specVal(val));
    this.setIndexLFOBounds;
  }

  setIndexLFOFreq { |val|
    synth.set(\indexLFOfreq, lfoFreqSpec.map(this.specVal(val)));
  }

  // **************** private

  specVal { |val|
    ^(val / 128);
  }

  setIndexLFOBounds { |width|
    synth.set(
      \indexLFOlo,
      max(indexPosition - indexLFOwidth, 0.01)
    );
    synth.set(
      \indexLFOhi,
      indexPosition + indexLFOwidth
    );
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
