HerSynthBase {
  var <group, <bus;
  var <synth;

  *new { |group, bus|
    ^super.newCopyArgs(group, bus).init;
  }

  init {
    synth = Synth.newPaused(currentSynth, [\bus, bus], group);
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
  setBright { |val|
    // TODO
  }

  setBrightLFOLevel { |val|
    // TODO
  }

  setBrightLFOFreq { |val|
    // TODO
  }

  setIndexWidth { |val|
    // TODO
  }

  setIndexPosition { |val|
    // TODO
  }

  setIndexLFOFreq { |val|
    // TODO
  }
}

HerSynthFank : HerSynthBase {
}
