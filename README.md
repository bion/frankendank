# her

this kid sucks at tetris

![sucks at tetris](http://distilleryimage7.ak.instagram.com/4bcc7fc2381f11e3844022000a1f9adf_8.jpg)

### I(gain)/O channel mappings:

* sax: 1, 2 (3.5) / 0
* tuba: 0 / 0
* drums: n/a / 0
* com: n/a / 0
* met: n/a / 1

### Monitor channel mappings:

* sax: 3
* tub: 4
* drums: 5
* com: 7

### Saffire settings

* Sample Rate set to 44.1 kHz
* Settings -> Firewire Driver Latency -> Short
* Routing Prest -> DAW tracking

## Practice

For practicing on your own.

### Setup

1. Download and install [Supercollider](http://supercollider.github.io/). [Direct download link for OSX](http://sourceforge.net/projects/supercollider/files/Mac%20OS%20X/3.6/SuperCollider-3.6.5-OSX-universal.dmg/download). 

2. Download and install [Git](http://git-scm.com/).

3. Open a Terminal and navigate to the folder where you want to keep the code for this project, then clone this repository with git. For example, to store it in a directory in ```YourUserName/Documents/EDE/code/``` (capitilization matters!):
```bash
mkdir -p ~/Documents/EDE/code
cd ~/Documents/EDE/code
git clone https://github.com/bion/frankendank.git
enter your username and password
```

### Running this fucker

1. Go to the directory you cloned everything into in setup (with finder, not the terminal).

2. Open ```main.scd``` with Supercollider

3. Highlight all the text, probably with ```cmd a``` and then press ```shift enter``` to run it.

4. A bunch of stuff will load, then a window should pop up. Select your instrument, a tempo, press 'Boom!' and go to town.

5. Stop everything with ```cmd .```

6. If something breaks copy everything from the Post window and send it to me in an email, please.

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
