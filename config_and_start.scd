(
~maindir = "~/dev/frankendank/".standardizePath;

~horn_gate_lag = 0.005;
~freq_lag_dur = 0.01;
~tempo = 50/60;
~sax_gate_thresh = -46.dbamp;
~tuba_gate_thresh = -30.dbamp;

~spoof_horns = false;
~do_bus_map_overrides = false;
~bus_map_overrides = IdentityDictionary[
  \main_out_0 -> 3,

  \com_mon_out -> 2,
  \drums_mon_out -> 2,
  \nugs_mon_out -> 2,
  \tub_mon_out -> 2,
  \sax_mon_out -> 2,
];

load(~maindir ++ "main.scd");
)
s.queryAllNodes
~p_synths[\com_mon].free
~p_synths[\sax_mon].free
~p_synths[\tub_mon].free
~p_synths[\nugs_mon].set(\outbus, 2);
~p_synths[\drums_mon].set(\outbus, 2);

