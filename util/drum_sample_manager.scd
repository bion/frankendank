(
var guiLength=750, guiHeight=500,
hiPaths = "../samples/drum/hi/".resolveRelative,
medPaths = "../samples/drum/med/".resolveRelative,
lowPaths = "../samples/drum/low".resolveRelative,
archivePath = "../archive/drum_sample_sets".resolveRelative,

mainWindow = Window("man-handle drum sample sets",
  Rect(100, 100, guiLength, guiHeight)
).front,

volatileElements = LinkedList[],

menu,

renderSampleSelectors,
addNewSet, renderSelectedSet;

mainWindow.onClose = {
  0.exit;
};

QtGUI.palette = QPalette.dark;

// exports ~drum_samples
"../instr/drum_sample_map.scd".loadRelative;

~sample_sets = Object.readArchive(archivePath);

// **************************** UI elements

StaticText(mainWindow, Rect(10, 10, 90, 30))
.string_("set").stringColor_(Color.white).align_(\left);

menu = PopUpMenu(mainWindow, Rect(10, 40, 90, 30))
.items_(["select set"] ++ (0 .. (~sample_sets.size-1)) ++ ["new set"])
.action_({|val|
  volatileElements.do {|e| e.remove};
  if (val.item == "new set") {
    addNewSet.();
  } {
    renderSelectedSet.(val.item);
  };
});

renderSampleSelectors = {|sampleName, top, left, action, default|
  var dropDown, items = ~drum_samples.keys.asArray.sort, indexOfDefault;
  indexOfDefault = items.indexOf(default);
  dropDown = PopUpMenu(mainWindow, Rect(left, top, 160, 30))
  .items_(items)
  .action_(action)
  .value_(indexOfDefault);
  volatileElements.add(dropDown);
};

renderSelectedSet = {|setIndex| block{|break|
  var thisSet;

  if (setIndex.isKindOf(String)) { break.() };

  thisSet = ~sample_sets[setIndex];

  9.do {|padNum|
    var name = 'old',
    left = padNum % 4 * 180 + 20, top,

    action = {|val|
      thisSet[asSymbol("drum_" ++ padNum)] = val.item;
      ~sample_sets.writeArchive(archivePath);
      thisSet.postln;
    },

    default = thisSet[asSymbol("drum_" ++ padNum)];

    case
    {padNum < 4 } { top = 100 }
    {padNum < 8 } { top = 250 }
    {padNum < 12} { top = 400 };

    renderSampleSelectors.(name, top, left, action, default);
  };
}};

addNewSet = {
  var newSet = ~sample_sets[~sample_sets.size-1].deepCopy;
  ~sample_sets = ~sample_sets.add(newSet);
  menu.items_(["select set"] ++ (0 .. (~sample_sets.size-1)) ++ ["new set"]);
  ~sample_sets.writeArchive(archivePath);
  menu.valueAction = ~sample_sets.size;
};
)