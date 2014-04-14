(
var mainPath = "./samples/com/".resolveRelative;

~ordered_com_samples = [

  (name: "IWYB", duration: 16, tempo: 98, loopable: false),

  (name: "caddyshack", duration: 16, tempo: 80, loopable: true)


].collect {|sample|
  sample.buffer = Buffer.read(s, (mainPath ++ sample.name ++ ".aiff"));
};

~sampleController = HerSampleController(~ordered_com_samples, false, ~buss[\com_agg], ~clock);

)