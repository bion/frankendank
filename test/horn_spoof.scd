(
var source_dir = "~/Dropbox/electric_band_shared_music/raw_horn_samples/".standardizePath;
~sax_buf = Buffer.read(s, source_dir ++ "sax.aiff");
~tuba_buf = Buffer.read(s, source_dir ++ "tuba.aiff");
)

a = Synth(\playbuf_simple, [\outbus, ~buss[\sax_spoof], \buf, ~sax_buf], ~playbuf_g);
b = Synth(\playbuf_simple, [\outbus, ~buss[\tub_spoof], \buf, ~tuba_buf], ~playbuf_g);
a.free;
b.free;