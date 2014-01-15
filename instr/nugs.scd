(

[
  [\nugs_mon, Synth(\mon,
    [ \main, \met, \sax, \tub, \drum, \com ].collect({|input|
      [asSymbol(input++"_scale"), ~monitor_levels[\nugs][input]]
    }).flat ++
    [
      \metranome_bus, ~buss[\metranome],
      \inbus, ~buss[\nugs_mon],
      \outbus, ~id_bus_map[\nugs_mon_out],
    ],
    ~out_g )],
].do {|pair| ~p_synths.add(pair[0] -> pair[1]) };

"NUGS LOADED".postln;
)
