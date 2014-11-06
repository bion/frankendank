~horn_gate_lag = 0.01;
~freq_lag_dur = 0.005;
~sax_gate_thresh = -66.dbamp;
~tuba_gate_thresh = -26.dbamp;

~monitorLevels = Object.readArchive("../archive/monitor_levels".resolveRelative);

~andrew_midi_map = "../doc/dk_10_midi_info.yml".resolveRelative.parseYAMLFile;

loadRelative("./chord_sets.scd");
if (~chordSets.isNil) { Error("~chordSets not loaded!").throw };

~spoof_horns = false;
~do_bus_map_overrides = false;

// dev, practice, perform
~mode = \dev;

if (~mode == \dev) {
  ~spoof_horns = true;
  ~do_bus_map_overrides = true;

  ~bus_map_overrides = IdentityDictionary[
    \main_out_0 -> 3,

    \com_mon_out -> 1,
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
