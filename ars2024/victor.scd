"defining synth...".postln;

(
~synthdefs.add(SynthDef(\victor, {
	var amp, detect, gain, signal;
	var in = SoundIn.ar(~pickup_buses);
	var ctrl = AnalogIn.kr(~analog_buses);

	in = in * ctrl * 48;

	in = (in-0.5).softclip;
	in = HPF.ar(in, 50);

	// in = in[0..3] + in[4..7]; // more efficient

	// // adaptive gain
	amp = Amplitude.ar(in, 0.03, 0.03);
	detect = Integrator.kr(
		Clip.kr(A2K.kr(amp) - 0.05, -3e-3, 1e-4),
		coef:0.99999);
	gain = 2.pow(0-detect.max(-1));
	gain = K2A.ar(gain);

	// amp.poll(5,\amp);
	// detect.poll(10,\detector);
	// gain.poll(5,\gain);

	signal = in * gain;
	signal = Mix(
		FreqShift.ar(signal,
			[-5,-7,-9,-11,5,7,9,11]*Lag.ar(amp, 3)/36
		),
	);
	signal = LPZ1.ar(signal)/6 + HPZ1.ar(signal);
	signal = Notch.ar(signal, 160);
	// signal = Notch.ar(signal, 890);
	signal = MoogFF.ar(signal, 5000, 1.5);
	// signal = LPF.ar(signal, 10000);

	signal = signal.softclip;

	~output.(signal);


}).add.name);
)
