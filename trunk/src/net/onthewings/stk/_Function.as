package net.onthewings.stk
{
	/***************************************************/
	/*! \class Function
			\brief STK abstract function parent class.

			This class provides common functionality for STK classes which
			implement tables or other types of input to output function
			mappings.

			by Perry R. Cook and Gary P. Scavone, 1995 - 2007.
	*/
	/***************************************************/
	public class _Function extends Stk
	{
		//! Class constructor.
		public function _Function()
		{
			super();
			lastOutput_ = 0.0;
		}
		
		//! Class destructor.
		public function destruct():void {
			
		}

		//! Return the last output value.
		public function lastOut():Number { return lastOutput_; }

		//! Take one sample input and compute one sample of output.
		//! Take a channel of the StkFrames object as inputs to the function and replace with corresponding outputs.
		/*!
			The \c channel argument should be zero or greater (the first
			channel is specified by 0).	An StkError will be thrown if the \c
			channel argument is equal to or greater than the number of
			channels in the StkFrames object.
		*/
		public function tick( ...args ):*{
			if (args.length == 1 && args[0] is Number) {
				var input:Number = args[0];
				return computeSample( input );
			} else {
				var frames:StkFrames = args[0];
				var channel:uint = 0;
				
				var i:uint;
				if (args.length == 2) {
					channel = args[1];
				}
				if ( channel >= frames.channels() ) {
					errorString_ = "Function::tick(): channel and StkFrames arguments are incompatible!";
					handleError( StkError.FUNCTION_ARGUMENT );
				}

				if ( frames.channels() == 1 ) {
					for ( i=0; i<frames.frames(); i++ )
						frames._squareBracket(i, computeSample( frames._squareBracket(i) ));
				} else if ( frames.interleaved() ) {
					var hop:uint = frames.channels();
					var index:uint = channel;
					for ( i=0; i<frames.frames(); i++ ) {
						frames._squareBracket(index, computeSample( frames._squareBracket(index) ));
						index += hop;
					}
				} else {
					var iStart:uint = channel * frames.frames();
					for ( i=0; i<frames.frames(); i++, iStart++ )
						frames._squareBracket(iStart, computeSample( frames._squareBracket(iStart) ));
				}

				return frames;
			}
		}
		
		// This abstract function must be implemented in all subclasses.
		// It is used to get around a C++ problem with overloaded virtual
		// functions.
		protected function computeSample( input:Number ):Number {
			return 0;
		}

		protected var lastOutput_:Number;
	}
}