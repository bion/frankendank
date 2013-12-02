(
  ~current_jam = ~setlist[0];
  ~current_chord = [];
  ~loop_this_jam = true;

  ~toggle_loop_jam = {
    ~loop_this_jam = ~loop_this_jam.not;
    postln("LOOP JAM IS " ++ ~loop_this_jam);
  };

  ~scheduler = {
    var upcoming_jam, beat_of_measure=0;
    if (~current_jam[\loop] && ~loop_this_jam)
      { upcoming_jam = ~current_jam }
      {
        upcoming_jam = ~setlist[~current_jam[\index] + 1];
        ~loop_this_jam = true;
        postln("MOVING ON TO " ++ upcoming_jam[\index]);
      };

    upcoming_jam[\measures].do {|measure, i|

      /* --------------------------- metranome ---------------------- */
      // measure[0] = num eigths in measure
      (measure[0] / 2).floor.do {|i|
        var beats_away = beat_of_measure + i + ~clock.timeToNextBeat;
        ~clock.sched(beats_away - (s.latency / ~clock.beatDur), {
          Synth(\playbuf_simple, [\outbus, ~buss[\metranome], \buf, ~met_bufs.wrapAt(i)], ~playbuf_g);
        });
      };

      /* --------------------------- chords ---------------------- */
      ~clock.sched(
        ~clock.timeToNextBeat + beat_of_measure - ~freq_lag_dur - (s.latency / ~clock.beatDur),
        ~set_chord.(measure[1])
      );

      /* --------------------------- measure actions ---------------------- */
      if (measure[2].notNil) {
        measure[2].do {|action|
          var beat_of_action, beats_to_wait;
          beat_of_action = beat_of_measure + action[\beat] + s.latency.neg;
          beats_to_wait = beat_of_action + ~clock.timeToNextBeat;
          ~clock.sched(beats_to_wait, ~create_scheduled_fxn[action[\action_type]].(action));
        };
      };

      beat_of_measure = (measure[0] / 2) + beat_of_measure;
    };

    ~clock.playNextBar({ ~current_jam = upcoming_jam });
    ~clock.schedAbs(~clock.nextBar + beat_of_measure - 0.5, ~scheduler);
    postln("SCHEDULED SETLIST INDEX " ++ upcoming_jam[\index]);
    nil;
  };

  /* ____________________________ synth updating */

  ~set_chord = {|chord| {
    ~current_chord = chord;
    ~update_synths_with_chord.(chord);
  }}; 

  ~update_synths_with_chord = {|chord|
    ~com_synths_groups.do {|group| if (group[\uses_chord]) {
      var synths = group[\chord_synths], bundle;
      /* for each pitch in the chord */
      chord.do {|pitch_class, i|
        /* if there is a synth for the pitch */
        if (synths[i].notNil) {
          synths[i].set(\freq, pitch_class.freq);
        }
        {
          synths.add(
            Synth(
                    group[\name],
                    group[\args] ++ [\freq, pitch_class.freq],
                    group[\target],
                    group[\add_message]
                  );
          );
        };
        /* if there are more synths than pitches */
        if (synths.size > chord.size) {
            (synths.size - chord.size).do {|i|
            synths.removeAt(chord.size + i - 1).free;
          };
        };
      };
    }};
  };

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
