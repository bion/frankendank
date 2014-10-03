(
var met_sfd = "./met_sfs/*".resolveRelative.pathMatch; // natural numbers

"LOADING BUFFERS...".post;

if (met_sfd.size == 0) {
  var mes = "No metronome files found, where are they?";
  Error(mes).throw;
} {
  ~met_bufs = Array.newClear(met_sfd.size);

  met_sfd.do {|path, i|
    ~met_bufs[i] = Buffer.read(s, path) };
};

"done".postln;
)