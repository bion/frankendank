~loop_touch.(IdentityDictionary[\instr -> \sax, \num -> 3]);
~loop_touch.(IdentityDictionary[\instr -> \sax, \num -> 2]);
~clear_loop.(\sax);
s.boot
s.quit

(
    ~change_breath_synth.(
      \com_fank,
      [\bus, ~buss[\com_eq], \amp_bus, ~buss[\breath_v], \freq_lag_bus, ~buss[\freq_lag]],
      ~dirt_rhode_g
    );
)
