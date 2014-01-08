## Sampling

non-drum samples should be placed in the ```samples/com``` directory and have unique names

### Monitor channel mappings:

* sax: 3
* tub: 4
* drums: 5
* com: 7

### Marshall this is for you

Add new drum samples by putting them in the ```samples/drums/``` and then ```low```, ```med```, or ```hi``` depending on if it's a boom boom, kack kack, or click click. Make sure the samples are in .aiff format and have UNIQUE names. The names can contain letters, numbers, and underscores. No spaces.

To assign these to specific sample sets, open ```instr/drums.scd``` and add more of these:

```supercollider
        IdentityDictionary[
            \drum_0 -> \kick_synth_1,
            \drum_1 -> \kick_synth_2,
            \drum_2 -> \snare_1,
            \drum_3 -> \snare_2,
            \drum_4 -> \clap_1,
            \drum_5 -> \pop_1,
            \drum_6 -> \snick_1,
            \drum_7 -> \snick_2
        ],
```

To this:

```supercollider
    ~sample_sets = [
        IdentityDictionary[ // 0
            \drum_0 -> \kick_synth_1,
            \drum_1 -> \kick_synth_2,
            \drum_2 -> \snare_1,
            \drum_3 -> \snare_2,
            \drum_4 -> \clap_1,
            \drum_5 -> \pop_1,
            \drum_6 -> \snick_1,
            \drum_7 -> \snick_2
        ],
        IdentityDictionary[ // 1
            \drum_0 -> \kick_synth_1,
            \drum_1 -> \kick_synth_2,
            \drum_2 -> \snare_1,
            \drum_3 -> \snare_2,
            \drum_4 -> \clap_1,
            \drum_5 -> \pop_1,
            \drum_6 -> \snick_1,
            \drum_7 -> \snick_2
        ]
    ];
```

They are indexed sequentially. So the first one will be sample set 0, the next one is sample set 1, and so on. Put a ```\``` before the ***exact*** name you used for the samples when you added them to the folders (sans the ```.aiff``` part.

Make sure to save the file before running the system again.
