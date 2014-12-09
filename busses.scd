"Loading Busses...".post;

~id_bus_map = IdentityDictionary[
  \sax -> 8,
  \sax_contact_in -> 10,
  \tub -> 9,
  \mars_kick_in -> 11,

  \com_mon_out -> 2,
  \sax_mon_out -> 3,
  \tub_mon_out -> 4,
  \nugs_mon_out -> 5,
  \drums_mon_out -> 6,

  \main_out_0 -> 0,
  \main_out_1 -> 1,
];

if (~do_bus_map_overrides) {
  ~bus_map_overrides.keysValuesDo {|key, bus_num|
    ~id_bus_map[key] = bus_num;
  };
};

~buss = IdentityDictionary[];

~loop_filt_buss = IdentityDictionary[
  \sax -> Bus.audio(s, 4),
  \sax_loops -> Bus.audio(s, 1),

  \tub -> Bus.audio(s, 4),
  \tub_loops -> Bus.audio(s, 1),

  \com -> Bus.audio(s, 1),
  \com_loops -> Bus.audio(s, 1)
];

~multi_record_buss = IdentityDictionary[
  \tuba -> Bus.audio(s, 1),
  \sax -> Bus.audio(s, 1),
  \computer -> Bus.audio(s, 1),
  \sample -> Bus.audio(s, 1)
];

[
  \sax_eq, \tub_eq, \dru_eq, \com_eq,
  \one_out, \two_out, \three_out,
  \sax_agg, \tub_agg, \com_agg,
  \d_low_bus, \d_med_bus, \d_hi_bus,
  \metronome, \sample,
  \all_monitors
].do {|name|
  ~buss.put(name, Bus.audio(s, 1) );
};

~buss.put(\monitor, Bus.audio(s, 5) );

[
  \sax_info, \tub_info
].do {|name|
  ~buss.put(name, Bus.control(s, 4) );
};

[
  \breath_v, \sax_v, \sax_p, \tub_v, \tub_p, \tub_relax,
  \freq_lag, \tempo, \mars_kick_trig
].do {|name|
  ~buss.put(name, Bus.control(s, 1) );
};

if (~spoof_horns) {
  [\sax, \tub].do {|instr|
    var bus = Bus.audio(s, 1);
    ~buss[(instr ++ "_spoof").asSymbol] = bus;
    ~id_bus_map[instr] = bus;
  };
};

"done".postln;
