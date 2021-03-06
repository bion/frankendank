/*
  sax preamp gain: 3

  FCB1010 notes:
  buttons are type: program, src: big int, chan: 0, num: button#
  pedals are type: control, src: same big int, chan: 0, ccNum: (a: 27, b: 7), val: 0-127
  MIDIFunc.cc args: [val, ccNum, chan, srcID

  USB2.0-MIDI notes:
  buttons are type program, for button labeled '1':
  MIDIdef.program(\whodunnit, {|...args| args.postln; "this one".postln;}, 0, -1815496440, {|val| val==0});

  nano pad nums:
  39, 48, 45, 43, 51, 49

  36, 38, 40, 42, 44, 46

*/
var keyFileMap;

"Loading MIDI config...".postln;

keyFileMap = (
  sax: "sax",
  bcr: "bcr",
  drums_switch: "drums_shared",
  drum_pad: "mars_drums",
  andrew: "andrew_drums",
  breath: "breath",
  samples: "com_samples",
  chords: "com_chords"
);

keyFileMap.keysValuesDo { |sourceId, fileName|
  if (~mSrc[sourceId].notNil) {
    loadRelative("./midi_mapping/" ++ fileName ++ ".scd");
  };
};

"Done loading midi config".postln;
