(
	~current_jam = ~setlist[0];
	~current_chord = [];
	~loop_this_jam = true;

	~toggle_loop_jam = {
		if(~loop_this_jam, {~loop_this_jam = false}, {~loop_this_jam = true});
		postln("LOOP JAM IS " ++ ~loop_this_jam);
	};

	~scheduler = {
		var upcoming_jam, beat_of_measure=0;
		if(~current_jam[\loop] && ~loop_this_jam,
			{upcoming_jam = ~current_jam},
			{
				upcoming_jam = ~setlist[~current_jam[\index] + 1];
				~loop_this_jam = true;
				postln("MOVING ON TO " ++ upcoming_jam[\index]);
			}
		);

		upcoming_jam[\measures].do {|measure, i|

			/* --------------------------- metranome ---------------------- */
			// measure[0] = num eigths in measure
			(measure[0] / 2).floor.do {|i|
				var beats_away = beat_of_measure + i + ~clock.timeToNextBeat;
				~clock.sched(beats_away - (s.latency / ~clock.beatDur), {
					Synth(\playbuf_simple, [\outbus, ~met_outbus, 
																\buf, ~met_bufs.wrapAt(i)], ~playbuf_g);
					postln("BEAT IS " ++ ~clock.beats);
				});
			};

			/* --------------------------- chords ---------------------- */
			~clock.sched(
				~clock.timeToNextBeat + beat_of_measure - (s.latency / ~clock.beatDur),
				~set_chord_fxn.(measure[1])
			);

			/* --------------------------- measure actions ---------------------- */
			if(measure[2].notNil, {
				measure[2].do {|action|
					var beat_of_action, beats_to_wait;
					beat_of_action = beat_of_measure + action[\beat] + s.latency.neg;
					beats_to_wait = beat_of_action + ~clock.timeToNextBeat;
					~clock.sched(beats_to_wait, ~create_scheduled_fxn[action[\action_type]].(action));
				};
			});

			beat_of_measure = (measure[0] / 2) + beat_of_measure;
		};

		~clock.playNextBar({ ~current_jam = upcoming_jam });
		~clock.schedAbs(~clock.nextBar + beat_of_measure - 0.5, ~scheduler);
		postln("SCHEDULED SETLIST INDEX " ++ upcoming_jam[\index]);
		nil;
	};

	~set_chord_fxn = {|chord| {
		~current_chord = chord;
		~update_synths_with_chord.(chord);
	}}; 

	~create_scheduled_fxn = IdentityDictionary[
		\playbuf -> {|action|
			{
				Synth(\playbuf_simple,
					[ \buf, ~com_bufs[action[\buf]],
						\outbus, 0,
						\amp, action[\amp] ? 1 ],
					~playbuf_g);
					postln("PLAYED BUF " ++ action[\buf]);
					nil;
			};
		},

		\post -> {|action| {postln(action[\message])} },

		\change_tempo -> {|action| {~clock.tempo_(action[\new_tempo])} },

		\quit -> {|action| postln("END"); CmdPeriod.run }
	];

	postln("TASK MASTER LOADED");
)
