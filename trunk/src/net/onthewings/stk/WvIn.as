package net.onthewings.stk
{
	import mx.flash.UIMovieClip;
	
	/***************************************************/
	/*! \class WvIn
	    \brief STK audio input abstract base class.
	
	    This class provides common functionality for a variety of audio
	    data input subclasses.
	
	    WvIn supports multi-channel data.  It is important to distinguish
	    the tick() methods, which return samples produced by averaging
	    across sample frames, from the tickFrame() methods, which return
	    references or pointers to multi-channel sample frames.
	
	    Both interleaved and non-interleaved data is supported via the use
	    of StkFrames objects.
	
	    by Perry R. Cook and Gary P. Scavone, 1995 - 2007.
	*/
	/***************************************************/
	public class WvIn extends Stk
	{
		//! Default constructor.
		public function WvIn():void	{
			super();
		}
	
		//! Class destructor.
		public function destruct():void {
			
		}
	
		//! Return the number of audio channels in the data.
		public function getChannels():uint { 
			return data_.channels();
		}
	
		//! Return the average across the last output sample frame.
		/*!
			If no file data is loaded, the returned value is 0.0.
		*/
		public function lastOut():Number{
			if ( lastOutputs_.empty() ) return 0.0;

			if ( lastOutputs_.size() == 1 )
				return lastOutputs_._squareBracket(0);
		
			var output:Number = 0.0;
			for ( var i:uint=0; i<lastOutputs_.size(); i++ ) {
				output += lastOutputs_._squareBracket(i);
			}
			return output / lastOutputs_.size();
		}
	
		//! Return an StkFrames reference to the last output sample frame.
		/*!
			If no file data is loaded, an empty container is returned.
		 */
		public function lastFrame():StkFrames {
			return lastOutputs_;
		}
	
		//! Read out the average across one sample frame of data.
		/*!
			If no file data is loaded, the returned value is 0.0.
		*/
		//! Fill a channel of the StkFrames object with averaged sample frames.
		/*!
			The \c channel argument should be zero or greater (the first
			channel is specified by 0).	An StkError will be thrown if the \c
			channel argument is greater than or equal to the number of
			channels in the StkFrames object.	If no file data is loaded, the
			container is filled with zeroes.
		*/
		public function tick(...args):* {
			if (!args || args.length == 0){
				computeFrame();
				return lastOut();
			} else {
				var frames:StkFrames = args[0];
				var channel:uint = 0;
				var i:uint;
				
				if (args.length == 2){
					channel = args[1];
				}
				
				if ( channel >= frames.channels() ) {
					errorString_ = "WvIn::tick(): channel and StkFrames arguments are incompatible!";
					handleError( StkError.FUNCTION_ARGUMENT );
				}
			
				if ( frames.channels() == 1 ) {
					for ( i=0; i<frames.frames(); i++ )
						frames._squareBracket(i, tick());
				}
				else if ( frames.interleaved() ) {
					var hop:uint = frames.channels();
					var index:uint = channel;
					for ( i=0; i<frames.frames(); i++ ) {
						frames._squareBracket(index, tick());
						index += hop;
					}
				}
				else {
					var iStart:uint = channel * frames.frames();
					for ( i=0; i<frames.frames(); i++ )
						frames._squareBracket(iStart++, tick());
				}
			
				return frames;
			}
		}
		
		//! Fill the StkFrames argument with data and return the same reference.
		/*!
			An StkError will be thrown if there is an incompatability
			between the number of channels in the loaded data and that in the
			StkFrames argument.	If no file data is loaded, the container is
			filled with zeroes.
		*/
		public function tickFrame( frames:StkFrames ):StkFrames {
			var i:uint;
			var nChannels:uint = lastOutputs_.channels();
			if ( nChannels == 0 ) {
				errorString_ = "WvIn::tickFrame(): no data has been loaded!";
				handleError( StkError.WARNING );
				return frames;
			}
		
			if ( nChannels != frames.channels() ) {
				errorString_ = "WvIn::tickFrame(): incompatible channel value in StkFrames argument!";
				handleError( StkError.FUNCTION_ARGUMENT );
			}
		
			var j:uint;
			if ( nChannels == 1 || frames.interleaved() ) {
				var counter:uint = 0;
				for ( i=0; i<frames.frames(); i++ ) {
					this.computeFrame();
					for ( j=0; j<nChannels; j++ )
						frames._squareBracket(counter++, lastOutputs_._squareBracket(j));
				}
			}
			else { // non-interleaved data
				var hop:uint = frames.frames();
				var index:uint;
				for ( i=0; i<frames.frames(); i++ ) {
					this.computeFrame();
					index = i;
					for ( j=0; j<nChannels; j++ ) {
						frames._squareBracket(index, lastOutputs_._squareBracket(j));
						index += hop;
					}
				}
			}
		
			return frames;
		}
	
		// This abstract function must be implemented in all subclasses.
		// It is used to get around a C++ problem with overloaded virtual
		// functions.
		protected function computeFrame():void {
			
		}
	
		protected var data_:StkFrames;
		protected var lastOutputs_:StkFrames;
	}
}