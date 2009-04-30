package net.onthewings.stk
{
	import __AS3__.vec.Vector;
	
	/***************************************************/
	/*! \class StkFrames
    \brief An STK class to handle vectorized audio data.

    This class can hold single- or multi-channel audio data in either
    interleaved or non-interleaved formats.  The data type is always
    StkFloat.  In an effort to maintain efficiency, no out-of-bounds
    checks are performed in this class.

    Possible future improvements in this class could include functions
    to inter- or de-interleave the data and to convert to and return
    other data types.

    by Perry R. Cook and Gary P. Scavone, 1995 - 2007.
	*/
	/***************************************************/
	public class StkFrames
	{		
		//! The default constructor initializes the frame data structure to size zero.
		//! Overloaded constructor that initializes the frame data to the specified size with \c value.
		public function StkFrames( ...args ):void
		{
			var nFrames:uint = args[0];
			var nChannels:uint = args[1]; 
			var interleaved:Boolean = args[2];
			if (args.length == 3){
				nFrames = args[0];
				nChannels = args[1]; 
				interleaved = args[2];
				
				nFrames_ = nFrames;
				nChannels_ = nChannels;
				interleaved_ = interleaved;
				
				size_ = nFrames_ * nChannels_;
				bufferSize_ = size_;
			
				if ( size_ > 0 ) {
					data_ = new Vector.<Number>();
					data_.length = size_;
					if(Stk._STK_DEBUG_){
						if ( data_ == null ) {
					      	var error:String = "StkFrames: memory allocation error in constructor!";
					    	Stk.handleError( error, StkError.MEMORY_ALLOCATION );
					    }
					}
				} else {
					data_ = null;
				}
			
				dataRate_ = Stk.sampleRate();
			} else if (args.length == 4) {
				var value:Number = args[0];
				nFrames = args[1];
				nChannels = args[2];
				interleaved = args[3];
				
				nFrames_ = nFrames;
				nChannels_ = nChannels;
				interleaved_ = interleaved;
				
				size_ = nFrames_ * nChannels_;
				bufferSize_ = size_;
				if ( size_ > 0 ) {
					data_ = new Vector.<Number>();
					data_.length = size_;
					if(Stk._STK_DEBUG_) {
				    	if ( data_ == null ) {
					      Stk.handleError( "StkFrames: memory allocation error in constructor!", StkError.MEMORY_ALLOCATION );
					    }
					}
					
			    	for ( var i:Number = 0; i< size_; ++i ) {
			    		data_[i] = value;
			    	}
				} else {
					data_ = null;
				}
			
				dataRate_ = Stk.sampleRate();
			}
		}
		
		//! The destructor.
		public function destruct():void
		{
		  if ( data_ ) data_.length = 0;
		}
		
		//! Subscript operator which returns a reference to element \c n of self.
		/*!
		  The result can be used as an lvalue . This reference is valid
		  until the resize function is called or the array is destroyed. The
		  index \c n must be between 0 and size less one.  No range checking
		  is performed unless _STK_DEBUG_ is defined.
		*/
		public function _squareBracket(n:Number, value:Number = Number.NEGATIVE_INFINITY):Number {
			if (Stk._STK_DEBUG_){
				if ( n >= size_ ) {
			      var error:String = "StkFrames::operator[]: invalid index (" + n + ") value!";
			      Stk.handleError( error, StkError.MEMORY_ACCESS );
			    }
			}
			
			if (value != Number.NEGATIVE_INFINITY){
				data_[n] = value;
				return Number.NEGATIVE_INFINITY;
			} else {
				return data_[n];
			}
		}
		
		//! Channel / frame subscript operator that returns a reference.
		/*!
	  	The result can be used as an lvalue. This reference is valid
	  	until the resize function is called or the array is destroyed. The
	  	\c frame index must be between 0 and frames() - 1.  The \c channel
	  	index must be between 0 and channels() - 1.  No range checking is
	  	performed unless _STK_DEBUG_ is defined.
		*/
		public function _bracket(frame:uint, channel:uint, value:Number = Number.NEGATIVE_INFINITY):Number {
			if(Stk._STK_DEBUG_) {
			    if ( frame >= nFrames_ || channel >= nChannels_ ) {
			      var error:String = "StkFrames::operator(): invalid frame (" + frame + ") or channel (" + channel + ") value!";
			      Stk.handleError( error, StkError.MEMORY_ACCESS );
			    }
			}
			
			if (value == Number.NEGATIVE_INFINITY) {
				if ( interleaved_ ) {
					return data_[frame * nChannels_ + channel];
				} else {
					return data_[channel * nFrames_ + frame];
				}
			} else {
				if ( interleaved_ ) {
					data_[frame * nChannels_ + channel] = value;
				} else {
					data_[channel * nFrames_ + frame] = value;
				}
				return Number.NEGATIVE_INFINITY;
			}
		}
		
		//! Return an interpolated value at the fractional frame index and channel.
		/*!
		  This function performs linear interpolation.  The \c frame
		  index must be between 0.0 and frames() - 1.  The \c channel index
		  must be between 0 and channels() - 1.  No range checking is
		  performed unless _STK_DEBUG_ is defined.
		*/
		public function interpolate( frame:Number, channel:uint = 0 ):Number {
			if(Stk._STK_DEBUG_){
			    if ( frame >=  nFrames_ || channel >= nChannels_ ) {
			      var error:String = "StkFrames::interpolate: invalid frame (" + frame + ") or channel (" + channel + ") value!";
			      Stk.handleError( error, StkError.MEMORY_ACCESS );
			    }
			}
		
			var iIndex:uint = Math.floor(frame);                    // integer part of index
		  	var output:Number = frame - iIndex;			// fractional part of index
		  	var alpha:Number = frame - iIndex;			// fractional part of index
		
		  if ( interleaved_ ) {
		    iIndex = iIndex * nChannels_ + channel;
		    output = data_[iIndex];
		    output += ( alpha * ( data_[iIndex + nChannels_] - output ) );
		  } else {
		    iIndex += channel * nFrames_;
		    output = data_[iIndex]
		    output += ( alpha * ( data_[++iIndex] - output ) );
		  }
		
		  return output;
		}
		
		//! Returns the total number of audio samples represented by the object.
		public function size():uint { return size_; }; 
		
		//! Returns \e true if the object size is zero and \e false otherwise.
		public function empty():Boolean {
		  	return size_ <= 0;
		}
		
		//! Resize self to represent the specified number of channels and frames.
		/*!
  		Changes the size of self based on the number of frames and
  		channels.  No element assignment is performed.  No memory
  		deallocation occurs if the new size is smaller than the previous
    	size.  Further, no new memory is allocated when the new size is
    	smaller or equal to a previously allocated size.
  		*/
		public function resize( nFrames:uint, nChannels:uint = 1, value:Number = Number.NEGATIVE_INFINITY ):void
		{
			if (value == Number.NEGATIVE_INFINITY){
				nFrames_ = nFrames;
				nChannels_ = nChannels;
				
				size_ = nFrames_ * nChannels_;
				if ( size_ > bufferSize_ ) {
					if ( data_ ) data_.length = 0;
				    data_.length = size_;
					if(Stk._STK_DEBUG_){
					    if ( data_ == null ) {
					    	var error:String = "StkFrames::resize: memory allocation error!";
					    	Stk.handleError( error, StkError.MEMORY_ALLOCATION );
					    }
					}
			    	bufferSize_ = size_;
				}
			} else {
				resize( nFrames, nChannels );
				for ( var i:uint=0; i<size_; ++i ){
					data_[i] = value;
				}
			}
		}
		
		//! Return the number of channels represented by the data.
		public function channels():uint { return nChannels_; }
		
		//! Return the number of sample frames represented by the data.
		public function frames():uint { return nFrames_; }
		
		//! Set the sample rate associated with the StkFrames data.
		/*!
    	By default, this value is set equal to the current STK sample
    	rate at the time of instantiation.
   		*/
		public function setDataRate( rate:Number ):void { dataRate_ = rate; }
		
		//! Return the sample rate associated with the StkFrames data.
		/*!
  		By default, this value is set equal to the current STK sample
  		rate at the time of instantiation.
  		*/
		public function dataRate():Number { return dataRate_; }
		
		//! Returns \c true if the data is in interleaved format, \c false if the data is non-interleaved.
		public function interleaved():Boolean { return interleaved_; }
		
		//! Set the flag to indicate whether the internal data is in interleaved (\c true) or non-interleaved (\c false) format.
		/*!
    	Note that this function does not modify the internal data order
   		with respect to the argument value.  It simply changes the
    	indicator flag value.
   		*/
		public function setInterleaved( isInterleaved:Boolean ):void { interleaved_ = isInterleaved; }
		
		private var data_:Vector.<Number> = new Vector.<Number>();
		private var dataRate_:Number;
		private var nFrames_:uint;
		private var nChannels_:uint;
		private var size_:uint;
		private var bufferSize_:uint;
		private var interleaved_:Boolean;
	}
}