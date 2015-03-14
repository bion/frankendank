"Loading basic_synth gesture spec".postln;

(
  target: ~synth_g,
  addAction: \addToTail,
  action: \basic_synth,
  synthArgs: (
    outbus: ~buss[\bass_eq],
    freq: 110,
    amp: 0.25,
    cutOffFreq: 200,
    duration: 1,
    envCurve: -3
  )
);
