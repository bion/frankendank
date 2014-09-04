a = IdentityDictionary[];
b = IdentityDictionary[];
b.put(321.asSymbol, rrand(0, 1.0));
1000.do {|num|
  a.put(num.asSymbol, rrand(0, 1.0))
};
Qitch
\tuba_1.asString[0]
bench{ a[234] }
bench{ b[321] }


  a.()
"one two".subStr[0 .. 2]
~mSrc
a = [1, 2, 3];
#b, c  = a;
a
a = Buffer.read(s, "/Users/bionjohnson/Documents/sound projects/Current/EB/scott testing.aiff");

~h_filt.(\sax_f1)

~pSynths[\sax_p].set(\param, 100)
~pSynths[\sax_p].get(\param, {|val| val.postln});

a = Window("sax test", Rect(200, 200, 200, 200));
c = Button(a, 20, 20, 30, 80)
.states_([["quit", Color.black, Color.red]])
.mouseDownAction({
  MIDIdef.freeAll;
});
