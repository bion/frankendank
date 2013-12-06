(
var run, after_boot,
  activated_instruments = [], instr_buttons = IdentityDictionary[],
  instruments = [ \sax, \tuba, \drums, \com ],

  gui_height = 350, gui_length = 600,
  startup_gui = Window("her we go", Rect(250, 250, gui_length, gui_height)),

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
        activated_instruments.add(instr);
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
  };

// * * * * * * * * * * * * * * * * * * * * * * GLOBALS

~maindir = "~/dev/frankendank/".standardizePath;
~tempo = 220/60;
~freq_lag_dur = 0.01;

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
  StaticText(startup_gui, Rect(instr_btn_left, instr_btn_top + 20 + (i*(btn_height + 40)), btn_length, 10))
  .string_(instr.asString);

  instr_buttons[instr] = Button(startup_gui, Rect(instr_btn_left,
                                                  instr_btn_top + 40 + (i*(btn_height + 40)),
                                                  btn_length,
                                                  btn_height)
  )
  .states_([["off"]])
  .mouseDownAction_({
    if (instr_buttons[instr].states[0][0] == "active") // shitty
    {
      activated_instruments.remove(instr);
      ("deactiving " ++ instr ++ "...").postln;
      midi_listener.free;
      ("removed listener for " ++ midi_listener.key).postln;
      if (MIDIdef.all != []) { Error("untracked MIDIdef!!!").throw }; 
      AppClock.sched(0, {
        update_button.(instr_buttons[instr], "off");
      });
    }
    {
      make_midi_listener.(instr);
      ("added listener for " ++ midi_listener.key).postln;
      AppClock.sched(0, {
        update_button.(instr_buttons[instr], "active");
      });
    };
  });
};

load_btn = Button(startup_gui, Rect(instr_btn_left, gui_height - 100, btn_length * 1.5, btn_height * 1.5) )
  .states_( [ ["Load From Disk", Color.black], ["No Archive", Color.red] ] )
  .mouseDownAction_({
    ~mSrc = Object.readArchive(~maindir ++ "/archive/mSrc");
    ~mSrc.keysValuesDo {|instr, midi_id|
      postln(instr ++ ": " ++ midi_id);
      activated_instruments.remove(instr);
      update_button(instr_buttons[instr], "active", Color.green);
      load_btn.destroy;
    };
  });

tempo_box = NumberBox(startup_gui, Rect(tempo_box_left,
                                        tempo_box_top,
                                        tempo_box_length,
                                        tempo_box_height));

StaticText(startup_gui, Rect(tempo_box_left,
                             tempo_box_top - 50,
                             tempo_box_length,
                             tempo_box_height)).align_(\center).string_("tempo");

tempo_spec = ControlSpec(60, 220, \lin, 1);
tempo_slider = Slider(startup_gui, Rect(tempo_box_left, tempo_box_top + tempo_box_height + 20, 220, 40))
                .value_(~tempo) .action_({
                  var val = tempo_spec.map(tempo_slider.value);
                  tempo_box.value_(val);
                  ~tempo = val/60;
                });
tempo_box.value_(tempo_spec.map(tempo_slider.value));

Button(startup_gui, Rect(gui_length * 0.5, gui_height - 100, btn_length * 1.5, btn_height * 1.5) )
  .states_([["BOOM!", Color.black, Color.red]])
  .mouseDownAction_({ run.() });

// * * * * * * * * * * * * * * * * * * * * * * RUN

run = {
  Server.default = s = Server.local;
  s.latency = 0.02;
  s.options = ServerOptions.new.hardwareBufferSize = 128;

  s.waitForBoot({ after_boot.() });
};

after_boot = {
  var cond = Condition.new;

  ~clock = TempoClock(~tempo, queueSize: 2**10);

  [
    "SD.scd",
    "core.scd",
    "looping.scd",
    "instr/com_sample_map.scd",
    "jams.scd",
    "task_master.scd",
    "isntr/com.scd"
  ].do {|file|
    (~maindir ++ file).load;
    s.sync;
  };

  [\sax, \tuba, \drums].do {|instr|
    if (~mSrc.includesKey(instr)) {
      var path = (~maindir++"instr/"++instr++".scd");
      path.postln;
      path.load;
    };
  };

  s.sync(cond);

  s.queryAllNodes;

  CmdPeriod.doOnce {
    s.freeAll;
    ~clock.clear.stop;
    ~buss.keysValuesDo {|key, value| value.free };
    "busses freed".postln;
    OSCFunc.allEnabled.do {|func| func.free};
    "OSCFuncs freed".postln;
    ~loops.keysValuesDo {|key, value| value.keysValuesDo {|kk, vv| vv[\buffer].free }; };
    "loop freed".postln;
    MIDIdef.freeAll;
    "MIDIdefs freed".postln;
    s.quit;
  };

  ~mSrc.writeArchive(~maindir ++ "/archive/mSrc");

  ~scheduler.();
  startup_gui.close;
};

startup_gui.front;
)
