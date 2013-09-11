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
					[PC(\a, 4)]], [8, [PC(\a, 4)]]
			];
		],

		\test_1 -> IdentityDictionary[
			\loop -> false,
			\measures -> [
				[8,
					[PC(\a, 4)]], [8, [PC(\a, 4)]], [8, [PC(\a, 4)],
					[(beat: 0, action_type: \playbuf, buf: \bob)]],
				[8,
					[PC(\a, 4)]], [8, [PC(\a, 4)]], [8, [PC(\a, 4)]]
			];
		],

		\test_2 -> IdentityDictionary[
			\loop -> true,
			\measures -> [
				[4,
					[PC(\a, 4)], [(beat: 0, action_type: \post, message: "test action")]],
				[4,
					[PC(\a, 4)]]
			];
		]
	];

~setlist = [
	\blank_two_measures,
	\test_1,
	\test_2,
	\test_1
].collect {|dict, i| jams[dict].dup[0].put(\index, i)};
"SETLIST LOADED".postln
)
