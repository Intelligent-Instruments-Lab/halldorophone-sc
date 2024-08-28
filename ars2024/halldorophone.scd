"sc-halldorophone init...".postln;

(
// add your presets here
// there can be up to 3, to be selected by the three buttons
~presets = ["victor.scd", "thor.scd", "perform.scd"];

///Users/victor/Library/CloudStorage/OneDrive-Menntaský/lab-notebook/halldorophone/sc-template/victor.scd

// hardware config
// pickups in (numbered for SoundIn)
~pickup_buses = [2,3,4,5,6,7,0,1];
// faders
~analog_buses = (0..7);
// output to transducer
~output_bus = 0;
// digital ins from buttons
~button_pins = [1,2,3];// (with multichannel expander); 18,19,20 in Pd
// function for audio output from synths
~output = {arg signal;
	Out.ar(~output_bus, signal!4)
};
);

(
~synths!?(_.do{ arg y; y.free});
~button_synths!?(_.do{ arg y; y.free});
{
	// haptic feedback synth for button
	SynthDef(\click, {arg num_clicks;
		var signal = Blip.ar(8, 200)/8;
		var env = EnvGen.kr(
			Env.perc(0, (num_clicks-0.5)/8, curve:\hold),
			doneAction: Done.freeSelf,
			gate: Impulse.kr(0));
		~output.(signal)
	}).add;

	// convert button voltage to OSC
	~button_synths = ~button_pins.collect{ |b|
		SynthDef((\button++b).postln, {
			var button = DigitalIn.kr(b);
			var trig = Trig1.kr(button, 0.2);
			SendReply.kr(trig, '/button', [b]);
		}).play;
	};

	// handle OSC from button
	n = 0;
	OSCdef(\button_def, { |msg|
		msg.postln;
		n = ~button_pins.indexOfEqual(msg[3]) + 1;
		// (msg[3]==~button_pins[0]).if{
		// n = n%~synths.size + 1;
		"running synth %".format(n).postln;
		Synth(\click, [\num_clicks, n]);
		~synths.do{arg s; s!?(_.run(false))};
		~synths[n-1]!?(_.run);
	// }
	}, "/button");

	// define synths from preset files
	~synthdefs = List[];
	~presets.do{ |p| this.executeFile(p)};

	s.sync;

	// make one of each synth
	~synths = ~synthdefs.collect{ |name| Synth.newPaused(name.postln) };

	s.sync;

	// run the first synth
	~synths[0].run(true);

}.forkIfNeeded;)