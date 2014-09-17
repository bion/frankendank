HerSynthBase {
  var <group, <bus;
  var <synth;

  *new { |group, bus|
    ^super.newCopyArgs(group, bus).init;
  }

  init {
    synth = Synth.newPaused(currentSynth, [\bus, bus], group);
    ^this;
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
  var indexHalfWidthSpec, indexPosition = 0;
  var indexLFOwidth;

  init {
    brightHarms = (1..7).reverse / 7;
    darkHarms = ((1..7).reverse / 7) ** 6;

    brightLFOLevelSpec = ControlSpec(-60, 0, \exponential);
    lfoFreqSpec = ControlSpec(0.01, 100, \lin);
    indexHalfWidthSpec = ControlSpec(0.01, 10, \lin);
    indexPositionSpec = ControlSpec(0.01, 20, \lin);

    ^super;
  }

  setBright { |val|
    synth.set(\harmAmpArray, blend(darkArray, brightArray, val/128));
  }

  setBrightLFOLevel { |val|
    var specVal = val / 128;
    synth.set(\harmLFOlo, brightLFOLevelSpec.map(specVal));
  }

  setBrightLFOFreq { |val|
    var specVal = val / 128;
    synth.set(\harmLFOfreq, lfoFreqSpec.map(specVal));
  }

  setIndexWidth { |val|
    var specVal = val / 128;
    indexLFOwidth = indexHalfWidthSpec.map(specVal);
    this.setIndexLFOBounds;
  }

  setIndexPosition { |val|
    var specVal = val / 128;
    indexPosition = indexPositionSpec.map(specVal);
    this.setIndexLFOBounds;
  }

  setIndexLFOFreq { |val|
    var specVal = val / 128;
    synth.set(\indexLFOfreq, lfoFreqSpec.map(specVal));
  }

  // **************** private

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
