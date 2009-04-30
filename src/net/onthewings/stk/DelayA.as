package net.onthewings.stk
{
	/***************************************************/
	/*! \class DelayA
			\brief STK allpass interpolating delay line class.
	
			This Delay subclass implements a fractional-length digital
			delay-line using a first-order allpass filter.	A fixed maximum
			length of 4095 and a delay of 0.5 is set using the default
			constructor.	Alternatively, the delay and maximum length can be
			set during instantiation with an overloaded constructor.
	
			An allpass filter has unity magnitude gain but variable phase
			delay properties, making it useful in achieving fractional delays
			without affecting a signal's frequency magnitude response.	In
			order to achieve a maximally flat phase delay response, the
			minimum delay possible in this implementation is limited to a
			value of 0.5.
	
			by Perry R. Cook and Gary P. Scavone, 1995 - 2007.
	*/
	/***************************************************/
	public class DelayA extends Delay
	{
		//! Default constructor creates a delay-line with maximum length of 4095 samples and zero delay.
		//! Overloaded constructor which specifies the current and maximum delay-line lengths.
		/*!
			An StkError will be thrown if the delay parameter is less than
			zero, the maximum delay parameter is less than one, or the delay
			parameter is greater than the maxDelay value.
		 */	
		public function DelayA(...args):void {
			super();
			
			if (!args || args.length == 0){
				this.setDelay( 0.5 );
				apInput_ = 0.0;
				doNextOut_ = true;
			} else {
				var delay:Number = args[0];
				var maxDelay:Number = args[1];
				
				if ( delay < 0.0 || maxDelay < 1 ) {
					errorString_ = "DelayA::DelayA: delay must be >= 0.0, maxDelay must be > 0!";
					handleError( StkError.FUNCTION_ARGUMENT );
				}
			
				if ( delay > maxDelay ) {
					errorString_ = "DelayA::DelayA: maxDelay must be > than delay argument!";
					handleError( StkError.FUNCTION_ARGUMENT );
				}
			
				// Writing before reading allows delays from 0 to length-1. 
				if ( maxDelay > inputs_.length-1 ) {
					inputs_.length = maxDelay+1 ;
					this.clear();
				}
			
				inPoint_ = 0;
				this.setDelay(delay);
				apInput_ = 0.0;
				doNextOut_ = true;
			}
		}
	
		//! Class destructor.
		public override function destruct():void {
			super.destruct();
		}
	
		//! Clears the internal state of the delay line.
		public override function clear():void {
			super.clear();
			apInput_ = 0.0;
		}
	
		//! Set the delay-line length
		/*!
			The valid range for \e theDelay is from 0.5 to the maximum delay-line length.
		*/
		public override function setDelay(delay:Number):void {
			var outPointer:Number;
			var length:Number = inputs_.length;
		
			if ( delay > inputs_.length - 1 ) { // The value is too big.
				errorString_ = "DelayA::setDelay: argument (" + delay + ") too big ... setting to maximum!";
				handleError( StkError.WARNING );
		
				// Force delay to maxLength
				outPointer = inPoint_ + 1.0;
				delay_ = length - 1;
			}
			else if (delay < 0.5) {
				errorString_ = "DelayA::setDelay: argument (" + delay + ") less than 0.5 not possible!";
				handleError( StkError.WARNING );
		
				outPointer = inPoint_ + 0.4999999999;
				delay_ = 0.5;
			}
			else {
				outPointer = inPoint_ - delay + 1.0;		 // outPoint chases inpoint
				delay_ = delay;
			}
		
			if (outPointer < 0)
				outPointer += length;	// modulo maximum length
		
			outPoint_ = Math.floor(outPointer);				 // integer part
			if ( outPoint_ == length ) outPoint_ = 0;
			alpha_ = 1.0 + outPoint_ - outPointer; // fractional part
		
			if (alpha_ < 0.5) {
				// The optimal range for alpha is about 0.5 - 1.5 in order to
				// achieve the flattest phase delay response.
				outPoint_ += 1;
				if (outPoint_ >= length) outPoint_ -= length;
				alpha_ += 1.0;
			}
		
			coeff_ = (1.0 - alpha_) / (1.0 + alpha_);				 // coefficient for all pass
		}
	
		//! Return the current delay-line length.
		public override function getDelay():Number {
			return delay_;
		}
	
		//! Return the value which will be output by the next call to tick().
		/*!
			This method is valid only for delay settings greater than zero!
		 */
		public override function nextOut():Number {
			if ( doNextOut_ ) {
				// Do allpass interpolation delay.
				nextOutput_ = -coeff_ * outputs_[0];
				nextOutput_ += apInput_ + (coeff_ * inputs_[outPoint_]);
				doNextOut_ = false;
			}
		
			return nextOutput_;
		}
	
		protected override function computeSample( input:Number ):Number {
			inputs_[inPoint_++] = input;

			// Increment input pointer modulo length.
			if (inPoint_ == inputs_.length)
				inPoint_ = 0;
		
			outputs_[0] = nextOut();
			doNextOut_ = true;
		
			// Save the allpass input and increment modulo length.
			apInput_ = inputs_[outPoint_++];
			if (outPoint_ == inputs_.length)
				outPoint_ = 0;
		
			return outputs_[0];
		}
	
		protected var alpha_:Number;
		protected var coeff_:Number;
		protected var apInput_:Number;
		protected var nextOutput_:Number;
		protected var doNextOut_:Boolean;
	}
}