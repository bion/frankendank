~horn_gate_lag = 0.001;
~freq_lag_dur = 0.005;
~sax_gate_thresh = -52.dbamp;
~tuba_gate_thresh = -26.dbamp;

~monitor_levels = Object.readArchive("../archive/monitor_levels".resolveRelative);

loadRelative("./chord_schema.scd");
if (~chordSchema.isNil) { Error("~chordSchema not loaded!").throw };

~spoof_horns = false;
~do_bus_map_overrides = false;

~dev_mode = false;

if (~dev_mode) {
  // dev config

  ~spoof_horns = true;
  ~do_bus_map_overrides = true;

  ~bus_map_overrides = IdentityDictionary[
    \main_out_0 -> 3,

    \acoustic_drums -> 8,

    \com_mon_out -> 0,
    \drums_mon_out -> 2,
    \nugs_mon_out -> 2,
    \tub_mon_out -> 2,
    \sax_mon_out -> 2
  ];
  ~mSrc = IdentityDictionary[];
  ~mSrc.putPairs([
    \sax, 10000,
    \tuba, 20000,
    \drums, 30000
  ]);
};

~config_loaded_flag = true;
