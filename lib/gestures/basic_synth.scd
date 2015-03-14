"Loading basic synth gesture function".postln;

{ |offset, gesture|
  s.makeBundle(offset, {
    Synth(gesture.synthName, gesture.synthArgs, gesture.target, gesture.addAction)
  });
};
