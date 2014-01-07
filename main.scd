(
var run, after_boot,
activated_instr = [], instr_buttons = IdentityDictionary[],
instruments = [ \sax, \tuba, \drums, \com ],

gui_height = 700, gui_length = 900,
main_window = Window("her we go", Rect(250, 250, gui_length, gui_height)),

btn_length = 80, btn_height = 30,

load_btn,

instr_btn_left = 10, instr_btn_top = 10,

tempo_slider, tempo_box,
tempo_box_top = gui_height * 0.25, tempo_box_left = gui_length * 0.5,
tempo_box_height = 60, tempo_box_length = 100,
tempo_spec,

midi_listener,
make_midi_listener = {|instr|
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


// * * * * * * * * * * * * * * * * * * * * * * GLOBALS

~mSrc = IdentityDictionary[];

MIDIClient.init;
MIDIIn.connectAll;

MIDIClient.sources.do {|source|
  case
  {source.device == "Breath Controller"}  {~mSrc[\breath] = source.uid}
  {source.device == "ControlPad"}         { ~mSrc[\drum_pad] = source.uid};
};


// * * * * * * * * * * * * * * * * * * * * * * UI

[ \sax, \tuba, \drums ].do {|instr, i|
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

load_btn = Button(main_window, Rect(instr_btn_left, instr_btn_top + 40 + (3 * (btn_height + 40)), btn_length * 1.5, btn_height * 1.5) )
.states_( [ ["Load From Disk", Color.black], ["No Archive", Color.red] ] )
.mouseDownAction_({
  // unfortunate hack
  // thisProcess.nowExecutingPath binds to nil when the interpreter is run from a GUI
  // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
  thisProcess.nowExecutingPath_(thisPath);
  // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
  // end of unfortunate hack

  ~mSrc = Object.readArchive("./archive/mSrc".resolveRelative);
  ~mSrc.keysValuesDo {|instr, midi_id|
    postln(instr ++ ": " ++ midi_id);
    activated_instr = activated_instr.add(instr);
    update_button(instr_buttons[instr], "active", Color.green);
    load_btn.destroy;
  };
});

tempo_box = NumberBox(main_window, Rect(tempo_box_left,
  tempo_box_top,
  tempo_box_length,
  tempo_box_height));

StaticText(main_window, Rect(tempo_box_left,
  tempo_box_top - 50,
  tempo_box_length,
  tempo_box_height)).align_(\center).string_("tempo");

tempo_spec = ControlSpec(60, 220, \lin, 1);
tempo_slider = Slider(main_window, Rect(tempo_box_left, tempo_box_top + tempo_box_height + 20, 220, 40))
.value_(10) .action_({
  var val = tempo_spec.map(tempo_slider.value);
  tempo_box.value_(val);
  ~tempo = val/60;
});
tempo_box.value_(tempo_spec.map(tempo_slider.value));

Button(main_window, Rect(gui_length * 0.5, gui_height - 100, btn_length * 1.5, btn_height * 1.5) )
.states_([["BOOM!", Color.black, Color.red]])
.mouseDownAction_({ run.() });

// * * * * * * * * * * * * * * * * * * * * * * RUN

run = {
  // unfortunate hack
  // thisProcess.nowExecutingPath binds to nil when the interpreter is run from a GUI
  // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
  thisProcess.nowExecutingPath_(thisPath);
  // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
  // end of unfortunate hack

  Server.default = s = Server.local;
  s.latency = 0.02;
  s.options = ServerOptions.new.hardwareBufferSize = 128;

  s.waitForBoot({ after_boot.() });
};

after_boot = {
  var cond = Condition.new;

  [
    "config/config",
    "SD",
    "core",
    "looping",
    "instr/com_sample_map",
    "jams",
    "task_master",
    "instr/nugs",
    "instr/com"
  ].do {|file|
    loadRelative("./" ++ file ++ ".scd");
    s.sync;
  };

  activated_instr.do {|instr| loadRelative("./instr/" ++ instr ++ ".scd") };

  s.sync(cond);

  s.queryAllNodes;

  CmdPeriod.doOnce {
    s.freeAll;
    ~clock.clear.stop;
    ~buss.keysValuesDo {|key, value| value.free };
    postln("busses freed");
    OSCFunc.allEnabled.do {|func| func.free};
    postln("OSCFuncs freed");
    ~loops.keysValuesDo {|key, value| value.keysValuesDo {|kk, vv| vv[\buffer].free }; };
    postln("loop freed");
    MIDIdef.freeAll;
    postln("MIDIdefs freed");
    s.quit;
  };

  ~mSrc.writeArchive("./archive/mSrc".resolveRelative);

  ~scheduler.();
};

main_window.onClose = {
  CmdPeriod.run;
  0.exit;
};

currentEnvironment.do {_.free};

main_window.front;
)
