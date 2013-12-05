(
var activated_instruments = [], instr_buttons = IdentityDictionary[],
  instruments = [ \sax, \tuba, \drums, \com ],

  gui_height = 450, gui_length = 250,
  startup_gui = Window("her we go", Rect(250, 250, gui_length, gui_height)),

  btn_length = 80, btn_height = 30,

  load_btn,

  instr_btn_left = 10, instr_btn_top = 10,

  tempo_slider, tempo_box,

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

MIDIClient.sources.do {|sources|
  case
  {source.device == "Breath Controller"}  {~mSrc[\breath] = source.uid}
  {source.device == "ControlPad"}         { ~mSrc[\drum_pad] = source.uid};
};

// * * * * * * * * * * * * * * * * * * * * * * UI

[ \sax, \tuba, \com ].do {|instr|
  StaticText(startup_gui, Rect(instr_btn_left, instr_btn_top - 10, btn_length, 10))
  .string_(instr.asString);

  instr_buttons[instr] = Button(startup_gui, Rect(instr_btn_left,
                                                  instr_btn_top+(i*(instr_btn_height + 20)),
                                                  btn_length,
                                                  btn_height)
  )
  .states_([["off"]])
  .mouseDownAction_({
    if (instr_buttons[instr][0][0] == "on")
    {
      activated_instruments.remove(instr);
      midi_listener.free;
      AppClock.sched(0, {
        update_button.(instr_buttons[instr], "off");
      });
    }
    {
      make_midi_listener.(instr);
      AppClock.sched(0, {
        update_button.(instr_buttons[instr], "active");
      });
    };
  });
};

load_btn = Button(startup_gui, Rect(instr_btn_left, gui_height - 10, btn_height, btn_length) )
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
                             tempo_box_top,
                             tempo_box_length,
                             tempo_box_height)).align_(\center).string_("tempo");

tempo_spec = ControlSpec(50, 220, \linear, 1);
tempo_slider = Slider(startup_gui, Rect(tempo_box_left, tempo_box_top+ 35, 220, 40))
                .value_(~tempo) .action_({
                  var val = tempo_spec.map(tempo_slider.value);
                  tempo_box.value_(val);
                  ~tempo = val/60;
                });
tempo_box.value_(tempo_spec.map(tempo_slider.value));

Button(startup_gui, Rect(gui_height - 40, gui_length -100, btn_height, btn_length * 1.5) )
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
    "task_master.scd"
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
