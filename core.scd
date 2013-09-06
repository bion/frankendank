(
  var docpath = thisProcess.nowExecutingPath,
  // metranome
		met_sfd_path = ~maindir ++ "met_sfs/*",
    met_sfd = (met_sfd_path).pathMatch, // natural numbers
    met_bufs = Array.newClear(met_sfd.size),
    met_outbus = 1,
    playing = IdentityDictionary[],
		id_bus_map = IdentityDictionary[
			\sax -> 8,
			\tub -> 9,
		];
  // persistent synths
  ~p_synths = IdentityDictionary[];

  /* ___________________________________ synth controllers */

  ~h_filt = {arg id;
    var node = playing[id];
    var instr = id.asString[0 .. 2];
    if(node.isNil, {
      node = Synth(id,
        [	\hornDataBus, ~buss[(instr++"_i").asSymbol], 
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
    var instr = id[\inst].asString;
    if(node.isNil, {
      node = Synth(id,
        [ \hornDataBus, ~buss[(instr++"_i").asSymbol], 
					\bus, ~buss[(instr++"_eq").asSymbol],
          \pbus, ~buss[(instr++"_p").asSymbol]],
        ~synth_g);
      ~p_synths[id[\inst]].set(\amp, 0);
      }, {
        node.set(\gate, 0);
        node = nil;
        ~p_synths[id[\inst]].set(\amp, 1);
    });
    playing[id] = node;
  };

	/* ____________________________ groups, busses, buffers */

	~playbuf_g = Group(s);
	~in_g = Group(s);
	~synth_g = Group(~in_g, \addAfter);
	~filt_g = Group(~synth_g, \addAfter);
	~eq_g = Group(~filt_g, \addAfter);
	~out_g = Group(~eq_g, \addAfter);
	~record_g = Group(~playbuf_g, \addAfter);

	~buss = IdentityDictionary[];
	[ \sax_eq, \tub_eq, \dru_eq, \com_eq,
		\one_out, \two_out, \three_out,
		\sax_agg, \tub_agg,
		\low, \med, \hi // drum busses
	].do {arg name;
		~buss.put(name, Bus.audio(s, 1) );
	};

	[ \sax_i, \tub_i].do {arg name;
		~buss.put(name, Bus.control(s, 4) );
	};

	[ \sax_v, \sax_p, \tub_v, \tub_p ].do {arg name;
		~buss.put(name, Bus.control(s, 1) );
	};

	if(met_sfd.size == 0, {
		var mes = "No metranome files found at %, where are they?".format(met_sfd_path);
		Error(mes).throw;
		}, {
		met_sfd.do {arg path, i; met_bufs[i] = Buffer.read(s, path) };
	});

	s.sync(~cond);

	/* ________________________________ metranome */
	~clock.sched(0, {
		~clock.beatsPerBar.do {arg beat, i;
			~clock.sched(beat, {
				Synth(\playbuf_simple, [\outbus, met_outbus, 
																\buf, met_bufs.wrapAt(i)], ~playbuf_g);
			});
		};
		~clock.nextBar - ~clock.beats + 0.00001;
	});

	/* ________________________________ persistent synths */
	~p_synths.add(
		\sax_v -> Synth(\v_control, 
			[\outbus, ~buss[\sax_v], \amp, 0], ~in_g),
		\tub_v -> Synth(\v_control, 
			[\outbus, ~buss[\tub_v], \amp, 0], ~in_g),

		\sax_p -> Synth(\p_control, 
			[\outbus, ~buss[\sax_p], \param, 0], ~in_g),
		\tub_p -> Synth(\p_control, 
			[\outbus, ~buss[\tub_p], \param, 0], ~in_g),

		\sax_info -> Synth(\horninfo,
			[\inbus, id_bus_map[\sax], \outbus, ~buss[\sax_info] ], ~in_g),
		\tub_info -> Synth(\horninfo,
			[\inbus, id_bus_map[\tub], \outbus, ~buss[\tub_info] ], ~in_g),

		\sax_in -> Synth(\route_mono,
			[\inbus, id_bus_map[\sax], \outbus, ~buss[\sax_eq] ], ~in_g),
		\tub_in -> Synth(\route_mono,
			[\inbus, id_bus_map[\tub], \outbus, ~buss[\tub_eq] ], ~in_g),

		\sax_eq -> Synth(\sax_eq, 
			[\inbus, ~buss[\sax_eq], \outbus, ~buss[\sax_agg],
				\vbus, \sax_v], ~eq_g),
		\tub_eq -> Synth(\tub_eq, 
			[\inbus, ~buss[\tub_eq], \outbus, ~buss[\tub_agg],
				\vbus, \tub_v], ~eq_g),

		\agg -> Synth(\agg,
			[\saxbus, ~buss[\sax_agg], \tubbus, ~buss[\tub_agg],
			\outbus, ~buss[\one_out]], ~out_g);

		\out_left -> Synth(\route_mono, 
			[\inbus, ~buss[\one_out], \outbus, 0], ~out_g)
	);

	"CORE LOADED".postln;
)
