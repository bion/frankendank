/*
  Each jam has keys for 
  loop -> boolean for whether or not it is a loopable jam
  measures -> Array of arrays, each nested array has
    [0] == number of eighth notes in measure
    [1] == array of PC objects representing the chord for that measure
    [2] == array of events, each event has its own properties as well as:
      \beat == the beat in the measure that event happens on
      \action_type == the action in ~clock_functions for receiving the event
*/

(
  var jams = IdentityDictionary[
    \blank_two_measures -> IdentityDictionary[
      \loop -> true,
      \measures -> [
        [8,
          [PC(\a, 4)]],
        [8,
          [PC(\a, 3), PC(\c, 4), PC(\e, 4), PC(\g, 3)]]
      ]
    ],

    \want_you_back -> IdentityDictionary[
      \loop -> true,
      \measures -> [
        [8,
          [PC(\c, 2), PC(\g, 2), PC(\bf, 2), PC(\ef, 3)]],
        [8,
          [PC(\a, 4)]],
        [8,
          [PC(\a, 4)]],
        [8,
          [PC(\a, 4)]],

        [8,
          [PC(\a, 4)]],
        [8,
          [PC(\a, 4)]],
        [8,
          [PC(\a, 4)]],
        [8,
          [PC(\a, 4)]],
      ]
    ],

		\tango ->  IdentityDictionary[
      \loop -> true,
      \measures -> [
        [8,
          [PC(\a, 4)],
          [(beat: 2, action_type: \playbuf, buf: \tango1)]],
        [8,
          [PC(\a, 4)]],
        [8,
          [PC(\a, 4)]],
        [8,
          [PC(\a, 4)]],
        [8,
          [PC(\a, 4)]],
        [8,
          [PC(\a, 4)]],
        [8,
          [PC(\a, 4)]],
        [8,
          [PC(\a, 4)]],
        [8,
          [PC(\a, 4)]],

        [8,
          [PC(\a, 4)]],
        [8,
          [PC(\a, 4)]],
        [8,
          [PC(\a, 4)]],
        [8,
          [PC(\a, 4)]],
        [8,
          [PC(\a, 4)]],
        [8,
          [PC(\a, 4)]],
        [8,
          [PC(\a, 4)]],
        [8,
          [PC(\a, 4)]]
      ]
		],

    \test_1 -> IdentityDictionary[
      \loop -> false,
      \measures -> [
        [8,
          [PC(\a, 4)]],
        [8,
          [PC(\a, 4)]],
        [8,
          [PC(\a, 4)],
          [(beat: 0, action_type: \playbuf, buf: \bob)]],
        [8,
          [PC(\a, 4)]], [8, [PC(\a, 4)]], [8, [PC(\a, 4)]]
      ]
    ],

    \test_2 -> IdentityDictionary[
      \loop -> true,
      \measures -> [
        [4,
          [PC(\a, 4)],
          [(beat: 0, action_type: \post, message: "test action")]],
        [4,
          [PC(\a, 4)]]
      ]
    ],

    \quit -> IdentityDictionary[
      \loop -> false,
      \measures -> [
        [4,
          [PC(\a, 4)],
          [(beat: 0, action_type: \quit)]
        ]
      ]
    ]
  ];

~setlist = [
  \blank_two_measures,

	\tango,

  \quit
].collect {|dict, i| jams[dict].dup[0].put(\index, i)};
"SETLIST LOADED".postln
)
