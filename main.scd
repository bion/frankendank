var run, afterBoot,
activatedInstr = [], instrButtons = IdentityDictionary[],
instruments = [ \sax, \tuba, \drums, \com ],

guiHeight = 700, guiLength = 260,
mainRect = Rect(250, 250, guiLength, guiHeight),
mainWindow = View(nil, mainRect),

monWindows = IdentityDictionary[],

btnLength = 80, btnHeight = 30,

loadBtn, startBtn,

instrBtnLeft = 10, instrBtnTop = 10,

tempoBox,

recordBtn, playerBtn, recordStart, recordEnd, recordBuf, recordedBuf,
stopPlaying, playerRouteSynth, recordSynth, playerSynth, playRecordedBuf,
multiRecorder,

sampleSets,

metronome,
metronomeAmp,

midiListener,
makeMidiListener = {|instr|
  if ([\andrew, \samples, \chords].includes(instr)) {
    midiListener = MIDIdef.noteOn(instr,
      func: { |num, chan, something, source|
        ~mSrc[instr] = source;
        midiListener.free;
        AppClock.sched(0, {
          updateButton.(instrButtons[instr], instr ++ " active", Color.green)
        });
      }
    );
  } {
    midiListener = MIDIdef(instr,
      func: { |num, chan, source|
        ~mSrc[instr] = source;
        midiListener.free;
        AppClock.sched(0, {
          updateButton.(instrButtons[instr], instr ++ " active", Color.green)
        });
      },
      msgType: \program
    );
  };
},

makeLabeledSlider = { | window, left, top, lo, hi, text, fxn, default=0 |
  var box, slider, spec;
  box = NumberBox(window, Rect(left, top, 50, 30))
    .align_(\center)
    .value_(default)
    .stringColor_(Color.white);

  StaticText(window, Rect(left, top - 50, 50, 30))
  .align_(\center).string_(text).stringColor_(Color.white);

  spec = ControlSpec(lo, hi, \lin, 1);
  slider = Slider(window, Rect(left - 50, top - 50, 40, 200))
  .orientation_(\vertical)
  .value_(spec.unmap(default))
  .action_({
    var val = spec.map(slider.value);
    box.value_(val);
    fxn.(val);
  });
},

updateButton = {|b, string, color=nil|
  b.states = [[string.asString, Color.black, color]];
  b.refresh;
},

// unfortunate hack
// thisProcess.nowExecutingPath binds to nil when the interpreter is run from a GUI
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
thisPath = thisProcess.nowExecutingPath;
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// end of unfortunate hack

mainWindow.name_("her");

3.do { "".postln; };

"================================================================".postln;
"Initializing...".postln;
"================================================================".postln;
"".postln;

// * * * * * * * * * * * * * * * * * * * * * * LOAD CONFIG

"./config/config.scd".loadRelative;

// * * * * * * * * * * * * * * * * * * * * * * CHORD INDICATOR

~tempo = 96/60;
StaticText(mainWindow, Rect(instrBtnLeft + btnLength * 1.5, 415, 50, 50)).string_("Tempo");
tempoBox = NumberBox(mainWindow, Rect(instrBtnLeft + btnLength * 1.5, 455, 50, 50))
.decimals_(0).value_((~tempo * 60).round).align_(\center).action_({
  |box|
  ~tempo = box.value / 60;
  if (~clock.notNil) { ~clock.tempo_(~tempo) };
});

// * * * * * * * * * * * * * * * * * * * * * * MONITORING WINDOWS

