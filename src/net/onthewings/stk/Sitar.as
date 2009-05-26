package net.onthewings.stk {

	/*! \class Sitar
	   \brief STK sitar string model class.

	   This class implements a sitar plucked string
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
	public class Sitar extends Instrmnt {
		//! Class constructor, taking the lowest desired playing frequency.
		public function Sitar(lowestFrequency:Number = 20):void {
			var length:Number = Math.floor(Stk.sampleRate() / lowestFrequency + 1);
			delayLine_.setMaximumDelay(length);
			delay_ = 0.5 * length;
			delayLine_.setDelay(delay_);
			targetDelay_ = delay_;

			loopFilter_.setZero(0.01);
			loopGain_ = 0.999;

			envelope_.setAllTimes(0.001, 0.04, 0.0, 0.5);
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
		}

		//! Set instrument parameters for a particular frequency.
		public override function setFrequency(frequency:Number):void {
			var freakency:Number = frequency;
			if (frequency <= 0.0) {
				errorString_ += "Sitar::setFrequency: parameter is less than or equal to zero!";
				handleError(StkError.WARNING);
				freakency = 220.0;
			}

			targetDelay_ = (Stk.sampleRate() / freakency);
			delay_ = targetDelay_ * (1.0 + (0.05 * noise_.tick()));
			delayLine_.setDelay(delay_);
			loopGain_ = 0.995 + (freakency * 0.0000005);
			if (loopGain_ > 0.9995)
				loopGain_ = 0.9995;
		}

		//! Pluck the string with the given amplitude using the current frequency.
		public function pluck(amplitude:Number):void {
			envelope_.keyOn();
		}

		//! Start a note with the given frequency and amplitude.
		public override function noteOn(frequency:Number, amplitude:Number):void {
			setFrequency(frequency);
			pluck(amplitude);
			amGain_ = 0.1 * amplitude;

			if (Stk._STK_DEBUG_) {
				errorString_ += "Sitar::NoteOn: frequency = " + frequency + ", amplitude = " + amplitude + ".";
				handleError(StkError.DEBUG_WARNING);
			}
		}

		//! Stop a note with the given amplitude (speed of decay).
		public override function noteOff(amplitude:Number):void {
			loopGain_ = 1.0 - amplitude;
			if (loopGain_ < 0.0) {
				errorString_ += "Sitar::noteOff: amplitude is greater than 1.0 ... setting to 1.0!";
				handleError(StkError.WARNING);
				loopGain_ = 0.0;
			} else if (loopGain_ > 1.0) {
				errorString_ += "Sitar::noteOff: amplitude is < 0.0  ... setting to 0.0!";
				handleError(StkError.WARNING);
				loopGain_ = 0.99999;
			}

			if (Stk._STK_DEBUG_) {
				errorString_ += "Sitar::NoteOff: amplitude = " + amplitude + ".";
				handleError(StkError.DEBUG_WARNING);
			}
		}


		protected override function computeSample():Number {
			if (Math.abs(targetDelay_ - delay_) > 0.001) {
				if (targetDelay_ < delay_)
					delay_ *= 0.99999;
				else
					delay_ *= 1.00001;
				delayLine_.setDelay(delay_);
			}

			lastOutput_ = delayLine_.tick(loopFilter_.tick(delayLine_.lastOut() * loopGain_) + (amGain_ * envelope_.tick() * noise_.tick()));

			return lastOutput_;
		}

		protected var delayLine_:DelayA = new DelayA();
		protected var loopFilter_:OneZero = new OneZero();
		protected var noise_:Noise = new Noise();
		protected var envelope_:ADSR = new ADSR();

		protected var loopGain_:Number;
		protected var amGain_:Number;
		protected var delay_:Number;
		protected var targetDelay_:Number;
	}
}