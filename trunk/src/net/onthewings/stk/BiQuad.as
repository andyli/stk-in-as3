package net.onthewings.stk
{
	import __AS3__.vec.Vector;
	
	/***************************************************/
	/*! \class BiQuad
			\brief STK biquad (two-pole, two-zero) filter class.
	
			This protected Filter subclass implements a
			two-pole, two-zero digital filter.	A method
			is provided for creating a resonance in the
			frequency response while maintaining a constant
			filter gain.
	
			by Perry R. Cook and Gary P. Scavone, 1995 - 2007.
	*/
	/***************************************************/
	public class BiQuad extends Filter
	{
		//! Default constructor creates a second-order pass-through filter.
		public function BiQuad():void {
			super();
			var b:Vector.<Number> = Vector.<Number>([0,0,0]);
			var a:Vector.<Number> = Vector.<Number>([0,0,0]);
			b[0] = 1.0;
			a[0] = 1.0;
			setCoefficients( b, a );
			addSampleRateAlert( this );
		}
	
		//! Class destructor.
		public override function destruct():void {
			removeSampleRateAlert(this);
			super.destruct();
		}
	
		//! A function to enable/disable the automatic updating of class data when the STK sample rate changes.
		public override function ignoreSampleRateChange( ignore:Boolean = true ):void { ignoreSampleRateChange_ = ignore; };
	
		//! Clears all internal states of the filter.
		public override function clear():void {
			super.clear();
		}
	
		//! Set the b[0] coefficient value.
		public function setB0(b0:Number):void {
			b_[0] = b0;
		}
	
		//! Set the b[1] coefficient value.
		public function setB1(b1:Number):void {
			b_[1] = b1;
		}
	
		//! Set the b[2] coefficient value.
		public function setB2(b2:Number):void {
			b_[2] = b2;
		}
	
		//! Set the a[1] coefficient value.
		public function setA1(a1:Number):void {
			a_[1] = a1;
		}
	
		//! Set the a[2] coefficient value.
		public function setA2(a2:Number):void {
			a_[2] = a2;
		}
	
		//! Sets the filter coefficients for a resonance at \e frequency (in Hz).
		/*!
			This method determines the filter coefficients corresponding to
			two complex-conjugate poles with the given \e frequency (in Hz)
			and \e radius from the z-plane origin.	If \e normalize is true,
			the filter zeros are placed at z = 1, z = -1, and the coefficients
			are then normalized to produce a constant unity peak gain
			(independent of the filter \e gain parameter).	The resulting
			filter frequency response has a resonance at the given \e
			frequency.	The closer the poles are to the unit-circle (\e radius
			close to one), the narrower the resulting resonance width.
		*/
		public function setResonance(frequency:Number, radius:Number, normalize:Boolean = false):void {
			a_[2] = radius * radius;
			a_[1] = -2.0 * radius * Math.cos(Stk.TWO_PI * frequency / Stk.sampleRate());
		
			if ( normalize ) {
				// Use zeros at +- 1 and normalize the filter peak gain.
				b_[0] = 0.5 - 0.5 * a_[2];
				b_[1] = 0.0;
				b_[2] = -b_[0];
			}
		}
	
		//! Set the filter coefficients for a notch at \e frequency (in Hz).
		/*!
			This method determines the filter coefficients corresponding to
			two complex-conjugate zeros with the given \e frequency (in Hz)
			and \e radius from the z-plane origin.	No filter normalization
			is attempted.
		*/
		public function setNotch(frequency:Number, radius:Number):void {
			// This method does not attempt to normalize the filter gain.
			b_[2] = radius * radius;
			b_[1] = -2.0 * radius * Math.cos(Stk.TWO_PI * frequency / Stk.sampleRate());
		}
	
		//! Sets the filter zeroes for equal resonance gain.
		/*!
			When using the filter as a resonator, zeroes places at z = 1, z
			= -1 will result in a constant gain at resonance of 1 / (1 - R),
			where R is the pole radius setting.
	
		*/
		public function setEqualGainZeroes():void {
			b_[0] = 1.0;
			b_[1] = 0.0;
			b_[2] = -1.0;
		}
	
		//! Set the filter gain.
		/*!
			The gain is applied at the filter input and does not affect the
			coefficient values.	The default gain value is 1.0.
		 */
		public override function setGain(gain:Number):void {
			super.setGain(gain);
		}
	
		//! Return the current filter gain.
		public override function getGain():Number {
			return super.getGain();
		}
	
		//! Return the last computed output value.
		public override function lastOut():Number {
			return super.lastOut();
		}
	
		//! Input one sample to the filter and return one output.
		//! Take a channel of the StkFrames object as inputs to the filter and replace with corresponding outputs.
		/*!
			The \c channel argument should be zero or greater (the first
			channel is specified by 0).	An StkError will be thrown if the \c
			channel argument is equal to or greater than the number of
			channels in the StkFrames object.
		*/
		public override function tick(...args):* {
			if (args.length == 1 && args[0] is Number) {
				var input:Number = args[0];
				return this.computeSample( input );
			} else {
				var frames:StkFrames = args[0];
				var channel:Number = 0;
				if (args.length == 2){
					channel = args[1];
				}
				return super.tick( frames, channel );
			}
		}

		// This function must be implemented in all subclasses. It is used
		// to get around a C++ problem with overloaded virtual functions.
		protected function computeSample( input:Number ):Number {
			inputs_[0] = gain_ * input;
			if (inputs_.length < 3){
				inputs_.length = 3;
			}
			outputs_[0] = b_[0] * inputs_[0] + b_[1] * inputs_[1] + b_[2] * inputs_[2];
			if (outputs_.length < 3){
				outputs_.length = 3;
			}
			outputs_[0] -= a_[2] * outputs_[2] + a_[1] * outputs_[1];
			inputs_[2] = inputs_[1];
			inputs_[1] = inputs_[0];
			outputs_[2] = outputs_[1];
			outputs_[1] = outputs_[0];
		
			return outputs_[0];
		}
		
		protected override function sampleRateChanged( newRate:Number, oldRate:Number ):void {
			if ( !ignoreSampleRateChange_ ) {
				errorString_ = "BiQuad::sampleRateChanged: you may need to recompute filter coefficients!";
				handleError( StkError.WARNING );
			}
		}
	}
}