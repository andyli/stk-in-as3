package net.onthewings.stk
{
	/***************************************************/
	/*! \class Instrmnt
	    \brief STK instrument abstract base class.
	
	    This class provides a common interface for
	    all STK instruments.
	
	    by Perry R. Cook and Gary P. Scavone, 1995 - 2007.
	*/
	/***************************************************/
	public class Instrmnt extends Stk
	{
		//! Default constructor.
		public function Instrmnt():void {
			super();
		}
		
		//! Class destructor.
		public function destruct():void {
			
		}

		//! Start a note with the given frequency and amplitude.
		public function noteOn(frequency:Number, amplitude:Number):void{
			
		}

		//! Stop a note with the given amplitude (speed of decay).
		public function noteOff(amplitude:Number):void {
			
		}

		//! Set instrument parameters for a particular frequency.
		public function setFrequency(frequency:Number):void {
			errorString_ = "Instrmnt::setFrequency: virtual setFrequency function call!";
			handleError( StkError.WARNING );
		}

		//! Return the last output value.
		public function lastOut():Number {
			return lastOutput_;
		}

		//! Return the last left output value.
		public function lastOutLeft():Number {
			return 0.5 * lastOutput_;
		}

		//! Return the last right output value.
		public function lastOutRight():Number {
			return 0.5 * lastOutput_;
		}

		//! Compute one sample and output.
		//! Fill a channel of the StkFrames object with computed outputs.
		/*!
    	The \c channel argument should be zero or greater (the first
    	channel is specified by 0).  An StkError will be thrown if the \c
    	channel argument is equal to or greater than the number of
    	channels in the StkFrames object.
		*/
		public function tick(... args):* {
			if (!args || args.length == 0) {
				return computeSample();
			} else {
				var frames:StkFrames = args[0];
				var channel:uint = 0;
				if (args[1]) {
					channel = args[1]
				}
				
				var i:uint;
				
				if ( channel >= frames.channels() ) {
				    errorString_ = "Instrmnt::tick(): channel and StkFrames arguments are incompatible!";
				    handleError( StkError.FUNCTION_ARGUMENT );
				}
				
				if ( frames.channels() == 1 ) {
				    for ( i = 0; i<frames.frames(); ++i )
						frames._squareBracket(i, tick());
				} else if ( frames.interleaved() ) {
				    var hop:uint = frames.channels();
				    var index:uint = channel;
				    for ( i = 0; i<frames.frames(); ++i ) {
				    	frames._squareBracket(index, tick());
				    	index += hop;
				    }
				} else {
				    var iStart:uint = channel * frames.frames();
				    for ( i = 0; i<frames.frames(); ++i, ++iStart )
				    	frames._squareBracket(iStart, tick());
				}
				
				return frames;
			}
		}

		//! Perform the control change specified by \e number and \e value (0.0 - 128.0).
		public function controlChange(number:int, value:Number):void {
			errorString_ = "Instrmnt::controlChange: virtual function call!";
			handleError( StkError.WARNING );
		}

		// This abstract function must be implemented in all subclasses.
		// It is used to get around a C++ problem with overloaded virtual
		// functions.
		protected function computeSample():Number {
			return 0;
		}

		protected var lastOutput_:Number;
	}
}