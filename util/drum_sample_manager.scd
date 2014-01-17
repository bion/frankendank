(
var guiLength=750, guiHeight=400,
hiPaths = "../samples/drum/hi/".resolveRelative,
medPaths = "../samples/drum/med/".resolveRelative,
lowPaths = "../samples/drum/low".resolveRelative,

mainWindow = Window("man-handle drum sample sets",
  Rect(100, 100, guiLength, guiHeight)
).front,

volatileElements = LinkedList[],

renderSampleSelectors,
renderNewTemplate, renderSelectedSet;

QtGUI.palette = QPalette.dark;

// exports ~drums
"../instr/drum_sample_map.scd".loadRelative;

~sample_sets = Object.readArchive("../archive/drum_sample_sets".resolveRelative);

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

renderSampleSelectors = {|sampleName, top, left|
  var dropDown;
  dropDown = PopUpMenu(mainWindow, Rect(left, top, 160, 30))
  .items_(~drums.keys.asArray.sort);
  volatileElements.add(dropDown);
};

renderSelectedSet = {|setIndex|
  var thisSet = ~sample_sets[setIndex];

  8.do {|padNum|
    var name = 'old',
    left = padNum % 4 * 180 + 20, top;

    if (padNum < 4) { top = 100 } { top = 250 };
    renderSampleSelectors.(name, top, left);
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