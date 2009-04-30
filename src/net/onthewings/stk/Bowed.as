package net.onthewings.stk
{
	/***************************************************/
	/*! \class Bowed
			\brief STK bowed string instrument class.
	
			This class implements a bowed string model, a
			la Smith (1986), after McIntyre, Schumacher,
			Woodhouse (1983).
	
			This is a digital waveguide model, making its
			use possibly subject to patents held by
			Stanford University, Yamaha, and others.
	
			Control Change Numbers: 
				 - Bow Pressure = 2
				 - Bow Position = 4
				 - Vibrato Frequency = 11
				 - Vibrato Gain = 1
				 - Volume = 128
	
			by Perry R. Cook and Gary P. Scavone, 1995 - 2007.
	*/
	/***************************************************/
	public class Bowed extends Instrmnt
	{
		include "SKINI_msg.as"
		
		//! Class constructor, taking the lowest desired playing frequency.
		public function Bowed(lowestFrequency:Number):void {
			super();
			
			var length:Number;
			length = Math.abs(Math.floor( Stk.sampleRate() / lowestFrequency + 1 ));
			neckDelay_.setMaximumDelay( length );
			neckDelay_.setDelay( 100.0 );
		
			length >>= 1;
			bridgeDelay_.setMaximumDelay( length );
			bridgeDelay_.setDelay( 29.0 );
		
			bowTable_.setSlope(3.0 );
		
			vibrato_.setFrequency( 6.12723 );
			vibratoGain_ = 0.0;
		
			stringFilter_.setPole( 0.6 - (0.1 * 22050.0 / Stk.sampleRate()) );
			stringFilter_.setGain( 0.95 );
		
			bodyFilter_.setResonance( 500.0, 0.85, true );
			bodyFilter_.setGain( 0.2 );
		
			adsr_.setAllTimes( 0.02, 0.005, 0.9, 0.01 );
				
			betaRatio_ = 0.127236;
		
			// Necessary to initialize internal variables.
			this.setFrequency( 220.0 );
		}
		
	
		//! Class destructor.
		public override function destruct():void {
			super.destruct();
		}
	
		//! Reset and clear all internal state.
		public function clear():void {
			neckDelay_.clear();
			bridgeDelay_.clear();
		}
	
		//! Set instrument parameters for a particular frequency.
		public override function setFrequency(frequency:Number):void {
			var freakency:Number = frequency;
			if ( frequency <= 0.0 ) {
				errorString_ = "Bowed::setFrequency: parameter is less than or equal to zero!";
				handleError( StkError.WARNING );
				freakency = 220.0;
			}
		
			// Delay = length - approximate filter delay.
			baseDelay_ = Stk.sampleRate() / freakency - 4.0;
			if ( baseDelay_ <= 0.0 ) baseDelay_ = 0.3;
			bridgeDelay_.setDelay( baseDelay_ * betaRatio_ ); 			 // bow to bridge length
			neckDelay_.setDelay( baseDelay_ * (1.0 - betaRatio_) );	// bow to nut (finger) length
		}
	
		//! Set vibrato gain.
		public function setVibrato(gain:Number):void {
			vibratoGain_ = gain;
		}
	
		//! Apply breath pressure to instrument with given amplitude and rate of increase.
		public function startBowing(amplitude:Number, rate:Number):void {
			adsr_.setRate( rate );
			adsr_.keyOn();
			maxVelocity_ = 0.03 + ( 0.2 * amplitude ); 
		}
	
		//! Decrease breath pressure with given rate of decrease.
		public function stopBowing(rate:Number):void {
			adsr_.setRate( rate );
			adsr_.keyOff();
		}
	
		//! Start a note with the given frequency and amplitude.
		public override function noteOn(frequency:Number, amplitude:Number):void {
			this.startBowing( amplitude, amplitude * 0.001 );
			this.setFrequency( frequency );
		
			if(Stk._STK_DEBUG_){
				errorString_ = "Bowed::NoteOn: frequency = " + frequency + ", amplitude = " + amplitude + ".";
				handleError( StkError.DEBUG_WARNING );
			}
		}
	
		//! Stop a note with the given amplitude (speed of decay).
		public override function noteOff(amplitude:Number):void {
			this.stopBowing( (1.0 - amplitude) * 0.005 );

			if(Stk._STK_DEBUG_){
				errorString_ = "Bowed::NoteOff: amplitude = " + amplitude + ".";
				handleError( StkError.DEBUG_WARNING );
			}
		}
	
		//! Perform the control change specified by \e number and \e value (0.0 - 128.0).
		public override function controlChange(number:int, value:Number):void {
			var norm:Number = value * ONE_OVER_128;
			if ( norm < 0 ) {
				norm = 0.0;
				errorString_ = "Bowed::controlChange: control value less than zero ... setting to zero!";
				handleError( StkError.WARNING );
			}
			else if ( norm > 1.0 ) {
				norm = 1.0;
				errorString_ = "Bowed::controlChange: control value greater than 128.0 ... setting to 128.0!";
				handleError( StkError.WARNING );
			}
		
			if (number == __SK_BowPressure_) // 2
				bowTable_.setSlope( 5.0 - (4.0 * norm) );
			else if (number == __SK_BowPosition_) { // 4
				betaRatio_ = 0.027236 + (0.2 * norm);
				bridgeDelay_.setDelay( baseDelay_ * betaRatio_ );
				neckDelay_.setDelay( baseDelay_ * (1.0 - betaRatio_) );
			}
			else if (number == __SK_ModFrequency_) // 11
				vibrato_.setFrequency( norm * 12.0 );
			else if (number == __SK_ModWheel_) // 1
				vibratoGain_ = ( norm * 0.4 );
			else if (number == __SK_AfterTouch_Cont_) // 128
				adsr_.setTarget(norm);
			else {
				errorString_ = "Bowed::controlChange: undefined control number (" + number + ")!";
				handleError( StkError.WARNING );
			}
		
			if(Stk._STK_DEBUG_){
					errorString_ = "Bowed::controlChange: number = " + number + ", value = " + value + ".";
					handleError( StkError.DEBUG_WARNING );
			}
		}
	
		protected override function computeSample():Number {
			var bowVelocity:Number;
			var bridgeRefl:Number;
			var nutRefl:Number;
			var newVel:Number;
			var velDiff:Number;
			var stringVel:Number;

			bowVelocity = maxVelocity_ * adsr_.tick();
		
			bridgeRefl = -stringFilter_.tick( bridgeDelay_.lastOut() );
			nutRefl = -neckDelay_.lastOut();
			stringVel = bridgeRefl + nutRefl;		 		 // Sum is String Velocity
			velDiff = bowVelocity - stringVel;				// Differential Velocity
			newVel = velDiff * bowTable_.tick( velDiff );	 // Non-Linear Bow Function
			neckDelay_.tick(bridgeRefl + newVel);			 // Do string propagations
			bridgeDelay_.tick(nutRefl + newVel);
			
			if ( vibratoGain_ > 0.0 )	{
				neckDelay_.setDelay( (baseDelay_ * (1.0 - betaRatio_) ) + (baseDelay_ * vibratoGain_ * vibrato_.tick()) );
			}
			lastOutput_ = bodyFilter_.tick( bridgeDelay_.lastOut() );
		
			return lastOutput_;
		}
	
		protected var neckDelay_:DelayL = new DelayL();
		protected var bridgeDelay_:DelayL = new DelayL();
		protected var bowTable_:BowTable = new BowTable();
		protected var stringFilter_:OnePole = new OnePole();
		protected var bodyFilter_:BiQuad = new BiQuad();
		protected var vibrato_:SineWave = new SineWave();
		protected var adsr_:ADSR = new ADSR();
		protected var maxVelocity_:Number;
		protected var baseDelay_:Number;
		protected var vibratoGain_:Number;
		protected var betaRatio_:Number;
	}
}