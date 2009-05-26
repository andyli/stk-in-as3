package net.onthewings.stk {
	import __AS3__.vec.Vector;


	/*! \class Saxofony
	   \brief STK faux conical bore reed instrument class.

	   This class implements a "hybrid" digital
	   waveguide instrument that can generate a
	   variety of wind-like sounds.  It has also been
	   referred to as the "blowed string" model.  The
	   waveguide section is essentially that of a
	   string, with one rigid and one lossy
	   termination.  The non-linear function is a
	   reed table.  The string can be "blown" at any
	   point between the terminations, though just as
	   with strings, it is impossible to excite the
	   system at either end.  If the excitation is
	   placed at the string mid-point, the sound is
	   that of a clarinet.  At points closer to the
	   "bridge", the sound is closer to that of a
	   saxophone.  See Scavone (2002) for more details.

	   This is a digital waveguide model, making its
	   use possibly subject to patents held by Stanford
	   University, Yamaha, and others.

	   Control Change Numbers:
	   - Reed Stiffness = 2
	   - Reed Aperture = 26
	   - Noise Gain = 4
	   - Blow Position = 11
	   - Vibrato Frequency = 29
	   - Vibrato Gain = 1
	   - Breath Pressure = 128

	   by Perry R. Cook and Gary P. Scavone, 1995 - 2007.
	 */
	public class Saxofony extends Instrmnt {
		include "SKINI_MSG.as"

		//! Class constructor, taking the lowest desired playing frequency.
		/*!
		   An StkError will be thrown if the rawwave path is incorrectly set.
		 */
		public function Saxofony(lowestFrequency:Number):void {
			length_ = Stk.sampleRate() / lowestFrequency + 1;
			// Initialize blowing position to 0.2 of length / 2.
			position_ = 0.2;
			delays_[0] = new DelayL();
			delays_[0].setMaximumDelay(length_);
			delays_[0].setDelay((1.0 - position_) * (length_ >> 1));
			delays_[1] = new DelayL();
			delays_[1].setMaximumDelay(length_);
			delays_[1].setDelay((1.0 - position_) * (length_ >> 1));

			reedTable_.setOffset(0.7);
			reedTable_.setSlope(0.3);

			vibrato_.setFrequency(5.735);

			outputGain_ = 0.3;
			noiseGain_ = 0.2;
			vibratoGain_ = 0.1;
		}

		//! Class destructor.
		public override function destruct():void {
			super.destruct()
		}

		//! Reset and clear all internal state.
		public function clear():void {
			delays_[0].clear();
			delays_[1].clear();
			filter_.clear();
		}

		//! Set instrument parameters for a particular frequency.
		public override function setFrequency(frequency:Number):void {
			var freakency:Number = frequency;
			if (frequency <= 0.0) {
				errorString_ += "Saxofony::setFrequency: parameter is less than or equal to zero!";
				handleError(StkError.WARNING);
				freakency = 220.0;
			}

			var delay:Number = (Stk.sampleRate() / freakency) - 3.0;
			if (delay <= 0.0)
				delay = 0.3;
			else if (delay > length_)
				delay = length_;

			delays_[0].setDelay((1.0 - position_) * delay);
			delays_[1].setDelay(position_ * delay);
		}

		//! Set the "blowing" position between the air column terminations (0.0 - 1.0).
		public function setBlowPosition(position:Number):void {
			if (position_ == position)
				return;

			if (position < 0.0)
				position_ = 0.0;
			else if (position > 1.0)
				position_ = 1.0;
			else
				position_ = position;

			var totalDelay:Number = delays_[0].getDelay();
			totalDelay += delays_[1].getDelay();

			delays_[0].setDelay((1.0 - position_) * totalDelay);
			delays_[1].setDelay(position_ * totalDelay);
		}

		//! Apply breath pressure to instrument with given amplitude and rate of increase.
		public function startBlowing(amplitude:Number, rate:Number):void {
			envelope_.setRate(rate);
			envelope_.setTarget(amplitude);
		}

		//! Decrease breath pressure with given rate of decrease.
		public function stopBlowing(rate:Number):void {
			envelope_.setRate(rate);
			envelope_.setTarget(0.0);
		}

		//! Start a note with the given frequency and amplitude.
		public override function noteOn(frequency:Number, amplitude:Number):void {
			setFrequency(frequency);
			startBlowing(0.55 + (amplitude * 0.30), amplitude * 0.005);
			outputGain_ = amplitude + 0.001;

			if (_STK_DEBUG_) {
				errorString_ += "Saxofony::NoteOn: frequency = " + frequency + ", amplitude = " + amplitude + ".";
				handleError(StkError.DEBUG_WARNING);
			}
		}

		//! Stop a note with the given amplitude (speed of decay).
		public override function noteOff(amplitude:Number):void {
			stopBlowing(amplitude * 0.01);

			if (_STK_DEBUG_) {
				errorString_ += "Saxofony::NoteOff: amplitude = " + amplitude + ".";
				handleError(StkError.DEBUG_WARNING);
			}
		}

		//! Perform the control change specified by \e number and \e value (0.0 - 128.0).
		public override function controlChange(number:int, value:Number):void {
			var norm:Number = value * ONE_OVER_128;
			if (norm < 0) {
				norm = 0.0;
				errorString_ += "Saxofony::controlChange: control value less than zero ... setting to zero!";
				handleError(StkError.WARNING);
			} else if (norm > 1.0) {
				norm = 1.0;
				errorString_ += "Saxofony::controlChange: control value greater than 128.0 ... setting to 128.0!";
				handleError(StkError.WARNING);
			}

			if (number == __SK_ReedStiffness_) // 2
				reedTable_.setSlope(0.1 + (0.4 * norm));
			else if (number == __SK_NoiseLevel_) // 4
				noiseGain_ = (norm * 0.4);
			else if (number == 29) // 29
				vibrato_.setFrequency(norm * 12.0);
			else if (number == __SK_ModWheel_) // 1
				vibratoGain_ = (norm * 0.5);
			else if (number == __SK_AfterTouch_Cont_) // 128
				envelope_.setValue(norm);
			else if (number == 11) // 11
				setBlowPosition(norm);
			else if (number == 26) // reed table offset
				reedTable_.setOffset(0.4 + (norm * 0.6));
			else {
				errorString_ += "Saxofony::controlChange: undefined control number (" + number + ")!";
				handleError(StkError.WARNING);
			}

			if (_STK_DEBUG_) {
				errorString_ += "Saxofony::controlChange: number = " + number + ", value = " + value + ".";
				handleError(StkError.DEBUG_WARNING);
			}
		}


		protected override function computeSample():Number {
			var pressureDiff:Number, breathPressure:Number, temp:Number;

			// Calculate the breath pressure (envelope + noise + vibrato)
			breathPressure = envelope_.tick();
			breathPressure += breathPressure * noiseGain_ * noise_.tick();
			breathPressure += breathPressure * vibratoGain_ * vibrato_.tick();

			temp = -0.95 * filter_.tick(delays_[0].lastOut());
			lastOutput_ = temp - delays_[1].lastOut();
			pressureDiff = breathPressure - lastOutput_;
			delays_[1].tick(temp);
			delays_[0].tick(breathPressure - (pressureDiff * reedTable_.tick(pressureDiff)) - temp);

			lastOutput_ *= outputGain_;
			return lastOutput_;
		}

		protected var delays_:Vector.<DelayL> = new Vector.<DelayL>(2);
		protected var reedTable_:ReedTable = new ReedTable();
		protected var filter_:OneZero = new OneZero();
		protected var envelope_:Envelope = new Envelope();
		protected var noise_:Noise = new Noise();
		protected var vibrato_:SineWave = new SineWave();

		protected function get length_():Number {
			return _length_;
		}

		protected function set length_(l:Number):void {
			_length_ = Math.floor(l);
		}
		protected var _length_:Number;
		protected var outputGain_:Number;
		protected var noiseGain_:Number;
		protected var vibratoGain_:Number;
		protected var position_:Number;

	}
}