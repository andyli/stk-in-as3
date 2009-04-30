package net.onthewings.stk
{
	import __AS3__.vec.Vector;
	
	/***************************************************/
	/*! \class Filter
	    \brief STK filter class.
	
	    This class implements a generic structure that
	    can be used to create a wide range of filters.
	    It can function independently or be subclassed
	    to provide more specific controls based on a
	    particular filter type.
	
	    In particular, this class implements the standard
	    difference equation:
	
	    a[0]*y[n] = b[0]*x[n] + ... + b[nb]*x[n-nb] -
	                a[1]*y[n-1] - ... - a[na]*y[n-na]
	
	    If a[0] is not equal to 1, the filter coeffcients
	    are normalized by a[0].
	
	    The \e gain parameter is applied at the filter
	    input and does not affect the coefficient values.
	    The default gain value is 1.0.  This structure
	    results in one extra multiply per computed sample,
	    but allows easy control of the overall filter gain.
	
	    by Perry R. Cook and Gary P. Scavone, 1995 - 2007.
	*/
	/***************************************************/
	public class Filter extends Stk
	{
		//! Default constructor creates a zero-order pass-through "filter".
		//! Overloaded constructor which takes filter coefficients.
		/*!
			An StkError can be thrown if either of the coefficient vector
			sizes is zero, or if the a[0] coefficient is equal to zero.
		*/
		public function Filter(...args):void {
			super();
			
			if (!args || args.length == 0){
				// The default constructor should setup for pass-through.
				gain_ = 1.0;
				b_.push( 1.0 );
				a_.push( 1.0 );
	
				inputs_.push( 0.0 );
				outputs_.push( 0.0 );
			} else {
				var bCoefficients:Vector.<Number> = args[0];
				var aCoefficients:Vector.<Number> = args[1];
				
				// Check the arguments.
				if ( bCoefficients.length == 0 || aCoefficients.length == 0 ) {
					errorString_ = "Filter: a and b coefficient vectors must both have size > 0!";
					handleError( StkError.FUNCTION_ARGUMENT );
				}

				if ( aCoefficients[0] == 0.0 ) {
					errorString_ = "Filter: a[0] coefficient cannot == 0!";
					handleError( StkError.FUNCTION_ARGUMENT );
				}

				gain_ = 1.0;
				b_ = bCoefficients;
				a_ = aCoefficients;

				inputs_ = new Vector.<Number>(b_.length);
				outputs_ =new Vector.<Number>(a_.length);
				this.clear();
			}
		}

		//! Class destructor.
		public function destruct():void {
			
		}

		//! Sets all internal states of the filter to zero.
		public function clear():void {
			var i:uint;
			for (i=0; i<inputs_.length; ++i)
				inputs_[i] = 0.0;
			for (i=0; i<outputs_.length; ++i)
				outputs_[i] = 0.0;
		}

		//! Set filter coefficients.
		/*!
			An StkError can be thrown if either of the coefficient vector
			sizes is zero, or if the a[0] coefficient is equal to zero.  If
			a[0] is not equal to 1, the filter coeffcients are normalized by
			a[0].  The internal state of the filter is not cleared unless the
			\e clearState flag is \c true.
		*/
		public function setCoefficients( bCoefficients:Vector.<Number>, aCoefficients:Vector.<Number>, clearState:Boolean = false ):void {
			var i:uint;
			// Check the arguments.
			if ( bCoefficients.length == 0 || aCoefficients.length == 0 ) {
				errorString_ = "Filter::setCoefficients: a and b coefficient vectors must both have size > 0!";
				handleError( StkError.FUNCTION_ARGUMENT );
			}
			
			if ( aCoefficients[0] == 0.0 ) {
				errorString_ = "Filter::setCoefficients: a[0] coefficient cannot == 0!";
				handleError( StkError.FUNCTION_ARGUMENT );
			}

			if ( b_.length != bCoefficients.length ) {
				b_ = bCoefficients;
				inputs_.length = 0;
				inputs_ = new Vector.<Number>();
			} else {
				for ( i=0; i<b_.length; ++i ) b_[i] = bCoefficients[i];
			}

			if ( a_.length != aCoefficients.length ) {
				a_ = aCoefficients;
				outputs_.length = 0;
				outputs_ = new Vector.<Number>();
			} else {
				for ( i=0; i<a_.length; ++i ) a_[i] = aCoefficients[i];
			}

			if ( clearState ) this.clear();

			// Scale coefficients by a[0] if necessary
			if ( a_[0] != 1.0 ) {
				for ( i=0; i<b_.length; ++i ) b_[i] /= a_[0];
				for ( i=1; i<a_.length; ++i )  a_[i] /= a_[0];
			}
		}

		//! Set numerator coefficients.
		/*!
			An StkError can be thrown if coefficient vector is empty.  Any
			previously set denominator coefficients are left unaffected.  Note
			that the default constructor sets the single denominator
			coefficient a[0] to 1.0.  The internal state of the filter is not
			cleared unless the \e clearState flag is \c true.
		*/
		public function setNumerator( bCoefficients:Vector.<Number>, clearState:Boolean = false ):void {
			// Check the argument.
			if ( bCoefficients.length == 0 ) {
				errorString_ = "Filter::setNumerator: coefficient vector must have size > 0!";
				handleError( StkError.FUNCTION_ARGUMENT );
			}
		
			if ( b_.length != bCoefficients.length ) {
				b_ = bCoefficients;
				inputs_.length = 0;
				inputs_ = new Vector.<Number>();
			} else {
				for ( var i:uint=0; i<b_.length; ++i ) b_[i] = bCoefficients[i];
			}
		
			if ( clearState ) this.clear();
		}

		//! Set denominator coefficients.
		/*!
			An StkError can be thrown if the coefficient vector is empty or
			if the a[0] coefficient is equal to zero.	Previously set
			numerator coefficients are unaffected unless a[0] is not equal to
			1, in which case all coeffcients are normalized by a[0].	Note
			that the default constructor sets the single numerator coefficient
			b[0] to 1.0.	The internal state of the filter is not cleared
			unless the \e clearState flag is \c true.
		*/
		public function setDenominator( aCoefficients:Vector.<Number>, clearState:Boolean = false ):void {
			var i:uint;
			// Check the argument.
			if ( aCoefficients.length == 0 ) {
				errorString_ = "Filter::setDenominator: coefficient vector must have size > 0!";
				handleError( StkError.FUNCTION_ARGUMENT );
			}
		
			if ( aCoefficients[0] == 0.0 ) {
				errorString_ = "Filter::setDenominator: a[0] coefficient cannot == 0!";
				handleError( StkError.FUNCTION_ARGUMENT );
			}
		
			if ( a_.length != aCoefficients.length ) {
				a_ = aCoefficients;
				outputs_.length = 0;
				outputs_ = new Vector.<Number>();
			} else {
				for ( i=0; i<a_.length; ++i ) a_[i] = aCoefficients[i];
			}
		
			if ( clearState ) this.clear();
		
			// Scale coefficients by a[0] if necessary
			if ( a_[0] != 1.0 ) {
				for ( i=0; i<b_.length; ++i )	b_[i] /= a_[0];
				for ( i=1; i<a_.length; ++i )	a_[i] /= a_[0];
			}
		}

		//! Set the filter gain.
		/*!
			The gain is applied at the filter input and does not affect the
			coefficient values.	The default gain value is 1.0.
		 */
		public function setGain(gain:Number):void {
			gain_ = gain;
		}

		//! Return the current filter gain.
		public function getGain():Number {
			return gain_;
		}

		//! Return the last computed output value.
		public function lastOut():Number {
			if (outputs_.length == 0 || !outputs_[0]){ //sometime lastout is called even no tick is called...
				outputs_[0] = 0;
			}
			return outputs_[0];
		}

		//! Input one sample to the filter and return one output.
		//! Take a channel of the StkFrames object as inputs to the filter and replace with corresponding outputs.
		/*!
			The \c channel argument should be zero or greater (the first
			channel is specified by 0).	An StkError will be thrown if the \c
			channel argument is equal to or greater than the number of
			channels in the StkFrames object.
		*/
		public function tick( ...args ):* {
			var i:uint;
			if (args.length == 1 && args[0] is Number){
				var input:Number = args[0];

				outputs_[0] = 0.0;
				inputs_[0] = gain_ * input;
				for (i=b_.length-1; i>0; i--) {
					outputs_[0] += b_[i] * inputs_[i];
					inputs_[i] = inputs_[i-1];
				}
				outputs_[0] += b_[0] * inputs_[0];
			
				for (i=a_.length-1; i>0; i--) {
					outputs_[0] += -a_[i] * outputs_[i];
					outputs_[i] = outputs_[i-1];
				}
			
				return outputs_[0];
			} else {
				var frames:StkFrames = args[0];
				var channel:uint = 0;
				if (args.length == 2){
					channel = args[1];
				}
				
				if ( channel >= frames.channels() ) {
					errorString_ = "Filter::tick(): channel and StkFrames arguments are incompatible!";
					handleError( StkError.FUNCTION_ARGUMENT );
				}
			
				if ( frames.channels() == 1 ) {
					for ( i=0; i<frames.frames(); ++i )
						frames._squareBracket(i, tick( frames._squareBracket(i) ));
				} else if ( frames.interleaved() ) {
					var hop:uint = frames.channels();
					var index:uint = channel;
					for ( i=0; i<frames.frames(); ++i ) {
						frames._squareBracket(index, tick( frames._squareBracket(index) ));
						index += hop;
					}
				} else {
					var iStart:uint = channel * frames.frames();
					for ( i=0; i<frames.frames(); ++i, ++iStart )
						frames._squareBracket(iStart, tick( frames._squareBracket(iStart) ));
				}
			
				return frames;
			}
		}
	
		protected var gain_:Number;
		protected var b_:Vector.<Number> = new Vector.<Number>();
		protected var a_:Vector.<Number> = new Vector.<Number>();
		protected var outputs_:Vector.<Number> = new Vector.<Number>();
		protected var inputs_:Vector.<Number> = new Vector.<Number>();
	}
}