[ \sax, \tub, \drums, \nugs, \com ].do {|instr, i|
  var thisWindow;

  StaticText(mainWindow, Rect(instrBtnLeft + btnLength * 1.5, instrBtnTop + 15 + (i*(btnHeight + 40)), btnLength, 20))
  .string_(instr.asString);

  monWindows[instr] = thisWindow = Window(instr ++ " monitor",
    Rect(300, 300, 1000, 350));

  [ \main, \met, \sax, \tub, \drum, \com, \sample, \met ].do {|input, j|
    makeLabeledSlider.(thisWindow, 100 + (j * 120), 120, -60, 48, input, {|val|
      ~monitorLevels[instr][input] = val.dbamp;
      if (s.serverRunning) {
        var synth = ~pSynths[asSymbol(instr ++ "_mon")];
        synth.set(asSymbol(input ++ "Scale"), val.dbamp);
      };
    },
      ~monitorLevels[instr][input].ampdb
    );
  };

  Button(thisWindow,
    Rect(400, guiHeight * 0.4, btnLength * 1.5, btnHeight * 1.5))
  .states_( [["save to disk"]])
  .mouseDownAction_({
    thisProcess.nowExecutingPath = thisPath;
    ~monitorLevels.writeArchive("./archive/monitor_levels".resolveRelative);
  });

  Button(thisWindow,
    Rect(guiLength * 0.3, guiHeight * 0.4, btnLength * 1.5, btnHeight * 1.5))
  .states_( [["close window"]])
  .mouseDownAction_({
    thisWindow.visible = false;
  });

  Button(mainWindow,
    Rect(
      instrBtnLeft + btnLength * 1.5, instrBtnTop + 40 + (i * (btnHeight + 40)),
      btnLength,
      btnHeight))
  .states_( [["monitor", Color.black]] )
  .mouseDownAction_({
    thisWindow.visible = true;
  });

};

// * * * * * * * * * * * * * * * * * * * * * * GLOBALS

QtGUI.palette = QPalette.dark;

~mSrc = IdentityDictionary[];

MIDIClient.init;
MIDIIn.connectAll;

MIDIClient.sources.do {|source|
  case
  { source.device == "Breath Controller-Breath Controller MIDI 1" }
    { ~mSrc[\breath] = source.uid }
  { source.device == "BCR2000" }
    { ~mSrc[\bcr] = ~mSrc[\bcr] ? source.uid }
  { source.device == "BCR2000-BCR2000 MIDI 1" }
    { ~mSrc[\bcr] = ~mSrc[\bcr] ? source.uid }
  { source.device == "ControlPad" }
    { ~mSrc[\drum_pad] = source.uid }
  { source.device == "ControlPad-ControlPad MIDI 1" }
    { ~mSrc[\drum_pad] = source.uid };
};

// * * * * * * * * * * * * * * * * * * * * * * UI

[ \sax, \tuba, \drums_switch, \andrew, \samples, \chords ].do {|instr, i|
  StaticText(mainWindow, Rect(instrBtnLeft, instrBtnTop + 20 + (i*(btnHeight + 40)), btnLength, 10))
  .string_(instr.asString);

  instrButtons[instr] = Button(mainWindow, Rect(instrBtnLeft,
    instrBtnTop + 40 + (i*(btnHeight + 40)),
    btnLength,
    btnHeight)
  )
  .states_([["off"]])
  .mouseDownAction_({
    if (instrButtons[instr].states[0][0] == "active") // shitty
    {
      postln("deactiving " ++ instr ++ "...");
      midiListener.free;
      postln("removed listener for " ++ midiListener.key);
      if (MIDIdef.all != []) { Error("untracked MIDIdef!!!").throw };
      AppClock.sched(0, {
        updateButton.(instrButtons[instr], "off");
      });
    }
    {
      makeMidiListener.(instr);
      postln("added listener for " ++ midiListener.key);
      activatedInstr = activatedInstr.add(instr);
      postln("activated " ++ instr);
      AppClock.sched(0, {
        updateButton.(instrButtons[instr], "active");
      });
    };
  });
};

metronomeAmp = 1;
makeLabeledSlider.(mainWindow, instrBtnLeft + 50, 500,
  -60, 0,
  "met amp", {|val|
    metronomeAmp = val.dbamp;
    if (metronome.notNil) { metronome.amp = val.dbamp };
  },
  0
);

