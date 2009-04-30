package net.onthewings.stk
{
	//! STK error handling class.
	/*!
	  This is a fairly abstract exception handling class.  There could
	  be sub-classes to take care of more specific error conditions ... or
	  not.
	*/
	public class StkError
	{
		public static const STATUS:String = "STATUS";
		public static const WARNING:String = "WARNING";
	    public static const DEBUG_WARNING:String = "DEBUG_WARNING";
	    public static const MEMORY_ALLOCATION:String = "MEMORY_ALLOCATION";
	    public static const MEMORY_ACCESS:String = "MEMORY_ACCESS";
	    public static const FUNCTION_ARGUMENT:String = "FUNCTION_ARGUMENT";
	    public static const FILE_NOT_FOUND:String = "FILE_NOT_FOUND";
	    public static const FILE_UNKNOWN_FORMAT:String = "FILE_UNKNOWN_FORMAT";
	    public static const FILE_ERROR:String = "FILE_ERROR";
	    public static const PROCESS_THREAD:String = "PROCESS_THREAD";
	    public static const PROCESS_SOCKET:String = "PROCESS_SOCKET";
	    public static const PROCESS_SOCKET_IPADDR:String = "PROCESS_SOCKET_IPADDR";
	    public static const AUDIO_SYSTEM:String = "AUDIO_SYSTEM";
	    public static const MIDI_SYSTEM:String = "MIDI_SYSTEM";
	    public static const UNSPECIFIED:String = "UNSPECIFIED";
		
		protected var message_:String;
		protected var type_:String;
		
		//! The constructor.
		public function StkError(message:String, type:String = UNSPECIFIED) {
			message_ = message;
			type_ = type;
		}
		
		//! Prints thrown error message to stderr.
		public function printMessage():void { 
			trace(message_);
		}

		//! Returns the thrown error message type.
		public function getType():String { 
			return type_;
		}
		
		//! Returns the thrown error message string.
		public function getMessage():String {
			return message_;
		}
		
		//! Returns the thrown error message as a C string.
		public function getMessageCString():String {
			return message_;
		}
	}
}