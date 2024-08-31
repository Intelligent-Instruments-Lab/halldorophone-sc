// basic mixer patch

"defining synth...".postln;

(
Routine {
	var synth;
	var name = SynthDef(\example, {
		var in = SoundIn.ar(~pickup_buses);
		var ctrl = AnalogIn.ar(~analog_buses);

		var signal = in * ctrl * 16;
		signal = Limiter.ar(Mix(signal));

		~output.(signal);
	}).add.name;
	1.wait;
	// s.sync;
	synth = Synth.newPaused(name.postln);
	(\run:{synth.run}, \pause:{synth.run(false)}).yield;
}//.forkIfNeeded;
)