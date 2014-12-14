(
var guiLength=500, guiHeight=200,
mainWindow = Window("man-handle drum sample sets",
  Rect(100, 100, guiLength, guiHeight)).front,

filePath, buffer,
playerSynth,

button, fileField,

addPlaySynth, stopPushed, playPushed;

QtGUI.palette = QPalette.dark;

playPushed = {
  if (filePath == fileField.string) {
    addPlaySynth.();
  } {
    buffer.free;
    filePath = fileField.string;
    Buffer.read(s, filePath, action: addPlaySynth);
  };
};

addPlaySynth = {
  playerSynth = Synth(\playbuf_stereo_to_mono_to_mons,
    [
      \amp, 0.5,
      \buf, buffer,
      \sax_mon, ~id_bus_map[\sax_mon_out],
      \drums_mon, ~id_bus_map[\drums_mon_out],
      \nugs_mon, ~id_bus_map[\nugs_mon_out],
      \com_mon, ~id_bus_map[\com_mon_out]
    ]
  );

  AppClock.sched(0, {
    button.mouseDownAction_(stopPushed);
    button.states = [["stop", Color.red]];
    button.refresh;
  });

  "playing".postln;
};

stopPushed = {
  AppClock.sched(0, {
    button.mouseDownAction_(playPushed);
    button.states_([["play", Color.green]]);
    button.refresh;
  });

  playerSynth.free;
  playerSynth = nil;

  "stopped".postln;
};

StaticText(mainWindow, Rect(30, 50, 400, 30))
.string_("drag sound file here").stringColor_(Color.white).align_(\left);
fileField = TextField(mainWindow, Rect(30, 80, 400, 60));

button = Button(mainWindow, Rect(30, 150, 120, 30))
.states_([["play", Color.green]])
.mouseDownAction_(playPushed);

mainWindow.onClose_({
  if (playerSynth.notNil) { playerSynth.free };
  buffer.free;
});

)
