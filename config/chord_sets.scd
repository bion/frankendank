~chordSets = IdentityDictionary[
  \peas_1 -> [
    (type: \literal, pitches: [PC(\fs, 3), PC(\b, 4), PC(\e, 4)]),
    (type: \literal, pitches: [PC(\fs, 3), PC(\c, 4), PC(\e, 4)]),
    (type: \literal, pitches: [PC(\fs, 4), PC(\b, 5), PC(\e, 5)]),
    (type: \literal, pitches: [PC(\fs, 4), PC(\c, 5), PC(\e, 5)]),
    (type: \literal, pitches: [PC(\fs, 4), PC(\d, 5), PC(\fs, 5)]),

    (type: \literal, pitches: [PC(\e, 4), PC(\a, 4), PC(\e, 5), PC(\g, 5)]),
    (type: \literal, pitches: [PC(\b, 4), PC(\e, 4), PC(\fs, 4), PC(\b, 5), PC(\e, 5), PC(\fs, 6)]),
    (type: \literal, pitches: [PC(\b, 4), PC(\e, 4), PC(\fs, 4), PC(\b, 5), PC(\e, 5)]),
    (type: \literal, pitches: [PC(\c, 4), PC(\e, 4), PC(\fs, 4), PC(\b, 5), PC(\e, 5), PC(\a, 6)]),
    (type: \literal, pitches: [PC(\g, 3), PC(\c, 4), PC(\fs, 4), PC(\b, 5), PC(\e, 5), PC(\a, 6)])
  ],
  \peas_2 -> [
    (type: \literal, pitches: [PC(\b, 4), PC(\d, 4), PC(\e, 4), PC(\a, 5), PC(\b, 5), PC(\d, 5), PC(\e, 5), PC(\a, 6), PC(\b, 6), PC(\d, 6)]),
    (type: \literal, pitches: [PC(\a, 4), PC(\d, 4), PC(\g, 4), PC(\a, 5), PC(\d, 5), PC(\g, 5)]),
    (type: \literal, pitches: [PC(\g, 3), PC(\c, 4), PC(\f, 4), PC(\g, 4), PC(\c, 5), PC(\f, 5)]),

    (type: \literal, pitches: [PC(\af, 4), PC(\d, 4), PC(\g, 4), PC(\af, 5), PC(\d, 5), PC(\g, 5)]),
    (type: \literal, pitches: [PC(\e, 4), PC(\a, 5), PC(\d, 5), PC(\e, 5), PC(\a, 6), PC(\d, 6)]),
    (type: \literal, pitches: [PC(\fs, 4), PC(\b, 5), PC(\e, 5), PC(\fs, 5), PC(\b, 6), PC(\e, 6)]),

    (type: \literal, pitches: [PC(\af, 4), PC(\d, 4), PC(\g, 4), PC(\af, 5), PC(\d, 5), PC(\g, 5), PC(\c, 6), PC(\f, 6)])
  ],
  \bion1 -> [
    (type: \reference, voicing: \Xm, pitchClass: PC(\bf, 3)),
    (type: \reference, voicing: \XM, pitchClass: PC(\af, 3)),
    (type: \reference, voicing: \XM, pitchClass: PC(\gf, 3)),
    (type: \reference, voicing: \XM, pitchClass: PC(\f, 3)),

    (type: \reference, voicing: \X7, pitchClass: PC(\ef, 4))
  ],
  \bion2 -> [
    (type: \reference, voicing: \Xm11, pitchClass: PC(\f, 4)),
    (type: \reference, voicing: \Xm7, pitchClass: PC(\c, 5)),
    (type: \reference, voicing: \X7, pitchClass: PC(\bf, 5)),
    (type: \reference, voicing: \XM, pitchClass: PC(\c, 4))
  ]
];
