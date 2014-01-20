(
var guiLength=750, guiHeight=400,
hiPaths = "../samples/drum/hi/".resolveRelative,
medPaths = "../samples/drum/med/".resolveRelative,
lowPaths = "../samples/drum/low".resolveRelative,
archivePath = "../archive/drum_sample_sets".resolveRelative,

mainWindow = Window("man-handle drum sample sets",
  Rect(100, 100, guiLength, guiHeight)
).front,

volatileElements = LinkedList[],

renderSampleSelectors,
renderNewTemplate, renderSelectedSet;

QtGUI.palette = QPalette.dark;

// exports ~drums
"../instr/drum_sample_map.scd".loadRelative;

~sample_sets = Object.readArchive(archivePath);

// **************************** UI elements

StaticText(mainWindow, Rect(10, 10, 90, 30))
.string_("set").stringColor_(Color.white).align_(\left);

PopUpMenu(mainWindow, Rect(10, 40, 90, 30))
.items_(["select set"] ++ (0 .. ~sample_sets.size) ++ ["new set"])
.action_({|val|
  if (val == "new set") {
    renderNewTemplate.();
  } {
    volatileElements.do {|e| e.remove};
    renderSelectedSet.(val.item);
  };
});

renderSampleSelectors = {|sampleName, top, left, action, default|
  var dropDown, items = ~drums.keys.asArray.sort, indexOfDefault;
  indexOfDefault = items.indexOf(default);
  dropDown = PopUpMenu(mainWindow, Rect(left, top, 160, 30))
  .items_(items)
  .action_(action)
  .value_(indexOfDefault);
  volatileElements.add(dropDown);
};

renderSelectedSet = {|setIndex|
  var thisSet = ~sample_sets[setIndex];

  8.do {|padNum|
    var name = 'old',
    left = padNum % 4 * 180 + 20, top,

    action = {|val|
      thisSet[asSymbol("drum_" ++ padNum)] = val.item;
      ~sample_sets.writeArchive(archivePath);
      thisSet.postln;
    },

    default = thisSet[asSymbol("drum_" ++ padNum)];

    if (padNum < 4) { top = 100 } { top = 250 };

    renderSampleSelectors.(name, top, left, action, default);
  };
};

renderNewTemplate = {
  8.do {|padNum|
    var name = 'new',
    left = padNum % 4 * 180 + 20, top;

    if (padNum < 4) { top = 100 } { top = 250 };
    renderSampleSelectors.(name, top, left);
  };
};

)