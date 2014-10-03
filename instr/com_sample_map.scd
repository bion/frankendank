var com_sample_dir = "../samples/com/".resolveRelative,
com_sample_paths = (com_sample_dir ++ "*").pathMatch;

"Loading com samples...".post;

~com_bufs = IdentityDictionary[];

com_sample_paths.do {|path|
  var name = path.findRegexp("([0-9a-zA-Z\_]+)\.aiff")[1][1];
  ~com_bufs.add( name.asSymbol -> Buffer.read(s, path) );
};

"done".postln;

postln("Loaded " ++ ~com_bufs.size ++ " com samples");
