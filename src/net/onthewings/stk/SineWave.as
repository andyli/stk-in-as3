package net.onthewings.stk
{
	/***************************************************/
	/*! \class SineWave
	    \brief STK sinusoid oscillator class.
	
	    This class computes and saves a static sine "table" that can be
	    shared by multiple instances.  It has an interface similar to the
	    WaveLoop class but inherits from the Generator class.  Output
	    values are computed using linear interpolation.
	
	    The "table" length, set in SineWave.h, is 2048 samples by default.
	
	    by Perry R. Cook and Gary P. Scavone, 1995 - 2007.
	*/
	/***************************************************/
	public class SineWave extends Generator
	{
		public static const TABLE_SIZE:Number = 2048;
		
		//! Default constructor.
		public function SineWave():void {
			super();
			
			time_ = 0.0;
			rate_ = 1.0;
			phaseOffset_ = 0.0;
			
			if ( table_.empty() ) {
				table_.resize( TABLE_SIZE + 1, 1 );
				var temp:Number = 1.0 / TABLE_SIZE;
				for ( var i:Number = 0; i<=TABLE_SIZE; ++i ) {
					table_._squareBracket(i, Math.sin( TWO_PI * i * temp ));
				}
			}

			super.addSampleRateAlert( this );
		}

		//! Class destructor.
		public override function destruct():void {
			super.removeSampleRateAlert( this );
			super.destruct();
		}

		//! Clear output and reset time pointer to zero.
		public function reset():void {
			time_ = 0.0;
			lastOutput_ = 0;
		}

		//! Set the data read rate in samples.  The rate can be negative.
		/*!
		  If the rate value is negative, the data is read in reverse order.
		*/
		public function setRate( rate:Number ):void { rate_ = rate; };

		//! Set the data interpolation rate based on a looping frequency.
		/*!
		 This function determines the interpolation rate based on the file
		 size and the current Stk::sampleRate.  The \e frequency value
		 corresponds to file cycles per second.  The frequency can be
		 negative, in which case the loop is read in reverse order.
		*/
		public function setFrequency( frequency:Number ):void {
			// This is a looping frequency.
			this.setRate( TABLE_SIZE * frequency / Stk.sampleRate() );
		}

		//! Increment the read pointer by \e time samples, modulo file size.
		public function addTime( time:Number ):void {
			// Add an absolute time in samples.
			time_ += time;

			while ( time_ < 0.0 )
				time_ += TABLE_SIZE;
			while ( time_ >= TABLE_SIZE )
				time_ -= TABLE_SIZE;
		}

		//! Increment current read pointer by \e angle, relative to a looping frequency.
		/*!
		  This function increments the read pointer based on the file
		  size and the current Stk::sampleRate.  The \e anAngle value
		  is a multiple of file size.
		 */
		public function addPhase( angle:Number ):void {
			// Add a time in cycles (one cycle = TABLE_SIZE).
			time_ += TABLE_SIZE * angle;

			while ( time_ < 0.0 )
				time_ += TABLE_SIZE;
			while ( time_ >= TABLE_SIZE )
				time_ -= TABLE_SIZE;
		}

		//! Add a phase offset to the current read pointer.
		/*!
		  This function determines a time offset based on the file
		  size and the current Stk::sampleRate.  The \e angle value
		  is a multiple of file size.
		*/
		public function addPhaseOffset( angle:Number ):void {
			// Add a phase offset in cycles, where 1.0 = TABLE_SIZE.
			phaseOffset_ = TABLE_SIZE * angle;
		}

		protected override function computeSample( ):Number {
			// Check limits of time address ... if necessary, recalculate modulo
			// TABLE_SIZE.
			while ( time_ < 0.0 )
				time_ += TABLE_SIZE;
			while ( time_ >= TABLE_SIZE )
				time_ -= TABLE_SIZE;

			var tyme:Number;
			if ( phaseOffset_ ) {
				tyme = time_ + phaseOffset_;
				while ( tyme < 0.0 )
					tyme += TABLE_SIZE;
				while ( tyme >= TABLE_SIZE )
					tyme -= TABLE_SIZE;
			} else {
				tyme = time_;
			}

			lastOutput_ = table_.interpolate( tyme );

			// Increment time, which can be negative.
			time_ += rate_;

			return lastOutput_;
		}
		protected override function sampleRateChanged( newRate:Number, oldRate:Number ):void {
			if ( !ignoreSampleRateChange_ )
				this.setRate( oldRate * rate_ / newRate );
		}

		protected static var table_:StkFrames = new StkFrames();
		protected var time_:Number;
		protected var rate_:Number;
		protected var phaseOffset_:Number;
	}
}