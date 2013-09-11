(
	~current_jam = ~setlist[0];
	~current_chord = [];
	~loop_this_jam = true;

	~toggle_loop_jam = {
		if(~loop_this_jam, {~loop_this_jam = false}, {~loop_this_jam = true});
	};

	~scheduler = {
		var upcoming_jam, beat_of_measure=0;
		if(~current_jam[\loop] && ~loop_this_jam,
			{upcoming_jam = ~current_jam},
			{upcoming_jam = ~setlist[~current_jam[\index] + 1]});

		upcoming_jam[\measures].do {|measure, i| block {|break|

			// 0.1 beat before each measure, update ~chord and ~bass
			~clock.sched(~clock.timeToNextBeat + beat_of_measure - 0.1,
				~create_chord_fxn.(measure[1]));

			// break if no events to schedule for this measure
			if(measure[2].isNil, {break.value});
			measure[2].do {|action|
				var beat_of_action, beats_to_wait;
				beat_of_action = beat_of_measure + action[\beat] + s.latency.neg;
				beats_to_wait = beat_of_action + ~clock.timeToNextBeat;
				~clock.sched(beats_to_wait, ~create_scheduled_fxn.(action));
			};

			beat_of_measure = measure[0] + beat_of_measure;
		}};

		~current_jam = upcoming_jam;
		~clock.sched(beat_of_measure + ~clock.timeToNextBeat - 1, ~scheduler);
		"SCHEDULER RAN & RESCHEDULED".postln;
		nil;
	};

	~create_chord_fxn = {|chord|
		{
			~current_chord = chord;
			// ~update_playing_chord_synths.(chord);
		}
	};

	~create_scheduled_fxn = IdentityDictionary[
		\playbuf -> {|action|
			{Synth(\playbuf_simple,
					[ \buf, ~com_bufs[action[\buf]],
						\outbus, ~buss[\one_out],
						\amp, action[\amp] ],
					~playbuf_g);};
		},
		\change_tempo -> {|action|
			{~clock.tempo_(action[\new_tempo])}
		}
	];

	"TASK MASTER LOADED".postln;
)
