[
  "chord_sets"
].do {|file|
  post("Loading " ++ file);
  loadRelative("./" ++ file ++ ".scd");
  "done".postln;
};

~setlist = [
  \jon1
]
