package net.onthewings.stk
{
	/***************************************************/
	/*! \class Generator
    	\brief STK abstract unit generator parent class.

	    This class provides common functionality for
    	STK unit generator sample-source subclasses.

    	by Perry R. Cook and Gary P. Scavone, 1995 - 2007.
	*/
	/***************************************************/
	public class Generator extends Stk
	{
		//! Class constructor.
		public function Generator():void {
			super();
			lastOutput_ = 0.0;
		}

		//! Class destructor.
		public function destruct():void {
			
		}

		//! Return the last output value.
		public function lastOut():Number { 
			return lastOutput_; 
		};

		//! Compute one sample and output.
		//! Fill a channel of the StkFrames object with computed outputs.
		/*!
		  The \c channel argument should be zero or greater (the first
		  channel is specified by 0).  An StkError will be thrown if the \c
		  channel argument is equal to or greater than the number of
		  channels in the StkFrames object.
		*/
		public function tick( ...args ):* {
			if (!args || args.length == 0){
				return computeSample();
			} else {
				var frames:StkFrames = args[0];
				var channel:uint = 0;
				var i:uint;
				
				if (args[1]) {
					channel = args[1];
				}
				
				if ( channel >= frames.channels() ) {
					errorString_ = "Generator::tick(): channel and StkFrames arguments are incompatible!";
					handleError( StkError.FUNCTION_ARGUMENT );
				}
			
				if ( frames.channels() == 1 ) {
					for ( i=0; i<frames.frames(); ++i )
			    		frames[i] = computeSample();
				} else if ( frames.interleaved() ) {
					var hop:uint = frames.channels();
			    	var index:uint = channel;
			    	for ( i=0; i<frames.frames(); ++i ) {
			    		frames._squareBracket(index, computeSample());
			    		index += hop;
			  		}
				} else {
					var iStart:uint = channel * frames.frames();
					for ( i=0; i<frames.frames(); ++i, ++iStart )
						frames._squareBracket(iStart, computeSample());
				}
			
				return frames;
			}
		}

		// This abstract function must be implemented in all subclasses.
		// It is used to get around a C++ problem with overloaded virtual
		// functions.
		protected function computeSample():Number{
			return 0;
		}

		protected var lastOutput_:Number;
	}
}