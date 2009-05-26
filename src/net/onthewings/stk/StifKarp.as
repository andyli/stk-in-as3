package net.onthewings.stk {

	/*! \class StifKarp
	   \brief STK plucked stiff string instrument.

	   This class implements a simple plucked string
	   algorithm (Karplus Strong) with enhancements
	   (Jaffe-Smith, Smith, and others), including
	   string stiffness and pluck position controls.
	   The stiffness is modeled with allpass filters.

	   This is a digital waveguide model, making its
	   use possibly subject to patents held by
	   Stanford University, Yamaha, and others.

	   Control Change Numbers:
	   - Pickup Position = 4
	   - String Sustain = 11
	   - String Stretch = 1

	   by Perry R. Cook and Gary P. Scavone, 1995 - 2007.
	 */
	public class StifKarp extends Instrmnt {
		include "SKINI_MSG.as"

		//! Class constructor, taking the lowest desired playing frequency.
		public function StifKarp(lowestFrequency:Number):void {
			for (var i:uint = 0; i < biquad_.length; ++i) {
				biquad_[i] = new BiQuad();
			}

			length_ = Stk.sampleRate() / lowestFrequency + 1;
			delayLine_.setMaximumDelay(length_);
			delayLine_.setDelay(0.5 * length_);
			combDelay_.setMaximumDelay(length_);
			combDelay_.setDelay(0.2 * length_);

			pluckAmplitude_ = 0.3;
			pickupPosition_ = 0.4;
			lastFrequency_ = lowestFrequency * 2.0;
			lastLength_ = length_ * 0.5;
			stretching_ = 0.9999;
			baseLoopGain_ = 0.995;
			loopGain_ = 0.999;

			clear();
		}

		//! Class destructor.
		public override function destruct():void {
			super.destruct();
		}

		//! Reset and clear all internal state.
		public function clear():void {
			delayLine_.clear();
			combDelay_.clear();
			filter_.clear();
		}

		//! Set instrument parameters for a particular frequency.
		public override function setFrequency(frequency:Number):void {
			lastFrequency_ = frequency;
			if (frequency <= 0.0) {
				errorString_ += "StifKarp::setFrequency: parameter is less than or equal to zero!";
				handleError(StkError.WARNING);
				lastFrequency_ = 220.0;
			}

			lastLength_ = Stk.sampleRate() / lastFrequency_;
			var delay:Number = lastLength_ - 0.5;
			if (delay <= 0.0)
				delay = 0.3;
			else if (delay > length_)
				delay = length_;
			delayLine_.setDelay(delay);

			loopGain_ = baseLoopGain_ + (frequency * 0.000005);
			if (loopGain_ >= 1.0)
				loopGain_ = 0.99999;

			setStretch(stretching_);

			combDelay_.setDelay(0.5 * pickupPosition_ * lastLength_);
		}

		//! Set the stretch "factor" of the string (0.0 - 1.0).
		public function setStretch(stretch:Number):void {
			stretching_ = stretch;
			var coefficient:Number;
			var freq:Number = lastFrequency_ * 2.0;
			var dFreq:Number = ((0.5 * Stk.sampleRate()) - freq) * 0.25;
			var temp:Number = 0.5 + (stretch * 0.5);
			if (temp > 0.9999)
				temp = 0.9999;
			for (var i:int = 0; i < 4; ++i) {
				coefficient = temp * temp;
				biquad_[i].setA2(coefficient);
				biquad_[i].setB0(coefficient);
				biquad_[i].setB2(1.0);

				coefficient = -2.0 * temp * Math.cos(TWO_PI * freq / Stk.sampleRate());
				biquad_[i].setA1(coefficient);
				biquad_[i].setB1(coefficient);

				freq += dFreq;
			}
		}

		//! Set the pluck or "excitation" position along the string (0.0 - 1.0).
		public function setPickupPosition(position:Number):void {
			pickupPosition_ = position;
			if (position < 0.0) {
				errorString_ += "StifKarp::setPickupPosition: parameter is less than zero ... setting to 0.0!";
				handleError(StkError.WARNING);
				pickupPosition_ = 0.0;
			} else if (position > 1.0) {
				errorString_ += "StifKarp::setPickupPosition: parameter is greater than 1.0 ... setting to 1.0!";
				handleError(StkError.WARNING);
				pickupPosition_ = 1.0;
			}

			// Set the pick position, which puts zeroes at position * length.
			combDelay_.setDelay(0.5 * pickupPosition_ * lastLength_);
		}

		//! Set the base loop gain.
		/*!
		   The actual loop gain is set according to the frequency.
		   Because of high-frequency loop filter roll-off, higher
		   frequency settings have greater loop gains.
		 */
		public function setBaseLoopGain(aGain:Number):void {
			baseLoopGain_ = aGain;
			loopGain_ = baseLoopGain_ + (lastFrequency_ * 0.000005);
			if (loopGain_ > 0.99999)
				loopGain_ = 0.99999;
		}

		//! Pluck the string with the given amplitude using the current frequency.
		public function pluck(amplitude:Number):void {
			var gain:Number = amplitude;
			if (gain > 1.0) {
				errorString_ += "StifKarp::pluck: amplitude is greater than 1.0 ... setting to 1.0!";
				handleError(StkError.WARNING);
				gain = 1.0;
			} else if (gain < 0.0) {
				errorString_ += "StifKarp::pluck: amplitude is less than zero ... setting to 0.0!";
				handleError(StkError.WARNING);
				gain = 0.0;
			}

			pluckAmplitude_ = amplitude;
			for (var i:Number = 0; i < length_; ++i) {
				// Fill delay with noise additively with current contents.
				delayLine_.tick((delayLine_.lastOut() * 0.6) + 0.4 * noise_.tick() * pluckAmplitude_);
					//delayLine_.tick( combDelay_.tick((delayLine_.lastOut() * 0.6) + 0.4 * noise->tick() * pluckAmplitude_) );
			}
		}

		//! Start a note with the given frequency and amplitude.
		public override function noteOn(frequency:Number, amplitude:Number):void {
			setFrequency(frequency);
			pluck(amplitude);

			if (Stk._STK_DEBUG_) {
				errorString_ += "StifKarp::NoteOn: frequency = " + frequency + ", amplitude = " + amplitude + ".";
				handleError(StkError.DEBUG_WARNING);
			}
		}

		//! Stop a note with the given amplitude (speed of decay).
		public override function noteOff(amplitude:Number):void {
			var gain:Number = amplitude;
			if (gain > 1.0) {
				errorString_ += "StifKarp::noteOff: amplitude is greater than 1.0 ... setting to 1.0!";
				handleError(StkError.WARNING);
				gain = 1.0;
			} else if (gain < 0.0) {
				errorString_ += "StifKarp::noteOff: amplitude is < 0.0  ... setting to 0.0!";
				handleError(StkError.WARNING);
				gain = 0.0;
			}
			loopGain_ = (1.0 - gain) * 0.5;

			if (Stk._STK_DEBUG_) {
				errorString_ += "StifKarp::NoteOff: amplitude = " + amplitude + ".";
				handleError(StkError.DEBUG_WARNING);
			}
		}

		//! Perform the control change specified by \e number and \e value (0.0 - 128.0).
		public override function controlChange(number:int, value:Number):void {
			var norm:Number = value * ONE_OVER_128;
			if (norm < 0) {
				norm = 0.0;
				errorString_ += "StifKarp::controlChange: control value less than zero ... setting to zero!";
				handleError(StkError.WARNING);
			} else if (norm > 1.0) {
				norm = 1.0;
				errorString_ += "StifKarp::controlChange: control value greater than 128.0 ... setting to 128.0!";
				handleError(StkError.WARNING);
			}

			if (number == __SK_PickPosition_) // 4
				setPickupPosition(norm);
			else if (number == __SK_StringDamping_) // 11
				setBaseLoopGain(0.97 + (norm * 0.03));
			else if (number == __SK_StringDetune_) // 1
				setStretch(0.9 + (0.1 * (1.0 - norm)));
			else {
				errorString_ += "StifKarp::controlChange: undefined control number (" + number + ")!";
				handleError(StkError.WARNING);
			}

			if (_STK_DEBUG_) {
				errorString_ += "StifKarp::controlChange: number = " + number + ", value = " + value + ".";
				handleError(StkError.DEBUG_WARNING);
			}
		}

		protected override function computeSample():Number {
			var temp:Number = delayLine_.lastOut() * loopGain_;

			// Calculate allpass stretching.
			for (var i:uint = 0; i < 4; ++i)
				temp = biquad_[i].tick(temp);

			// Moving average filter.
			temp = filter_.tick(temp);

			lastOutput_ = delayLine_.tick(temp);
			lastOutput_ = lastOutput_ - combDelay_.tick(lastOutput_);
			return lastOutput_;
		}

		protected var delayLine_:DelayA = new DelayA();
		protected var combDelay_:DelayL = new DelayL();
		protected var filter_:OneZero = new OneZero();
		protected var noise_:Noise = new Noise();
		protected var biquad_:Vector.<BiQuad> = new Vector.<BiQuad>(4);

		protected function get length_():Number {
			return _length_;
		}

		protected function set length_(l:Number):void {
			_length_ = Math.floor(l);
		}
		protected var _length_:Number;
		protected var loopGain_:Number;
		protected var baseLoopGain_:Number;
		protected var lastFrequency_:Number;
		protected var lastLength_:Number;
		protected var stretching_:Number;
		protected var pluckAmplitude_:Number;
		protected var pickupPosition_:Number;
	}
}