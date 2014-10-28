[
  "com_sample_sets",
  "chord_sets"
].do {|file|
  post("Loading " ++ name);
  loadRelative("./" ++ name ++ ".scd");
  "done".postln;
};

~setlist = [
  \jon1
]
