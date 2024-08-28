"defining synth...".postln;

(
~synthdefs.add(SynthDef(\victor, {
	var amp, detect, gain, signal;
	var in = SoundIn.ar(~pickup_buses);
	var ctrl = AnalogIn.ar(~analog_buses);

	in = in * ctrl * 24;
	//
	// // adaptive gain
	// in = in*0.1 + HPZ1.ar(in);
	in = HPF.ar(in, 200);
	// in = BHiPass4.ar(in, 100);
	// in = BLowShelf.ar(in, 600, db:-6);
	amp = Amplitude.ar(in, 0.03, 0.03);
	detect = Integrator.kr(
		(A2K.kr(amp) - 0.05).min(3e-4).max(-1e-5),
		coef:0.99999);
	gain = 2.pow(0-detect.max(-1));
	gain = K2A.ar(gain);

	// amp.poll(10,\amp);
	// detect.poll(10,\detector);
	// gain.poll(5,\gain);

	signal = in * gain;
	signal = LPF.ar(HPF.ar(Mix(
		FreqShift.ar(signal, \shift.kr(-5e0, 0.3)/(1e2*Lag.ar(amp, 1)+1)),
	), 30), 1100);
	//
	// // signal = Limiter.ar(signal, limit, 1e-3);
	// signal = (signal / limit).softclip * limit;*/
	//
	~output.(signal);
	// ~output.(Mix(in));
/*	var amp, detect, gain, signal;
	var in = SoundIn.ar(~pickup_buses);
	var ctrl = AnalogIn.ar(~analog_buses);

	var limit = \limit.kr(0.25, 3);

	in = in * ctrl * 2;

	in = Mix(in); // DEBUG
	// in = Mix(in)[0]; // DEBUG

	// idea: increase gain faster for the quietest strings

	// adaptive gain
	in = BHiPass4.ar(in, 100);
	in = BLowShelf.ar(in, 600, db:-6);
	amp = Amplitude.ar(in, 0.03, 0.03);
	detect = Integrator.kr(
		(A2K.kr(amp) - 0.2).min(3e-4).max(-1e-5),
		coef:0.99999);
	gain = 2.pow(0-detect.max(0));
	gain = K2A.ar(gain);

	// amp.poll(10,\amp);
	// detect.poll(10,\detector);
	gain.poll(10,\gain);

	signal = in * gain;

	signal = LPF.ar(HPF.ar(Mix(
		FreqShift.ar(signal, \shift.kr(-5e0, 0.3)/(1e2*Lag.ar(amp, 1)+1)),
	), 30), 700);

	// signal = Limiter.ar(signal, limit, 1e-3);
	signal = (signal / limit).softclip * limit;

	~output.(signal);*/

}).add.name);
)
