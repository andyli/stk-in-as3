package net.onthewings.stk
{
	/***************************************************/
	/*! \class Whistle
			\brief STK police/referee whistle instrument class.
	
			This class implements a hybrid physical/spectral
			model of a police whistle (a la Cook).
	
			Control Change Numbers: 
				 - Noise Gain = 4
				 - Fipple Modulation Frequency = 11
				 - Fipple Modulation Gain = 1
				 - Blowing Frequency Modulation = 2
				 - Volume = 128
	
			by Perry R. Cook	1996 - 2004.
	*/
	/***************************************************/
	public class Whistle extends Instrmnt
	{
		include "SKINI_msg.as"
		
		public static const CAN_RADIUS:int = 100;
		public static const PEA_RADIUS:int = 30;
		public static const BUMP_RADIUS:int = 5;
		
		public static const NORM_CAN_LOSS:Number = 0.97;
		public static const SLOW_CAN_LOSS:Number = 0.90;
		public static const GRAVITY:Number = 20.0;
		
		public static const NORM_TICK_SIZE:Number = 0.004;
		public static const SLOW_TICK_SIZE:Number = 0.0001;
		
		public static const ENV_RATE:Number = 0.001;
		
		private static var frameCount:int = 0;
		
		//! Class constructor.
		/*!
			An StkError will be thrown if the rawwave path is incorrectly set.
		*/
		public function Whistle():void {
			super();
			
			sine_.setFrequency( 2800.0 );

			can_.setRadius( CAN_RADIUS );
			can_.setPosition(0, 0, 0); // set can location
			can_.setVelocity(0, 0, 0); // and the velocity
		
			onepole_.setPole(0.95);	// 0.99
		
			bumper_.setRadius( BUMP_RADIUS );
			bumper_.setPosition(0.0, CAN_RADIUS-BUMP_RADIUS, 0);
			bumper_.setPosition(0.0, CAN_RADIUS-BUMP_RADIUS, 0);
		
			pea_.setRadius( PEA_RADIUS );
			pea_.setPosition(0, CAN_RADIUS/2, 0);
			pea_.setVelocity(35, 15, 0);
		
			envelope_.setRate( ENV_RATE );
			envelope_.keyOn();
		
			fippleFreqMod_ = 0.5;
			fippleGainMod_ = 0.5;
			blowFreqMod_ = 0.25;
			noiseGain_ = 0.125;
			baseFrequency_ = 2000;
		
			tickSize_ = NORM_TICK_SIZE;
			canLoss_ = NORM_CAN_LOSS;
		
			subSample_ = 1;
			subSampCount_ = subSample_;
		}
	
		//! Class destructor.
		public override function destruct():void{
			super.destruct();
			/*if (WHISTLE_ANIMATION){
				trace("Exit, Whistle bye bye!!\n");
			}*/
		}
	
		//! Reset and clear all internal state.
		public function clear():void {
			
		}
	
		//! Set instrument parameters for a particular frequency.
		public override function setFrequency(frequency:Number):void {
			var freakency:Number = frequency * 4;	// the whistle is a transposing instrument
			if ( frequency <= 0.0 ) {
				errorString_ = "Whistle::setFrequency: parameter is less than or equal to zero!";
				handleError( StkError.WARNING );
				freakency = 220.0;
			}
		
			baseFrequency_ = freakency;
		}
	
		//! Apply breath velocity to instrument with given amplitude and rate of increase.
		public function startBlowing(amplitude:Number, rate:Number):void {
			envelope_.setRate( ENV_RATE );
			envelope_.setTarget( amplitude );
		}
	
		//! Decrease breath velocity with given rate of decrease.
		public function stopBlowing(rate:Number):void {
			envelope_.setRate( rate );
			envelope_.keyOff();
		}
	
		//! Start a note with the given frequency and amplitude.
		public override function noteOn(frequency:Number, amplitude:Number):void {
			this.setFrequency( frequency );
			this.startBlowing( amplitude*2.0 ,amplitude * 0.2 );
			if(Stk._STK_DEBUG_){
				errorString_ = "Whistle::NoteOn: frequency = " + frequency + ", amplitude = " + amplitude + '.';
				handleError( StkError.DEBUG_WARNING );
			}
		}
	
		//! Stop a note with the given amplitude (speed of decay).
		public override function noteOff(amplitude:Number):void {
			this.stopBlowing( amplitude * 0.02 );

			if(Stk._STK_DEBUG_){
				errorString_ = "Whistle::NoteOff: amplitude = " + amplitude + '.';
				handleError( StkError.DEBUG_WARNING );
			}
		}
	
		//! Perform the control change specified by \e number and \e value (0.0 - 128.0).
		public override function controlChange(number:int, value:Number):void {
			var norm:Number = value * ONE_OVER_128;
			if ( norm < 0 ) {
				norm = 0.0;
				errorString_ = "Whistle::controlChange: control value less than zero ... setting to zero!";
				handleError( StkError.WARNING );
			} else if ( norm > 1.0 ) {
				norm = 1.0;
				errorString_ = "Whistle::controlChange: control value greater than 128.0 ... setting to 128.0!";
				handleError( StkError.WARNING );
			}
		
			if ( number == __SK_NoiseLevel_ ) // 4
				noiseGain_ = 0.25 * norm;
			else if ( number == __SK_ModFrequency_ ) // 11
				fippleFreqMod_ = norm;
			else if ( number == __SK_ModWheel_ ) // 1
				fippleGainMod_ = norm;
			else if ( number == __SK_AfterTouch_Cont_ ) // 128
				envelope_.setTarget( norm * 2.0 );
			else if ( number == __SK_Breath_ ) // 2
				blowFreqMod_ = norm * 0.5;
			else if ( number == __SK_Sustain_ )	{ // 64
				subSample_ = value;
				if ( subSample_ < 1.0 ) subSample_ = 1;
				envelope_.setRate( ENV_RATE / subSample_ );
			}
			else {
				errorString_ = "Whistle::controlChange: undefined control number (" + number + ")!";
				handleError( StkError.WARNING );
			}
		
			if(Stk._STK_DEBUG_){
				errorString_ = "Whistle::controlChange: number = " + number + ", value = " + value + '.';
				handleError( StkError.DEBUG_WARNING );
			}
		}
	
		protected override function computeSample():Number {
			var soundMix:Number, tempFreq:Number;
			var envOut:Number = 0, temp:Number, temp1:Number, temp2:Number, tempX:Number, tempY:Number;
			var phi:Number, cosphi:Number, sinphi:Number;
			var gain:Number = 0.5, mod:Number = 0.0;
		
			if ( --subSampCount_ <= 0 )	{
				tempVectorP_ = pea_.getPosition();
				subSampCount_ = subSample_;
				temp = bumper_.isInside( tempVectorP_ );
				/*if (WHISTLE_ANIMATION){
					frameCount += 1;
					if ( frameCount >= (1470 / subSample_) ) {
						frameCount = 0;
						trace(tempVectorP_->getX(),tempVectorP_->getY(),envOut);
					}
				}*/
				envOut = envelope_.tick();
		
				if (temp < (BUMP_RADIUS + PEA_RADIUS)) {
					tempX = envOut * tickSize_ * 2000 * noise_.tick();
					tempY = -envOut * tickSize_ * 1000 * (1.0 + noise_.tick());
					pea_.addVelocity( tempX, tempY, 0 ); 
					pea_.tick( tickSize_ );
				}
						
				mod	= Math.exp(-temp * 0.01);		// exp. distance falloff of fipple/pea effect
				temp = onepole_.tick(mod);	// smooth it a little
				gain = (1.0 - (fippleGainMod_*0.5)) + (2.0 * fippleGainMod_ * temp);
				gain *= gain;								// squared distance/gain
				//		tempFreq = 1.0				//	Normalized Base Freq
				//			+ (fippleFreqMod_ * 0.25) - (fippleFreqMod_ * temp) // fippleModulation 
				//			- (blowFreqMod_) + (blowFreqMod_ * envOut); // blowingModulation
				// short form of above
				tempFreq = 1.0 + fippleFreqMod_*(0.25-temp) + blowFreqMod_*(envOut-1.0);
				tempFreq *= baseFrequency_;
		
				sine_.setFrequency(tempFreq);
				
				tempVectorP_ = pea_.getPosition();
				temp = can_.isInside(tempVectorP_);
				temp	= -temp;			 // We know (hope) it's inside, just how much??
				if (temp < (PEA_RADIUS * 1.25)) {
					pea_.getVelocity( tempVector_ );	// This is the can/pea collision
					tempX = tempVectorP_.getX();		 // calculation.	Could probably
					tempY = tempVectorP_.getY();		 // simplify using tables, etc.
					phi = -Math.atan2(tempY,tempX);
		
					cosphi = Math.cos(phi);
					sinphi = Math.sin(phi);
					temp1 = (cosphi*tempVector_.getX()) - (sinphi*tempVector_.getY());
					temp2 = (sinphi*tempVector_.getX()) + (cosphi*tempVector_.getY());
					temp1 = -temp1;
					tempX = (cosphi*temp1) + (sinphi*temp2);
					tempY = (-sinphi*temp1) + (cosphi*temp2);
					pea_.setVelocity(tempX, tempY, 0);
					pea_.tick(tickSize_);
					pea_.setVelocity( tempX*canLoss_, tempY*canLoss_, 0 );
					pea_.tick(tickSize_);
				}
		
				temp = tempVectorP_.getLength();	
				if (temp > 0.01) {
					tempX = tempVectorP_.getX();
					tempY = tempVectorP_.getY();
					phi = Math.atan2( tempY, tempX );
					phi += 0.3 * temp / CAN_RADIUS;
					cosphi = Math.cos(phi);
					sinphi = Math.sin(phi);
					tempX = 3.0 * temp * cosphi;
					tempY = 3.0 * temp * sinphi;
				}
				else {
					tempX = 0.0;
					tempY = 0.0;
				}
				
				temp = (0.9 + 0.1*subSample_*noise_.tick()) * envOut * 0.6 * tickSize_;
				pea_.addVelocity( temp * tempX, (temp*tempY) - (GRAVITY*tickSize_), 0 );
				pea_.tick( tickSize_ );
		
				// bumper_.tick(0.0);
			}
		
			temp = envOut * envOut * gain / 2;
			soundMix = temp * ( sine_.tick() + ( noiseGain_*noise_.tick() ) );
			lastOutput_ = 0.25 * soundMix; // should probably do one-zero filter here
		
			return lastOutput_;
		}
	
		protected var tempVectorP_:Vector3D = new Vector3D();
		protected var tempVector_:Vector3D = new Vector3D();
		protected var onepole_:OnePole = new OnePole();
		protected var noise_:Noise = new Noise();
		protected var envelope_:Envelope = new Envelope();
		protected var can_:Sphere = new Sphere() // Declare a Spherical "can".
		protected var pea_:Sphere = new Sphere(); // One spherical "pea",
		protected var bumper_:Sphere = new Sphere(); // and a spherical "bumper".
	
		protected var sine_:SineWave = new SineWave();
	
		protected var baseFrequency_:Number;
		protected var noiseGain_:Number;
		protected var fippleFreqMod_:Number;
		protected var fippleGainMod_:Number;
		protected var blowFreqMod_:Number;
		protected var tickSize_:Number;
		protected var canLoss_:Number;
		protected var subSample_:int, subSampCount_:int;
	}
}