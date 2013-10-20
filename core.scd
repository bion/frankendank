(
  var docpath = thisProcess.nowExecutingPath,
		add_chord_synth,
  // metranome
		met_sfd_path = ~maindir ++ "met_sfs/*",
    met_sfd = (met_sfd_path).pathMatch, // natural numbers
    playing = IdentityDictionary[];

	~id_bus_map = IdentityDictionary[
		\sax -> 8,
		\tub -> 9,
	];

	~met_bufs = Array.newClear(met_sfd.size);

  // persistent synths
  ~p_synths = IdentityDictionary[];

  /* ___________________________________ synth controllers */

  ~h_filt = {arg id;
    var node = playing[id];
    var instr = id.asString[0 .. 2];
    if(node.isNil, {
      node = Synth(id,
        [	\hornDataBus, ~buss[(instr++"_info").asSymbol],
					\bus, ~buss[(instr++"_eq").asSymbol],
          \pbus, ~buss[(instr++"_p").asSymbol]],
        ~filt_g);
      }, {
        node.set(\gate, 0);
        node = nil;
    });
    playing[id] = node;
  };

  ~h_synth = {arg id;
    var node = playing[id];
    var instr = id.asString[0 .. 2];
    if(node.isNil, {
      node = Synth(id,
        [ \hornDataBus, ~buss[(instr++"_info").asSymbol],
					\bus, ~buss[(instr++"_eq").asSymbol],
          \pbus, ~buss[(instr++"_p").asSymbol]],
        ~synth_g);
      ~p_synths[(instr ++ "_in").asSymbol].set(\amp, 0);
      }, {
        node.set(\gate, 0);
        node = nil;
				~p_synths[(instr ++ "_in").asSymbol].set(\amp, 1);
    });
    playing[id] = node;
  };

	/* ____________________________ synth updating */

	~update_synths_with_chord = {|chord|
		~com_synths_groups.do {|group| if(group[\uses_chord], {
			var synths = group[\chord_synths], bundle;
			var pitch =1;
			chord.do {|pitch_class, i|
				if(synths[i].notNil, {
					synths[i].set(\freq, pitch_class.freq);
				},{
					synths[i] = Synth(
															group[\synth_name],
															group[\args] ++ [\freq, pitch_class.freq],
															group[\target],
															group[\add_message]
														);
				});
				if(group.size > chord.size, {
						(group.size - chord.size).do {|i|
						synths.removeAt(chord.size + i - 1).free;
					};
				});
				if(group.size < chord.size, {
					(chord.size - group.size).do {|i|
						var index = i + chord.size;
						synths.add( Synth(
																group[\synth_name],
																group[\args] ++ [\freq, pitch],
																group[\target],
																group[\add_message]
															);
						);
					};
				});
			};
		})};
	};

	add_chord_synth = {|group, pitch|
	};

	/* ____________________________ groups, busses, buffers */

	~playbuf_g = Group(s);
	~in_g = Group(s);
	~synth_g = Group(~in_g, \addAfter);
	~filt_g = Group(~synth_g, \addAfter);
	~eq_g = Group(~filt_g, \addAfter);
	~agg_g = Group(~eq_g, \addAfter);
	~out_g = Group(~agg_g, \addAfter);
	~record_g = Group(~playbuf_g, \addAfter);

	~buss = IdentityDictionary[];
	[ \sax_eq, \tub_eq, \dru_eq, \com_eq,
		\one_out, \two_out, \three_out,
		\sax_agg, \tub_agg,
		\low, \med, \hi, // drum busses
		\metranome
	].do {arg name;
		~buss.put(name, Bus.audio(s, 1) );
	};

	[ \drums_mon, \sax_mon, \tub_mon, \com_mon].do {arg name;
		~buss.put(name, Bus.audio(s, 5) );
	};

	[ \sax_info, \tub_info].do {arg name;
		~buss.put(name, Bus.control(s, 4) );
	};

	[ \breath_v, \sax_v, \sax_p, \tub_v, \tub_p, \tub_relax ].do {arg name;
		~buss.put(name, Bus.control(s, 1) );
	};

	if(met_sfd.size == 0, {
		var mes = "No metranome files found at %, where are they?".format(met_sfd_path);
		Error(mes).throw;
		}, {
		met_sfd.do {arg path, i; ~met_bufs[i] = Buffer.read(s, path) };
	});

	s.sync(~cond);

	/* ________________________________ persistent synths */
	[
		[\agg, Synth(\agg,
			[
				\sax_bus,				~buss[\sax_agg],
				\tub_bus,				~buss[\tub_agg],
				\d_low_bus,			~buss[\d_low_bus],
				\d_med_bus,			~buss[\d_med_bus],
				\d_hi_bus,			~buss[\d_hi_bus],
				\drums_mon_bus, ~buss[\drums_mon],
				\tub_mon_bus,		~buss[\tub_mon],
				\sax_mon_bus,		~buss[\sax_mon],
				\com_mon_bus,		~buss[\com_mon],
				\metranome_bus, ~buss[\metranome],
				\outbus,				~buss[\one_out],
			],
			~agg_g
		)],

		[\out_left, Synth(\route_mono, [\inbus, ~buss[\one_out], \outbus, 0], ~out_g)]
	].do {|pair| ~p_synths.add(pair[0] -> pair[1]) };

	"CORE LOADED".postln;
)
