(
var numLoops = 4, loopMaxdur = 60,
record, addRecordSynth, stopRecording,
clearLoopFunc,
addLoopSynth, playLoop, stopLoop,
clearLoop = IdentityDictionary[\sax -> false, \tub -> false];

~clear_loop = {|id|
  postln("CLEAR LOOP " ++ id);
  if (clearLoop[id]) {clearLoop[id] = false} {clearLoop[id] = true};
};

~loop_touch = {|id|
  var offset = ~clock.beats - ~clock.beats.round * ~clock.beatDur;
  var loopInstance = ~loops[id[\instr]][id[\num]], doubleTap;
  doubleTap = (~clock.beats - loopInstance[\last_touch]) < 1.5;
  postln("LOOP TOUCH " ++ id);
  if (clearLoop[id[\instr]] || doubleTap) {
    clearLoopFunc.(loopInstance, id);
    ("LOOP " ++ id ++ " CLEARED").postln;
  } {
    loopInstance[\next_action].(id, offset);
  };
  loopInstance[\last_touch] = ~clock.beats;
};

clearLoopFunc = {|loopInstance, id|
  if (loopInstance[\synth].notNil) { stopLoop.(id) };
  loopInstance[\next_action] = record;
  loopInstance[\dur] = 0.0;
  clearLoop[id[\instr]] = false;
};

record = {|id, offset|
  if (offset < 0) {
    fork {
      offset.abs.wait;
      addRecordSynth.(id);
    }} {
      addRecordSynth.(id, offset);
    };
};

addRecordSynth = {|id, offset=0|
  var bus = ~buss[(id[\instr].asString ++ "_agg").asSymbol];
  var loopInstance = ~loops[id[\instr]][id[\num]];
  loopInstance[\dur] = ~clock.beats;
  s.makeBundle(0.025, {
    loopInstance[\recording] = Synth(\recordbuf_mono,
      [ \inbus,    bus,
        \startpos, offset * s.sampleRate,
        \buf,      loopInstance[\buffer] ],
      ~record_loop_g, \addToHead);
  });
  loopInstance[\next_action] = stopRecording;
  postln("STARTED " ++ id ++ " RECORDING, OFFSET: " ++ offset);
};

stopRecording = {|id, offset|
  var dur, recordSurplus = 0;
  var loopInstance = ~loops[id[\instr]][id[\num]];
  fork{
    if (offset < 0.0) {offset.abs.wait; offset=0.0};
    dur = ~clock.beats - loopInstance[\dur];
    loopInstance[\dur] = dur.round;
    playLoop.(id, offset);
    loopInstance[\recording].set(\gate, -1.01);
    loopInstance[\next_action] = stopLoop;
    postln("STOPPED " ++ id ++ " RECORDING, OFFSET: " ++ offset);
  };
};

playLoop = {|id, offset|
  if (offset < 0.0) {
    fork {
      offset.abs.wait;
      addLoopSynth.(id);
    }} {
      addLoopSynth.(id, offset);
    };
};

addLoopSynth = {|id, offset=0|
  var loopInstance = ~loops[id[\instr]][id[\num]];
  var bus = ~loop_filt_buss[id[\instr]][id[\num]];
  var synth;
  s.makeBundle(0.005, { synth = Synth(\playbuf_mono,
    [ \outbus,   bus,
      \amp,      1,
      \buf,      loopInstance[\buffer],
      \dur,      loopInstance[\dur] * ~clock.beatDur - offset - 0.005,
      \startpos, offset * s.sampleRate],
    ~play_loop_g, \addToTail).onFree({loopInstance[\synth] = nil});
  });
  loopInstance.putAll(IdentityDictionary[
    \synth -> synth,
    \responder -> OSCFunc(
      { playLoop.(id, ~clock.beats - ~clock.beats.round * ~clock.beatDur) },
      '/n_end', s.addr, nil, [synth.nodeID]
    ).oneShot,
  ]);
  loopInstance[\next_action] = stopLoop;
  postln("STARTED LOOPING " ++ id ++ " OFFSET: " ++ offset);
};

stopLoop = {|id, offset|
  var loopInstance = ~loops[id[\instr]][id[\num]];
  loopInstance[\responder].free;
  loopInstance[\synth].set(\gate, -1.03);
  loopInstance.put( \synth -> nil );
  loopInstance[\next_action] = playLoop;
  postln("KILLED LOOP " ++ id);
};

~reset_instr = {|instr|
  ~loops[instr].do {|dict, i|
    if (dict[\synth].notNil) {
      stopLoop.(IdentityDictionary[\instr -> instr, \num -> i]);
    };
    dict[\next_action] = record;
    dict[\dur] = 0.0;
    instr ++ " LOOP RESET";
  };
};

~loops = IdentityDictionary[
  \sax -> Array.newClear(numLoops),
  \tub -> Array.newClear(numLoops)
];

[[\sax, \tub], (0 .. (numLoops - 1)).stutter(2)].flop.do {|pair|
  ~loops[pair[0]][pair[1]] = IdentityDictionary[
    \buffer ->      Buffer.alloc(s, loopMaxdur * s.sampleRate, 1),
    \next_action -> record,
    \dur ->         0.0, // loop dur or record touch time
    \recording ->   false,
    \synth ->       nil,
    \responder ->   false,
    \last_touch ->  ~clock.beats
  ];
};
)
