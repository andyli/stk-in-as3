package net.onthewings.stk {

	/*! \class BlowBotl
	   \brief STK blown bottle instrument class.

	   This class implements a helmholtz resonator
	   (biquad filter) with a polynomial jet
	   excitation (a la Cook).

	   Control Change Numbers:
	   - Noise Gain = 4
	   - Vibrato Frequency = 11
	   - Vibrato Gain = 1
	   - Volume = 128

	   by Perry R. Cook and Gary P. Scavone, 1995 - 2007.
	 */
	public class BlowBotl extends Instrmnt {
		include "SKINI_msg.as"

		public static const __BOTTLE_RADIUS_:Number = 0.999;

		//! Class constructor.
		/*!
		   An StkError will be thrown if the rawwave path is incorrectly set.
		 */
		public function BlowBotl() {
			super();
			dcBlock_.setBlockZero();

			vibrato_.setFrequency(5.925);
			vibratoGain_ = 0.0;

			resonator_.setResonance(500.0, __BOTTLE_RADIUS_, true);
			adsr_.setAllTimes(0.005, 0.01, 0.8, 0.010);

			noiseGain_ = 20.0;
			maxPressure_ = 0.0;
		}

		//! Class destructor.
		public override function destruct():void {
			super.destruct();
		}

		//! Reset and clear all internal state.
		public function clear():void {
			resonator_.clear();
		}

		//! Set instrument parameters for a particular frequency.
		public override function setFrequency(frequency:Number):void {
			var freakency:Number = frequency;
			if (frequency <= 0.0) {
				errorString_ = "BlowBotl::setFrequency: parameter is less than or equal to zero!";
				handleError(StkError.WARNING);
				freakency = 220.0;
			}

			resonator_.setResonance(freakency, __BOTTLE_RADIUS_, true);
		}

		//! Apply breath velocity to instrument with given amplitude and rate of increase.
		public function startBlowing(amplitude:Number, rate:Number):void {
			adsr_.setAttackRate(rate);
			maxPressure_ = amplitude;
			adsr_.keyOn();
		}

		//! Decrease breath velocity with given rate of decrease.
		public function stopBlowing(rate:Number):void {
			adsr_.setReleaseRate(rate);
			adsr_.keyOff();
		}

		//! Start a note with the given frequency and amplitude.
		public override function noteOn(frequency:Number, amplitude:Number):void {
			this.setFrequency(frequency);
			startBlowing(1.1 + (amplitude * 0.20), amplitude * 0.02);
			outputGain_ = amplitude + 0.001;

			if (Stk._STK_DEBUG_) {
				errorString_ = "BlowBotl::NoteOn: frequency = " + frequency + ", amplitude = " + amplitude + ".";
				handleError(StkError.DEBUG_WARNING);
			}
		}

		//! Stop a note with the given amplitude (speed of decay).
		public override function noteOff(amplitude:Number):void {
			this.stopBlowing(amplitude * 0.02);

			if (Stk._STK_DEBUG_) {
				errorString_ = "BlowBotl::NoteOff: amplitude = " + amplitude + ".";
				handleError(StkError.DEBUG_WARNING);
			}
		}

		//! Perform the control change specified by \e number and \e value (0.0 - 128.0).
		public override function controlChange(number:int, value:Number):void {
			var norm:Number = value * Stk.ONE_OVER_128;
			if (norm < 0) {
				norm = 0.0;
				errorString_ = "BlowBotl::controlChange: control value less than zero ... setting to zero!";
				handleError(StkError.WARNING);
			} else if (norm > 1.0) {
				norm = 1.0;
				errorString_ = "BlowBotl::controlChange: control value greater than 128.0 ... setting to 128.0!";
				handleError(StkError.WARNING);
			}

			if (number == __SK_NoiseLevel_) // 4
				noiseGain_ = norm * 30.0;
			else if (number == __SK_ModFrequency_) // 11
				vibrato_.setFrequency(norm * 12.0);
			else if (number == __SK_ModWheel_) // 1
				vibratoGain_ = norm * 0.4;
			else if (number == __SK_AfterTouch_Cont_) // 128
				adsr_.setTarget(norm);
			else {
				errorString_ = "BlowBotl::controlChange: undefined control number (" + number + ")!";
				handleError(StkError.WARNING);
			}

			if (Stk._STK_DEBUG_) {
				errorString_ = "BlowBotl::controlChange: number = " + number + ", value = " + value + ".";
				handleError(StkError.DEBUG_WARNING);
			}
		}

		protected override function computeSample():Number {
			var breathPressure:Number;
			var randPressure:Number;
			var pressureDiff:Number;

			// Calculate the breath pressure (envelope + vibrato)
			breathPressure = maxPressure_ * adsr_.tick();
			breathPressure += vibratoGain_ * vibrato_.tick();

			pressureDiff = breathPressure - resonator_.lastOut();

			randPressure = noiseGain_ * noise_.tick();
			randPressure *= breathPressure;
			randPressure *= (1.0 + pressureDiff);

			resonator_.tick(breathPressure + randPressure - (jetTable_.tick(pressureDiff) * pressureDiff));
			lastOutput_ = 0.2 * outputGain_ * dcBlock_.tick(pressureDiff);

			return lastOutput_;
		}

		protected var jetTable_:JetTable = new JetTable();
		protected var resonator_:BiQuad = new BiQuad();
		protected var dcBlock_:PoleZero = new PoleZero();
		protected var noise_:Noise = new Noise();
		protected var adsr_:ADSR = new ADSR();
		protected var vibrato_:SineWave = new SineWave();
		protected var maxPressure_:Number;
		protected var noiseGain_:Number;
		protected var vibratoGain_:Number;
		protected var outputGain_:Number;
	}
}