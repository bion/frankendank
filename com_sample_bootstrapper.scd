(
var mainPath = "./samples/com/".resolveRelative;

~ordered_com_samples = [

  (name: "rwy_vox_full", duration: 120, tempo: 115, loopable: false),

  (name: "iwyb_vox_full", duration: 18, tempo: 96, loopable: false)


].collect {|sample|
  sample.buffer = Buffer.read(s, (mainPath ++ sample.name ++ ".aiff"));
};

~sampleController = HerSampleController(~ordered_com_samples, ~buss[\com_agg], ~playbuf_g, ~clock);

)
