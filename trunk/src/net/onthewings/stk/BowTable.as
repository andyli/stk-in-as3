package net.onthewings.stk
{
	/***************************************************/
	/*! \class BowTable
			\brief STK bowed string table class.
	
			This class implements a simple bowed string
			non-linear function, as described by Smith (1986).
	
			by Perry R. Cook and Gary P. Scavone, 1995 - 2007.
	*/
	/***************************************************/
	public class BowTable extends _Function
	{
		//! Default constructor.
		public function BowTable():void	{
			super();
			offset_ = 0.0;
			slope_ = 0.1;
		}
	
		//! Class destructor.
		public override function destruct():void {
			super.destruct();
		}
	
		//! Set the table offset value.
		/*!
			The table offset is a bias which controls the
			symmetry of the friction.	If you want the
			friction to vary with direction, use a non-zero
			value for the offset.	The default value is zero.
		*/
		public function setOffset(offset:Number):void {
			offset_ = offset;
		}
	
		//! Set the table slope value.
		/*!
		 The table slope controls the width of the friction
		 pulse, which is related to bow force.
		*/
		public function setSlope(slope:Number):void {
			slope_ = slope;
		}
	
		protected override function computeSample( input:Number ):Number {
			// The input represents differential string vs. bow velocity.
			var sample:Number;
			sample = input + offset_;	// add bias to input
			sample *= slope_;					// then scale it
			lastOutput_ = Math.abs( sample ) + 0.75;
			lastOutput_ = Math.pow( lastOutput_, -4.0 );
		
			// Set minimum friction to 0.0
			// if (lastOutput < 0.0 ) lastOutput = 0.0;
			// Set maximum friction to 1.0.
			if (lastOutput_ > 1.0 ) lastOutput_ = 1.0;
		
			return lastOutput_;
		}
	
		protected var offset_:Number;
		protected var slope_:Number;
	}
}