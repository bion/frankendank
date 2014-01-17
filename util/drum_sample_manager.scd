(
var guiLength=900, guiHeight=700,
hiPaths = "../samples/drum/hi/".resolveRelative,
medPaths = "../samples/drum/med/".resolveRelative,
lowPaths = "../samples/drum/low".resolveRelative,

baseWindow = Window("manage drum samples",
  Rect(100, 100, guiLength, guiHeight)
),

currentSets;

// exports ~drums
"../instr/drum_sample_map.scd".loadRelative;
// exports ~sample_sets
"../instr/drum_sample_sets.scd".loadRelative;



)