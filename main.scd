(
var	startup_gui, startup_info, start_but, sg_but;

~maindir = "~/Documents/sound projects/Current/EB/main/".standardizePath;
sg_but = IdentityDictionary[];

MIDIClient.init;
MIDIIn.connectAll;
~mSrc = IdentityDictionary[];

startup_gui = Window("EDE Startup", Rect(200, 200, 400, 250));

[\sax, \tuba, \drums, \comp].do {arg name, i;
	sg_but.put(name, Button(startup_gui, Rect(10, 10+(i*40), 80, 30))
		.states_([[name ++ " off"], [name ++ " on"]]) );
	start_but = i*40+50;
};

start_but = Button(startup_gui, Rect(50, start_but, 80, 30) )
.states_([["BOOM!", Color.black, Color.red]])
.mouseDownAction_({
	MIDIClient.sources.do {arg source;
		case
		{source.device == "FCB1010"} {~mSrc[\fcb] = source.uid}
		{source.device == "USB2.0-MIDI"} {~mSrc[\fcb] = source.uid}
		{source.device == "drumz"} {~mSrc[\drums] = source.uid};
	};

  s.waitForBoot({
    ~cond = Condition.new;

		~clock = TempoClock(70/60);

		load(~maindir ++ "SD.scd");
		load(~maindir ++ "looping.scd");
		load(~maindir ++ "instr/" ++ "com_sample_map.scd");
		load(~maindir ++ "jams.scd");
		load(~maindir ++ "task_master.scd");
		load(~maindir ++ "core.scd");

		// load instrument-specific config files
		sg_but.keysValuesDo {arg key, value;
			if(value.value == 1, {(~maindir++"instr/"++key++".scd").load});
		};

		CmdPeriod.doOnce {
			s.freeAll;
			~buss.keysValuesDo {|key, value| value.free };
			"busses freed".postln;
			OSCFunc.allEnabled.do {|func| func.free};
			"OSCFuncs freed".postln;
			~loops.keysValuesDo {|key, value| value.keysValuesDo {|kk, vv| vv[\buffer].free }; };
			"loop freed".postln;
			MIDIdef.freeAll;
			"MIDIdefs freed".postln;
		};

		startup_gui.close;
	});
});
Environment
startup_gui.front;
)