startBtn = Button(mainWindow, Rect(instrBtnLeft + btnLength * 1.5, guiHeight - 160 - btnHeight, btnLength * 1.5, btnHeight * 1.5) )
.states_([["BOOM", Color.black, Color.red]])
.mouseDownAction_({ run.() });

// * * * * * * * * * * * * * * * * * * * * * * RECORDING

recordBtn = Button(mainWindow,
  Rect(instrBtnLeft + btnLength * 1.5, guiHeight - 130, btnLength * 1.5, btnHeight * 1.5) )
.states_([["inactive"], Color.black])
.mouseDownAction_({"server not booted".postln});

recordStart = {
  recordBtn.mouseDownAction_(recordEnd);

  multiRecorder.start;

  AppClock.sched(0, {
    updateButton.(recordBtn, "stop recording", Color.green);
  });

  recordSynth = Synth(\recordbuf_mono,
    [\inbus, ~buss[\com_mon_out], \buf, recordBuf, \startpos, 0],
    ~record_g
  );
};

recordEnd = {
  var path = thisPath.dirname ++ "/recordings/" ++ Date.getDate ++ ".aiff";

  postln("WRITING TO: " ++ path);

  multiRecorder.stop;

  recordSynth.free;
  recordBuf.write(
    path,
    sampleFormat: "float"
  );

  recordedBuf = recordBuf;

  recordBuf = Buffer.alloc(s, 10 * 60 * s.sampleRate);

  AppClock.sched(0, {
    updateButton.(recordBtn, "record", Color.red);
    recordBtn.mouseDownAction_(recordStart);

    updateButton.(playerBtn, "play last", Color.green);
    playerBtn.mouseDownAction_(playRecordedBuf);
  });

};

playerBtn = Button(mainWindow, Rect(instrBtnLeft + btnLength * 1.5,
  guiHeight - 80, btnLength * 1.5, btnHeight * 1.5) )
.states_([["inactive"], Color.black])
.mouseDownAction_({"server not booted".postln});

playRecordedBuf = {
  playerRouteSynth = Synth(\route_mono_to_6,
    [
      \inbus, ~buss[\all_monitors],
      \outbusses,
      [\drums_mon, \nugs_mon, \tub_mon, \sax_mon, \com_mon, \one_out]
      .collect {|bus| ~buss[bus] }
    ],
    ~agg_g
  );

  playerSynth = Synth(\playbuf_simple,
    [\buf, recordedBuf, \outbus, ~buss[\all_monitors]], ~playbuf_g
  );

  playerBtn.mouseDownAction_(stopPlaying);
  AppClock.sched(0, {
    updateButton.(playerBtn, "stop", Color.green);
  });
};

stopPlaying = {
  playerSynth.free;
  playerRouteSynth.free;
  playerBtn.mouseDownAction_(playRecordedBuf);
  AppClock.sched(0, {
    updateButton.(playerBtn, "play last", Color.red);
  });
};

// * * * * * * * * * * * * * * * * * * * * * * RUN

run = {
  // unfortunate hack
  // thisProcess.nowExecutingPath binds to nil when the interpreter is run from a GUI
  // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
  thisProcess.nowExecutingPath_(thisPath);
  // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
  // end of unfortunate hack
  3.do { "".postln; };
  "================================================================".postln;
  "Booting server...".postln;
  "================================================================".postln;
  "".postln;

  Server.default = s = Server.local;
  s.latency = 0.005;
  if (~devMode.not) {
    s.options = ServerOptions.new.hardwareBufferSize_(128).threads_(4);
  };

  s.waitForBoot({ afterBoot.() });
};

