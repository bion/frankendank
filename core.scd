(
var docpath = thisProcess.nowExecutingPath,
met_sfd = "./met_sfs/*".resolveRelative.pathMatch, // natural numbers
playing = IdentityDictionary[];

~clock = TempoClock(~tempo, queueSize: 2**10);

/* ___________________________________ synth controllers */

~reset_all = {|instr|
  ~dry_horn.(instr);
  HerLoop.resetAll(instr);
};

~dry_horn = {|instr|
  playing.keysValuesDo {| key, val |
    if (key.asString[0 .. 2] == instr.asString) {
      val.set(\gate, 0);
      val = nil;
      playing[key] = nil;
    };
  };

  ~p_synths[(instr ++ "_in").asSymbol].set(\amp, 1);
};

~h_filt = {|id|
  var node = playing[id];
  var instr = id.asString[0 .. 2];

  if (node.isNil) {
    playing[id] = Synth(id,
      [ \hornDataBus, ~buss[(instr++"_info").asSymbol],
        \bus,         ~buss[(instr++"_eq").asSymbol],
        \pbus,        ~buss[(instr++"_p").asSymbol]],
      ~filt_g);
  };

};

~h_synth = {|id|
  var node = playing[id];
  var instr = id.asString[0 .. 2];

  if (node.isNil) {
    playing[id] = Synth(id,
      [ \hornDataBus,   ~buss[(instr++"_info").asSymbol],
        \pedal_amp_bus, ~buss[(instr++"_v").asSymbol],
        \bus,           ~buss[(instr++"_eq").asSymbol],
        \pbus,          ~buss[(instr++"_p").asSymbol]],
      ~synth_g);

    ~p_synths[(instr ++ "_in").asSymbol].set(\amp, 0);
  };

};

/* ____________________________ groups */
Platform.case(
  \osx,
  {
    ~data_g     = Group(s);
    ~playbuf_g  = Group(~data_g, \addAfter);
    ~in_g       = Group(~playbuf_g, \addAfter);
    ~synth_g    = Group(~in_g, \addAfter);
    ~filt_g     = Group(~synth_g, \addAfter);
    ~eq_g       = Group(~filt_g, \addAfter);

    ~loop_g     = Group(~eq_g, \addAfter);
    ~record_loop_g = Group(~loop_g, \addToHead);
    ~play_loop_g   = Group(~record_loop_g, \addAfter);
    ~filt_loop_g   = Group(~play_loop_g, \addAfter);
    ~sum_loop_g    = Group(~filt_loop_g, \addAfter);
    ~route_loop_g  = Group(~sum_loop_g, \addAfter);

    ~agg_g      = Group(~loop_g, \addAfter);
    ~out_g      = Group(~agg_g, \addAfter);
    ~record_g   = Group(~out_g, \addAfter);
  },

  \linux,
  {
    ~data_g     = ParGroup(s);
    ~playbuf_g  = ParGroup(~data_g, \addAfter);
    ~in_g       = ParGroup(~playbuf_g, \addAfter);
    ~synth_g    = ParGroup(~in_g, \addAfter);
    ~filt_g     = Group(~synth_g, \addAfter);
    ~eq_g       = ParGroup(~filt_g, \addAfter);

    ~loop_g     = Group(~eq_g, \addAfter);
    ~record_loop_g = ParGroup(~loop_g, \addToHead);
    ~play_loop_g   = ParGroup(~record_loop_g, \addAfter);
    ~filt_loop_g   = ParGroup(~play_loop_g, \addAfter);
    ~sum_loop_g    = ParGroup(~filt_loop_g, \addAfter);
    ~route_loop_g  = ParGroup(~sum_loop_g, \addAfter);

    ~agg_g      = ParGroup(~loop_g, \addAfter);
    ~out_g      = ParGroup(~agg_g, \addAfter);
    ~record_g   = ParGroup(~out_g, \addAfter);
  }
);

/* ____________________________ buffers */

if (met_sfd.size == 0) {
  var mes = "No metronome files found, where are they?";
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
  \ambient -> 10,

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
  \sax -> 4.collect { Bus.audio(s, 1) },
  \sax_loops -> Bus.audio(s, 1),
  \tub -> 4.collect { Bus.audio(s, 1) },
  \tub_loops -> Bus.audio(s, 1)
];

[
  \sax_eq, \tub_eq, \dru_eq, \com_eq,
  \one_out, \two_out, \three_out,
  \sax_agg, \tub_agg, \com_agg,
  \low, \med, \hi, // drum busses
  \metronome, \sample,
  \all_monitors
].do {|name|
  ~buss.put(name, Bus.audio(s, 1) );
};

[
  \drums_mon, \nugs_mon, \sax_mon, \tub_mon, \com_mon
].do {|name|
  ~buss.put(name, Bus.audio(s, 5) );
};

[
  \sax_info, \tub_info
].do {|name|
  ~buss.put(name, Bus.control(s, 4) );
};

[
  \breath_v, \sax_v, \sax_p, \tub_v, \tub_p, \tub_relax,
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

~p_synths = IdentityDictionary[];

"CORE LOADED".postln;
)
