package net.onthewings.stk
{
	/***************************************************/
	/*! \class Delay
	    \brief STK non-interpolating delay line class.
	
	    This protected Filter subclass implements
	    a non-interpolating digital delay-line.
	    A fixed maximum length of 4095 and a delay
	    of zero is set using the default constructor.
	    Alternatively, the delay and maximum length
	    can be set during instantiation with an
	    overloaded constructor.
	    
	    A non-interpolating delay line is typically
	    used in fixed delay-length applications, such
	    as for reverberation.
	
	    by Perry R. Cook and Gary P. Scavone, 1995 - 2007.
	*/
	/***************************************************/
	public class Delay extends Filter
	{	
		//! Default constructor creates a delay-line with maximum length of 4095 samples and zero delay.
		//! Overloaded constructor which specifies the current and maximum delay-line lengths.
		/*!
			An StkError will be thrown if the delay parameter is less than
			zero, the maximum delay parameter is less than one, or the delay
			parameter is greater than the maxDelay value.
		 */
		public function Delay(...args):void {
			super();
			
			if (!args || args.length == 0){
				// Default maximum delay length set to 4095.
				inputs_.length = 4096;
				this.clear();
			
				inPoint_ = 0;
				outPoint_ = 0;
				delay_ = 0;
			} else {
				var delay:Number = args[0];
				var maxDelay:Number = args[1];
				
				// Writing before reading allows delays from 0 to length-1. 
				// If we want to allow a delay of maxDelay, we need a
				// delay-line of length = maxDelay+1.
				if ( maxDelay < 1 ) {
					errorString_ = "Delay::Delay: maxDelay must be > 0!\n";
					handleError( StkError.FUNCTION_ARGUMENT );
				}
			
				if ( delay > maxDelay ) {
					errorString_ = "Delay::Delay: maxDelay must be > than delay argument!\n";
					handleError( StkError.FUNCTION_ARGUMENT );
				}
			
				if ( maxDelay > inputs_.length-1 ) {
					inputs_.length = maxDelay+1;
					this.clear();
				}
			
				inPoint_ = 0;
				this.setDelay( delay );
			}
		}
	
		//! Class destructor.
		public override function destruct():void {
			super.destruct();
		}
	
		//! Clears the internal state of the delay line.
		public override function clear():void {
			for (var i:uint=0; i<inputs_.length; i++)
				inputs_[i] = 0.0;
			outputs_[0] = 0.0;
		}
	
		//! Set the maximum delay-line length.
		/*!
			This method should generally only be used during initial setup
			of the delay line.	If it is used between calls to the tick()
			function, without a call to clear(), a signal discontinuity will
			likely occur.	If the current maximum length is greater than the
			new length, no change will be made.
		*/
		public function setMaximumDelay(delay:Number):void {
			if ( delay < inputs_.length ) return;
		
			if ( delay < 0 ) {
				errorString_ = "Delay::setMaximumDelay: argument (" + delay + ") less than zero!\n";
				handleError( StkError.WARNING );
				return;
			} else if (delay < delay_ ) {
				errorString_ = "Delay::setMaximumDelay: argument (" + delay + ") less than current delay setting (" + delay_ + ")!\n";
				handleError( StkError.WARNING );
				return;
			}
		
			inputs_.length = delay + 1;
		}
	
		//! Set the delay-line length.
		/*!
			The valid range for \e theDelay is from 0 to the maximum delay-line length.
		*/
		public function setDelay(delay:Number):void {
			if ( delay > inputs_.length - 1 ) { // The value is too big.
				errorString_ = "Delay::setDelay: argument (" + delay + ") too big ... setting to maximum!\n";
				handleError( StkError.WARNING );
		
				// Force delay to maximum length.
				outPoint_ = inPoint_ + 1;
				if ( outPoint_ == inputs_.length ) outPoint_ = 0;
				delay_ = inputs_.length - 1;
			}
			else if ( delay < 0 ) {
				errorString_ = "Delay::setDelay: argument (" + delay + ") less than zero ... setting to zero!\n";
				handleError( StkError.WARNING );
		
				outPoint_ = inPoint_;
				delay_ = 0;
			}
			else { // read chases write
				if ( inPoint_ >= delay ) outPoint_ = inPoint_ - delay;
				else outPoint_ = inputs_.length + inPoint_ - delay;
				delay_ = delay;
			}
		}
	
		//! Return the current delay-line length.
		public function getDelay():Number {
			return delay_;
		}
	
		//! Calculate and return the signal energy in the delay-line.
		public function energy():Number {
			var i:Number;
			var e:Number = 0;
			var t:Number;
			if (inPoint_ >= outPoint_) {
				for (i=outPoint_; i<inPoint_; i++) {
					t = inputs_[i];
					e += t*t;
				}
			} else {
				for (i=outPoint_; i<inputs_.length; i++) {
					t = inputs_[i];
					e += t*t;
				}
				for (i=0; i<inPoint_; i++) {
					t = inputs_[i];
					e += t*t;
				}
			}
			return e;
		}
	
		//! Return the value at \e tapDelay samples from the delay-line input.
		/*!
			The tap point is determined modulo the delay-line length and is
			relative to the last input value (i.e., a tapDelay of zero returns
			the last input value).
		*/
		public function contentsAt(tapDelay:Number):Number {
			var i:Number = tapDelay;
			if (i < 1) {
				errorString_ = "Delay::contentsAt: argument (" + tapDelay + ") too small!";
				handleError( StkError.WARNING );
				return 0.0;
			}
			else if (i > delay_) {
				errorString_ = "Delay::contentsAt: argument (" + tapDelay + ") too big!";
				handleError( StkError.WARNING );
				return 0.0;
			}
		
			var tap:Number = inPoint_ - i;
			if (tap < 0) // Check for wraparound.
				tap += inputs_.length;
		
			return inputs_[tap];
		}
	
		//! Return the last computed output value.
		public override function lastOut():Number {
			return super.lastOut();
		}
	
		//! Return the value which will be output by the next call to tick().
		/*!
			This method is valid only for delay settings greater than zero!
		 */
		public function nextOut():Number {
			return inputs_[outPoint_];
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
				return computeSample( input );
			} else {
				var frames:StkFrames = args[0];
				var channel:uint = 0;
				if (args.length == 2){
					channel = args[1];
				}
				return super.tick(frames, channel);
			}
		}
		
		// This function must be implemented in all subclasses. It is used
		// to get around a C++ problem with overloaded virtual functions.
		protected function computeSample( input:Number ):Number {
			inputs_[inPoint_++] = input;

			// Check for end condition
			if (inPoint_ == inputs_.length)
				inPoint_ = 0;
		
			// Read out next value
			outputs_[0] = inputs_[outPoint_++];
		
			if (outPoint_ == inputs_.length)
				outPoint_ = 0;
		
			return outputs_[0];
		}
	
		protected var inPoint_:Number;
		protected function get outPoint_():Number{
			return outPoint__;
		}
		protected function set outPoint_(value:Number):void{
			outPoint__ = Math.floor(value);
		}
		protected var outPoint__:Number = 0;
		protected var delay_:Number;
	}
}