(
"loading midi config for breath...".post;

if (~mSrc[\breath].notNil) {
  MIDIdef.cc(\breathController,
    { |val|
      ~harmonyController.setAmp(val);
    },
    2,
    0,
    ~mSrc[\breath]
  );
};

"done".postln;
)
