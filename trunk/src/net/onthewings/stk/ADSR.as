package net.onthewings.stk
{
	/***************************************************/
	/*! \class ADSR
			\brief STK ADSR envelope class.
	
			This Envelope subclass implements a
			traditional ADSR (Attack, Decay,
			Sustain, Release) envelope.	It
			responds to simple keyOn and keyOff
			messages, keeping track of its state.
			The \e state = ADSR::DONE after the
			envelope value reaches 0.0 in the
			ADSR::RELEASE state.
	
			by Perry R. Cook and Gary P. Scavone, 1995 - 2007.
	*/
	/***************************************************/
	public class ADSR extends Envelope
	{
		//! Envelope states.
		public static const ATTACK:int = 1;
		public static const DECAY:int = 2;
		public static const SUSTAIN:int = 3;
		public static const RELEASE:int = 4;
		public static const DONE:int = 5;
		
		//! Default constructor.
		public function ADSR()
		{
			super();
			target_ = 0.0;
			value_ = 0.0;
			attackRate_ = 0.001;
			decayRate_ = 0.001;
			sustainLevel_ = 0.5;
			releaseRate_ = 0.01;
			state_ = ATTACK;
		}
		
		//! Class destructor.
		public override function destruct():void{
			super.destruct();
		}
	
		//! Set target = 1, state = \e ADSR::ATTACK.
		public override function keyOn():void{
			target_ = 1.0;
			rate_ = attackRate_;
			state_ = ATTACK;
		}
	
		//! Set target = 0, state = \e ADSR::RELEASE.
		public override function keyOff():void {
			target_ = 0.0;
			rate_ = releaseRate_;
			state_ = RELEASE;
		}
	
		//! Set the attack rate.
		public function setAttackRate(rate:Number):void {
			if (rate < 0.0) {
				errorString_ = "ADSR::setAttackRate: negative rates not allowed ... correcting!";
				handleError( StkError.WARNING );
				attackRate_ = -rate;
			} else {
				attackRate_ = rate;
			}
		}
	
		//! Set the decay rate.
		public function setDecayRate(rate:Number):void {
			if (rate < 0.0) {
				errorString_ = "ADSR::setDecayRate: negative rates not allowed ... correcting!";
				handleError( StkError.WARNING );
				decayRate_ = -rate;
			} else {
				decayRate_ = rate;
			}
		}
	
		//! Set the sustain level.
		public function setSustainLevel(level:Number):void {
			if (level < 0.0 ) {
				errorString_ = "ADSR::setSustainLevel: level out of range ... correcting!";
				handleError( StkError.WARNING );
				sustainLevel_ = 0.0;
			} else {
				sustainLevel_ = level;
			}
		}
	
		//! Set the release rate.
		public function setReleaseRate(rate:Number):void {
			if (rate < 0.0) {
				errorString_ = "ADSR::setReleaseRate: negative rates not allowed ... correcting!";
				handleError( StkError.WARNING );
				releaseRate_ = -rate;
			} else {
				releaseRate_ = rate;
			}
		}
	
		//! Set the attack rate based on a time duration.
		public function setAttackTime(time:Number):void {
			if (time < 0.0) {
				errorString_ = "ADSR::setAttackTime: negative times not allowed ... correcting!";
				handleError( StkError.WARNING );
				attackRate_ = 1.0 / ( -time * Stk.sampleRate() );
			}else {
				attackRate_ = 1.0 / ( time * Stk.sampleRate() );
			}
		}
	
		//! Set the decay rate based on a time duration.
		public function setDecayTime(time:Number):void {
			if (time < 0.0) {
				errorString_ = "ADSR::setDecayTime: negative times not allowed ... correcting!";
				handleError( StkError.WARNING );
				decayRate_ = 1.0 / ( -time * Stk.sampleRate() );
			} else {
				decayRate_ = 1.0 / ( time * Stk.sampleRate() );
			}
		}
	
		//! Set the release rate based on a time duration.
		public function setReleaseTime(time:Number):void {
			if (time < 0.0) {
				errorString_ = "ADSR::setReleaseTime: negative times not allowed ... correcting!";
				handleError( StkError.WARNING );
				releaseRate_ = sustainLevel_ / ( -time * Stk.sampleRate() );
			} else {
				releaseRate_ = sustainLevel_ / ( time * Stk.sampleRate() );
			}
		}
	
		//! Set sustain level and attack, decay, and release time durations.
		public function setAllTimes(aTime:Number, dTime:Number, sLevel:Number, rTime:Number):void {
			this.setAttackTime(aTime);
			this.setDecayTime(dTime);
			this.setSustainLevel(sLevel);
			this.setReleaseTime(rTime);
		}
	
		//! Set the target value.
		public override function setTarget(target:Number):void {
			target_ = target;
			if (value_ < target_) {
				state_ = ATTACK;
				this.setSustainLevel(target_);
				rate_ = attackRate_;
			}
			if (value_ > target_) {
				this.setSustainLevel(target_);
				state_ = DECAY;
				rate_ = decayRate_;
			}
		}
	
		//! Return the current envelope \e state (ATTACK, DECAY, SUSTAIN, RELEASE, DONE).
		public override function getState():int {
			return state_;
		}
	
		//! Set to state = ADSR::SUSTAIN with current and target values of \e aValue.
		public override function setValue(value:Number):void {
			state_ = SUSTAIN;
			target_ = value;
			value_ = value;
			this.setSustainLevel(value);
			rate_ = 0.0;
		}
	
		protected override function computeSample():Number {
		 	switch (state_) {
				case ATTACK:
					value_ += rate_;
					if (value_ >= target_) {
						value_ = target_;
						rate_ = decayRate_;
						target_ = sustainLevel_;
						state_ = DECAY;
					}
					break;
			
				case DECAY:
					value_ -= decayRate_;
					if (value_ <= sustainLevel_) {
						value_ = sustainLevel_;
						rate_ = 0.0;
						state_ = SUSTAIN;
					}
					break;
			
				case RELEASE:
					value_ -= releaseRate_;
					if (value_ <= 0.0)			 {
						value_ = 0.0;
						state_ = DONE;
					}
			}
		
			lastOutput_ = value_;
			return value_;
		}
	 
		protected override function sampleRateChanged( newRate:Number, oldRate:Number ):void{
			if ( !ignoreSampleRateChange_ ) {
				attackRate_ = oldRate * attackRate_ / newRate;
				decayRate_ = oldRate * decayRate_ / newRate;
				releaseRate_ = oldRate * releaseRate_ / newRate;
			}
		}
	
		protected var attackRate_:Number;
		protected var decayRate_:Number;
		protected var sustainLevel_:Number;
		protected var releaseRate_:Number;
	}
}