var sampleConstructor = loadRelative("./lib/her_com_sample.scd")[0];
var sampleSets = loadRelative("./config/sample_sets.scd")[0];

{arg ...args;
  var sample = sampleConstructor.value(*args);

  sampleSets.keysValuesDo { |name, set|
    sampleSets[name] = set.collect { |sampleConfig|
      sample.valueArray(sampleConfig);
    };
  };

  sampleSets;
};
