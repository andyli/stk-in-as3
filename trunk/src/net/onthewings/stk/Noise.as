package net.onthewings.stk
{
	import com.gskinner.utils.Rndm;
	
	/***************************************************/
	/*! \class Noise
			\brief STK noise generator.
	
			Generic random number generation using the
			C rand() function.	The quality of the rand()
			function varies from one OS to another.
	
			by Perry R. Cook and Gary P. Scavone, 1995 - 2007.
	*/
	/***************************************************/
	public class Noise extends Generator
	{
		//! Default constructor which seeds the random number generator with the system time.
		//! Constructor which seeds the random number generator with a given seed.
		/*!
			If the seed value is zero, the random number generator is
			seeded with the system time.
		*/
		public function Noise(...args):void	{
			super();
			if (!args || args.length == 0){
				// Seed the random number generator with system time.
				this.setSeed( 0 );
				lastOutput_ = 0.0;
			} else {
				var seed:uint = args[0];
				// Seed the random number generator
				this.setSeed( seed );
				lastOutput_ = 0.0;
			}
		}
		
		//! Class destructor.
		public override function destruct():void{
			super.destruct();
		}
	
		//! Seed the random number generator with a specific seed value.
		/*!
			If no seed is provided or the seed value is zero, the random
			number generator is seeded with the current system time.
		*/
		public function setSeed( seed:uint = 0 ):void {
			if ( seed == 0 )
				Rndm.seed = new Date().getMilliseconds();
			else
				Rndm.seed = seed;
		}
	
		protected override function computeSample():Number {
			lastOutput_ = (2.0 * Rndm.float(0,RAND_MAX) / (RAND_MAX + 1.0) );
			lastOutput_ -= 1.0;
			return lastOutput_;
		}
		
		private const RAND_MAX:Number = 32767;
	}
}