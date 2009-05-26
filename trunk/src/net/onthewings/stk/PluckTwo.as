package net.onthewings.stk {

	/*! \class PluckTwo
	   \brief STK enhanced plucked string model class.

	   This class implements an enhanced two-string,
	   plucked physical model, a la Jaffe-Smith,
	   Smith, and others.

	   PluckTwo is an abstract class, with no excitation
	   specified.  Therefore, it can't be directly
	   instantiated.

	   This is a digital waveguide model, making its
	   use possibly subject to patents held by
	   Stanford University, Yamaha, and others.

	   by Perry R. Cook and Gary P. Scavone, 1995 - 2007.
	 */
	public class PluckTwo extends Instrmnt {
		include "SKINI_MSG.as"

		//! Class constructor, taking the lowest desired playing frequency.
		public function PluckTwo(lowestFrequency:Number):void {
			super();
			length_ = Stk.sampleRate() / lowestFrequency + 1;
			lastLength_ = length_ * 0.5;
			delayLine_.setMaximumDelay(length_);
			delayLine_.setDelay(lastLength_);
			delayLine2_.setMaximumDelay(length_);
			delayLine2_.setDelay(lastLength_);
			combDelay_.setMaximumDelay(length_);
			combDelay_.setDelay(lastLength_);

			baseLoopGain_ = 0.995;
			loopGain_ = 0.999;
			pluckAmplitude_ = 0.3;
			pluckPosition_ = 0.4;
			detuning_ = 0.995;
			lastFrequency_ = lowestFrequency * 2.0;
		}

		//! Class destructor.
		public override function destruct():void {
			super.destruct();
		}

		//! Reset and clear all internal state.
		public function clear():void {
			delayLine_.clear();
			delayLine2_.clear();
			combDelay_.clear();
			filter_.clear();
			filter2_.clear();
		}

		//! Set instrument parameters for a particular frequency.
		public override function setFrequency(frequency:Number):void {
			lastFrequency_ = frequency;
			if (lastFrequency_ <= 0.0) {
				errorString_ += "Clarinet::setFrequency: parameter is less than or equal to zero!";
				handleError(StkError.WARNING);
				lastFrequency_ = 220.0;
			}

			// Delay = length - approximate filter delay.
			lastLength_ = Stk.sampleRate() / lastFrequency_;
			var delay:Number = (lastLength_ / detuning_) - 0.5;
			if (delay <= 0.0)
				delay = 0.3;
			else if (delay > length_)
				delay = length_;
			delayLine_.setDelay(delay);

			delay = (lastLength_ * detuning_) - 0.5;
			if (delay <= 0.0)
				delay = 0.3;
			else if (delay > length_)
				delay = length_;
			delayLine2_.setDelay(delay);

			loopGain_ = baseLoopGain_ + (frequency * 0.000005);
			if (loopGain_ > 1.0)
				loopGain_ = 0.99999;
		}

		//! Detune the two strings by the given factor.  A value of 1.0 produces unison strings.
		public function setDetune(detune:Number):void {
			detuning_ = detune;
			if (detuning_ <= 0.0) {
				errorString_ += "Clarinet::setDeturn: parameter is less than or equal to zero!";
				handleError(StkError.WARNING);
				detuning_ = 0.1;
			}
			delayLine_.setDelay((lastLength_ / detuning_) - 0.5);
			delayLine2_.setDelay((lastLength_ * detuning_) - 0.5);
		}

		//! Efficient combined setting of frequency and detuning.
		public function setFreqAndDetune(frequency:Number, detune:Number):void {
			detuning_ = detune;
			setFrequency(frequency);
		}

		//! Set the pluck or "excitation" position along the string (0.0 - 1.0).
		public function setPluckPosition(position:Number):void {
			pluckPosition_ = position;
			if (position < 0.0) {
				errorString_ += "PluckTwo::setPluckPosition: parameter is less than zero ... setting to 0.0!";
				handleError(StkError.WARNING);
				pluckPosition_ = 0.0;
			} else if (position > 1.0) {
				errorString_ += "PluckTwo::setPluckPosition: parameter is greater than one ... setting to 1.0!";
				handleError(StkError.WARNING);
				pluckPosition_ = 1.0;
			}
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

		//! Stop a note with the given amplitude (speed of decay).
		public override function noteOff(amplitude:Number):void {
			loopGain_ = (1.0 - amplitude) * 0.5;

			if (_STK_DEBUG_) {
				errorString_ += "PluckTwo::NoteOff: amplitude = " + amplitude + ".";
				handleError(StkError.DEBUG_WARNING);
			}
		}

		protected override function computeSample():Number {
			throw new Error();
			return 0;
		}

		protected var delayLine_:DelayA = new DelayA();
		protected var delayLine2_:DelayA = new DelayA();
		protected var combDelay_:DelayL = new DelayL();
		protected var filter_:OneZero = new OneZero();
		protected var filter2_:OneZero = new OneZero();

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
		protected var detuning_:Number;
		protected var pluckAmplitude_:Number;
		protected var pluckPosition_:Number;
	}
}