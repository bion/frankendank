(
var drum_sample_dir = "../samples/drum/".resolveRelative,
low_sample_paths = (drum_sample_dir ++ "low/*").pathMatch,
med_sample_paths = (drum_sample_dir ++ "med/*").pathMatch,
hi_sample_paths = (drum_sample_dir ++ "hi/*").pathMatch,
count=0;

~drum_samples = IdentityDictionary[];

// samples in different registers can't have the same name!
[low_sample_paths, med_sample_paths, hi_sample_paths].do {|paths, i|
  var register = (0: \low, 1: \med, 2: \hi);
  paths.do {|path|
    var name = path.findRegexp("([0-9a-zA-Z\_]+)\.aiff")[1][1],
    playFunction, sample;

    sample = (
      playFunction: playFunction,
      buffer: Buffer.read(s, path),
      register: register[i],
    );

    if ("reverse".matchRegexp(name)) {
      sample.playFunction = \reversed_sample;

    } {
      sample.playFunction = \basic_sample;
    };

    ~drum_samples.add(name.asSymbol -> sample);

    count = count + 1;
  };
};

if (count == 0)
{ Error("LOADED DRUMS BUT NO SAMPLES FOUND").throw }
{ (count ++ "Drum samples loaded").postln };
)
