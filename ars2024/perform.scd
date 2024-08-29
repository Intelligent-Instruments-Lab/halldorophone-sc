// basic mixer patch

"defining synth...".postln;

(
~synthdefs.add(SynthDef(\example, {
	var in = SoundIn.ar(~pickup_buses);
	var ctrl = AnalogIn.ar(~analog_buses);

	var signal = in * ctrl * 16;
	signal = Limiter.ar(Mix(signal));

	~output.(signal);
}).add.name);
)