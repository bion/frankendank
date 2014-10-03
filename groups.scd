"LOADING GROUPS...".post;

~data_g        = ParGroup(s);
~playbuf_g     = ParGroup(~data_g, \addAfter);
~in_g          = ParGroup(~playbuf_g, \addAfter);
~synth_g       = ParGroup(~in_g, \addAfter);
~filt_g        = ParGroup(~synth_g, \addAfter);
~eq_g          = ParGroup(~filt_g, \addAfter);

~loop_g        = ParGroup(~eq_g, \addAfter);
~record_loop_g = ParGroup(~loop_g, \addToHead);
~play_loop_g   = ParGroup(~record_loop_g, \addAfter);
~filt_loop_g   = ParGroup(~play_loop_g, \addAfter);
~sum_loop_g    = ParGroup(~filt_loop_g, \addAfter);
~route_loop_g  = ParGroup(~sum_loop_g, \addAfter);

~agg_g         = ParGroup(~loop_g, \addAfter);
~out_g         = ParGroup(~agg_g, \addAfter);
~record_g      = ParGroup(~out_g, \addAfter);

"done".postln;