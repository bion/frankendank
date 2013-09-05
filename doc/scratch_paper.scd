~clear_loop.(\sax)
~loops
~path = "/Users/bionjohnson/Documents/sound projects/Current/EB/Main/";
(~path ++ "main.scd").load;

~loop_touch.(IdentityDictionary[\inst -> \sax, \num -> 0]);
~loops[\sax][0]

(
AbstractResponderFunc.allEnabled.keysValuesDo {|key, value|
	postln("key: " ++ key);
	postln("value: " ++ value);
}
)

~loops[\sax][0]
~h_filt.(\sax_f1)
~h_synth.(\sax_s1)

~maindir = "/Users/bionjohnson/Documents/sound projects/Current/EB/Main";

MIDIClient.sources;
MIDIClient.init;
MIDIIn.connectAll;
s.boot
~buf = Buffer.read(s, "/Users/bionjohnson/Documents/sound projects/Current/EB/Main/samples/drum/hi.snick_1.aiff")
(
SynthDef(\buf1, {|bufnum|
	Out.ar([0, 1], PlayBuf.ar(1, bufnum, BufRateScale.ir(bufnum), doneAction: 2));
}).add;
)
Platform.userConfigDir

MIDIClient.init;
MIDIIn.connectAll;
MIDIClient.sources;
~uid = MIDIClient.sources[0].uid;
MIDIdef.program(\whodunnit, {arg ...args; args.postln; "this one".postln;}, 0, -1815496440, {arg val; val==0});
MIDIdef.program(\whodunnsit, {arg ...args; "that one".postln;}, 0, -1815496440, {arg val; val.postln; true});
MIDIdef.all;
MIDIdef.freeAll;

(
a = NoteOnResponder({|src, chan, note, vel|
	Synth(\buf1, [\bufnum, ~buf]);
	"working!".postln;
}, nil, nil, nil, nil)
)
