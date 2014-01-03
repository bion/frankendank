~maindir = "~/dev/frankendank/".standardizePath;

~horn_gate_lag = 0.005;
~freq_lag_dur = 0.01;
~tempo = 50/60;
~sax_gate_thresh = -46.dbamp;
~tuba_gate_thresh = -30.dbamp;

~spoof_horns = false;
~do_bus_map_overrides = true;
~bus_map_overrides = IdentityDictionary[
  \main_out_0 -> 3,

  \com_mon_out -> 0,
  \drums_mon_out -> 2,
  \nugs_mon_out -> 2,
  \tub_mon_out -> 2,
  \sax_mon_out -> 2
];
