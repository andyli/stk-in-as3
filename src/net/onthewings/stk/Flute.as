package net.onthewings.stk
{
	/***************************************************/
	/*! \class Flute
			\brief STK flute physical model class.
	
			This class implements a simple flute
			physical model, as discussed by Karjalainen,
			Smith, Waryznyk, etc.	The jet model uses
			a polynomial, a la Cook.
	
			This is a digital waveguide model, making its
			use possibly subject to patents held by Stanford
			University, Yamaha, and others.
	
			Control Change Numbers: 
				 - Jet Delay = 2
				 - Noise Gain = 4
				 - Vibrato Frequency = 11
				 - Vibrato Gain = 1
				 - Breath Pressure = 128
	
			by Perry R. Cook and Gary P. Scavone, 1995 - 2007.
	*/
	/***************************************************/
	public class Flute extends Instrmnt
	{
		include "SKINI_msg.as"
		
		//! Class constructor, taking the lowest desired playing frequency.
		/*!
			An StkError will be thrown if the rawwave path is incorrectly set.
		*/
		public function Flute(lowestFrequency:Number):void {
			super();
			
			length_ = Math.floor(Stk.sampleRate() / lowestFrequency + 1);
			boreDelay_.setMaximumDelay( length_ );
			boreDelay_.setDelay( 100.0 );
		
			jetDelay_.setMaximumDelay( length_ );
			jetDelay_.setDelay( 49.0 );
		
			vibrato_.setFrequency( 5.925 );
		
			this.clear();
		
			filter_.setPole( 0.7 - (0.1 * 22050.0 / Stk.sampleRate() ) );
			filter_.setGain( -1.0 );
		
			dcBlock_.setBlockZero();
		
			adsr_.setAllTimes( 0.005, 0.01, 0.8, 0.010);
			endReflection_ = 0.5;
			jetReflection_ = 0.5;
			noiseGain_		 = 0.15;		// Breath pressure random component.
			vibratoGain_	 = 0.05;		// Breath periodic vibrato component.
			jetRatio_			= 0.32;
		
			maxPressure_ = 0.0;
			lastFrequency_ = 220.0;
		}
	
		//! Class destructor.
		public override function destruct():void {
			super.destruct();
		}
	
		//! Reset and clear all internal state.
		public function clear():void {
			jetDelay_.clear();
			boreDelay_.clear();
			filter_.clear();
			dcBlock_.clear();
		}
	
		//! Set instrument parameters for a particular frequency.
		public override function setFrequency(frequency:Number):void {
			lastFrequency_ = frequency;
			if ( frequency <= 0.0 ) {
				errorString_ = "Flute::setFrequency: parameter is less than or equal to zero!";
				handleError( StkError.WARNING );
				lastFrequency_ = 220.0;
			}
		
			// We're overblowing here.
			lastFrequency_ *= 0.66666;
		
			// delay = length - approximate filter delay.
			var delay:Number = Stk.sampleRate() / lastFrequency_ - 2.0;
			if ( delay <= 0.0 ) delay = 0.3;
			else if ( delay > length_ ) delay = length_;
		
			boreDelay_.setDelay(delay);
			jetDelay_.setDelay(delay * jetRatio_);
		}
	
		//! Set the reflection coefficient for the jet delay (-1.0 - 1.0).
		public function setJetReflection(coefficient:Number):void {
			jetReflection_ = coefficient;
		}
	
		//! Set the reflection coefficient for the air column delay (-1.0 - 1.0).
		public function setEndReflection(coefficient:Number):void {
			endReflection_ = coefficient;
		}
	
		//! Set the length of the jet delay in terms of a ratio of jet delay to air column delay lengths.
		public function setJetDelay(aRatio:Number):void {
			// Delay = length - approximate filter delay.
			var temp:Number = Stk.sampleRate() / lastFrequency_ - 2.0;
			jetRatio_ = aRatio;
			jetDelay_.setDelay(temp * aRatio); // Scaled by ratio.
		}
	
		//! Apply breath velocity to instrument with given amplitude and rate of increase.
		public function startBlowing(amplitude:Number, rate:Number):void {
			adsr_.setAttackRate( rate );
			maxPressure_ = amplitude / 0.8;
			adsr_.keyOn();
		}
	
		//! Decrease breath velocity with given rate of decrease.
		public function stopBlowing(rate:Number):void {
			adsr_.setReleaseRate( rate );
			adsr_.keyOff();
		}
	
		//! Start a note with the given frequency and amplitude.
		public override function noteOn(frequency:Number, amplitude:Number):void {
			this.setFrequency( frequency );
			this.startBlowing( 1.1 + (amplitude * 0.20), amplitude * 0.02 );
			outputGain_ = amplitude + 0.001;
		
			if(Stk._STK_DEBUG_){
				errorString_ = "Flute::NoteOn: frequency = " + frequency + ", amplitude = " + amplitude + ".";
				handleError( StkError.DEBUG_WARNING );
			}
		}
	
		//! Stop a note with the given amplitude (speed of decay).
		public override function noteOff(amplitude:Number):void {
			this.stopBlowing( amplitude * 0.02 );

			if(Stk._STK_DEBUG_){
				errorString_ = "Flute::NoteOff: amplitude = " + amplitude + ".";
				handleError( StkError.DEBUG_WARNING );
			}
		}
	
		//! Perform the control change specified by \e number and \e value (0.0 - 128.0).
		public override function controlChange(number:int, value:Number):void {
			var norm:Number = value * ONE_OVER_128;
			if ( norm < 0 ) {
				norm = 0.0;
				errorString_ = "Flute::controlChange: control value less than zero ... setting to zero!";
				handleError( StkError.WARNING );
			}
			else if ( norm > 1.0 ) {
				norm = 1.0;
				errorString_ = "Flute::controlChange: control value greater than 128.0 ... setting to 128.0!";
				handleError( StkError.WARNING );
			}
		
			if (number == __SK_JetDelay_) // 2
				this.setJetDelay( 0.08 + (0.48 * norm));
			else if (number == __SK_NoiseLevel_) // 4
				noiseGain_ = ( norm * 0.4);
			else if (number == __SK_ModFrequency_) // 11
				vibrato_.setFrequency( norm * 12.0);
			else if (number == __SK_ModWheel_) // 1
				vibratoGain_ = ( norm * 0.4 );
			else if (number == __SK_AfterTouch_Cont_) // 128
				adsr_.setTarget( norm );
			else {
				errorString_ = "Flute::controlChange: undefined control number (" + number + ")!";
				handleError( StkError.WARNING );
			}
		
			if(Stk._STK_DEBUG_){
				errorString_ = "Flute::controlChange: number = " + number + ", value = " + value + ".";
				handleError( StkError.DEBUG_WARNING );
			}
		}
	
	 	protected override function computeSample():Number {
	 		var pressureDiff:Number;
			var breathPressure:Number;
		
			// Calculate the breath pressure (envelope + noise + vibrato)
			breathPressure = maxPressure_ * adsr_.tick();
			breathPressure += breathPressure * ( noiseGain_ * noise_.tick() + vibratoGain_ * vibrato_.tick() );
		
			var temp:Number = filter_.tick( boreDelay_.lastOut() );
			temp = dcBlock_.tick( temp ); // Block DC on reflection.
		
			pressureDiff = breathPressure - (jetReflection_ * temp);
			pressureDiff = jetDelay_.tick( pressureDiff );
			pressureDiff = jetTable_.tick( pressureDiff ) + (endReflection_ * temp);
			lastOutput_ = 0.3 * boreDelay_.tick( pressureDiff );
		
			lastOutput_ *= outputGain_;
			return lastOutput_;
	 	}
	
		protected var jetDelay_:DelayL = new DelayL();
		protected var boreDelay_:DelayL = new DelayL();
		protected var jetTable_:JetTable = new JetTable();
		protected var filter_:OnePole = new OnePole();
		protected var dcBlock_:PoleZero = new PoleZero();
		protected var noise_:Noise = new Noise();
		protected var adsr_:ADSR = new ADSR();
		protected var vibrato_:SineWave = new SineWave();
		protected var length_:Number;
		protected var lastFrequency_:Number;
		protected var maxPressure_:Number;
		protected var jetReflection_:Number;
		protected var endReflection_:Number;
		protected var noiseGain_:Number;
		protected var vibratoGain_:Number;
		protected var outputGain_:Number;
		protected var jetRatio_:Number;
	}
}