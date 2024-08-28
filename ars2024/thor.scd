"defining synth...".postln;

(
~synthdefs.add(SynthDef(\thor, //name your patch here
	{
	var in = SoundIn.ar(~pickup_buses);
	var ctrl = AnalogIn.ar(~analog_buses);

	// implement your synth logic here
	var signal = 0;
	//

	~output.(signal);
}).add.name);
)