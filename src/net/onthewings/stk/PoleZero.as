package net.onthewings.stk
{
	import __AS3__.vec.Vector;
	
	public class PoleZero extends Filter
	{
		//! Default constructor creates a first-order pass-through filter.
		public function PoleZero():void {
			super();
			// Default setting for pass-through.
			var b:Vector.<Number> = Vector.<Number>([0,0]);
			var a:Vector.<Number> = Vector.<Number>([0,0]);
			b[0] = 1.0;
			a[0] = 1.0;
			setCoefficients( b, a );
		}
	
		//! Class destructor.
		public override function destruct():void {
			super.destruct();
		}
	
		//! Clears the internal states of the filter.
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
	
		//! Set the a[1] coefficient value.
		public function setA1(a1:Number):void {
			a_[1] = a1;
		}
	
		//! Set the filter for allpass behavior using \e coefficient.
		/*!
			This method uses \e coefficient to create an allpass filter,
			which has unity gain at all frequencies.	Note that the \e
			coefficient magnitude must be less than one to maintain stability.
		*/
		public function setAllpass(coefficient:Number):void {
			b_[0] = coefficient;
			b_[1] = 1.0;
			a_[0] = 1.0; // just in case
			a_[1] = coefficient;
		}
	
		//! Create a DC blocking filter with the given pole position in the z-plane.
		/*!
			This method sets the given pole position, together with a zero
			at z=1, to create a DC blocking filter.	\e thePole should be
			close to one to minimize low-frequency attenuation.
	
		*/
		public function setBlockZero(thePole:Number = 0.99):void {
			b_[0] = 1.0;
			b_[1] = -1.0;
			a_[0] = 1.0; // just in case
			a_[1] = -thePole;
		}
	
		//! Set the filter gain.
		/*!
			The gain is applied at the filter input and does not affect the
			coefficient values.	The default gain value is 1.0.
		 */
		public override function setGain( gain:Number ):void {
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
		public override function tick( ...args ):* {
			if (args.length == 1 && args[0] is Number){
				var input:Number = args[0];
				
				inputs_[0] = gain_ * input;
				if (inputs_.length < 2){
					inputs_.length = 2;
				}
				if (outputs_.length < 2){
					outputs_.length = 2;
				}
				outputs_[0] = b_[0] * inputs_[0] + b_[1] * inputs_[1] - a_[1] * outputs_[1];
				inputs_[1] = inputs_[0];
				outputs_[1] = outputs_[0];
			
				return outputs_[0];
			} else {
				return super.tick(args[0], args[1]);
			}
		}
	}
}