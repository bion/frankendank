(
var	startup_gui, startup_info, start_but, sg_but,
	tempo_box, tempo_slider, tempo_spec, tempo_coord;

~maindir = "~/Documents/EDE/code/frankendank/".standardizePath;
~tempo = 220/60;
sg_but = IdentityDictionary[];

MIDIClient.init;
MIDIIn.connectAll;
~mSrc = IdentityDictionary[];

startup_gui = Window("EDE Startup", Rect(200, 200, 400, 250));

[\sax, \tuba, \drums, \com].do {arg name, i;
	var responder;
	sg_but.put(name,
		Button(startup_gui, Rect(10, 10+(i*40), 80, 30))
			.states_([[name ++ " off"], [name ++ " on"]])
			.mouseDownAction_({
				var status = StaticText(startup_gui, Rect(90, 10+(i*40), 80, 30));
				if(responder.isNil, {
					status.stringColor_(Color.red).string_("Awaiting input");
					responder = MIDIFunc.program({
						arg num, chan, source;
						~mSrc[name] = source;
						status.stringColor_(Color.green).string_("Device found");
						responder.free;
					});
				}, {
					responder.free;
					status.stringColor_(Color.black).string_("MIDI device not initiated");
				});
			})
	);
	start_but = i*40+50;
};

tempo_coord = [200, 120];
tempo_box = NumberBox(startup_gui, Rect(tempo_coord[0] + 50, tempo_coord[1] + 25, 50, 30));
StaticText(startup_gui, Rect(tempo_coord[0], tempo_coord[1] + 30, 50, 20))
	.align_(\center).string_("tempo:");
tempo_spec = ControlSpec(50, 220, \linear, 1);
tempo_slider = Slider(startup_gui, Rect(tempo_coord[0], tempo_coord[1] + 60, 160, 40))
								.value_(~tempo)
								.action_({
									var val = tempo_spec.map(tempo_slider.value);
									tempo_box.value_(val);
									~tempo = val/60;
								});
tempo_box.value_(tempo_spec.map(tempo_slider.value));

start_but = Button(startup_gui, Rect(50, start_but, 80, 30) )
	.states_([["BOOM!", Color.black, Color.red]])
	.mouseDownAction_({
	~tempo = tempo_spec.map(tempo_slider.value)/60;
	
	MIDIClient.sources.do {arg source;
		case
		{source.device == "Breath Controller"}	{~mSrc[\breath] = source.uid}
		{source.device == "ControlPad"}					{ ~mSrc[\drum_pad] = ~mSrc[\drum_pad] ? source.uid};
	};

	s.latency = 0.075;
  s.waitForBoot({
    ~cond = Condition.new;

		~clock = TempoClock(~tempo);

		load(~maindir ++ "core.scd");

		load(~maindir ++ "SD.scd");
		load(~maindir ++ "looping.scd");
		load(~maindir ++ "instr/" ++ "com_sample_map.scd");
		load(~maindir ++ "jams.scd");
		load(~maindir ++ "task_master.scd");

		// load instrument-specific config files
		sg_but.keysValuesDo {arg key, value;
			if(value.value == 1, {(~maindir++"instr/"++key++".scd").load});
		};

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

		startup_gui.close;
		~scheduler.();
	});
});

startup_gui.front;
)
