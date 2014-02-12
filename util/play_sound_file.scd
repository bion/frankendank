(
var guiLength=500, guiHeight=200,
mainWindow = Window("man-handle drum sample sets",
  Rect(100, 100, guiLength, guiHeight)
).front,

filePath,
fileField;

QtGUI.palette = QPalette.dark;

StaticText(mainWindow, Rect(30, 50, 400, 30))
.string_("drag sound file here").stringColor_(Color.white).align_(\left);
fileField = TextField(mainWindow, Rect(30, 80, 400, 60));

Button(mainWindow, Rect(30, 150, 120, 30))
.states_([["play", Color.green], ["stop", Color.red]])
.mouseDownAction_({
  fileField.string.postln;
});

)