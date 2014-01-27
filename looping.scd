(
var num_loops = 8, loop_maxdur = 20,
record, add_record_synth, stop_recording,
clear_loop_func,
add_loop_synth, play_loop, stop_loop,
clear_loop = IdentityDictionary[\sax -> false, \tub -> false];

~clear_loop = {|id|
  postln("CLEAR LOOP " ++ id);
  if (clear_loop[id]) {clear_loop[id] = false} {clear_loop[id] = true};
};

~loop_touch = {|id|
  var offset = ~clock.beats - ~clock.beats.round * ~clock.beatDur;
  var loop_instance = ~loops[id[\instr]][id[\num]], double_tap;
  double_tap = (~clock.beats - loop_instance[\last_touch]) < 1.5;
  postln("LOOP TOUCH " ++ id);
  if (clear_loop[id[\instr]] || double_tap) {
    clear_loop_func.(loop_instance, id);
    ("LOOP " ++ id ++ " CLEARED").postln;
  } {
    loop_instance[\next_action].(id, offset);
  };
  loop_instance[\last_touch] = ~clock.beats;
};

clear_loop_func = {|loop_instance, id|
  if (loop_instance[\synth].notNil) { stop_loop.(id) };
  loop_instance[\next_action] = record;
  loop_instance[\dur] = 0.0;
  clear_loop[id[\instr]] = false;
};

record = {|id, offset|
  if (offset < 0) {
    fork {
      offset.abs.wait;
      add_record_synth.(id);
    }} {
      add_record_synth.(id, offset);
    };
};

add_record_synth = {|id, offset=0|
  var bus = ~buss[(id[\instr].asString ++ "_agg").asSymbol];
  var loop_instance = ~loops[id[\instr]][id[\num]];
  loop_instance[\dur] = ~clock.beats;
  s.makeBundle(0.025, {
    loop_instance[\recording] = Synth(\recordbuf_mono,
      [ \inbus, bus, \startpos, offset * s.sampleRate,
        \buf, loop_instance[\buffer] ],
      ~record_g);
  });
  loop_instance[\next_action] = stop_recording;
  postln("STARTED " ++ id ++ " RECORDING, OFFSET: " ++ offset);
};

stop_recording = {|id, offset|
  var dur, record_surplus = 0;
  var loop_instance = ~loops[id[\instr]][id[\num]];
  fork{
    if (offset < 0.0) {offset.abs.wait; offset=0.0};
    dur = ~clock.beats - loop_instance[\dur];
    loop_instance[\dur] = dur.round;
    play_loop.(id, offset);
    loop_instance[\recording].set(\gate, -1.01);
    loop_instance[\next_action] = stop_loop;
    postln("STOPPED " ++ id ++ " RECORDING, OFFSET: " ++ offset);
  };
};

play_loop = {|id, offset|
  if (offset < 0.0) {
    fork {
      offset.abs.wait;
      add_loop_synth.(id);
    }} {
      add_loop_synth.(id, offset);
    };
};

add_loop_synth = {|id, offset=0|
  var loop_instance = ~loops[id[\instr]][id[\num]];
  var bus = ~buss[(id[\instr].asString ++ "_agg").asSymbol];
  var synth;
  s.makeBundle(0.005, { synth = Synth(\playbuf_mono,
    [ \outbus, bus,
      \amp, 1,
      \buf, loop_instance[\buffer],
      \dur, loop_instance[\dur] * ~clock.beatDur - offset - 0.05,
      \startpos, offset * s.sampleRate],
    ~playbuf_g).onFree({loop_instance[\synth] = nil});
  });
  loop_instance.putAll(IdentityDictionary[
    \synth -> synth,
    \responder -> OSCFunc(
      { play_loop.(id, ~clock.beats - ~clock.beats.round * ~clock.beatDur) },
      '/n_end', s.addr, nil, [synth.nodeID]
    ).oneShot,
  ]);
  loop_instance[\next_action] = stop_loop;
  postln("STARTED LOOPING " ++ id ++ " OFFSET: " ++ offset);
};

stop_loop = {|id, offset|
  var loop_instance = ~loops[id[\instr]][id[\num]];
  loop_instance[\responder].free;
  loop_instance[\synth].set(\gate, -1.03);
  loop_instance.put( \synth -> nil );
  loop_instance[\next_action] = play_loop;
  postln("KILLED LOOP " ++ id);
};

~reset_instr = {|instr|
  ~loops[instr].do {|dict, i|
    if (dict[\synth].notNil) {
      stop_loop.(IdentityDictionary[\instr -> instr, \num -> i]);
    };
    dict[\next_action] = record;
    dict[\dur] = 0.0;
    instr ++ " LOOP RESET";
  };
};

~loops = IdentityDictionary[
  \sax -> Array.newClear(num_loops),
  \tub -> Array.newClear(num_loops)
];

[[\sax, \tub], (0 .. (num_loops - 1)).stutter(3)].flop.do {|pair|
  ~loops[pair[0]][pair[1]] = IdentityDictionary[
    \buffer -> Buffer.alloc(s, loop_maxdur * s.sampleRate, 1),
    \next_action -> record,
    \dur -> 0.0, // loop dur or record touch time
    \recording -> false,
    \synth -> nil,
    \responder -> false,
    \last_touch -> ~clock.beats
  ];
};
)
