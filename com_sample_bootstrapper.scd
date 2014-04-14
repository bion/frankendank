(
var mainPath = "./samples/com/".resolveRelative;

~ordered_com_samples = [

  (name: "caddyshack", duration: 16, tempo: 80, loopable: true),

  (name: "IWYB_chorus", duration: 16, tempo: 92, loopable: true)

].collect {|sample|
  sample.buffer = Buffer.read(s, (mainPath ++ sample.name ++ ".aiff"));
};

)