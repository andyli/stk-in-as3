# Available instruments #
The instrument classes are the subclasses of `Instrmnt`, as shown in the [documentation](http://ccrma.stanford.edu/software/stk/classstk_1_1Instrmnt.html). Currently a number of instruments is available to be used. They includes:
  * `BandedWG`
  * `BlowBotl`
  * `BlowHole`
  * `Bowed`
  * `Brass`
  * `Clarinet`
  * `Flute`
  * `Mesh2D`
  * `Plucked`
  * `PluckTwo` (abstract class)
  * `Resonate`
  * `Saxofony`
  * `Sitar`
  * `SitfKarp`
  * `Shakers`
  * `Whistle`

There are other classes that depend on loading sound files, more works are needed to be done in order to port them.<br />
[Some of the instruments are demoed here.](http://blog.onthewings.net/tag/stk-in-as3/)

# Generate `ByteArray` to be used as playback #
Basically you continuously call the `tick()` method which available from all the instrument classes. The method return a number which is the value of a sample of the wave generated. You then write that into the `ByteArray`.<br />
For example, if you want to create a `ByteArray` that holds 2 seconds of `Flute` playing at A4 (440Hz):
```
var soundBytes:ByteArray = new ByteArray();
var inst:Flute = new Flute(40); //give 40 as the lowest frequency it will sound
inst.noteOn(440,1); //frequency=440, amplitude=1
for (var i:Number = 0 ; i < 44100 * 2 ; ++i) { //Flash need 44100 samples per seconds
	var val:Number = inst.tick();
	//put the value to both left and right channels
	soundBytes.writeFloat(val);
	soundBytes.writeFloat(val);
}
//the 2 second flute sound is finished. If you want to smoothly turn off the note, see below.

inst.noteOff(0.3); //amplitude=0.3
for (i = 0 ; i < 44100 * 0.5 ; ++i) { //add 0.5 second to let the sound become completely silent
	val = inst.tick();
	soundBytes.writeFloat(val);
	soundBytes.writeFloat(val);
}
```