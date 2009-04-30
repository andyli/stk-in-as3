package net.onthewings.stk 
{
	import net.onthewings.stk._Function;
	
	/***************************************************/
	/*! \class ReedTable
			\brief STK reed table class.

			This class implements a simple one breakpoint,
			non-linear reed function, as described by
			Smith (1986).	This function is based on a
			memoryless non-linear spring model of the reed
			(the reed mass is ignored) which saturates when
			the reed collides with the mouthpiece facing.

			See McIntyre, Schumacher, & Woodhouse (1983),
			Smith (1986), Hirschman, Cook, Scavone, and
			others for more information.

			by Perry R. Cook and Gary P. Scavone, 1995 - 2007.
	*/
	/***************************************************/
	public class ReedTable extends _Function
	{
		//! Default constructor.
		public function ReedTable() 
		{
			super();
			offset_ = 0.6;	// Offset is a bias, related to reed rest position.
			slope_ = -0.8;	// Slope corresponds loosely to reed stiffness.
		}

		//! Class destructor.
		public override function destruct():void 
		{
			super.destruct();
		}

		//! Set the table offset value.
		/*!
			The table offset roughly corresponds to the size
			of the initial reed tip opening (a greater offset
			represents a smaller opening).
		*/
		public function setOffset(offset:Number):void {
			offset_ = offset;
		}

		//! Set the table slope value.
		/*!
		 The table slope roughly corresponds to the reed
		 stiffness (a greater slope represents a harder
		 reed).
		*/
		public function setSlope(slope:Number):void {
			slope_ = slope;
		}

		protected override function computeSample( input:Number ):Number {
			// The input is differential pressure across the reed.
			lastOutput_ = offset_ + (slope_ * input);

			// If output is > 1, the reed has slammed shut and the
			// reflection function value saturates at 1.0.
			if (lastOutput_ > 1.0) lastOutput_ = 1.0;

			// This is nearly impossible in a physical system, but
			// a reflection function value of -1.0 corresponds to
			// an open end (and no discontinuity in bore profile).
			if (lastOutput_ < -1.0) lastOutput_ = -1.0;
			return lastOutput_;
		}

		protected var offset_:Number;
		protected var slope_:Number;
	}
	
}