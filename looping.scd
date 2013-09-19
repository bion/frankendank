(
	var num_loops = 8, loop_maxdur = 20,
	record, add_record_synth, stop_recording,
	add_loop_synth, play_loop, stop_loop,
	clear_loop = IdentityDictionary[\sax -> false, \tub -> false];

	~clear_loop = {arg id;
		postln("CLEAR LOOP " ++ id);
		if(clear_loop[id],
			{clear_loop[id] = false}, {clear_loop[id] = true});
	};

	~loop_touch = {arg id; block {|break|
		var offset = ~clock.beats - ~clock.beats.round * ~clock.beatDur;
		var loop_instance = ~loops[id[\inst]][id[\num]];
		postln("LOOP TOUCH " ++ id);
		if(clear_loop[id[\inst]], {
			if(loop_instance[\synth].notNil, { stop_loop.(id) });
			loop_instance[\next_action] = record;
			loop_instance[\dur] = 0.0;
			clear_loop[id[\inst]] = false;
			("LOOP " ++ id ++ " CLEARED").postln;
			break.value;
		});
		loop_instance[\next_action].(id, offset);
	}};

	record = {arg id, offset;
		if(offset < 0, {
			fork{
				offset.abs.wait;
				add_record_synth.(id);
			}}, {
				add_record_synth.(id, offset);
		});
	};

	add_record_synth = {arg id, offset=0;
		var bus = ~buss[(id[\inst].asString ++ "_agg").asSymbol];
		var loop_instance = ~loops[id[\inst]][id[\num]];
		loop_instance[\dur] = ~clock.beats;
		s.makeBundle(0.025, {
			loop_instance[\recording] = Synth(\recordbuf_mono,
				[ \inbus, bus, \startpos, offset * s.sampleRate,
					\buf, loop_instance[\buffer] ],
				~record_g);
		});
		loop_instance[\next_action] = stop_recording;
		postln("STARTED " ++ id ++ " RECORDING, OFFSET: " ++ offset);
	};

	stop_recording = {arg id, offset;
		var dur, record_surplus = 0;
		var loop_instance = ~loops[id[\inst]][id[\num]];
		fork{
			if(offset < 0.0, {offset.abs.wait; offset=0.0});
			dur = ~clock.beats - loop_instance[\dur];
			loop_instance[\dur] = dur.round;
			loop_instance[\recording].set(\gate, -1.01);
			loop_instance[\next_action] = stop_loop;
			play_loop.(id, offset);
			postln("STOPPED " ++ id ++ " RECORDING, OFFSET: " ++ offset);
		};
	};

	play_loop = {arg id, offset;
		if(offset < 0, {
			fork {
				offset.abs.wait;
				add_loop_synth.(id);
			}}, {
				add_loop_synth.(id, offset);
		});
	};

	add_loop_synth = {arg id, offset=0;
		var loop_instance = ~loops[id[\inst]][id[\num]];
		var synth;
		s.makeBundle(0.025, { synth = Synth(\playbuf_mono,
			[ \outbus, 0,
				\amp, 1,
				\buf, loop_instance[\buffer], 
				\dur, loop_instance[\dur] * ~clock.beatDur - offset - 0.05,
				\startpos, offset * s.sampleRate],
			~playbuf_g).onFree({loop_instance[\synth] = nil});
		});
		loop_instance.putAll(IdentityDictionary[
			\synth -> synth,
			\responder -> OSCFunc(
				{ play_loop.(id, ~clock.beats - ~clock.beats.round * ~clock.beatDur) },
				'/n_end', s.addr, nil, [synth.nodeID]
				).oneShot,
		]);
		loop_instance[\next_action] = stop_loop;
		postln("STARTED LOOPING " ++ id ++ " OFFSET: " ++ offset);
	};

	stop_loop = {arg id, offset;
		var loop_instance = ~loops[id[\inst]][id[\num]];
		loop_instance[\responder].free;
		loop_instance[\synth].set(\gate, -1.03);
		loop_instance.put( \synth -> nil );
		loop_instance[\next_action] = play_loop;
		postln("KILLED LOOP " ++ id);
	};

	~loops = IdentityDictionary[
		\sax -> Array.newClear(num_loops),
		\tub -> Array.newClear(num_loops)
	];

	[[\sax, \tub], (0 .. (num_loops - 1)).stutter(3)].flop.do {|pair|
		~loops[pair[0]][pair[1]] = IdentityDictionary[
			\buffer -> Buffer.alloc(s, loop_maxdur * s.sampleRate, 1),
			\next_action -> record,
			\dur -> 0.0, // loop dur or record touch time
			\recording -> false,
			\synth -> nil,
			\responder -> false
		];
	};

)
