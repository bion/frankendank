(
postln("loading midi config for breath...");

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

postln("breath midi config loaded");
)
