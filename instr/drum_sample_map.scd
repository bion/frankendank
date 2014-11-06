var drum_sample_dir = "../samples/drum/".resolveRelative,
low_sample_paths = (drum_sample_dir ++ "low/*").pathMatch,
med_sample_paths = (drum_sample_dir ++ "med/*").pathMatch,
hi_sample_paths = (drum_sample_dir ++ "hi/*").pathMatch,
count=0;

"Loading drum samples...".post;

~drum_samples = IdentityDictionary[];
~drum_record_buss = IdentityDictionary[];

// samples in different registers can't have the same name!
[low_sample_paths, med_sample_paths, hi_sample_paths].do {|paths, i|
  var register = (0: \low, 1: \med, 2: \hi);
  paths.do {|path|
    var name = path.findRegexp("([0-9a-zA-Z\_]+)\.aiff?")[1][1],
        playFunction,
        sample;

    sample = (
      playFunction: playFunction,
      buffer: Buffer.read(s, path),
      register: register[i],
    );

    if ("reverse".matchRegexp(name)) {
      sample.playFunction = \reversed_sample;
    } {
      sample.playFunction = \play_sample;
    };

    ~drum_samples.add(name.asSymbol -> sample);
    ~drum_record_buss.add(name.asSymbol -> Bus.audio(s));

    count = count + 1;
  };
};

"done".postln;

if (count == 0) {
  Error("Loaded drums but no samples found").throw;
} {
  (count + "drum samples loaded").postln;
};
