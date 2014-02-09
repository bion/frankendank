loadRelative("../config/config.scd");
loadRelative("../SD.scd");
s.waitForBoot({
  g = Group(s);
  c = IdentityDictionary[
    \one -> [100, 200, 300, 400],
    \two -> [400, 600, 700, 800],
    \three -> [400, 600, 700, 2],
    \four -> [400, 600, 2, 2],
    \five -> [200, 2, 2, 2],
    \six -> [2, 2, 2, 2]
  ];

  ~subject = HerChordsController(
    g, 0, c, \one, \com_dirt_rhode
  );
});

~subject.setAmp(0.1);
~subject.changeChord(\two);
