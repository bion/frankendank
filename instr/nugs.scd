(

[
  [\nugs_mon, Synth(\mon,
    [
      \drum_scale, 1,
      \sax_scale, 1,
      \tub_scale, 1,
      \com_scale, 1,
      \met_scale, 1,
      \metranome_bus, ~buss[\metranome],
      \inbus, ~buss[\nugs_mon],
      \outbus, ~id_bus_map[\nugs_mon_out],
    ],
    ~out_g, \addAfter )],
].do {|pair| ~p_synths.add(pair[0] -> pair[1]) };

"NUGS LOADED".postln;
)
