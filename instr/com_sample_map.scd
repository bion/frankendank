(
	var com_sample_dir = (~maindir ++ "/samples/com/"),
		com_sample_paths = (com_sample_dir ++ "*").pathMatch;

	~com_bufs = IdentityDictionary[];

	com_sample_paths.do {|path|
		var name = path.findRegexp("([0-9a-zA-Z\_]+)\.aiff")[1][1];
		~com_bufs.add( name.asSymbol -> Buffer.read(s, path) );
		name.postln;
	};
)
