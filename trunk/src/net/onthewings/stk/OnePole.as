package net.onthewings.stk
{
	import __AS3__.vec.Vector;
	
	/***************************************************/
	/*! \class OnePole
			\brief STK one-pole filter class.
	
			This protected Filter subclass implements
			a one-pole digital filter.	A method is
			provided for setting the pole position along
			the real axis of the z-plane while maintaining
			a constant peak filter gain.
	
			by Perry R. Cook and Gary P. Scavone, 1995 - 2007.
	*/
	/***************************************************/
	public class OnePole extends Filter
	{
		//! Default constructor creates a first-order low-pass filter.
		//! Overloaded constructor which sets the pole position during instantiation.
		public function OnePole(...args):void {
			super();
			var a:Vector.<Number>;
			var b:Vector.<Number>;
			
			if (!args || args.length == 0){
				b = Vector.<Number>([0.1]);
				a = Vector.<Number>([1,1]);
				a[1] = -0.9;
				setCoefficients( b, a );
			} else {
				var thePole:Number = args[0];
				b = Vector.<Number>([0]);
				a = Vector.<Number>([1,1]);
				a[1] = -thePole;
			
				// Normalize coefficients for peak unity gain.
				if (thePole > 0.0)
					b[0] = 1.0 - thePole;
				else
					b[0] = 1.0 + thePole;
			
				setCoefficients( b, a );
			}
		}
	
		//! Class destructor.
		public override function destruct():void {
			super.destruct();
		}
	
		//! Clears the internal state of the filter.
		public override function clear():void {
			super.clear();
		}
	
		//! Set the b[0] coefficient value.
		public function setB0(b0:Number):void {
			b_[0] = b0;
		}
	
		//! Set the a[1] coefficient value.
		public function setA1(a1:Number):void {
			a_[1] = a1;
		}
	
		//! Set the pole position in the z-plane.
		/*!
			This method sets the pole position along the real-axis of the
			z-plane and normalizes the coefficients for a maximum gain of one.
			A positive pole value produces a low-pass filter, while a negative
			pole value produces a high-pass filter.	This method does not
			affect the filter \e gain value.
		*/
		public function setPole(thePole:Number):void {
			// Normalize coefficients for peak unity gain.
			if (thePole > 0.0)
				b_[0] = 1.0 - thePole;
			else
				b_[0] = 1.0 + thePole;
		
			a_[1] = -thePole;
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
			if (args.length == 1 && args[0] is Number){
				var input:Number = args[0];
				inputs_[0] = gain_ * input;
				if (outputs_.length < 2){
					outputs_.length = 2;
				}
				outputs_[0] = b_[0] * inputs_[0] - a_[1] * outputs_[1];
				outputs_[1] = outputs_[0];
			
				return outputs_[0];
			} else {
				var frames:StkFrames = args[0];
				var channel:uint = 0;
				if (args.length == 2){
					channel = args[1];
				}
				return super.tick(frames, channel);
			}
		}
	}
}