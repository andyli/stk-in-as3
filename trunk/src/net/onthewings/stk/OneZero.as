package net.onthewings.stk 
{
	import net.onthewings.stk.Filter;
	import net.onthewings.stk.StkFrames;
	
	/***************************************************/
	/*! \class OneZero
			\brief STK one-zero filter class.

			This protected Filter subclass implements
			a one-zero digital filter.	A method is
			provided for setting the zero position
			along the real axis of the z-plane while
			maintaining a constant filter gain.

			by Perry R. Cook and Gary P. Scavone, 1995 - 2007.
	*/
	/***************************************************/
	public class OneZero extends Filter
	{
		//! Default constructor creates a first-order low-pass filter.
		//! Overloaded constructor which sets the zero position during instantiation.
		public function OneZero(...args):void {
			var a:Vector.<Number>;
			var b:Vector.<Number>;
			if (args.length == 0) {
				b = Vector.<Number>([0.5,0.5]);
				a = Vector.<Number>([1]);
				setCoefficients( b, a );
			} else {
				var theZero:Number = args[0];
				b = new Vector.<Number>(2);
				a = Vector.<Number>([1]);

				// Normalize coefficients for unity gain.
				if (theZero > 0.0)
					b[0] = 1.0 / ( 1.0 + theZero);
				else
					b[0] = 1.0 / ( 1.0 - theZero);

				b[1] = -theZero * b[0];
				setCoefficients( b, a );
			}
		}
		
		//! Class destructor.
		public override function destruct():void 
		{
			super.destruct();
		}

		//! Clears the internal state of the filter.
		public override function clear():void 
		{
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

		//! Set the zero position in the z-plane.
		/*!
			This method sets the zero position along the real-axis of the
			z-plane and normalizes the coefficients for a maximum gain of one.
			A positive zero value produces a high-pass filter, while a
			negative zero value produces a low-pass filter.	This method does
			not affect the filter \e gain value.
		*/
		public function setZero(theZero:Number):void {
			// Normalize coefficients for unity gain.
			if (theZero > 0.0)
				b_[0] = 1.0 / ( 1.0 + theZero);
			else
				b_[0] = 1.0 / ( 1.0 - theZero);

			b_[1] = -theZero * b_[0];
		}

		//! Set the filter gain.
		/*!
			The gain is applied at the filter input and does not affect the
			coefficient values.	The default gain value is 1.0.
		 */
		public override function setGain(gain:Number):void 
		{
			super.setGain(gain);
		}

		//! Return the current filter gain.
		public override function getGain():Number 
		{
			return super.getGain();
		}

		//! Return the last computed output value.
		public override function lastOut():Number 
		{
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
		public override function tick(...args):* 
		{
			if (args.length == 1 && args[0] is Number) {
				var input:Number = args[0];
				
				inputs_[0] = gain_ * input;
				if (inputs_.length == 1){
					inputs_[1] = 0;
				}
				outputs_[0] = b_[1] * inputs_[1] + b_[0] * inputs_[0];
				inputs_[1] = inputs_[0];

				return outputs_[0];
			} else {
				var frames:StkFrames = args[0];
				var channel:uint = 0;
				if (args.length == 2) {
					channel = args[1];
				}
				return super.tick( frames, channel );
			}
		}
	}
	
}