(
  var breath_uid;
  /* each group is an
  IdentityDictionary[
    \name -> \some_synth_name,
    \uses_chord -> boolean,
    \chord_synths -> [synth, synth, synth],
    \fx_synths -> [one, two, three],
    \args -> [\bus, ~buss[\whatev], \freq, some_freq],
    \target -> ~synth_group,
    \add_message -> \addToTail
  ]
  */

  MIDIClient.sources.do {|source|
    if (source.device == "Breath Controller") { breath_uid = source.uid };
  };

  ~fank_g = Group(~synth_g, \addToHead);
  ~dirt_rhode_g = Group(~synth_g, \addToHead);

  [
    [\com_mon, Synth(\mon,
      [
        \drum_scale, 1,
        \sax_scale, 1,
        \tub_scale, 1,
        \com_scale, 1,
        \met_scale, 1,
        \metranome_bus, ~buss[\metranome],
        \inbus, ~buss[\sax_mon],
        \outbus, ~id_bus_map[\com_mon_out],
      ],
      ~out_g )],

    [\breath_p, Synth(\v_control, [\outbus, ~buss[\breath_v], \param, 0], ~in_g)],

    [\freq_lag, Synth(\p_control, [\outbus, ~buss[\freq_lag], \param, 0], ~in_g)],

    [\com_eq, Synth(\com_eq, [\inbus, ~buss[\com_eq], \outbus, ~buss[\com_agg] ], ~eq_g)]

  ].do {|pair| ~p_synths.add(pair[0] -> pair[1]) };

  ~com_synths_groups = [];
  ~current_breath_synth = nil;

  ~change_breath_synth = {|synth_name, args, target|
    var remove_these = [];

    ~com_synths_groups.do {|synth_dict, i|

      if (synth_dict[\uses_chord]) {
        synth_dict[\chord_synths].do {_.free};
        synth_dict[\fx_synths].do {_.free};
        remove_these.add(i);
        ~com_synth_groups.remove(synth_dict);
      };

    };

    ~com_synths_groups.add(
      IdentityDictionary[
        \name -> synth_name,
        \uses_chord -> true,
        \chord_synths -> [],
        \fx_synths -> [],
        \args -> args,
        \target -> target,
        \add_message -> \addToTail
      ];
    );

    ~current_breath_synth = synth_name;
    ~update_synths_with_chord.(~current_chord);
    remove_these.do {|i| ~com_synths_groups.removeAt(i) };
  };

  MIDIdef.cc(\breath_p, {|num|
    ~p_synths[\breath_p].set(\amp, num);
  }, 2, 0, srcID: breath_uid);

  MIDIdef.cc(\next_jam, {
    ~toggle_loop_jam.value;
  }, srcID: ~mSrc[\com], ccNum: 20, chan: 0);

  MIDIdef.cc(\freq_lag, {|num|
    ~freq_lag_dur = num / 127.0 * 2;
    ~p_synths[\freq_lag].set(\param, ~lag_dur);
  }, srcID: ~mSrc[\com], ccNum: 12, chan: 0);

  MIDIdef.cc(\dirt_rhode, {
    ~change_breath_synth.(
      \com_dirt_rhode,
      [\bus, ~buss[\com_eq], \amp_bus, ~buss[\breath_v], \freq_lag_bus, ~buss[\freq_lag]],
      ~dirt_rhode_g
    );
  }, srcID: ~mSrc[\com], ccNum: 50, chan: 9);

  MIDIdef.cc(\fank, {
    ~change_breath_synth.(
      \com_fank,
      [\bus, ~buss[\com_eq], \amp_bus, ~buss[\breath_v], \freq_lag_bus, ~buss[\freq_lag]],
      ~fank_g
    );
  }, srcID: ~mSrc[\com], ccNum: 36, chan: 9);

  "COM LOADED".postln;
)
