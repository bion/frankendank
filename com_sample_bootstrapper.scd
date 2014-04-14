(
var mainPath = "./samples/com/".resolveRelative;

~ordered_com_samples = [

  (name: "caddyshack", duration: 16, tempo: 80, loopable: true),

  (name: "IWYB_chorus", duration: 16, tempo: 98, loopable: false)

].collect {|sample|
  sample.buffer = Buffer.read(s, (mainPath ++ sample.name ++ ".aiff"));
};

)