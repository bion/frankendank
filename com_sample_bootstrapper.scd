var mainPath = "./samples/com/".resolveRelative,
    sampleGroups,
    orderedSampleGroups;

sampleGroups = IdentityDictionary[
  \jon1 -> [
    IdentityDictionary[
      \name -> "HER1JONSample1",
      \loopable -> false
    ],
    IdentityDictionary[
      \name -> "HER1JONSample1wPickup",
      \loopable -> false
    ],
    IdentityDictionary[
      \name -> "HER1JONSample2",
      \loopable -> false
    ],
    IdentityDictionary[
      \name -> "HER1JONSample3",
      \loopable -> false
    ],
    IdentityDictionary[
      \name -> "HER1JONSample4",
      \loopable -> false
    ]
  ]
].do {|sampleGroup|
  sampleGroup.do {|sample|
    sample[\buffer] = Buffer.read(s, (mainPath ++ sample[\name] ++ ".aiff"));
  };
};

orderedSampleGroups = [
  \jon1
].collect {|groupName| sampleGroups[groupName] };

~samplesController = HerSampleController(orderedSampleGroups, ~buss[\sample], ~playbuf_g, ~clock);
