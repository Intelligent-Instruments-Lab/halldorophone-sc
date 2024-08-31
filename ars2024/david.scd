(
Routine {
	var task1;
	// Define the SynthDef
	SynthDef(\randomSine, {
		|freq = 440|  // Add a frequency and gain argument with default values

		// Generate a random duration between 15 and 20 seconds
		var dur = Rand(18, 30);

		var gain = AnalogIn.kr(~analog_buses[0]);

		// Calculate attack time as a random percentage (20% to 40%) of the duration
		var attack = dur * Rand(0.1, 0.25);

		// Calculate decay time as the remainder of the duration
		var decay = dur - attack;

		// Generate a sine wave with an envelope
		var env = Env.perc(attack, decay, curve: 4); // Percussive envelope with attack and decay

		// Sine wave oscillator with a frequency passed in from the Task
		var sig;// = SinOsc.ar(freq, 0, gain); // Use the gain argument to control amplitude

		var filtered;
		var input;


		// Compressor parameters
		var cthreshold = 0.2; // Threshold level
		var cslopeBelow = 1;  // Slope below threshold (1 means no change)
		var cslopeAbove = 0.01; // Compression ratio above threshold (0.2 is heavy compression)
		var cclampTime = 0.01; // Attack time (seconds)
		var crelaxTime = 0.2;  // Release time (seconds)
		var compressed;
		var reverb;

		// gain.poll;

		input = Mix(SoundIn.ar(~pickup_buses[..3]));

		sig = input * 8;

		// Bandpass filter with center frequency of 1000 Hz and reciprocal of Q (quality factor)
		filtered = gain * BBandPass.ar(sig, freq: freq, bw: 0.005, mul: 10.0);

		reverb = FreeVerb.ar(filtered, mix: 0.25, room: 0.8, damp: 0.5);

		reverb = reverb * EnvGen.ar(env, doneAction: 2);

		compressed = Compander.ar(
			reverb,     // Input signal
			reverb,     // Control signal (using the input signal as the control signal)
			cthreshold,  // Threshold level
			cslopeBelow, // Slope below threshold
			cslopeAbove, // Slope above threshold (compression ratio)
			cclampTime,  // Attack time
			crelaxTime   // Release time
		);

		// reverb = FreeVerb.ar(compressed, mix: 0.25, room: 0.8, damp: 0.5);

		// Apply the envelope to the sine wave and reverb signal
		// ~output.(reverb);
		~output.(compressed);
		// Out.ar(0, reverb * 0.1);
		// Out.ar(4, reverb * 1.0);
	}).add;

	// s.sync;
	0.1.wait;

	// [95, 131, 140, 174] * 60/95;

	task1 = Task({
		var pitch_correction = 60/95;
		// [95, 131, 140, 174]*60/95
		// var funds = [95, 131, 140, 174] * pitch_correction;
		var funds = [95, 131, 140, 174] * pitch_correction;

		var frequencies1 = [
			//[[funds[2] * 6], [funds[2] * 6]], // 1
			//[[funds[2] * 6], [funds[2] * 4]], // 2
			[[funds[2] * 6], [funds[2] * 4, funds[2] * 3], [funds[2] * 7]], // 4
			[[funds[2] * 6], [funds[2] * 4, funds[2] * 3, funds[2] * 2],
				[funds[2] * 7], [funds[1] * 6]], // 7
			[[funds[2] * 6], [funds[2] * 3, funds[2] * 2, funds[2] * 1],
				[funds[2] * 7], [funds[0] * 10]], // 8*
			[[funds[2] * 6], [funds[2] * 2, funds[2] * 1], [funds[2] * 7],
				[funds[0] * 10], [funds[1] * 6]], // 9
			[[funds[2] * 6], [funds[2] * 1], [funds[2] * 7], [funds[0] * 10],
				[funds[1] * 6], [funds[1] * 1]], // 10
			[[funds[2] * 6], [funds[2] * 7], [funds[0] * 10], [funds[1] * 6],
				[funds[1] * 1]], // 11
			[[funds[2] * 6], [funds[0] * 10], [funds[1] * 6], [funds[1] * 1]], // 12
			[[funds[2] * 6], [funds[1] * 6], [funds[1] * 1]] // 13
		]; // Define the array of frequencies

		var gains1 = [
			//[[1.0], [1.0]], // 1
			//[[1.0], [1.0]], // 2
			[[1.0], [1.0, 3.0], [2.0]], // 4
			[[1.0], [1.0, 3.0, 9.0], [2.0], [1.0]], // 7
			[[1.0], [3.0, 9.0, 18.0], [2.0], [1.0]], // 8*
			[[1.0], [9.0, 18.0], [2.0], [1.0], [1.0]], // 9
			[[1.0], [18.0], [2.0], [1.0], [1.0], [18.0]], // 10
			[[1.0], [2.0], [1.0],[1.0], [18.0]], // 11
			[[1.0], [1.0], [1.0], [18.0]], // 12
			[[1.0], [1.0], [18.0]] // 13
		]; // Define the corresponding array of gains

		var min_distance = [ 7, 5, 3, 2, 2, 3, 4, 6];
		var module_duration = [ 35, 30, 35, 30, 35, 30, 25, 30];
		var freq, gain;
		var del;
		var index;
		var rnd;
		var module1 = 0;  // Start from the first module
		var elapsedTime = 0; // Track elapsed time
		var fdiv = 1.0;
		var lastIndex = nil; // Keep track of the last index
		var choices;

		\david.postln;

		loop {
			("-------------").postln;
			1.wait;
			// Randomly choose a frequency or a set of frequencies from the selected row based on the `module`
			choices = frequencies1[module1].select { |item, i| i != lastIndex }; // Exclude the last chosen item
			freq = choices.choose;
			index = frequencies1[module1].indexOf(freq); // Find the index of the chosen frequency array in the selected row
			lastIndex = index; // Update the last index to the current index
			gain = gains1[module1][index]; // Get the corresponding gain array from the selected row

			// Check if the chosen element is an array with more than one frequency
			if (freq.size > 1) {
				// If it's an array with more than one frequency, trigger the first synth instance
				Routine {
					// Play the first frequency (100% chance)
					Synth(\randomSine, [\freq, freq[0] / fdiv, \gain, gain[0]]);  // Pass the gain value
					freq[0].postln;
					// For each additional frequency, there is a 50% chance to play it
					freq[1..].do { |f, i|
						if ((1.0).coin) {  // 50% chance to play the secondary pitches
							Synth(\randomSine, [\freq, f / fdiv, \gain, gain[i + 1]]);  // Pass the gain value
						};

						// Introduce a slight delay between 0 to 2 seconds for each synth without affecting the main loop
						rrand(0, 5).wait;
					};
				}.play;
			} {
				freq[0].postln;
				// If it's a single frequency, trigger one synth instance
				Synth(\randomSine, [\freq, freq[0] / fdiv, \gain, gain[0]]);  // Pass the gain value
			};

			rnd = (100).rand / 100.0;
			rnd = rnd * rnd * rnd;
			rnd = rnd * 10.0;
			del = (min_distance[module1] + rnd);
			del.postln;

			// Wait for the calculated delay
			del.wait;
			elapsedTime = elapsedTime + del; // Increment elapsed time by the delay duration
			module1.postln;
			// Check if it's time to advance the module
			if (elapsedTime >= module_duration[round(module1)]) {
				module1 = (module1 + 1) % 8; // Advance module1 with modulus 13 to loop back after 12
				elapsedTime = 0; // Reset elapsed time for the next module
				("=================================").postln;
			}
		}
	});

	// task1.play;
	(\run:{task1.resume}, \pause:{task1.pause}).yield;
}//.forkIfNeeded
// .next[\run].value
)