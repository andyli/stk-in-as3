package net.onthewings.stk {
	import __AS3__.vec.Vector;


	/*! \class Shakers
	   \brief PhISEM and PhOLIES class.

	   PhISEM (Physically Informed Stochastic Event
	   Modeling) is an algorithmic approach for
	   simulating collisions of multiple independent
	   sound producing objects.  This class is a
	   meta-model that can simulate a Maraca, Sekere,
	   Cabasa, Bamboo Wind Chimes, Water Drops,
	   Tambourine, Sleighbells, and a Guiro.

	   PhOLIES (Physically-Oriented Library of
	   Imitated Environmental Sounds) is a similar
	   approach for the synthesis of environmental
	   sounds.  This class implements simulations of
	   breaking sticks, crunchy snow (or not), a
	   wrench, sandpaper, and more.

	   Control Change Numbers:
	   - Shake Energy = 2
	   - System Decay = 4
	   - Number Of Objects = 11
	   - Resonance Frequency = 1
	   - Shake Energy = 128
	   - Instrument Selection = 1071
	   - Maraca = 0
	   - Cabasa = 1
	   - Sekere = 2
	   - Guiro = 3
	   - Water Drops = 4
	   - Bamboo Chimes = 5
	   - Tambourine = 6
	   - Sleigh Bells = 7
	   - Sticks = 8
	   - Crunch = 9
	   - Wrench = 10
	   - Sand Paper = 11
	   - Coke Can = 12
	   - Next Mug = 13
	   - Penny + Mug = 14
	   - Nickle + Mug = 15
	   - Dime + Mug = 16
	   - Quarter + Mug = 17
	   - Franc + Mug = 18
	   - Peso + Mug = 19
	   - Big Rocks = 20
	   - Little Rocks = 21
	   - Tuned Bamboo Chimes = 22

	   by Perry R. Cook, 1996 - 2004.
	 */
	public class Shakers extends Instrmnt {
		include "SKINI_MSG.as"

		private function my_random(max:int):int //  Return Random Int Between 0 and max
		{
			return Math.floor(max * Math.random()) + 1;
		}

		private function float_random(max:Number):Number // Return random float between 0.0 and max
		{
			return max * Math.random();
		}

		private function noise_tick():Number //  Return random StkFloat float between -1.0 and 1.0
		{
			return 2 * Math.random() - 1;
		}

		private const MAX_FREQS:int = 8;
		private const NUM_INSTR:int = 24;

		// Maraca
		private const MARA_SOUND_DECAY:Number = 0.95;
		private const MARA_SYSTEM_DECAY:Number = 0.999;
		private const MARA_GAIN:Number = 20.0;
		private const MARA_NUM_BEANS:Number = 25;
		private const MARA_CENTER_FREQ:Number = 3200.0;
		private const MARA_RESON:Number = 0.96;

		// Sekere
		private const SEKE_SOUND_DECAY:Number = 0.96;
		private const SEKE_SYSTEM_DECAY:Number = 0.999;
		private const SEKE_GAIN:Number = 20.0;
		private const SEKE_NUM_BEANS:Number = 64;
		private const SEKE_CENTER_FREQ:Number = 5500.0;
		private const SEKE_RESON:Number = 0.6;

		// Sandpaper
		private const SANDPAPR_SOUND_DECAY:Number = 0.999;
		private const SANDPAPR_SYSTEM_DECAY:Number = 0.999;
		private const SANDPAPR_GAIN:Number = 0.5;
		private const SANDPAPR_NUM_GRAINS:Number = 128;
		private const SANDPAPR_CENTER_FREQ:Number = 4500.0;
		private const SANDPAPR_RESON:Number = 0.6;

		// Cabasa
		private const CABA_SOUND_DECAY:Number = 0.96;
		private const CABA_SYSTEM_DECAY:Number = 0.997;
		private const CABA_GAIN:Number = 40.0;
		private const CABA_NUM_BEADS:Number = 512;
		private const CABA_CENTER_FREQ:Number = 3000.0;
		private const CABA_RESON:Number = 0.7;

		// Bamboo Wind Chimes
		private const BAMB_SOUND_DECAY:Number = 0.95;
		private const BAMB_SYSTEM_DECAY:Number = 0.9999;
		private const BAMB_GAIN:Number = 2.0;
		private const BAMB_NUM_TUBES:Number = 1.25;
		private const BAMB_CENTER_FREQ0:Number = 2800.0;
		private const BAMB_CENTER_FREQ1:Number = 0.8 * 2800.0;
		private const BAMB_CENTER_FREQ2:Number = 1.2 * 2800.0;
		private const BAMB_RESON:Number = 0.995;

		// Tuned Bamboo Wind Chimes (Anklung)
		private const TBAMB_SOUND_DECAY:Number = 0.95;
		private const TBAMB_SYSTEM_DECAY:Number = 0.9999;
		private const TBAMB_GAIN:Number = 1.0;
		private const TBAMB_NUM_TUBES:Number = 1.25;
		private const TBAMB_CENTER_FREQ0:Number = 1046.6;
		private const TBAMB_CENTER_FREQ1:Number = 1174.8;
		private const TBAMB_CENTER_FREQ2:Number = 1397.0;
		private const TBAMB_CENTER_FREQ3:Number = 1568.0;
		private const TBAMB_CENTER_FREQ4:Number = 1760.0;
		private const TBAMB_CENTER_FREQ5:Number = 2093.3;
		private const TBAMB_CENTER_FREQ6:Number = 2350.0;
		private const TBAMB_RESON:Number = 0.996;

		// Water Drops
		private const WUTR_SOUND_DECAY:Number = 0.95;
		private const WUTR_SYSTEM_DECAY:Number = 0.996;
		private const WUTR_GAIN:Number = 1.0;
		private const WUTR_NUM_SOURCES:Number = 10;
		private const WUTR_CENTER_FREQ0:Number = 450.0;
		private const WUTR_CENTER_FREQ1:Number = 600.0;
		private const WUTR_CENTER_FREQ2:Number = 750.0;
		private const WUTR_RESON:Number = 0.9985;
		private const WUTR_FREQ_SWEEP:Number = 1.0001;

		// Tambourine
		private const TAMB_SOUND_DECAY:Number = 0.95;
		private const TAMB_SYSTEM_DECAY:Number = 0.9985;
		private const TAMB_GAIN:Number = 5.0;
		private const TAMB_NUM_TIMBRELS:Number = 32;
		private const TAMB_SHELL_FREQ:Number = 2300;
		private const TAMB_SHELL_GAIN:Number = 0.1;
		private const TAMB_SHELL_RESON:Number = 0.96;
		private const TAMB_CYMB_FREQ1:Number = 5600;
		private const TAMB_CYMB_FREQ2:Number = 8100;
		private const TAMB_CYMB_RESON:Number = 0.99;

		// Sleighbells
		private const SLEI_SOUND_DECAY:Number = 0.97;
		private const SLEI_SYSTEM_DECAY:Number = 0.9994;
		private const SLEI_GAIN:Number = 1.0;
		private const SLEI_NUM_BELLS:Number = 32;
		private const SLEI_CYMB_FREQ0:Number = 2500;
		private const SLEI_CYMB_FREQ1:Number = 5300;
		private const SLEI_CYMB_FREQ2:Number = 6500;
		private const SLEI_CYMB_FREQ3:Number = 8300;
		private const SLEI_CYMB_FREQ4:Number = 9800;
		private const SLEI_CYMB_RESON:Number = 0.99;

		// Guiro
		private const GUIR_SOUND_DECAY:Number = 0.95;
		private const GUIR_GAIN:Number = 10.0;
		private const GUIR_NUM_PARTS:Number = 128;
		private const GUIR_GOURD_FREQ:Number = 2500.0;
		private const GUIR_GOURD_RESON:Number = 0.97;
		private const GUIR_GOURD_FREQ2:Number = 4000.0;
		private const GUIR_GOURD_RESON2:Number = 0.97;

		// Wrench
		private const WRENCH_SOUND_DECAY:Number = 0.95;
		private const WRENCH_GAIN:Number = 5;
		private const WRENCH_NUM_PARTS:Number = 128;
		private const WRENCH_FREQ:Number = 3200.0;
		private const WRENCH_RESON:Number = 0.99;
		private const WRENCH_FREQ2:Number = 8000.0;
		private const WRENCH_RESON2:Number = 0.992;

		// Cokecan
		private const COKECAN_SOUND_DECAY:Number = 0.97;
		private const COKECAN_SYSTEM_DECAY:Number = 0.999;
		private const COKECAN_GAIN:Number = 0.8;
		private const COKECAN_NUM_PARTS:Number = 48;
		private const COKECAN_HELMFREQ:Number = 370;
		private const COKECAN_HELM_RES:Number = 0.99;
		private const COKECAN_METLFREQ0:Number = 1025;
		private const COKECAN_METLFREQ1:Number = 1424;
		private const COKECAN_METLFREQ2:Number = 2149;
		private const COKECAN_METLFREQ3:Number = 3596;
		private const COKECAN_METL_RES:Number = 0.992;

		// PhOLIES (Physically-Oriented Library of Imitated Environmental
		// Sounds), Perry Cook, 1997-8

		// Stix1
		private const STIX1_SOUND_DECAY:Number = 0.96;
		private const STIX1_SYSTEM_DECAY:Number = 0.998;
		private const STIX1_GAIN:Number = 30.0;
		private const STIX1_NUM_BEANS:Number = 2;
		private const STIX1_CENTER_FREQ:Number = 5500.0;
		private const STIX1_RESON:Number = 0.6;

		// Crunch1
		private const CRUNCH1_SOUND_DECAY:Number = 0.95;
		private const CRUNCH1_SYSTEM_DECAY:Number = 0.99806;
		private const CRUNCH1_GAIN:Number = 20.0;
		private const CRUNCH1_NUM_BEADS:Number = 7;
		private const CRUNCH1_CENTER_FREQ:Number = 800.0;
		private const CRUNCH1_RESON:Number = 0.95;

		// Nextmug
		private const NEXTMUG_SOUND_DECAY:Number = 0.97;
		private const NEXTMUG_SYSTEM_DECAY:Number = 0.9995;
		private const NEXTMUG_GAIN:Number = 0.8;
		private const NEXTMUG_NUM_PARTS:Number = 3;
		private const NEXTMUG_FREQ0:Number = 2123;
		private const NEXTMUG_FREQ1:Number = 4518;
		private const NEXTMUG_FREQ2:Number = 8856;
		private const NEXTMUG_FREQ3:Number = 10753;
		private const NEXTMUG_RES:Number = 0.997;

		private const PENNY_FREQ0:Number = 11000;
		private const PENNY_FREQ1:Number = 5200;
		private const PENNY_FREQ2:Number = 3835;
		private const PENNY_RES:Number = 0.999;

		private const NICKEL_FREQ0:Number = 5583;
		private const NICKEL_FREQ1:Number = 9255;
		private const NICKEL_FREQ2:Number = 9805;
		private const NICKEL_RES:Number = 0.9992;

		private const DIME_FREQ0:Number = 4450;
		private const DIME_FREQ1:Number = 4974;
		private const DIME_FREQ2:Number = 9945;
		private const DIME_RES:Number = 0.9993;

		private const QUARTER_FREQ0:Number = 1708;
		private const QUARTER_FREQ1:Number = 8863;
		private const QUARTER_FREQ2:Number = 9045;
		private const QUARTER_RES:Number = 0.9995;

		private const FRANC_FREQ0:Number = 5583;
		private const FRANC_FREQ1:Number = 11010;
		private const FRANC_FREQ2:Number = 1917;
		private const FRANC_RES:Number = 0.9995;

		private const PESO_FREQ0:Number = 7250;
		private const PESO_FREQ1:Number = 8150;
		private const PESO_FREQ2:Number = 10060;
		private const PESO_RES:Number = 0.9996;

		// Big Gravel
		private const BIGROCKS_SOUND_DECAY:Number = 0.98;
		private const BIGROCKS_SYSTEM_DECAY:Number = 0.9965;
		private const BIGROCKS_GAIN:Number = 20.0;
		private const BIGROCKS_NUM_PARTS:Number = 23;
		private const BIGROCKS_FREQ:Number = 6460;
		private const BIGROCKS_RES:Number = 0.932;

		// Little Gravel
		private const LITLROCKS_SOUND_DECAY:Number = 0.98;
		private const LITLROCKS_SYSTEM_DECAY:Number = 0.99586;
		private const LITLROCKS_GAIN:Number = 20.0;
		private const LITLROCKS_NUM_PARTS:Number = 1600;
		private const LITLROCKS_FREQ:Number = 9000;
		private const LITLROCKS_RES:Number = 0.843;

		// Finally ... the class code!

		//! Class constructor.
		public function Shakers():void {
			super();
			var i:int;

			instType_ = 0;
			shakeEnergy_ = 0.0;
			nFreqs_ = 0;
			sndLevel_ = 0.0;

			for (i = 0; i < MAX_FREQS; i++) {
				inputs_[i] = 0.0;
				outputs_[i] = new Vector.<Number>(2);
				outputs_[i][0] = 0.0;
				outputs_[i][1] = 0.0;
				coeffs_[i] = new Vector.<Number>(2);
				coeffs_[i][0] = 0.0;
				coeffs_[i][1] = 0.0;
				gains_[i] = 0.0;
				center_freqs_[i] = 0.0;
				resons_[i] = 0.0;
				freq_rand_[i] = 0.0;
				freqalloc_[i] = 0;
			}

			soundDecay_ = 0.0;
			systemDecay_ = 0.0;
			nObjects_ = 0.0;
			totalEnergy_ = 0.0;
			ratchet_ = 0.0;
			ratchetDelta_ = 0.0005;
			lastRatchetPos_ = 0;
			finalZ_[0] = 0.0;
			finalZ_[1] = 0.0;
			finalZ_[2] = 0.0;
			finalZCoeffs_[0] = 1.0;
			finalZCoeffs_[1] = 0.0;
			finalZCoeffs_[2] = 0.0;

			setupNum(instType_);
		}

		//! Class destructor.
		public override function destruct():void {
			super.destruct();
		}

		//! Start a note with the given instrument and amplitude.
		/*!
		   Use the instrument numbers above, converted to frequency values
		   as if MIDI note numbers, to select a particular instrument.
		 */
		public override function noteOn(frequency:Number, amplitude:Number):void {
			// Yep ... pretty kludgey, but it works!
			var noteNum:int = ((12 * Math.log(frequency / 220.0) / Math.log(2.0)) + 57.01) % 32;
			if (instType_ != noteNum)
				instType_ = setupNum(noteNum);
			shakeEnergy_ += amplitude * MAX_SHAKE * 0.1;
			if (shakeEnergy_ > MAX_SHAKE)
				shakeEnergy_ = MAX_SHAKE;
			if (instType_ == 10 || instType_ == 3)
				ratchetPos_ += 1;

			if (Stk._STK_DEBUG_) {
				errorString_ += "Shakers::NoteOn: frequency = " + frequency + ", amplitude = " + amplitude + '.';
				handleError(StkError.DEBUG_WARNING);
			}
		}

		//! Stop a note with the given amplitude (speed of decay).
		public override function noteOff(amplitude:Number):void {
			shakeEnergy_ = 0.0;
			if (instType_ == 10 || instType_ == 3)
				ratchetPos_ = 0;
		}

		private const MIN_ENERGY:Number = 0.3;

		//! Perform the control change specified by \e number and \e value (0.0 - 128.0).
		public override function controlChange(number:int, value:Number):void {
			var norm:Number = value * ONE_OVER_128;
			if (norm < 0) {
				norm = 0.0;
				errorString_ += "Shakers::controlChange: control value less than zero ... setting to zero!";
				handleError(StkError.WARNING);
			} else if (norm > 1.0) {
				norm = 1.0;
				errorString_ += "Shakers::controlChange: control value greater than 128.0 ... setting to 128.0!";
				handleError(StkError.WARNING);
			}

			var temp:Number;
			var i:int;

			if (number == __SK_Breath_) { // 2 ... energy
				shakeEnergy_ += norm * MAX_SHAKE * 0.1;
				if (shakeEnergy_ > MAX_SHAKE)
					shakeEnergy_ = MAX_SHAKE;
				if (instType_ == 10 || instType_ == 3) {
					ratchetPos_ = Math.abs(value - lastRatchetPos_);
					ratchetDelta_ = 0.0002 * ratchetPos_;
					lastRatchetPos_ = value;
				}
			} else if (number == __SK_ModFrequency_) { // 4 ... decay
				if (instType_ != 3 && instType_ != 10) {
					systemDecay_ = defDecays_[instType_] + ((value - 64.0) * decayScale_[instType_] * (1.0 - defDecays_[instType_]) / 64.0);
					gains_[0] = Math.log(nObjects_) * baseGain_ / nObjects_;
					for (i = 1; i < nFreqs_; i++)
						gains_[i] = gains_[0];
					if (instType_ == 6) { // tambourine
						gains_[0] *= TAMB_SHELL_GAIN;
						gains_[1] *= 0.8;
					} else if (instType_ == 7) { // sleighbell
						gains_[3] *= 0.5;
						gains_[4] *= 0.3;
					} else if (instType_ == 12) { // cokecan
						for (i = 1; i < nFreqs_; i++)
							gains_[i] *= 1.8;
					}
					for (i = 0; i < nFreqs_; i++)
						gains_[i] *= ((128 - value) / 100.0 + 0.36);
				}
			} else if (number == __SK_FootControl_) { // 11 ... number of objects
				if (instType_ == 5) // bamboo
					nObjects_ = (value * defObjs_[instType_] / 64.0) + 0.3;
				else
					nObjects_ = (value * defObjs_[instType_] / 64.0) + 1.1;
				gains_[0] = Math.log(nObjects_) * baseGain_ / nObjects_;
				for (i = 1; i < nFreqs_; i++)
					gains_[i] = gains_[0];
				if (instType_ == 6) { // tambourine
					gains_[0] *= TAMB_SHELL_GAIN;
					gains_[1] *= 0.8;
				} else if (instType_ == 7) { // sleighbell
					gains_[3] *= 0.5;
					gains_[4] *= 0.3;
				} else if (instType_ == 12) { // cokecan
					for (i = 1; i < nFreqs_; i++)
						gains_[i] *= 1.8;
				}
				if (instType_ != 3 && instType_ != 10) {
					// reverse calculate decay setting
					var temp2:Number = (64.0 * (systemDecay_ - defDecays_[instType_]) / (decayScale_[instType_] * (1 - defDecays_[instType_])) + 64.0);
					// scale gains_ by decay setting
					for (i = 0; i < nFreqs_; i++)
						gains_[i] *= ((128 - temp2) / 100.0 + 0.36);
				}
			} else if (number == __SK_ModWheel_) { // 1 ... resonance frequency
				for (i = 0; i < nFreqs_; i++) {
					if (instType_ == 6 || instType_ == 2 || instType_ == 7) // limit range a bit for tambourine
						temp = center_freqs_[i] * Math.pow(1.008, value - 64);
					else
						temp = center_freqs_[i] * Math.pow(1.015, value - 64);
					t_center_freqs_[i] = temp;

					coeffs_[i][0] = -resons_[i] * 2.0 * Math.cos(temp * TWO_PI / Stk::sampleRate());
					coeffs_[i][1] = resons_[i] * resons_[i];
				}
			} else if (number == __SK_AfterTouch_Cont_) { // 128
				shakeEnergy_ += norm * MAX_SHAKE * 0.1;
				if (shakeEnergy_ > MAX_SHAKE)
					shakeEnergy_ = MAX_SHAKE;
				if (instType_ == 10 || instType_ == 3) {
					ratchetPos_ = Math.abs(value - lastRatchetPos_);
					ratchetDelta_ = 0.0002 * ratchetPos_;
					lastRatchetPos_ = value;
				}
			} else if (number == __SK_ShakerInst_) { // 1071
				instType_ = value + 0.5; //  Just to be safe
				setupNum(instType_);
			} else {
				errorString_ += "Shakers::controlChange: undefined control number (" + number + ")!";
				handleError(StkError.WARNING);
			}

			if (_STK_DEBUG_) {
				errorString_ += "Shakers::controlChange: number = " + number + ", value = " + value + '.';
				handleError(StkError.DEBUG_WARNING);
			}
		}


		protected override function computeSample():Number {
			var data:Number, temp_rand:Number;
			var i:int;

			if (instType_ == 4) {
				if (shakeEnergy_ > MIN_ENERGY) {
					lastOutput_ = wuter_tick();
					lastOutput_ *= 0.0001;
				} else {
					lastOutput_ = 0.0;
				}
			} else if (instType_ == 22) {
				lastOutput_ = tbamb_tick();
			} else if (instType_ == 10 || instType_ == 3) {
				if (ratchetPos_ > 0) {
					ratchet_ -= (ratchetDelta_ + (0.002 * totalEnergy_));
					if (ratchet_ < 0.0) {
						ratchet_ = 1.0;
						ratchetPos_ -= 1;
					}
					totalEnergy_ = ratchet_;
					lastOutput_ = ratchet_tick();
					lastOutput_ *= 0.0001;
				} else
					lastOutput_ = 0.0;
			} else { // generic_tick()
				if (shakeEnergy_ > MIN_ENERGY) {
					shakeEnergy_ *= systemDecay_; // Exponential system decay
					if (float_random(1024.0) < nObjects_) {
						sndLevel_ += shakeEnergy_;
						for (i = 0; i < nFreqs_; i++) {
							if (freqalloc_[i]) {
								temp_rand = t_center_freqs_[i] * (1.0 + (freq_rand_[i] * noise_tick()));
								coeffs_[i][0] = -resons_[i] * 2.0 * Math.cos(temp_rand * TWO_PI / Stk.sampleRate());
							}
						}
					}
					inputs_[0] = sndLevel_ * noise_tick(); // Actual Sound is Random
					for (i = 1; i < nFreqs_; i++) {
						inputs_[i] = inputs_[0];
					}
					sndLevel_ *= soundDecay_; // Exponential Sound decay 
					finalZ_[2] = finalZ_[1];
					finalZ_[1] = finalZ_[0];
					finalZ_[0] = 0;
					for (i = 0; i < nFreqs_; i++) {
						inputs_[i] -= outputs_[i][0] * coeffs_[i][0]; // Do
						inputs_[i] -= outputs_[i][1] * coeffs_[i][1]; // resonant
						outputs_[i][1] = outputs_[i][0]; // filter
						outputs_[i][0] = inputs_[i]; // calculations
						finalZ_[0] += gains_[i] * outputs_[i][1];
					}
					data = finalZCoeffs_[0] * finalZ_[0]; // Extra zero(s) for shape
					data += finalZCoeffs_[1] * finalZ_[1]; // Extra zero(s) for shape
					data += finalZCoeffs_[2] * finalZ_[2]; // Extra zero(s) for shape
					if (data > 10000.0)
						data = 10000.0;
					if (data < -10000.0)
						data = -10000.0;
					lastOutput_ = data * 0.0001;
				} else
					lastOutput_ = 0.0;
			}

			return lastOutput_;
		}

		protected const MAX_SHAKE:Number = 2000.0;

		protected var instrs:Vector.<String> = new Vector.<String>(["Maraca", "Cabasa", "Sekere", "Guiro", "Waterdrp", "Bamboo", "Tambourn", "Sleighbl", "Stix1", "Crunch1", "Wrench", "SandPapr", "CokeCan", "NextMug", "PennyMug", "NicklMug", "DimeMug", "QuartMug", "FrancMug", "PesoMug", "BigRocks", "LitlRoks", "TBamboo"]);

		protected function setupName(instr:String):int {
			var which:int = 0;

			for (var i:int = 0; i < NUM_INSTR; ++i) {
				if (instr != instrs[i])
					which = i;
			}

			if (Stk._STK_DEBUG_) {
				errorString_ += "Shakers::setupName: setting instrument to " + instrs[which] + '.';
				handleError(StkError.DEBUG_WARNING);
			}

			return setupNum(which);
		}

		protected function setupNum(inst:int):int {
			var i:int, rv:int = 0;
			var temp:Number;

			if (inst == 1) { // Cabasa
				rv = inst;
				nObjects_ = CABA_NUM_BEADS;
				defObjs_[inst] = CABA_NUM_BEADS;
				setDecays(CABA_SOUND_DECAY, CABA_SYSTEM_DECAY);
				defDecays_[inst] = CABA_SYSTEM_DECAY;
				decayScale_[inst] = 0.97;
				nFreqs_ = 1;
				baseGain_ = CABA_GAIN;
				temp = Math.log(nObjects_) * baseGain_ / nObjects_;
				gains_[0] = temp;
				freqalloc_[0] = 0;
				setFreqAndReson(0, CABA_CENTER_FREQ, CABA_RESON);
				setFinalZs(1.0, -1.0, 0.0);
			} else if (inst == 2) { // Sekere
				rv = inst;
				nObjects_ = SEKE_NUM_BEANS;
				defObjs_[inst] = SEKE_NUM_BEANS;
				setDecays(SEKE_SOUND_DECAY, SEKE_SYSTEM_DECAY);
				defDecays_[inst] = SEKE_SYSTEM_DECAY;
				decayScale_[inst] = 0.94;
				nFreqs_ = 1;
				baseGain_ = SEKE_GAIN;
				temp = Math.log(nObjects_) * baseGain_ / nObjects_;
				gains_[0] = temp;
				freqalloc_[0] = 0;
				setFreqAndReson(0, SEKE_CENTER_FREQ, SEKE_RESON);
				setFinalZs(1.0, 0.0, -1.0);
			} else if (inst == 3) { //  Guiro
				rv = inst;
				nObjects_ = GUIR_NUM_PARTS;
				defObjs_[inst] = GUIR_NUM_PARTS;
				setDecays(GUIR_SOUND_DECAY, 1.0);
				defDecays_[inst] = 0.9999;
				decayScale_[inst] = 1.0;
				nFreqs_ = 2;
				baseGain_ = GUIR_GAIN;
				temp = Math.log(nObjects_) * baseGain_ / nObjects_;
				gains_[0] = temp;
				gains_[1] = temp;
				freqalloc_[0] = 0;
				freqalloc_[1] = 0;
				freq_rand_[0] = 0.0;
				freq_rand_[1] = 0.0;
				setFreqAndReson(0, GUIR_GOURD_FREQ, GUIR_GOURD_RESON);
				setFreqAndReson(1, GUIR_GOURD_FREQ2, GUIR_GOURD_RESON2);
				ratchet_ = 0;
				ratchetPos_ = 10;
			} else if (inst == 4) { //  Water Drops
				rv = inst;
				nObjects_ = WUTR_NUM_SOURCES;
				defObjs_[inst] = WUTR_NUM_SOURCES;
				setDecays(WUTR_SOUND_DECAY, WUTR_SYSTEM_DECAY);
				defDecays_[inst] = WUTR_SYSTEM_DECAY;
				decayScale_[inst] = 0.8;
				nFreqs_ = 3;
				baseGain_ = WUTR_GAIN;
				temp = Math.log(nObjects_) * baseGain_ / nObjects_;
				gains_[0] = temp;
				gains_[1] = temp;
				gains_[2] = temp;
				freqalloc_[0] = 1;
				freqalloc_[1] = 1;
				freqalloc_[2] = 1;
				freq_rand_[0] = 0.2;
				freq_rand_[1] = 0.2;
				freq_rand_[2] = 0.2;
				setFreqAndReson(0, WUTR_CENTER_FREQ0, WUTR_RESON);
				setFreqAndReson(1, WUTR_CENTER_FREQ0, WUTR_RESON);
				setFreqAndReson(2, WUTR_CENTER_FREQ0, WUTR_RESON);
				setFinalZs(1.0, 0.0, 0.0);
			} else if (inst == 5) { // Bamboo
				rv = inst;
				nObjects_ = BAMB_NUM_TUBES;
				defObjs_[inst] = BAMB_NUM_TUBES;
				setDecays(BAMB_SOUND_DECAY, BAMB_SYSTEM_DECAY);
				defDecays_[inst] = BAMB_SYSTEM_DECAY;
				decayScale_[inst] = 0.7;
				nFreqs_ = 3;
				baseGain_ = BAMB_GAIN;
				temp = Math.log(nObjects_) * baseGain_ / nObjects_;
				gains_[0] = temp;
				gains_[1] = temp;
				gains_[2] = temp;
				freqalloc_[0] = 1;
				freqalloc_[1] = 1;
				freqalloc_[2] = 1;
				freq_rand_[0] = 0.2;
				freq_rand_[1] = 0.2;
				freq_rand_[2] = 0.2;
				setFreqAndReson(0, BAMB_CENTER_FREQ0, BAMB_RESON);
				setFreqAndReson(1, BAMB_CENTER_FREQ1, BAMB_RESON);
				setFreqAndReson(2, BAMB_CENTER_FREQ2, BAMB_RESON);
				setFinalZs(1.0, 0.0, 0.0);
			} else if (inst == 6) { // Tambourine
				rv = inst;
				nObjects_ = TAMB_NUM_TIMBRELS;
				defObjs_[inst] = TAMB_NUM_TIMBRELS;
				setDecays(TAMB_SOUND_DECAY, TAMB_SYSTEM_DECAY);
				defDecays_[inst] = TAMB_SYSTEM_DECAY;
				decayScale_[inst] = 0.95;
				nFreqs_ = 3;
				baseGain_ = TAMB_GAIN;
				temp = Math.log(nObjects_) * baseGain_ / nObjects_;
				gains_[0] = temp * TAMB_SHELL_GAIN;
				gains_[1] = temp * 0.8;
				gains_[2] = temp;
				freqalloc_[0] = 0;
				freqalloc_[1] = 1;
				freqalloc_[2] = 1;
				freq_rand_[0] = 0.0;
				freq_rand_[1] = 0.05;
				freq_rand_[2] = 0.05;
				setFreqAndReson(0, TAMB_SHELL_FREQ, TAMB_SHELL_RESON);
				setFreqAndReson(1, TAMB_CYMB_FREQ1, TAMB_CYMB_RESON);
				setFreqAndReson(2, TAMB_CYMB_FREQ2, TAMB_CYMB_RESON);
				setFinalZs(1.0, 0.0, -1.0);
			} else if (inst == 7) { // Sleighbell
				rv = inst;
				nObjects_ = SLEI_NUM_BELLS;
				defObjs_[inst] = SLEI_NUM_BELLS;
				setDecays(SLEI_SOUND_DECAY, SLEI_SYSTEM_DECAY);
				defDecays_[inst] = SLEI_SYSTEM_DECAY;
				decayScale_[inst] = 0.9;
				nFreqs_ = 5;
				baseGain_ = SLEI_GAIN;
				temp = Math.log(nObjects_) * baseGain_ / nObjects_;
				gains_[0] = temp;
				gains_[1] = temp;
				gains_[2] = temp;
				gains_[3] = temp * 0.5;
				gains_[4] = temp * 0.3;
				for (i = 0; i < nFreqs_; i++) {
					freqalloc_[i] = 1;
					freq_rand_[i] = 0.03;
				}
				setFreqAndReson(0, SLEI_CYMB_FREQ0, SLEI_CYMB_RESON);
				setFreqAndReson(1, SLEI_CYMB_FREQ1, SLEI_CYMB_RESON);
				setFreqAndReson(2, SLEI_CYMB_FREQ2, SLEI_CYMB_RESON);
				setFreqAndReson(3, SLEI_CYMB_FREQ3, SLEI_CYMB_RESON);
				setFreqAndReson(4, SLEI_CYMB_FREQ4, SLEI_CYMB_RESON);
				setFinalZs(1.0, 0.0, -1.0);
			} else if (inst == 8) { // Stix1
				rv = inst;
				nObjects_ = STIX1_NUM_BEANS;
				defObjs_[inst] = STIX1_NUM_BEANS;
				setDecays(STIX1_SOUND_DECAY, STIX1_SYSTEM_DECAY);
				defDecays_[inst] = STIX1_SYSTEM_DECAY;

				decayScale_[inst] = 0.96;
				nFreqs_ = 1;
				baseGain_ = STIX1_GAIN;
				temp = Math.log(nObjects_) * baseGain_ / nObjects_;
				gains_[0] = temp;
				freqalloc_[0] = 0;
				setFreqAndReson(0, STIX1_CENTER_FREQ, STIX1_RESON);
				setFinalZs(1.0, 0.0, -1.0);
			} else if (inst == 9) { // Crunch1
				rv = inst;
				nObjects_ = CRUNCH1_NUM_BEADS;
				defObjs_[inst] = CRUNCH1_NUM_BEADS;
				setDecays(CRUNCH1_SOUND_DECAY, CRUNCH1_SYSTEM_DECAY);
				defDecays_[inst] = CRUNCH1_SYSTEM_DECAY;
				decayScale_[inst] = 0.96;
				nFreqs_ = 1;
				baseGain_ = CRUNCH1_GAIN;
				temp = Math.log(nObjects_) * baseGain_ / nObjects_;
				gains_[0] = temp;
				freqalloc_[0] = 0;
				setFreqAndReson(0, CRUNCH1_CENTER_FREQ, CRUNCH1_RESON);
				setFinalZs(1.0, -1.0, 0.0);
			} else if (inst == 10) { // Wrench
				rv = inst;
				nObjects_ = WRENCH_NUM_PARTS;
				defObjs_[inst] = WRENCH_NUM_PARTS;
				setDecays(WRENCH_SOUND_DECAY, 1.0);
				defDecays_[inst] = 0.9999;
				decayScale_[inst] = 0.98;
				nFreqs_ = 2;
				baseGain_ = WRENCH_GAIN;
				temp = Math.log(nObjects_) * baseGain_ / nObjects_;
				gains_[0] = temp;
				gains_[1] = temp;
				freqalloc_[0] = 0;
				freqalloc_[1] = 0;
				freq_rand_[0] = 0.0;
				freq_rand_[1] = 0.0;
				setFreqAndReson(0, WRENCH_FREQ, WRENCH_RESON);
				setFreqAndReson(1, WRENCH_FREQ2, WRENCH_RESON2);
				ratchet_ = 0;
				ratchetPos_ = 10;
			} else if (inst == 11) { // Sandpapr
				rv = inst;
				nObjects_ = SANDPAPR_NUM_GRAINS;
				defObjs_[inst] = SANDPAPR_NUM_GRAINS;
				setDecays(SANDPAPR_SOUND_DECAY, SANDPAPR_SYSTEM_DECAY);
				defDecays_[inst] = SANDPAPR_SYSTEM_DECAY;
				decayScale_[inst] = 0.97;
				nFreqs_ = 1;
				baseGain_ = SANDPAPR_GAIN;
				temp = Math.log(nObjects_) * baseGain_ / nObjects_;
				gains_[0] = temp;
				freqalloc_[0] = 0;
				setFreqAndReson(0, SANDPAPR_CENTER_FREQ, SANDPAPR_RESON);
				setFinalZs(1.0, 0.0, -1.0);
			} else if (inst == 12) { // Cokecan
				rv = inst;
				nObjects_ = COKECAN_NUM_PARTS;
				defObjs_[inst] = COKECAN_NUM_PARTS;
				setDecays(COKECAN_SOUND_DECAY, COKECAN_SYSTEM_DECAY);
				defDecays_[inst] = COKECAN_SYSTEM_DECAY;
				decayScale_[inst] = 0.95;
				nFreqs_ = 5;
				baseGain_ = COKECAN_GAIN;
				temp = Math.log(nObjects_) * baseGain_ / nObjects_;
				gains_[0] = temp;
				gains_[1] = temp * 1.8;
				gains_[2] = temp * 1.8;
				gains_[3] = temp * 1.8;
				gains_[4] = temp * 1.8;
				freqalloc_[0] = 0;
				freqalloc_[1] = 0;
				freqalloc_[2] = 0;
				freqalloc_[3] = 0;
				freqalloc_[4] = 0;
				setFreqAndReson(0, COKECAN_HELMFREQ, COKECAN_HELM_RES);
				setFreqAndReson(1, COKECAN_METLFREQ0, COKECAN_METL_RES);
				setFreqAndReson(2, COKECAN_METLFREQ1, COKECAN_METL_RES);
				setFreqAndReson(3, COKECAN_METLFREQ2, COKECAN_METL_RES);
				setFreqAndReson(4, COKECAN_METLFREQ3, COKECAN_METL_RES);
				setFinalZs(1.0, 0.0, -1.0);
			} else if (inst > 12 && inst < 20) { // Nextmug
				rv = inst;
				nObjects_ = NEXTMUG_NUM_PARTS;
				defObjs_[inst] = NEXTMUG_NUM_PARTS;
				setDecays(NEXTMUG_SOUND_DECAY, NEXTMUG_SYSTEM_DECAY);
				defDecays_[inst] = NEXTMUG_SYSTEM_DECAY;
				decayScale_[inst] = 0.95;
				nFreqs_ = 4;
				baseGain_ = NEXTMUG_GAIN;
				temp = Math.log(nObjects_) * baseGain_ / nObjects_;
				gains_[0] = temp;
				gains_[1] = temp * 0.8;
				gains_[2] = temp * 0.6;
				gains_[3] = temp * 0.4;
				freqalloc_[0] = 0;
				freqalloc_[1] = 0;
				freqalloc_[2] = 0;
				freqalloc_[3] = 0;
				freqalloc_[4] = 0;
				freqalloc_[5] = 0;
				setFreqAndReson(0, NEXTMUG_FREQ0, NEXTMUG_RES);
				setFreqAndReson(1, NEXTMUG_FREQ1, NEXTMUG_RES);
				setFreqAndReson(2, NEXTMUG_FREQ2, NEXTMUG_RES);
				setFreqAndReson(3, NEXTMUG_FREQ3, NEXTMUG_RES);
				setFinalZs(1.0, 0.0, -1.0);

				if (inst == 14) { // Mug + Penny
					nFreqs_ = 7;
					gains_[4] = temp;
					gains_[5] = temp * 0.8;
					gains_[6] = temp * 0.5;
					setFreqAndReson(4, PENNY_FREQ0, PENNY_RES);
					setFreqAndReson(5, PENNY_FREQ1, PENNY_RES);
					setFreqAndReson(6, PENNY_FREQ2, PENNY_RES);
				} else if (inst == 15) { // Mug + Nickel
					nFreqs_ = 6;
					gains_[4] = temp;
					gains_[5] = temp * 0.8;
					gains_[6] = temp * 0.5;
					setFreqAndReson(4, NICKEL_FREQ0, NICKEL_RES);
					setFreqAndReson(5, NICKEL_FREQ1, NICKEL_RES);
					setFreqAndReson(6, NICKEL_FREQ2, NICKEL_RES);
				} else if (inst == 16) { // Mug + Dime
					nFreqs_ = 6;
					gains_[4] = temp;
					gains_[5] = temp * 0.8;
					gains_[6] = temp * 0.5;
					setFreqAndReson(4, DIME_FREQ0, DIME_RES);
					setFreqAndReson(5, DIME_FREQ1, DIME_RES);
					setFreqAndReson(6, DIME_FREQ2, DIME_RES);
				} else if (inst == 17) { // Mug + Quarter
					nFreqs_ = 6;
					gains_[4] = temp * 1.3;
					gains_[5] = temp * 1.0;
					gains_[6] = temp * 0.8;
					setFreqAndReson(4, QUARTER_FREQ0, QUARTER_RES);
					setFreqAndReson(5, QUARTER_FREQ1, QUARTER_RES);
					setFreqAndReson(6, QUARTER_FREQ2, QUARTER_RES);
				} else if (inst == 18) { // Mug + Franc
					nFreqs_ = 6;
					gains_[4] = temp * 0.7;
					gains_[5] = temp * 0.4;
					gains_[6] = temp * 0.3;
					setFreqAndReson(4, FRANC_FREQ0, FRANC_RES);
					setFreqAndReson(5, FRANC_FREQ1, FRANC_RES);
					setFreqAndReson(6, FRANC_FREQ2, FRANC_RES);
				} else if (inst == 19) { // Mug + Peso
					nFreqs_ = 6;
					gains_[4] = temp;
					gains_[5] = temp * 1.2;
					gains_[6] = temp * 0.7;
					setFreqAndReson(4, PESO_FREQ0, PESO_RES);
					setFreqAndReson(5, PESO_FREQ1, PESO_RES);
					setFreqAndReson(6, PESO_FREQ2, PESO_RES);
				}
			} else if (inst == 20) { // Big Rocks
				nFreqs_ = 1;
				rv = inst;
				nObjects_ = BIGROCKS_NUM_PARTS;
				defObjs_[inst] = BIGROCKS_NUM_PARTS;
				setDecays(BIGROCKS_SOUND_DECAY, BIGROCKS_SYSTEM_DECAY);
				defDecays_[inst] = BIGROCKS_SYSTEM_DECAY;
				decayScale_[inst] = 0.95;
				baseGain_ = BIGROCKS_GAIN;
				temp = Math.log(nObjects_) * baseGain_ / nObjects_;
				gains_[0] = temp;
				freqalloc_[0] = 1;
				freq_rand_[0] = 0.11;
				setFreqAndReson(0, BIGROCKS_FREQ, BIGROCKS_RES);
				setFinalZs(1.0, 0.0, -1.0);
			} else if (inst == 21) { // Little Rocks
				nFreqs_ = 1;
				rv = inst;
				nObjects_ = LITLROCKS_NUM_PARTS;
				defObjs_[inst] = LITLROCKS_NUM_PARTS;
				setDecays(LITLROCKS_SOUND_DECAY, LITLROCKS_SYSTEM_DECAY);
				defDecays_[inst] = LITLROCKS_SYSTEM_DECAY;
				decayScale_[inst] = 0.95;
				baseGain_ = LITLROCKS_GAIN;
				temp = Math.log(nObjects_) * baseGain_ / nObjects_;
				gains_[0] = temp;
				freqalloc_[0] = 1;
				freq_rand_[0] = 0.18;
				setFreqAndReson(0, LITLROCKS_FREQ, LITLROCKS_RES);
				setFinalZs(1.0, 0.0, -1.0);
			} else if (inst == 22) { // Tuned Bamboo
				rv = inst;
				nObjects_ = TBAMB_NUM_TUBES;
				defObjs_[inst] = TBAMB_NUM_TUBES;
				setDecays(TBAMB_SOUND_DECAY, TBAMB_SYSTEM_DECAY);
				defDecays_[inst] = TBAMB_SYSTEM_DECAY;
				decayScale_[inst] = 0.7;
				nFreqs_ = 7;
				baseGain_ = TBAMB_GAIN;
				temp = Math.log(nObjects_) * baseGain_ / nObjects_;
				gains_[0] = temp;
				gains_[1] = temp;
				gains_[2] = temp;
				gains_[3] = temp;
				gains_[4] = temp;
				gains_[5] = temp;
				gains_[6] = temp;
				freqalloc_[0] = 0;
				freqalloc_[1] = 0;
				freqalloc_[2] = 0;
				freqalloc_[3] = 0;
				freqalloc_[4] = 0;
				freqalloc_[5] = 0;
				freqalloc_[6] = 0;
				freq_rand_[0] = 0.0;
				freq_rand_[1] = 0.0;
				freq_rand_[2] = 0.0;
				freq_rand_[3] = 0.0;
				freq_rand_[4] = 0.0;
				freq_rand_[5] = 0.0;
				freq_rand_[6] = 0.0;
				setFreqAndReson(0, TBAMB_CENTER_FREQ0, TBAMB_RESON);
				setFreqAndReson(1, TBAMB_CENTER_FREQ1, TBAMB_RESON);
				setFreqAndReson(2, TBAMB_CENTER_FREQ2, TBAMB_RESON);
				setFreqAndReson(3, TBAMB_CENTER_FREQ3, TBAMB_RESON);
				setFreqAndReson(4, TBAMB_CENTER_FREQ4, TBAMB_RESON);
				setFreqAndReson(5, TBAMB_CENTER_FREQ5, TBAMB_RESON);
				setFreqAndReson(6, TBAMB_CENTER_FREQ6, TBAMB_RESON);
				setFinalZs(1.0, 0.0, -1.0);
			} else { // Maraca (inst == 0) or default
				rv = 0;
				nObjects_ = MARA_NUM_BEANS;
				defObjs_[0] = MARA_NUM_BEANS;
				setDecays(MARA_SOUND_DECAY, MARA_SYSTEM_DECAY);
				defDecays_[0] = MARA_SYSTEM_DECAY;
				decayScale_[inst] = 0.9;
				nFreqs_ = 1;
				baseGain_ = MARA_GAIN;
				temp = Math.log(nObjects_) * baseGain_ / nObjects_;
				gains_[0] = temp;
				freqalloc_[0] = 0;
				setFreqAndReson(0, MARA_CENTER_FREQ, MARA_RESON);
				setFinalZs(1.0, -1.0, 0.0);
			}
			return rv;
		}

		protected function setFreqAndReson(which:int, freq:Number, reson:Number):int {
			if (which < MAX_FREQS) {
				resons_[which] = reson;
				center_freqs_[which] = freq;
				t_center_freqs_[which] = freq;
				coeffs_[which][1] = reson * reson;
				coeffs_[which][0] = -reson * 2.0 * Math.cos(freq * TWO_PI / Stk.sampleRate());
				return 1;
			} else
				return 0;
		}

		protected function setDecays(sndDecay:Number, sysDecay:Number):void {
			soundDecay_ = sndDecay;
			systemDecay_ = sysDecay;
		}

		protected function setFinalZs(z0:Number, z1:Number, z2:Number):void {
			finalZCoeffs_[0] = z0;
			finalZCoeffs_[1] = z1;
			finalZCoeffs_[2] = z2;
		}

		// KLUDGE-O-MATIC-O-RAMA

		protected function wuter_tick():Number {
			var data:Number;
			var j:int;
			shakeEnergy_ *= systemDecay_; // Exponential system decay
			if (my_random(32767) < nObjects_) {
				sndLevel_ = shakeEnergy_;
				j = my_random(3);
				if (j == 0) {
					center_freqs_[0] = WUTR_CENTER_FREQ1 * (0.75 + (0.25 * noise_tick()));
					gains_[0] = Math.abs(noise_tick());
				} else if (j == 1) {
					center_freqs_[1] = WUTR_CENTER_FREQ1 * (1.0 + (0.25 * noise_tick()));
					gains_[1] = Math.abs(noise_tick());
				} else {
					center_freqs_[2] = WUTR_CENTER_FREQ1 * (1.25 + (0.25 * noise_tick()));
					gains_[2] = Math.abs(noise_tick());
				}
			}

			gains_[0] *= resons_[0];
			if (gains_[0] > 0.001) {
				center_freqs_[0] *= WUTR_FREQ_SWEEP;
				coeffs_[0][0] = -resons_[0] * 2.0 * Math.cos(center_freqs_[0] * TWO_PI / Stk.sampleRate());
			}
			gains_[1] *= resons_[1];
			if (gains_[1] > 0.001) {
				center_freqs_[1] *= WUTR_FREQ_SWEEP;
				coeffs_[1][0] = -resons_[1] * 2.0 * Math.cos(center_freqs_[1] * TWO_PI / Stk.sampleRate());
			}
			gains_[2] *= resons_[2];
			if (gains_[2] > 0.001) {
				center_freqs_[2] *= WUTR_FREQ_SWEEP;
				coeffs_[2][0] = -resons_[2] * 2.0 * Math.cos(center_freqs_[2] * TWO_PI / Stk.sampleRate());
			}

			sndLevel_ *= soundDecay_; // Each (all) event(s) 
			// decay(s) exponentially 
			inputs_[0] = sndLevel_;
			inputs_[0] *= noise_tick(); // Actual Sound is Random
			inputs_[1] = inputs_[0] * gains_[1];
			inputs_[2] = inputs_[0] * gains_[2];
			inputs_[0] *= gains_[0];
			inputs_[0] -= outputs_[0][0] * coeffs_[0][0];
			inputs_[0] -= outputs_[0][1] * coeffs_[0][1];
			outputs_[0][1] = outputs_[0][0];
			outputs_[0][0] = inputs_[0];
			data = gains_[0] * outputs_[0][0];
			inputs_[1] -= outputs_[1][0] * coeffs_[1][0];
			inputs_[1] -= outputs_[1][1] * coeffs_[1][1];
			outputs_[1][1] = outputs_[1][0];
			outputs_[1][0] = inputs_[1];
			data += gains_[1] * outputs_[1][0];
			inputs_[2] -= outputs_[2][0] * coeffs_[2][0];
			inputs_[2] -= outputs_[2][1] * coeffs_[2][1];
			outputs_[2][1] = outputs_[2][0];
			outputs_[2][0] = inputs_[2];
			data += gains_[2] * outputs_[2][0];

			finalZ_[2] = finalZ_[1];
			finalZ_[1] = finalZ_[0];
			finalZ_[0] = data * 4;

			data = finalZ_[2] - finalZ_[0];
			return data;
		}

		protected static var which:int = 0;

		protected function tbamb_tick():Number {
			var data:Number, temp:Number;
			var i:int;

			if (shakeEnergy_ > MIN_ENERGY) {
				shakeEnergy_ *= systemDecay_; // Exponential system decay
				if (float_random(1024.0) < nObjects_) {
					sndLevel_ += shakeEnergy_;
					which = my_random(7);
				}
				temp = sndLevel_ * noise_tick(); // Actual Sound is Random
				for (i = 0; i < nFreqs_; i++)
					inputs_[i] = 0;
				inputs_[which] = temp;
				sndLevel_ *= soundDecay_; // Exponential Sound decay 
				finalZ_[2] = finalZ_[1];
				finalZ_[1] = finalZ_[0];
				finalZ_[0] = 0;
				for (i = 0; i < nFreqs_; i++) {
					inputs_[i] -= outputs_[i][0] * coeffs_[i][0]; // Do
					inputs_[i] -= outputs_[i][1] * coeffs_[i][1]; // resonant
					outputs_[i][1] = outputs_[i][0]; // filter
					outputs_[i][0] = inputs_[i]; // calculations
					finalZ_[0] += gains_[i] * outputs_[i][1];
				}
				data = finalZCoeffs_[0] * finalZ_[0]; // Extra zero(s) for shape
				data += finalZCoeffs_[1] * finalZ_[1]; // Extra zero(s) for shape
				data += finalZCoeffs_[2] * finalZ_[2]; // Extra zero(s) for shape
				if (data > 10000.0)
					data = 10000.0;
				if (data < -10000.0)
					data = -10000.0;
				data = data * 0.0001;
			} else
				data = 0.0;
			return data;
		}

		protected function ratchet_tick():Number {
			var data:Number;
			if (my_random(1024) < nObjects_) {
				sndLevel_ += 512 * ratchet_ * totalEnergy_;
			}
			inputs_[0] = sndLevel_;
			inputs_[0] *= noise_tick() * ratchet_;
			sndLevel_ *= soundDecay_;

			inputs_[1] = inputs_[0];
			inputs_[0] -= outputs_[0][0] * coeffs_[0][0];
			inputs_[0] -= outputs_[0][1] * coeffs_[0][1];
			outputs_[0][1] = outputs_[0][0];
			outputs_[0][0] = inputs_[0];
			inputs_[1] -= outputs_[1][0] * coeffs_[1][0];
			inputs_[1] -= outputs_[1][1] * coeffs_[1][1];
			outputs_[1][1] = outputs_[1][0];
			outputs_[1][0] = inputs_[1];

			finalZ_[2] = finalZ_[1];
			finalZ_[1] = finalZ_[0];
			finalZ_[0] = gains_[0] * outputs_[0][1] + gains_[1] * outputs_[1][1];
			data = finalZ_[0] - finalZ_[2];
			return data;
		}

		protected var instType_:int
		protected var ratchetPos_:int, lastRatchetPos_:int
		protected var shakeEnergy_:Number
		protected var inputs_:Vector.<Number> = new Vector.<Number>(MAX_FREQS);
		protected var outputs_:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>(MAX_FREQS);
		protected var coeffs_:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>(MAX_FREQS);
		protected var sndLevel_:Number
		protected var baseGain_:Number
		protected var gains_:Vector.<Number> = new Vector.<Number>(MAX_FREQS);
		protected var nFreqs_:int
		protected var t_center_freqs_:Vector.<Number> = new Vector.<Number>(MAX_FREQS);
		protected var center_freqs_:Vector.<Number> = new Vector.<Number>(MAX_FREQS);
		protected var resons_:Vector.<Number> = new Vector.<Number>(MAX_FREQS);
		protected var freq_rand_:Vector.<Number> = new Vector.<Number>(MAX_FREQS);
		protected var freqalloc_:Vector.<int> = new Vector.<int>(MAX_FREQS);
		protected var soundDecay_:Number;
		protected var systemDecay_:Number;
		protected var nObjects_:Number;
		protected var totalEnergy_:Number;
		protected var ratchet_:Number, ratchetDelta_:Number;
		protected var finalZ_:Vector.<Number> = new Vector.<Number>(3);
		protected var finalZCoeffs_:Vector.<Number> = new Vector.<Number>(3);
		protected var defObjs_:Vector.<Number> = new Vector.<Number>(NUM_INSTR);
		protected var defDecays_:Vector.<Number> = new Vector.<Number>(NUM_INSTR);
		protected var decayScale_:Vector.<Number> = new Vector.<Number>(NUM_INSTR);
	}
}