~synthesis_functions = IdentityDictionary[
  \procmod_proto -> {|amp, id, outbus, buf|
    ProcModR(Env([0,1,0],[0.05, 0.1],\sin,1), amp, 1, outbus, target: ~playbuf_g, server: s)
      .function_({arg group, routebus, server, pm;
      });
  },
  \playbuf -> {|amp, outbus, buf|
    Synth(\playbuf_mono, [\outbus, outbus, \buf, buf, \dur, buf.duration], ~playbuf_g);
  },
];
"ProcMods Loaded".postln;
