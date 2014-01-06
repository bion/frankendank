(
var docpath = thisProcess.nowExecutingPath,
// metranome
met_sfd = "./met_sfs/*".resolveRelative.pathMatch, // natural numbers
playing = IdentityDictionary[];

~clock = TempoClock(~tempo, queueSize: 2**10);

/* ___________________________________ synth controllers */

~reset_all = {|instr|
  playing.keysValuesDo {| key, val |
    if (key.asString[0 .. 2] == key.asString) {
      val.set(\gate, 0);
      val = nil;
      playing[key] = nil;
    };
  };

  ~p_synths[(instr ++ "_in").asSymbol].set(\amp, 1);

  ~reset_instr.(instr);
};

~h_filt = {|id|
  var node = playing[id];
  var instr = id.asString[0 .. 2];
  if (node.isNil) {
    node = Synth(id,
      [ \hornDataBus, ~buss[(instr++"_info").asSymbol],
        \bus, ~buss[(instr++"_eq").asSymbol],
        \pbus, ~buss[(instr++"_p").asSymbol]],
      ~filt_g);
  } {
    node.set(\gate, 0);
    node = nil;
  };
  playing[id] = node;
};

~h_synth = {|id|
  var node = playing[id];
  var instr = id.asString[0 .. 2];
  if (node.isNil) {
    node = Synth(id,
      [ \hornDataBus, ~buss[(instr++"_info").asSymbol],
        \pedal_amp_bus, ~buss[(instr++"_v").asSymbol],
        \bus, ~buss[(instr++"_eq").asSymbol],
        \pbus, ~buss[(instr++"_p").asSymbol]],
      ~synth_g);
    ~p_synths[(instr ++ "_in").asSymbol].set(\amp, 0);
  } {
    node.set(\gate, 0);
    node = nil;
    ~p_synths[(instr ++ "_in").asSymbol].set(\amp, 1);
  };
  playing[id] = node;
};

/* ____________________________ groups */

~data_g     = Group(s);
~playbuf_g  = Group(~data_g, \addAfter);
~in_g       = Group(~playbuf_g, \addAfter);
~synth_g    = Group(~in_g, \addAfter);
~filt_g     = Group(~synth_g, \addAfter);
~eq_g       = Group(~filt_g, \addAfter);
~agg_g      = Group(~eq_g, \addAfter);
~out_g      = Group(~agg_g, \addAfter);
~record_g   = Group(~out_g, \addAfter);

/* ____________________________ buffers */

if (met_sfd.size == 0) {
  var mes = "No metranome files found, where are they?";
  Error(mes).throw;
} {
  ~met_bufs = Array.newClear(met_sfd.size);
  met_sfd.do {|path, i|

    ~met_bufs[i] = Buffer.read(s, path) };
};

s.sync(~cond);

/* ____________________________ busses */

~id_bus_map = IdentityDictionary[
  \sax -> 8,
  \tub -> 9,

  \com_mon_out -> 3,
  \drums_mon_out -> 3,
  \nugs_mon_out -> 4,
  \tub_mon_out -> 5,
  \sax_mon_out -> 6,

  \main_out_0 -> 0,
  \main_out_1 -> 1,
  \main_out_2 -> 2,
  \main_out_3 -> 3,
  \main_out_4 -> 4,
  \main_out_5 -> 5,
  \main_out_6 -> 6,
  \main_out_7 -> 7
];

if (~do_bus_map_overrides) {
  ~bus_map_overrides.keysValuesDo {|key, bus_num|
    ~id_bus_map[key] = bus_num;
  };
};

~buss = IdentityDictionary[];

[ \sax_eq, \tub_eq, \dru_eq, \com_eq,
  \one_out, \two_out, \three_out,
  \sax_agg, \tub_agg, \com_agg,
  \low, \med, \hi, // drum busses
  \metranome
].do {|name|
  ~buss.put(name, Bus.audio(s, 1) );
};

[ \drums_mon, \nugs_mon, \sax_mon, \tub_mon, \com_mon].do {|name|
  ~buss.put(name, Bus.audio(s, 6) );
};

[ \sax_info, \tub_info].do {|name|
  ~buss.put(name, Bus.control(s, 4) );
};

[ \breath_v, \sax_v, \sax_p, \tub_v, \tub_p, \tub_relax,
  \freq_lag, \tempo
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

/* ________________________________ persistent synths */

~p_synths = IdentityDictionary[];

[
  [\beat_dur, Synth(\p_control, [\outbus, ~buss[\beat_dur], \value, ~clock.beatDur], ~data_g)],

  [\agg, Synth(\agg,
    [
      \sax_bus,       ~buss[\sax_agg],
      \tub_bus,       ~buss[\tub_agg],
      \com_bus,       ~buss[\com_agg],
      \d_low_bus,     ~buss[\d_low_bus],
      \d_med_bus,     ~buss[\d_med_bus],
      \d_hi_bus,      ~buss[\d_hi_bus],
      \drums_mon_bus, ~buss[\drums_mon],
      \nugs_mon_bus,  ~buss[\nugs_mon],
      \tub_mon_bus,   ~buss[\tub_mon],
      \sax_mon_bus,   ~buss[\sax_mon],
      \com_mon_bus,   ~buss[\com_mon],
      \metranome_bus, ~buss[\metranome],
      \outbus,        ~buss[\one_out]
    ],
    ~agg_g
  )],

  [\out_left, Synth(\route_mono, [\inbus, ~buss[\one_out], \outbus, ~id_bus_map[\main_out_0]], ~out_g)]

].do {|pair| ~p_synths.add(pair[0] -> pair[1]) };

"CORE LOADED".postln;
)
