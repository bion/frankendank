(
var playing = IdentityDictionary[];

"LOADING HORN CONTROL...".post;

~reset_all = {|instr|
  ~dry_horn.(instr);
  HerLoop.resetAll(instr);
  postln("reset all: " ++ instr);
};

~dry_horn = {|instr|
  playing.keysValuesDo {| key, val |
    if (key.asString[0 .. 2] == instr.asString) {
      val.set(\gate, 0);
      val = nil;
      playing[key] = nil;
    };
  };

  ~pSynths[(instr ++ "_in").asSymbol].set(\amp, 1);
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
        \pbus,          ~buss[(instr++"_p").asSymbol] ],
      ~synth_g);
    ~pSynths[(instr ++ "_in").asSymbol].set(\amp, 0);
  };
};

"done".postln;
)