(
{
    var in, ou, springs, sel;
    var freq=MouseX.kr(10,1000,'exponential');
    var numsprings= 60;
    var spring = {rrand(0.1,0.18)}!numsprings;
    var damp = MouseY.kr(0.01,0.5,'exponential');

    in = LPF.ar(LocalIn.ar(1), 10) * 0.95 + (LPF.ar(Trig.ar(Impulse.ar(2), 0.01)) * WhiteNoise.ar.range(0.98,1));
    ou = in;

    springs = spring.collect { arg spr, i;  ou = Spring.ar(ou, spr, damp); };
    LocalOut.ar(ou);

    sel = SinOsc.ar(freq+(in*100)).range(0, spring.size-1);
    ou = SelectX.ar(sel, springs);

    Pan2.ar(ou);
}.play;
)

(
SynthDef(\scansynth1, { arg out=0, amp=0.1, gate=1, pan=0, freq=200;
    var in, ou;
    var numSprings = 20;
    var spring = numSprings.collect({ Rand(0.04, 0.045) });
    var damp = numSprings.collect({ Rand(0.01, 0.002) });
    var springs;
    var sel;
    in = LocalIn.ar(1) * 0.99 + LPF.ar(Decay.ar(Impulse.ar(2), 0.01), 10);
    ou = in;
    springs = spring.collect { arg spr, i;
        ou = Spring.ar(ou, spr, damp[i]);
    };

    sel = VarSaw.ar(100).range(0, spring.size-1);

    ou = SelectX.ar(sel, springs);
    ou = MoogFF.ar(ou, 2000);
    Out.ar(out, ou ! 2);
}).add;
);
s.makeGui
Synth(\scansynth1, [\amp, 0.4])

/*
    todo with jon

    turn up tub_s2 by 16-18 dB

    tub_s1 -- cutoff resonence too loud relative to fundamental

*/