afterBoot = {
  var cond = Condition.new(true);
  "".postln;
  "================================================================".postln;
  "Server booted.".postln;
  "Bootsrapping performance environment, hold on tight...".postln;
  "================================================================".postln;
  "".postln;

  ~clock = TempoClock(~tempo, queueSize: 2**10);
  ~pSynths = IdentityDictionary[];
  HerLoop.setPersistentSynths(~pSynths);

  MIDIdef.freeAll;

  [
    "SD",
    "busses",
    "groups",
    "buffers",
    "horn_control",
    "instr/drums",
    "persistent_synths",
  ].do {|file|
    loadRelative("./" ++ file ++ ".scd");
    "".postln;
    s.sync;
  };

  sampleSets = loadRelative("./com_samples.scd")[0].value(
    ~playbuf_g,
    ~buss[\sample]
  );
  ~samplesController = loadRelative("./lib/her_sample_controller.scd")[0].value(
    ~clock,
    sampleSets
  );

  s.sync(Condition(true));

  if (~mSrc[\breath].notNil) {
    var breathSynthCond = Condition(true);
    "Loading breath synths...".postln;

    ~comSynths = [
      HerSynthDanDan(~synth_g, ~buss[\com_agg]),
      HerSynthFank(~synth_g, ~buss[\com_agg]),
      HerSynthDirtRhode(~synth_g, ~buss[\com_agg])
    ];

    s.sync(breathSynthCond);

    ~harmonyController = HerHarmonyController(
      ~comSynths,
      ~chordSets,
      ~clock.beatDur
    );

    "Done loading breath synths".postln;
  };

  if (~harmonyController.notNil) {
    ~pieceController = loadRelative("./lib/her_piece_controller.scd")[0].value(
      ~samplesController,
      ~harmonyController
    );
  };

  multiRecorder = HerMultiTrackRecorder(
    ~record_g,
    thisPath.dirname ++ "/recordings",
    ~multi_record_buss
  );

  recordBuf = Buffer.alloc(Server.default, 10 * 60 * Server.default.sampleRate);

  AppClock.sched(0, {
    updateButton.(recordBtn, "record", Color.red);
    recordBtn.mouseDownAction_(recordStart);
  });

  s.sync(cond);

  metronome = Metronome(
    ~clock,
    s,
    ~buss[\metronome],
    ~playbuf_g,
    \metronome_sine,
    metronomeAmp
  );

  ["midi_mapping"].do { |file|
    loadRelative("./" ++ file ++ ".scd");
  };

  CmdPeriod.doOnce {
    "".postln;
    "================================================================".postln;
    "Kill received, shutting down...".postln;
    "================================================================".postln;
    multiRecorder = nil;
    s.freeAll;
    metronome.stop;
    metronome = nil;
    ~clock.clear.stop;
    ~clock = nil;
    ~buss.keysValuesDo {|key, value| value.free; ~buss[key] = nil; };
    postln("busses freed");
    OSCFunc.allEnabled.do {|func| func.free};
    postln("OSCFuncs freed");
    // TODO cleanup loops

    AppClock.sched(0, {
      updateButton.(recordBtn, "disabled", nil);
      updateButton.(playerBtn, "disabled", nil);
      recordBtn.mouseDownAction_({"server not started".postln});
      playerBtn.mouseDownAction_({"server not started".postln});
    });

    postln("loop freed");
    MIDIdef.freeAll;
    postln("MIDIdefs freed");
    s.quit;
    "".postln;
    "Server quit".postln;
  };

  startBtn
  .states_([["Server Quit", Color.black, Color.green]])
  .mouseDownAction_({
    CmdPeriod.run;
    startBtn
    .states_([["BOOM!", Color.black, Color.red]])
    .mouseDownAction_({ run.() });
  });

  s.sync;

  "".postln;

"
|                                    o
|---. ,---. ,---.  ,-.-. .   . ,---. . ,---.
|   | |---' |      | | | |   | `---. | |
`   ' `---' `      ` ' ' `---' `---' ` `---'
".postln;

  "".postln;

  "server ready".postln;

  "".postln;
};

mainWindow.onClose = {
  CmdPeriod.run;
  if (~devMode.not) { 0.exit };
};

currentEnvironment.do {_.free};
mainWindow.front;

"".postln;

"\nStartup loaded, waiting...".postln;
"";
