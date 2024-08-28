// this file is for connecting to the Bela SC server and running sclang commands on e.g. a laptop

//connect to bela
(
Server.default = s = Server("belaServer", NetAddr("192.168.7.2", 57110));
s.options.maxLogins = 4; // should match the settings on the Bela
s.initTree;
s.startAliveThread;

s.boot
)

//alternatively: local simulation
(
s.options.numInputBusChannels = 8;
~pickup_buses = (0..7);
// ~pickup_buses = 0!8;
~output_bus = 0;
~output = {arg signal;
	Out.ar(~output_bus, signal!2)
};
s.options.sampleRate = 48000;
s.options.hardwareBufferSize = 64;
s.options.blockSize = 64;
s.boot;
)

//===============================================


// crude halldorophone simulator for local testing
(
~sim = SynthDef(\sim, {
	var in = InFeedback.ar(~output_bus);
	var out;
	in = 8.do{WhiteNoise.ar}*1e-2 + in * 0.99;
	out = CombC.ar(in, 0.2,
		delaytime:2/([100, 150, 225, 300, 100, 150, 200, 250]+[0,1,2,3,7,6,5,4]),
		decaytime:[4,3,2,1,4,3,2,1]+5
	);
	out = HPF.ar(out, 30);
	out = out.softclip;
	~pickup_buses.do{ |p,i|
		ReplaceOut.ar(p + s.options.numOutputBusChannels, out[i])
	}
}).play(s, addAction:\addToHead);

~victor.run;
)

~sim.free

s.queryAllNodes