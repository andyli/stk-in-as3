package net.onthewings.stk {

	/*! \class Plucked
	   \brief STK plucked string model class.

	   This class implements a simple plucked string
	   physical model based on the Karplus-Strong
	   algorithm.

	   This is a digital waveguide model, making its
	   use possibly subject to patents held by
	   Stanford University, Yamaha, and others.
	   There exist at least two patents, assigned to
	   Stanford, bearing the names of Karplus and/or
	   Strong.

	   by Perry R. Cook and Gary P. Scavone, 1995 - 2007.
	 */
	public class Plucked extends Instrmnt {
		//! Class constructor, taking the lowest desired playing frequency.
		public function Plucked(lowestFrequency:Number) {
			super();
			length_ = Stk.sampleRate() / lowestFrequency + 1;
			loopGain_ = 0.999;
			delayLine_.setMaximumDelay(length_);
			delayLine_.setDelay(0.5 * length_);
			clear();
		}

		//! Class destructor.
		public override function destruct():void {
			super.destruct();
		}

		//! Reset and clear all internal state.
		public function clear():void {
			delayLine_.clear();
			loopFilter_.clear();
			pickFilter_.clear();
		}

		//! Set instrument parameters for a particular frequency.
		public override function setFrequency(frequency:Number):void {
			var freakency:Number = frequency;
			if (frequency <= 0.0) {
				errorString_ += "Plucked::setFrequency: parameter is less than or equal to zero!";
				handleError(StkError.WARNING);
				freakency = 220.0;
			}

			// Delay = length - approximate filter delay.
			var delay:Number = (Stk.sampleRate() / freakency) - 0.5;
			if (delay <= 0.0)
				delay = 0.3;
			else if (delay > length_)
				delay = length_;
			delayLine_.setDelay(delay);

			loopGain_ = 0.995 + (freakency * 0.000005);
			if (loopGain_ >= 1.0)
				loopGain_ = 0.99999;
		}

		//! Pluck the string with the given amplitude using the current frequency.
		public function pluck(amplitude:Number):void {
			var gain:Number = amplitude;
			if (gain > 1.0) {
				errorString_ += "Plucked::pluck: amplitude is greater than 1.0 ... setting to 1.0!";
				handleError(StkError.WARNING);
				gain = 1.0;
			} else if (gain < 0.0) {
				errorString_ += "Plucked::pluck: amplitude is < 0.0		... setting to 0.0!";
				handleError(StkError.WARNING);
				gain = 0.0;
			}

			pickFilter_.setPole(0.999 - (gain * 0.15));
			pickFilter_.setGain(gain * 0.5);
			for (var i:Number = 0; i < length_; ++i)
				// Fill delay with noise additively with current contents.
				delayLine_.tick(0.6 * delayLine_.lastOut() + pickFilter_.tick(noise_.tick()));
		}

		//! Start a note with the given frequency and amplitude.
		public override function noteOn(frequency:Number, amplitude:Number):void {
			setFrequency(frequency);
			pluck(amplitude);

			if (Stk._STK_DEBUG_) {
				errorString_ += "Plucked::NoteOn: frequency = " + frequency + ", amplitude = " + amplitude + ".";
				handleError(StkError.DEBUG_WARNING);
			}
		}

		//! Stop a note with the given amplitude (speed of decay).
		public override function noteOff(amplitude:Number):void {
			loopGain_ = 1.0 - amplitude;
			if (loopGain_ < 0.0) {
				errorString_ += "Plucked::noteOff: amplitude is greater than 1.0 ... setting to 1.0!";
				handleError(StkError.WARNING);
				loopGain_ = 0.0;
			} else if (loopGain_ > 1.0) {
				errorString_ += "Plucked::noteOff: amplitude is < 0.0		... setting to 0.0!";
				handleError(StkError.WARNING);
				loopGain_ = 0.99999;
			}

			if (Stk._STK_DEBUG_) {
				errorString_ += "Plucked::NoteOff: amplitude = " + amplitude + ".";
				handleError(StkError.DEBUG_WARNING);
			}
		}


		protected override function computeSample():Number {
			// Here's the whole inner loop of the instrument!!
			lastOutput_ = delayLine_.tick(loopFilter_.tick(delayLine_.lastOut() * loopGain_));
			lastOutput_ *= 3.0;
			return lastOutput_;
		}

		protected var delayLine_:DelayA = new DelayA();
		protected var loopFilter_:OneZero = new OneZero();
		protected var pickFilter_:OnePole = new OnePole();
		protected var noise_:Noise = new Noise();
		protected var loopGain_:Number;

		protected function get length_():Number {
			return _length_;
		}

		protected function set length_(len:Number):void {
			_length_ = Math.floor(len);
		}
		protected var _length_:Number;
	}
}