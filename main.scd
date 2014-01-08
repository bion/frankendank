(
var run, after_boot,
activated_instr = [], instr_buttons = IdentityDictionary[],
instruments = [ \sax, \tuba, \drums, \com ],

gui_height = 700, gui_length = 900,
main_window = Window("her we go", Rect(250, 250, gui_length, gui_height)),

btn_length = 80, btn_height = 30,

load_btn, start_btn,

simple_loops_btn,
simple_loops_left = gui_length * 0.66, simple_loops_top = gui_height * 0.125,
currently_looping = false, wait_next_loops, looping_synth, schedule_simple_loops,
simple_loops_buf_name, simple_loops_list,

instr_btn_left = 10, instr_btn_top = 10,

tempo_slider, tempo_box, simple_loops,
tempo_box_top = gui_height * 0.125, tempo_box_left = gui_length * 0.375,
tempo_box_height = 30, tempo_box_length = 50,
tempo_spec,

met_amp_slider, met_amp_box,
met_amp_top = gui_height * 0.125, met_amp_left = gui_length * 0.25,
met_amp_height = 30, met_amp_length = 50,
met_amp_spec,

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

make_labeled_slider = { | window, left, top, lo, hi, text, fxn |
  var box, slider, spec;
  box = NumberBox(main_window, Rect(left, top, tempo_box_length, tempo_box_height)).align_(\center);

  StaticText(main_window, Rect(left, top - 50, tempo_box_length, tempo_box_height))
  .align_(\center).string_(text);

  spec = ControlSpec(lo, hi, \lin, 1);
  slider = Slider(window, Rect(left - 50, top - 50, 40, 180))
  .orientation_(\vertical)
  .value_(hi)
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
    update_button.(instr_buttons[instr], "active", Color.green);
    load_btn.destroy;
  };
});


tempo_box = NumberBox(main_window, Rect(tempo_box_left,
  tempo_box_top,
  tempo_box_length,
  tempo_box_height
)).align_(\center);

StaticText(main_window, Rect(tempo_box_left,
  tempo_box_top - 50,
  tempo_box_length,
  tempo_box_height)).align_(\center).string_("tempo");

tempo_spec = ControlSpec(60, 220, \lin, 1);
tempo_slider = Slider(main_window, Rect(tempo_box_left - 50, tempo_box_top - 50, 40, 180))
.orientation_(\vertical)
.value_(220)
.action_({
  var val = tempo_spec.map(tempo_slider.value);
  tempo_box.value_(val);
  ~tempo = val/60;
  if (~clock.notNil) { ~clock.tempo_(~tempo) };
});
tempo_box.value_(tempo_spec.map(tempo_slider.value));

met_amp_box = NumberBox(main_window, Rect(met_amp_left,
  met_amp_top,
  met_amp_length,
  met_amp_height
)).align_(\center);

StaticText(main_window, Rect(met_amp_left,
  met_amp_top - 50,
  met_amp_length,
  met_amp_height)).align_(\center).string_("met amp");

met_amp_spec = ControlSpec(-60, 0, \lin, 1);
met_amp_slider = Slider(main_window, Rect(met_amp_left - 50, met_amp_top - 50, 40, 180))
.orientation_(\vertical)
.value_(10)
.action_({
  var val = met_amp_spec.map(met_amp_slider.value);
  met_amp_box.value_(val);
  ~metronome_amp = val.dbamp;
});

make_labeled_slider.(main_window, simple_loops_left, simple_loops_top,
  4, 64,
  "beats in sample", {|val|
    ~simple_loops_beats = val;
});

simple_loops_list = PopUpMenu(main_window, Rect(gui_length * 0.75, gui_height * 0.125 - 50, 180, 20))
.items = "./samples/com/*".resolveRelative.pathMatch.collect { | path |
  path.findRegexp("([0-9a-zA-Z\_]+)\.aiff")[1][1];
};

schedule_simple_loops = {
  var buf = ~com_bufs[simple_loops_buf_name];
  ~simple_loops_amp = 1;
  "SCHEDULING SIMPLE LOOP...".postln;
  ~clock.playNextBar({
    postln("SIMPLE LOOP STARTED FOR " ++ buf);
    looping_synth = Synth(\playbuf_simple, [\buf, buf, \amp, ~simple_loops_amp, \outbus, 0]);
  });

  wait_next_loops = fork {
    wait(~clock.beatDur * ~simple_loops_beats);
    schedule_simple_loops.();
  };
};

simple_loops_btn = Button(main_window, Rect(gui_length * 0.75, gui_height * 0.125, btn_length, btn_height))
.states_([["disabled", Color.black]])
.mouseDownAction_({
  if (currently_looping) {
    wait_next_loops.stop.reset;
    looping_synth.free;
    AppClock.sched(0, {
      update_button.(simple_loops_btn, "play", Color.red);
    });
    currently_looping = false;
  } {
    schedule_simple_loops.();
    AppClock.sched(0, {
      update_button.(simple_loops_btn, "stop", Color.green);
    });
    currently_looping = true;
  };
});


start_btn = Button(main_window, Rect(gui_length * 0.5, gui_height - 100, btn_length * 1.5, btn_height * 1.5) )
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

  AppClock.sched(0, {
    simple_loops_buf_name = simple_loops_list.item.asSymbol;
    update_button.(simple_loops_btn, "play", Color.red);
  });

  s.queryAllNodes;

  CmdPeriod.doOnce {
    s.freeAll;
    ~clock.clear.stop;
    ~clock = nil;
    ~buss.keysValuesDo {|key, value| value.free };
    postln("busses freed");
    OSCFunc.allEnabled.do {|func| func.free};
    postln("OSCFuncs freed");
    ~loops.keysValuesDo {|key, value| value.keysValuesDo {|kk, vv| vv[\buffer].free }; };
    AppClock.sched(0, {
      update_button.(simple_loops_btn, "disabled", nil);
      simple_loops.remove;
    });

    postln("loop freed");
    MIDIdef.freeAll;
    postln("MIDIdefs freed");
    s.quit;
  };

  ~mSrc.writeArchive("./archive/mSrc".resolveRelative);

  ~scheduler.();

  start_btn
  .states_([["Press to Stop", Color.black, Color.green]])
  .mouseDownAction_({
    CmdPeriod.run;
    start_btn
    .states_([["BOOM!", Color.black, Color.red]])
    .mouseDownAction_({ run.() });
  });
};

main_window.onClose = {
  CmdPeriod.run;
  0.exit;
};

currentEnvironment.do {_.free};

main_window.front;
)
