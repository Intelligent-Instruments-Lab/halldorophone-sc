"defining synth...".postln;

(
Routine {
	var synth;
	var name = SynthDef(\thor, {
		var in = SoundIn.ar(~pickup_buses);
		var ctrl = AnalogIn.kr(~analog_buses);

		var signal = DC.ar(0);

		~output.(signal);

	}).add.name;
	// s.sync;
	1.wait;
	synth = Synth.newPaused(name.postln);
	(\run:{synth.run}, \pause:{synth.run(false)}).yield;
}//.forkIfNeeded;
)
