// this file is a template for adding new patches
"defining synth...".postln;

(
~synthdefs.add(SynthDef(\example, {
	var in = SoundIn.ar(~pickup_buses);
	var ctrl = AnalogIn.ar(~analog_buses);

	// implement your synth logic here
	var signal = 0;
	//

	~output.(signal);
}).add.name);
)