package net.onthewings.stk {

	/*! \class Brass
	   \brief STK simple brass instrument class.

	   This class implements a simple brass instrument
	   waveguide model, a la Cook (TBone, HosePlayer).

	   This is a digital waveguide model, making its
	   use possibly subject to patents held by
	   Stanford University, Yamaha, and others.

	   Control Change Numbers:
	   - Lip Tension = 2
	   - Slide Length = 4
	   - Vibrato Frequency = 11
	   - Vibrato Gain = 1
	   - Volume = 128

	   by Perry R. Cook and Gary P. Scavone, 1995 - 2007.
	 */
	public class Brass extends Instrmnt {
		include "SKINI_msg.as"

		//! Class constructor, taking the lowest desired playing frequency.
		/*!
		   An StkError will be thrown if the rawwave path is incorrectly set.
		 */
		public function Brass(lowestFrequency:Number):void {
			super();

			length_ = Math.floor(Stk.sampleRate() / lowestFrequency + 1);
			delayLine_.setMaximumDelay(length_);
			delayLine_.setDelay(0.5 * length_);

			lipFilter_.setGain(0.03);
			dcBlock_.setBlockZero();

			adsr_.setAllTimes(0.005, 0.001, 1.0, 0.010);

			vibrato_.setFrequency(6.137);
			vibratoGain_ = 0.0;

			this.clear();
			maxPressure_ = 0.0;
			lipTarget_ = 0.0;

			// This is necessary to initialize variables.
			this.setFrequency(220.0);
		}

		//! Class destructor.
		public override function destruct():void {
			super.destruct();
		}

		//! Reset and clear all internal state.
		public function clear():void {
			delayLine_.clear();
			lipFilter_.clear();
			dcBlock_.clear();
		}

		//! Set instrument parameters for a particular frequency.
		public override function setFrequency(frequency:Number):void {
			var freakency:Number = frequency;
			if (frequency <= 0.0) {
				errorString_ = "Brass::setFrequency: parameter is less than or equal to zero!";
				handleError(StkError.WARNING);
				freakency = 220.0;
			}

			// Fudge correction for filter delays.
			slideTarget_ = (Stk.sampleRate() / freakency * 2.0) + 3.0;
			delayLine_.setDelay(slideTarget_); // play a harmonic

			lipTarget_ = freakency;
			lipFilter_.setResonance(freakency, 0.997);
		}

		//! Set the lips frequency.
		public function setLip(frequency:Number):void {
			var freakency:Number = frequency;
			if (frequency <= 0.0) {
				errorString_ = "Brass::setLip: parameter is less than or equal to zero!";
				handleError(StkError.WARNING);
				freakency = 220.0;
			}

			lipFilter_.setResonance(freakency, 0.997);
		}

		//! Apply breath pressure to instrument with given amplitude and rate of increase.
		public function startBlowing(amplitude:Number, rate:Number):void {
			adsr_.setAttackRate(rate);
			maxPressure_ = amplitude;
			adsr_.keyOn();
		}

		//! Decrease breath pressure with given rate of decrease.
		public function stopBlowing(rate:Number):void {
			adsr_.setReleaseRate(rate);
			adsr_.keyOff();
		}

		//! Start a note with the given frequency and amplitude.
		public override function noteOn(frequency:Number, amplitude:Number):void {
			this.setFrequency(frequency);
			this.startBlowing(amplitude, amplitude * 0.001);

			if (Stk._STK_DEBUG_) {
				errorString_ = "Brass::NoteOn: frequency = " + frequency + ", amplitude = " + amplitude + ".";
				handleError(StkError.DEBUG_WARNING);
			}
		}

		//! Stop a note with the given amplitude (speed of decay).
		public override function noteOff(amplitude:Number):void {
			this.stopBlowing(amplitude * 0.005);

			if (Stk._STK_DEBUG_) {
				errorString_ = "Brass::NoteOff: amplitude = " + amplitude + ".";
				handleError(StkError.DEBUG_WARNING);
			}
		}

		//! Perform the control change specified by \e number and \e value (0.0 - 128.0).
		public override function controlChange(number:int, value:Number):void {
			var norm:Number = value * ONE_OVER_128;
			if (norm < 0) {
				norm = 0.0;
				errorString_ = "Brass::controlChange: control value less than zero ... setting to zero!";
				handleError(StkError.WARNING);
			} else if (norm > 1.0) {
				norm = 1.0;
				errorString_ = "Brass::controlChange: control value greater than 128.0 ... setting to 128.0!";
				handleError(StkError.WARNING);
			}

			if (number == __SK_LipTension_) { // 2
				var temp:Number = lipTarget_ * Math.pow(4.0, (2.0 * norm) - 1.0);
				this.setLip(temp);
			} else if (number == __SK_SlideLength_) // 4
				delayLine_.setDelay(slideTarget_ * (0.5 + norm));
			else if (number == __SK_ModFrequency_) // 11
				vibrato_.setFrequency(norm * 12.0);
			else if (number == __SK_ModWheel_) // 1
				vibratoGain_ = norm * 0.4;
			else if (number == __SK_AfterTouch_Cont_) // 128
				adsr_.setTarget(norm);
			else {
				errorString_ = "Brass::controlChange: undefined control number (" + number + ")!";
				handleError(StkError.WARNING);
			}

			if (Stk._STK_DEBUG_) {
				errorString_ = "Brass::controlChange: number = " + number + ", value = " + value + ".";
				handleError(StkError.DEBUG_WARNING);
			}
		}

		protected override function computeSample():Number {
			var breathPressure:Number = maxPressure_ * adsr_.tick();
			breathPressure += vibratoGain_ * vibrato_.tick();

			var mouthPressure:Number = 0.3 * breathPressure;
			var borePressure:Number = 0.85 * delayLine_.lastOut();
			var deltaPressure:Number = mouthPressure - borePressure; // Differential pressure.
			deltaPressure = lipFilter_.tick(deltaPressure); // Force - > position.
			deltaPressure *= deltaPressure; // Basic position to area mapping.
			if (deltaPressure > 1.0)
				deltaPressure = 1.0; // Non-linear saturation.

			// The following input scattering assumes the mouthPressure = area.
			lastOutput_ = deltaPressure * mouthPressure + (1.0 - deltaPressure) * borePressure;
			lastOutput_ = delayLine_.tick(dcBlock_.tick(lastOutput_));

			return lastOutput_;
		}

		protected var delayLine_:DelayA = new DelayA();
		protected var lipFilter_:BiQuad = new BiQuad();
		protected var dcBlock_:PoleZero = new PoleZero();
		protected var adsr_:ADSR = new ADSR();
		protected var vibrato_:SineWave = new SineWave();
		protected var length_:Number;
		protected var lipTarget_:Number;
		protected var slideTarget_:Number;
		protected var vibratoGain_:Number;
		protected var maxPressure_:Number;
	}
}