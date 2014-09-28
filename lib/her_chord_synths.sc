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
  var indexHalfWidthSpec, indexPositionSpec, lfoFreqSpec;
  var indexLFOwidth, indexPosition;

  init {
    darkHarms = [5, 0.5, 5, 0.5, 3, 0.5, 1] / 7;
    brightHarms = [0.25, 0.5, 0.2, 0.3, 0.2, 0.1, 0.1];

    lfoFreqSpec = ControlSpec(1, 100, \lin);
    indexHalfWidthSpec = ControlSpec(0.01, 4, \lin);
    indexPositionSpec = ControlSpec(0.01, 8, \lin);

    indexLFOwidth = indexHalfWidthSpec.map(this.specVal(0));
    indexPosition = indexPositionSpec.map(this.specVal(0));

    synth = Synth.newPaused(\com_dandan, [\bus, bus], group);

    ^this;
  }

  setBright { |val|
    synth.set(\harmAmpArray, blend(darkHarms, brightHarms, this.specVal(val)));
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
