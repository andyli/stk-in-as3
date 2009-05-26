package net.onthewings.stk {

	/*! \class Resonate
	   \brief STK noise driven formant filter.

	   This instrument contains a noise source, which
	   excites a biquad resonance filter, with volume
	   controlled by an ADSR.

	   Control Change Numbers:
	   - Resonance Frequency (0-Nyquist) = 2
	   - Pole Radii = 4
	   - Notch Frequency (0-Nyquist) = 11
	   - Zero Radii = 1
	   - Envelope Gain = 128

	   by Perry R. Cook and Gary P. Scavone, 1995 - 2007.
	 */
	public class Resonate extends Instrmnt {
		include "SKINI_MSG.as"

		//! Class constructor.
		public function Resonate():void {
			super();
			poleFrequency_ = 4000.0;
			poleRadius_ = 0.95;
			// Set the filter parameters.
			filter_.setResonance(poleFrequency_, poleRadius_, true);
			zeroFrequency_ = 0.0;
			zeroRadius_ = 0.0;
		}

		//! Class destructor.
		public override function destruct():void {
			super.destruct();
		}

		//! Reset and clear all internal state.
		public function clear():void {

		}

		//! Set the filter for a resonance at the given frequency (Hz) and radius.
		public function setResonance(frequency:Number, radius:Number):void {
			poleFrequency_ = frequency;
			if (frequency < 0.0) {
				errorString_ += "Resonate::setResonance: frequency parameter is less than zero ... setting to 0.0!";
				handleError(StkError.WARNING);
				poleFrequency_ = 0.0;
			}

			poleRadius_ = radius;
			if (radius < 0.0) {
				errorString_ += "Resonate::setResonance: radius parameter is less than 0.0 ... setting to 0.0!";
				handleError(StkError.WARNING);
				poleRadius_ = 0.0;
			} else if (radius >= 1.0) {
				errorString_ += "Resonate::setResonance: radius parameter is greater than or equal to 1.0, which is unstable ... correcting!";
				handleError(StkError.WARNING);
				poleRadius_ = 0.9999;
			}
			filter_.setResonance(poleFrequency_, poleRadius_, true);
		}

		//! Set the filter for a notch at the given frequency (Hz) and radius.
		public function setNotch(frequency:Number, radius:Number):void {
			zeroFrequency_ = frequency;
			if (frequency < 0.0) {
				errorString_ += "Resonate::setNotch: frequency parameter is less than zero ... setting to 0.0!";
				handleError(StkError.WARNING);
				zeroFrequency_ = 0.0;
			}

			zeroRadius_ = radius;
			if (radius < 0.0) {
				errorString_ += "Resonate::setNotch: radius parameter is less than 0.0 ... setting to 0.0!";
				handleError(StkError.WARNING);
				zeroRadius_ = 0.0;
			}

			filter_.setNotch(zeroFrequency_, zeroRadius_);
		}

		//! Set the filter zero coefficients for contant resonance gain.
		public function setEqualGainZeroes():void {
			filter_.setEqualGainZeroes();
		}

		//! Initiate the envelope with a key-on event.
		public function keyOn():void {
			adsr_.keyOn();
		}

		//! Signal a key-off event to the envelope.
		public function keyOff():void {
			adsr_.keyOff();
		}

		//! Start a note with the given frequency and amplitude.
		public override function noteOn(frequency:Number, amplitude:Number):void {
			adsr_.setTarget(amplitude);
			keyOn();
			setResonance(frequency, poleRadius_);

			if (Stk._STK_DEBUG_) {
				errorString_ += "Resonate::NoteOn: frequency = " + frequency + ", amplitude = " + amplitude + '.';
				handleError(StkError.DEBUG_WARNING);
			}
		}

		//! Stop a note with the given amplitude (speed of decay).
		public override function noteOff(amplitude:Number):void {
			keyOff();

			if (Stk._STK_DEBUG_) {
				errorString_ += "Resonate::NoteOff: amplitude = " + amplitude + '.';
				handleError(StkError.DEBUG_WARNING);
			}
		}

		//! Perform the control change specified by \e number and \e value (0.0 - 128.0).
		public override function controlChange(number:int, value:Number):void {
			var norm:Number = value * ONE_OVER_128;
			if (norm < 0) {
				norm = 0.0;
				errorString_ += "Resonate::controlChange: control value less than zero ... setting to zero!";
				handleError(StkError.WARNING);
			} else if (norm > 1.0) {
				norm = 1.0;
				errorString_ += "Resonate::controlChange: control value greater than 128.0 ... setting to 128.0!";
				handleError(StkError.WARNING);
			}

			if (number == 2) // 2
				setResonance(norm * Stk.sampleRate() * 0.5, poleRadius_);
			else if (number == 4) // 4
				setResonance(poleFrequency_, norm * 0.9999);
			else if (number == 11) // 11
				setNotch(norm * Stk.sampleRate() * 0.5, zeroRadius_);
			else if (number == 1)
				setNotch(zeroFrequency_, norm);
			else if (number == __SK_AfterTouch_Cont_) // 128
				adsr_.setTarget(norm);
			else {
				errorString_ += "Resonate::controlChange: undefined control number (" + number + ")!";
				handleError(StkError.WARNING);
			}

			if (_STK_DEBUG_) {
				errorString_ += "Resonate::controlChange: number = " + number + ", value = " + value + '.';
				handleError(StkError.DEBUG_WARNING);
			}
		}


		protected override function computeSample():Number {
			lastOutput_ = filter_.tick(noise_.tick());
			lastOutput_ *= adsr_.tick();
			return lastOutput_;
		}

		protected var adsr_:ADSR = new ADSR();
		protected var filter_:BiQuad = new BiQuad();
		protected var noise_:Noise = new Noise();
		protected var poleFrequency_:Number;
		protected var poleRadius_:Number;
		protected var zeroFrequency_:Number;
		protected var zeroRadius_:Number;
	}
}