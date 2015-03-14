var expand;
var expansionStrategies;
var argExpansions;
var expandEvent;
var applyArgExpansion;

expandEvent = { |input|
  block { |break|
    if (input.class != Event) { break.value };

    input.keysValuesDo { |k, v|
      case
      {argExpansions[k].notNil} {
        applyArgExpansion.value(input, k);
      }
      {v.class == Event} {
        expand.value(v);
      }
      {v.class == Array} {
        v.do {|vv|
          expandEvent.value(vv);
        };
      };
    };
  };
};

expansionStrategies = Dictionary[
  Event -> expandEvent
];

argExpansions = IdentityDictionary[
  \pitch -> { |input|
    input.freq = input.pitch.freq;
  }
];

applyArgExpansion = { |input, key|
  argExpansions[key].value(input);
  input.removeAt(key);
};

{ |input|
  var strategy = expansionStrategies[input.class];

  if (strategy.class == Function) {
    strategy.value(input);
  };
};
