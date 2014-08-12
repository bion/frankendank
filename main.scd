(
var run, after_boot,
activated_instr = [], instr_buttons = IdentityDictionary[],
instruments = [ \sax, \tuba, \drums, \com ],

gui_height = 700, gui_length = 900,
main_rect = Rect(250, 250, gui_length, gui_height),
main_window = View(nil, main_rect),

mon_windows = IdentityDictionary[],

btn_length = 80, btn_height = 30,

load_btn, start_btn,

instr_btn_left = 10, instr_btn_top = 10,

tempo_box, chord_index_box,

record_btn, player_btn, record_start, record_end, record_buf, recorded_buf,
stop_playing, player_route_synth, record_synth, player_synth, play_recorded_buf,
multi_recorder,

metronome,
metronome_amp,

midi_listener,
make_midi_listener = {|instr|
  if (instr == \andrew) {
    midi_listener = MIDIdef.noteOn(instr,
      func: { |num, chan, something, source|
        ~mSrc[instr] = source;
        midi_listener.free;
        AppClock.sched(0, {
          update_button.(instr_buttons[instr], instr ++ " active", Color.green)
        });
      }
    );
  } {
    midi_listener = MIDIdef(instr,
      func: { |num, chan, source|
        ~mSrc[instr] = source;
        midi_listener.free;
        AppClock.sched(0, {
          update_button.(instr_buttons[instr], instr ++ " active", Color.green)
        });
      },
      msgType: \program
    );
  };
},

make_labeled_slider = { | window, left, top, lo, hi, text, fxn, default=0 |
  var box, slider, spec;
  box = NumberBox(window, Rect(left, top, 50, 30)).align_(\center).value_(default).stringColor_(Color.white);

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

update_button = {|b, string, color=nil|
  b.states = [[string.asString, Color.black, color]];
  b.refresh;
},

// unfortunate hack
// thisProcess.nowExecutingPath binds to nil when the interpreter is run from a GUI
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
thisPath = thisProcess.nowExecutingPath;
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// end of unfortunate hack

// * * * * * * * * * * * * * * * * * * * * * * LOAD CONFIG

"./config/config.scd".loadRelative;

// * * * * * * * * * * * * * * * * * * * * * * CHORD INDICATOR

~tempo = 96/60;
StaticText(main_window, Rect(gui_length * 0.2, gui_height * 0.65 - 40, 50, 50)).string_("Tempo");
tempo_box = NumberBox(main_window, Rect(gui_length * 0.2, gui_height * 0.65, 50, 50))
.decimals_(0).value_((~tempo * 60).round).align_(\center).action_({
  |box|
  ~tempo = box.value / 60;
  if (~clock.notNil) { ~clock.tempo_(~tempo) };
});

StaticText(main_window, Rect(gui_length * 0.2 + 60, gui_height * 0.65 - 40, 50, 50)).string_("Chord");
chord_index_box = NumberBox(main_window, Rect(gui_length * 0.2 + 60, gui_height * 0.65, 50, 50))
.value_(0).align_(\center).action_({
  |box|
  ~chordSelector.setChordSlot(box.value);
});

// * * * * * * * * * * * * * * * * * * * * * * MONITORING WINDOWS

[ \sax, \tub, \drums, \nugs, \com ].do {|instr, i|
  var thisWindow;

  StaticText(main_window, Rect(instr_btn_left + btn_length * 1.5, instr_btn_top + 15 + (i*(btn_height + 40)), btn_length, 20))
  .string_(instr.asString);

  mon_windows[instr] = thisWindow = Window(instr ++ " monitor",
    Rect(300, 300, gui_length + 150, gui_height/2));

  [ \main, \met, \sax, \tub, \drum, \com, \sample, \met ].do {|input, j|
    make_labeled_slider.(thisWindow, 100 + (j * 120), 120, -60, 48, input, {|val|
      ~monitor_levels[instr][input] = val.dbamp;
      if (s.serverRunning) {
        var synth = ~p_synths[asSymbol(instr ++ "_mon")];
        synth.set(asSymbol(input ++ "_scale"), val.dbamp);
      };
    },
      ~monitor_levels[instr][input].ampdb
    );
  };

  Button(thisWindow,
    Rect(400, gui_height * 0.4, btn_length * 1.5, btn_height * 1.5))
  .states_( [["save to disk"]])
  .mouseDownAction_({
    thisProcess.nowExecutingPath = thisPath;
    ~monitor_levels.writeArchive("./archive/monitor_levels".resolveRelative);
  });

  Button(thisWindow,
    Rect(gui_length * 0.3, gui_height * 0.4, btn_length * 1.5, btn_height * 1.5))
  .states_( [["close window"]])
  .mouseDownAction_({
    thisWindow.visible = false;
  });

  Button(main_window,
    Rect(
      instr_btn_left + btn_length * 1.5, instr_btn_top + 40 + (i * (btn_height + 40)),
      btn_length,
      btn_height) )
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
  { source.device == "nanoPAD-nanoPAD MIDI 1" }
    { ~mSrc[\fingerPads] = source.uid }
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

[ \sax, \tuba, \drums_switch, \andrew ].do {|instr, i|
  StaticText(main_window, Rect(instr_btn_left, instr_btn_top + 20 + (i*(btn_height + 40)), btn_length, 10))
  .string_(instr.asString);

  instr_buttons[instr] = Button(main_window, Rect(instr_btn_left,
    instr_btn_top + 40 + (i*(btn_height + 40)),
    btn_length,
    btn_height)
  )
  .states_([["off"]])
  .mouseDownAction_({
    if (instr_buttons[instr].states[0][0] == "active") // shitty
    {
      postln("deactiving " ++ instr ++ "...");
      midi_listener.free;
      postln("removed listener for " ++ midi_listener.key);
      if (MIDIdef.all != []) { Error("untracked MIDIdef!!!").throw };
      AppClock.sched(0, {
        update_button.(instr_buttons[instr], "off");
      });
    }
    {
      make_midi_listener.(instr);
      postln("added listener for " ++ midi_listener.key);
      activated_instr = activated_instr.add(instr);
      postln("activated " ++ instr);
      AppClock.sched(0, {
        update_button.(instr_buttons[instr], "active");
      });
    };
  });
};

metronome_amp = 1;
make_labeled_slider.(main_window, gui_length * 0.065, gui_height * 0.65,
  -60, 0,
  "met amp", {|val|
    metronome_amp = val.dbamp;
    if (metronome.notNil) { metronome.amp = val.dbamp };
  },
  0
);

start_btn = Button(main_window, Rect(gui_length * 0.5, gui_height - 100, btn_length * 1.5, btn_height * 1.5) )
.states_([["BOOM", Color.black, Color.red]])
.mouseDownAction_({ run.() });

// * * * * * * * * * * * * * * * * * * * * * * RECORDING

record_btn = Button(main_window,
  Rect(gui_length * 0.5 + (btn_length * 1.5) + 20, gui_height - 100, btn_length * 1.5, btn_height * 1.5) )
.states_([["inactive"], Color.black])
.mouseDownAction_({"server not booted".postln});

record_start = {
  record_btn.mouseDownAction_(record_end);

  multi_recorder.start;

  AppClock.sched(0, {
    update_button.(record_btn, "stop recording", Color.green);
  });

  record_synth = Synth(\recordbuf_mono,
    [\inbus, ~buss[\com_mon_out], \buf, record_buf, \startpos, 0],
    ~record_g
  );
};

record_end = {
  var path = thisPath.dirname ++ "/recordings/" ++ Date.getDate ++ ".aiff";

  postln("WRITING TO: " ++ path);

  multi_recorder.stop;

  record_synth.free;
  record_buf.write(
    path,
    sampleFormat: "float"
  );

  recorded_buf = record_buf;

  record_buf = Buffer.alloc(s, 10 * 60 * s.sampleRate);

  AppClock.sched(0, {
    update_button.(record_btn, "record", Color.red);
    record_btn.mouseDownAction_(record_start);

    update_button.(player_btn, "play last", Color.green);
    player_btn.mouseDownAction_(play_recorded_buf);
  });

};

player_btn = Button(main_window, Rect(gui_length * 0.5 + (btn_length * 1.5 * 2) + 20,
  gui_height - 100, btn_length * 1.5, btn_height * 1.5) )
.states_([["inactive"], Color.black])
.mouseDownAction_({"server not booted".postln});

play_recorded_buf = {
  player_route_synth = Synth(\route_mono_to_6,
    [
      \inbus, ~buss[\all_monitors],
      \outbusses,
      [\drums_mon, \nugs_mon, \tub_mon, \sax_mon, \com_mon, \one_out]
      .collect {|bus| ~buss[bus] }
    ],
    ~agg_g
  );

  player_synth = Synth(\playbuf_simple,
    [\buf, recorded_buf, \outbus, ~buss[\all_monitors]], ~playbuf_g
  );

  player_btn.mouseDownAction_(stop_playing);
  AppClock.sched(0, {
    update_button.(player_btn, "stop", Color.green);
  });
};

stop_playing = {
  player_synth.free;
  player_route_synth.free;
  player_btn.mouseDownAction_(play_recorded_buf);
  AppClock.sched(0, {
    update_button.(player_btn, "play last", Color.red);
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

  Server.default = s = Server.local;
  s.latency = 0.005;
  if (~dev_mode.not) {
    s.options = ServerOptions.new.hardwareBufferSize_(128).threads_(4);
  };

  s.waitForBoot({ after_boot.() });
};

after_boot = {
  var cond = Condition.new;

  MIDIdef.freeAll;

  [
    "SD",
    "core",
    "com_sample_bootstrapper",
    "instr/drums",
    "persistent_synths",
    "instr/com_sample_map",
    "midi_mapping"
  ].do {|file|
    loadRelative("./" ++ file ++ ".scd");
    "".postln;
    s.sync;
  };

  // * * * * * * * * * * * * * * * * * * * * * * RECORDING

  if (~mSrc[\breath].notNil) {
    ~harmonyController = HerHarmonyController(~synth_g, ~buss[\com_agg], \com_dirt_rhode, ~clock.beatDur);

    ~chordSelector = HerChordSelector(
      main_window,
      ~chordNumberText,
      ~chordSchema,
      ~harmonyController
    );
  };

  // * * * * * * * * * * * * * * * * * * * * * * RECORDING

  multi_recorder = HerMultiTrackRecorder(
    ~record_g,
    thisPath.dirname ++ "/recordings",
    ~multi_record_buss
  );

  record_buf = Buffer.alloc(Server.default, 10 * 60 * Server.default.sampleRate);

  AppClock.sched(0, {
    update_button.(record_btn, "record", Color.red);
    record_btn.mouseDownAction_(record_start);
  });

  s.sync(cond);

  s.queryAllNodes;

  metronome = Metronome(
    ~clock,
    s,
    ~buss[\metronome],
    ~playbuf_g,
    \metronome_sine,
    metronome_amp
  );

  CmdPeriod.doOnce {
    multi_recorder = nil;
    s.freeAll;
    metronome.stop;
    metronome = nil;
    ~clock.clear.stop;
    ~clock = nil;
    ~chordSelector = nil;
    ~buss.keysValuesDo {|key, value| value.free; ~buss[key] = nil; };
    postln("busses freed");
    OSCFunc.allEnabled.do {|func| func.free};
    postln("OSCFuncs freed");
    // TODO cleanup loops

    AppClock.sched(0, {
      update_button.(record_btn, "disabled", nil);
      update_button.(player_btn, "disabled", nil);
      record_btn.mouseDownAction_({"server not started".postln});
      player_btn.mouseDownAction_({"server not started".postln});
    });

    postln("loop freed");
    MIDIdef.freeAll;
    postln("MIDIdefs freed");
    s.quit;
  };

  start_btn
  .states_([["Server Quit", Color.black, Color.green]])
  .mouseDownAction_({
    CmdPeriod.run;
    start_btn
    .states_([["BOOM!", Color.black, Color.red]])
    .mouseDownAction_({ run.() });
  });
};

main_window.onClose = {
  CmdPeriod.run;
  if (~dev_mode.not) { 0.exit };
};

currentEnvironment.do {_.free};

main_window.front;
)
