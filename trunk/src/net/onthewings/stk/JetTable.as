package net.onthewings.stk
{
	/***************************************************/
	/*! \class JetTable
			\brief STK jet table class.
	
			This class implements a flue jet non-linear
			function, computed by a polynomial calculation.
			Contrary to the name, this is not a "table".
	
			Consult Fletcher and Rossing, Karjalainen,
			Cook, and others for more information.
	
			by Perry R. Cook and Gary P. Scavone, 1995 - 2007.
	*/
	/***************************************************/
	public class JetTable extends _Function
	{
		//! Default constructor.
		public function JetTable()
		{
			super();
		}
	
		//! Class destructor.
		public override function destruct():void{
			super.destruct();
		}
	
		protected override function computeSample( input:Number ):Number{
			// Perform "table lookup" using a polynomial
			// calculation (x^3 - x), which approximates
			// the jet sigmoid behavior.
			lastOutput_ = input * (input * input - 1.0);
		
			// Saturate at +/- 1.0.
			if (lastOutput_ > 1.0) 
				lastOutput_ = 1.0;
			if (lastOutput_ < -1.0)
				lastOutput_ = -1.0; 
			return lastOutput_;
		}
	}
}