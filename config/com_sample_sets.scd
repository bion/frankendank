var mainPath = "./samples/com/".resolveRelative,
    orderedSampleSets,
    sampleFrom,
    kill;

kill = {|obj|
  obj.synth.free;
  obj.playing = false;
  if (obj.loopable) { obj.looping = false };
};

sampleFrom = {|name, loopable|
  (
    name: name,
    loopable: loopable,
    looping: false,
    synth: nil,
    playing: false,
    kill: kill,
    buffer: Buffer.read(s, (mainPath ++ name ++ ".aiff"));
  )
};

~sampleSets = IdentityDictionary[
  \jon1 -> [
    sampleFrom.value("HER1JONSample1", false),
    sampleFrom.value("HER1JONSample1wPickup", false),
    sampleFrom.value("HER1JONSample2", false),
    sampleFrom.value("HER1JONSample3", false),
    sampleFrom.value("HER1JONSample4", false)
  ]
];

orderedSampleSets = [
  \jon1
].collect {|setName| ~sampleSets[setName] };

~samplesController = HerSampleController(orderedSampleSets, ~buss[\sample], ~playbuf_g, ~clock);
