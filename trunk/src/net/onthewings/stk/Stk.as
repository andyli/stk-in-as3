package net.onthewings.stk
{
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	public class Stk
	{	
		public static const STK_SINT8:uint = 0x1;   /*!< -128 to +127 */
		public static const STK_SINT16:uint = 0x2;  /*!< -32768 to +32767 */
		public static const STK_SINT24:uint = 0x4;  /*!< Upper 3 bytes of 32-bit signed integer. */
		public static const STK_SINT32:uint = 0x8;  /*!< -2147483648 to +2147483647. */
		public static const STK_FLOAT32:uint = 0x10; /*!< Normalized between plus/minus 1.0. */
		public static const STK_FLOAT64:uint = 0x20; /*!< Normalized between plus/minus 1.0. */
		
		//! Static method which returns the current STK sample rate.
		public static function sampleRate():Number {
			return srate_;
		}
		
		//! Static method that sets the STK sample rate.
		/*!
		The sample rate set using this method is queried by all STK
		classes which depend on its value.  It is initialized to the
  		default SRATE set in Stk.h.  Many STK classes use the sample rate
  		during instantiation.  Therefore, if you wish to use a rate which
  		is different from the default rate, it is imperative that it be
  		set \e BEFORE STK objects are instantiated.  A few classes that
  		make use of the global STK sample rate are automatically notified
  		when the rate changes so that internal class data can be
  		appropriately updated.  However, this has not been fully
  		implemented.  Specifically, classes that appropriately update
  		their own data when either a setFrequency() or noteOn() function
  		is called do not currently receive the automatic notification of
  		rate change.  If the user wants a specific class instance to
  		ignore such notifications, perhaps in a multi-rate context, the
  		function Stk::ignoreSampleRateChange() should be called.
  		*/
		public static function setSampleRate( rate:Number ):void{
			if ( rate > 0.0 && rate != srate_ ) {
		  		var oldRate:Number = srate_;
		  		srate_ = rate;
		
		  		for ( var i:uint = 0; i<alertList_.length; ++i )
		    		alertList_[i].sampleRateChanged( srate_, oldRate );
			}
		}
		
		//! A function to enable/disable the automatic updating of class data when the STK sample rate changes.
		/*!
  		This function allows the user to enable or disable class data
  		updates in response to global sample rate changes on a class by
  		class basis.
		*/
		public function ignoreSampleRateChange( ignore:Boolean = true ):void {
			ignoreSampleRateChange_ = ignore;
		}
		
		//! Static method which returns the current rawwave path.
		public static function rawwavePath():String {
			return rawwavepath_;
		}
		
		//! Static method which sets the STK rawwave path.
		public static function setRawwavePath( path:String ):void{
			if ( path && path.length>0 )
		  		rawwavepath_ = path;
		
			// Make sure the path includes a "/"
			if ( rawwavepath_[rawwavepath_.length-1] != '/' )
		  		rawwavepath_ += "/";
		}
		
		//! Static method which byte-swaps a 16-bit data type.
		public static function swap16( ptr:ByteArray ):void {			
			var oldPos:Number = ptr.position;
			// Swap 1st and 2nd bytes
			var val:uint = ptr.readDouble();
			var val2:uint = ptr.readDouble();
			ptr.position = oldPos;
			ptr.writeDouble(val2);
			ptr.writeDouble(val);
			ptr.position = oldPos;
		}
		
		//! Static method which byte-swaps a 32-bit data type.
		public static function swap32( ptr:ByteArray ):void {			
			var oldPos:Number = ptr.position;
			
			// Swap 1st and 4th bytes
			// Swap 2nd and 3rd bytes
			// That is 4 3 2 1
			var val:uint = ptr.readDouble();
			var val2:uint = ptr.readDouble();
			var val3:uint = ptr.readDouble();
			var val4:uint = ptr.readDouble();
			
			ptr.position = oldPos;
			ptr.writeUnsignedInt(val4);
			ptr.writeUnsignedInt(val3);
			ptr.writeUnsignedInt(val2);
			ptr.writeUnsignedInt(val);
			ptr.position = oldPos;
		}
		
		//! Static method which byte-swaps a 64-bit data type.
		public static function swap64( ptr:ByteArray ):void {
			var oldPos:Number = ptr.position;
			
			// Swap 1st and 8th bytes
			// Swap 2nd and 7th bytes
			// Swap 3rd and 6th bytes
			// Swap 4th and 5th bytes
			// That is 8 7 6 5 4 3 2 1
			var val:uint = ptr.readDouble();
			var val2:uint = ptr.readDouble();
			var val3:uint = ptr.readDouble();
			var val4:uint = ptr.readDouble();
			var val5:uint = ptr.readDouble();
			var val6:uint = ptr.readDouble();
			var val7:uint = ptr.readDouble();
			var val8:uint = ptr.readDouble();
			
			ptr.position = oldPos;
			ptr.writeDouble(val8);
			ptr.writeDouble(val7);
			ptr.writeDouble(val6);
			ptr.writeDouble(val5);
			ptr.writeDouble(val4);
			ptr.writeDouble(val3);
			ptr.writeDouble(val2);
			ptr.writeDouble(val);
			ptr.position = oldPos;
		}
		
		//! Static cross-platform method to sleep for a number of milliseconds.
  		public static function sleep(milliseconds:Number):void {
  			var startTime:int = getTimer();
			while (true) {
				if (getTimer() - startTime >= milliseconds) break;
			}
  		}
  		
  		//! Static function for error reporting and handling using c-strings.
		public static function handleError( ...args ):void {
			var type:String;
			if (args.length == 1){ //type:String
				type = args[0];
				
			} else if (args.length == 2){ //message:String, type:String
				type = args[1];
			}
			
			//check error type
			if (type == StkError.WARNING || type == StkError.STATUS) {
				if (!showWarnings_) return;
				trace(args)
			} else if (type == StkError.DEBUG_WARNING) {
				if (_STK_DEBUG_) {
					trace(args)
				}
			} else {
				if (printErrors_) {
					// Print error message before throwing.
					trace(args)
				}
				throw new Error(args[0] + " " + args[1]);
			}
		}
		
		//! Toggle display of WARNING and STATUS messages.
		public static function showWarnings( status:Boolean ):void {
			showWarnings_ = status;
		}
		
		//! Toggle display of error messages before throwing exceptions.
  		public static function printErrors( status:Boolean ):void {
  			printErrors_ = status;
  		}
  		
  		public static const _STK_DEBUG_:Boolean = false;
  		public static const SRATE:Number = 44100;
  		public static const RT_BUFFER_SIZE:uint = 512;
  		public static const RAWWAVE_PATH:String = "../../rawwaves/";
  		public static const PI:Number = Math.PI;
  		public static const TWO_PI:Number = Math.PI*2;
  		public static const ONE_OVER_128:Number = 0.0078125;
  		
  		private static var srate_:Number = SRATE;
  		private static var rawwavepath_:String = RAWWAVE_PATH;
		private static var showWarnings_:Boolean = true;
		private static var printErrors_:Boolean = true;
		private static var alertList_:Array = [];

		protected var errorString_:String;
		protected var ignoreSampleRateChange_:Boolean;
		
		public function Stk():void {
			ignoreSampleRateChange_ = false;
		}
		
		
		
		protected function sampleRateChanged( newRate:Number, oldRate:Number ):void
		{
		  // This function should be reimplemented in classes that need to
		  // make internal variable adjustments in response to a global sample
		  // rate change.
		}
		
		protected function addSampleRateAlert( ptr:Stk ):void
		{
			for ( var i:uint=0; i<alertList_.length; ++i )
				if ( alertList_[i] == ptr ) return;
		
			alertList_.push( ptr );
		}
		
		protected function removeSampleRateAlert( ptr:Stk ):void
		{
			for ( var i:uint=0; i<alertList_.length; ++i ) {
				if ( alertList_[i] == ptr ) {
					alertList_.erase( alertList_.begin() + i );
					return;
		    	}
			}
		}
	}
}
