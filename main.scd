(
var	startup_gui, startup_info, start_but, sg_but,
	tempo_box, tempo_slider, tempo_spec, tempo_coord, midi_stati;

~maindir = "~/dev/frankendank/".standardizePath;
~tempo = 220/60;
sg_but = IdentityDictionary[];

MIDIClient.init;
MIDIIn.connectAll;
~mSrc = IdentityDictionary[];

startup_gui = Window("EDE Startup", Rect(200, 200, 400, 250));

midi_stati = IdentityDictionary[];
[\sax, \tuba, \drums, \com].do {arg name, i;
	midi_stati[name] = IdentityDictionary[];

	sg_but.put(name,
		Button(startup_gui, Rect(10, 10+(i*40), 80, 30))
			.states_([[name ++ " off"], [name ++ " on"]])
			.mouseDownAction_({
				if(midi_stati[name][\status].notNil, {midi_stati[name][\status].remove});
				midi_stati[name][\status] = StaticText(startup_gui, Rect(100, 10+(i*40), 80, 30));
				if(midi_stati[name][\responder].isNil && ~mSrc[name].isNil, {
					var responder_type; 
					if(name != \com, {responder_type = \program}, {responder_type = \noteOn});
					midi_stati[name][\status].stringColor_(Color.red).string_("Awaiting input");
					midi_stati[name][\responder] = MIDIFunc(
						func: {
						arg num, chan, source;
						~mSrc[name] = source;
						AppClock.sched(0, {
							midi_stati[name][\status].stringColor_(Color.green).string_("Device found");
						});
						midi_stati[name][\responder].free;
						},
						msgType: responder_type
					);
				}, {
					midi_stati[name][\responder].free;
					midi_stati[name][\status] = nil;
					midi_stati[name][\responder] = nil;
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

	Server.default = s = Server.local;
	s.latency = 0.02;
	s.options = ServerOptions.new.hardwareBufferSize = 256;
  s.waitForBoot({
    ~cond = Condition.new;

		~clock = TempoClock(~tempo);

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

		sg_but.keysValuesDo {arg key, value;
			if(value.value == 1, {(~maindir++"instr/"++key++".scd").load});
		};

		s.sync(~cond);

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
