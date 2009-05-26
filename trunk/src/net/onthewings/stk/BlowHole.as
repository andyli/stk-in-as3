package net.onthewings.stk
{
	/***************************************************/
	/*! \class BlowHole
			\brief STK clarinet physical model with one
						 register hole and one tonehole.
	
			This class is based on the clarinet model,
			with the addition of a two-port register hole
			and a three-port dynamic tonehole
			implementation, as discussed by Scavone and
			Cook (1998).
	
			In this implementation, the distances between
			the reed/register hole and tonehole/bell are
			fixed.	As a result, both the tonehole and
			register hole will have variable influence on
			the playing frequency, which is dependent on
			the length of the air column.	In addition,
			the highest playing freqeuency is limited by
			these fixed lengths.
	
			This is a digital waveguide model, making its
			use possibly subject to patents held by Stanford
			University, Yamaha, and others.
	
			Control Change Numbers: 
				 - Reed Stiffness = 2
				 - Noise Gain = 4
				 - Tonehole State = 11
				 - Register State = 1
				 - Breath Pressure = 128
	
			by Perry R. Cook and Gary P. Scavone, 1995 - 2007.
	*/
	/***************************************************/
	public class BlowHole extends Instrmnt
	{
		include "SKINI_msg.as"
		
		//! Class constructor.
		/*!
			An StkError will be thrown if the rawwave path is incorrectly set.
		*/
		public function BlowHole(lowestFrequency:Number):void	{
			super();
			
			length_ = Math.floor(Stk.sampleRate() / lowestFrequency + 1);
			// delays[0] is the delay line between the reed and the register vent.
			delays_[0].setDelay( 5.0 * Stk.sampleRate() / 22050.0 );
			// delays[1] is the delay line between the register vent and the tonehole.
			delays_[1].setMaximumDelay( length_ );
			delays_[1].setDelay( length_ >> 1 );
			// delays[2] is the delay line between the tonehole and the end of the bore.
			delays_[2].setDelay( 4.0 * Stk.sampleRate() / 22050.0 );
		
			reedTable_.setOffset( 0.7 );
			reedTable_.setSlope( -0.3 );
		
			// Calculate the initial tonehole three-port scattering coefficient
			var rb:Number = 0.0075;		// main bore radius
			var rth:Number = 0.003;		// tonehole radius
			scatter_ = -Math.pow(rth,2) / ( Math.pow(rth,2) + 2*Math.pow(rb,2) );
		
			// Calculate tonehole coefficients and set for initially open.
			var te:Number = 1.4 * rth;		// effective length of the open hole
			thCoeff_ = (te*2*Stk.sampleRate() - 347.23) / (te*2*Stk.sampleRate() + 347.23);
			tonehole_.setA1(-thCoeff_);
			tonehole_.setB0(thCoeff_);
			tonehole_.setB1(-1.0);
		
			// Calculate register hole filter coefficients
			var r_rh:Number = 0.0015;		// register vent radius
			te = 1.4 * r_rh;				 // effective length of the open hole
			var xi:Number = 0.0;				 // series resistance term
			var zeta:Number = 347.23 + 2*Math.PI*Math.pow(rb,2)*xi/1.1769;
			var psi:Number = 2*Math.PI*Math.pow(rb,2)*te / (Math.PI*Math.pow(r_rh,2));
			var rhCoeff:Number = (zeta - 2 * Stk.sampleRate() * psi) / (zeta + 2 * Stk.sampleRate() * psi);
			rhGain_ = -347.23 / (zeta + 2 * Stk.sampleRate() * psi);
			vent_.setA1( rhCoeff );
			vent_.setB0(1.0);
			vent_.setB1(1.0);
			// Start with register vent closed
			vent_.setGain(0.0);
		
			vibrato_.setFrequency(5.735);
			outputGain_ = 1.0;
			noiseGain_ = 0.2;
			vibratoGain_ = 0.01;
		}
	
		//! Class destructor.
		public override function destruct():void {
			super.destruct();
		}
	
		//! Reset and clear all internal state.
		public function clear():void {
			delays_[0].clear();
			delays_[1].clear();
			delays_[2].clear();
			filter_.tick( 0.0 );
			tonehole_.tick( 0.0 );
			vent_.tick( 0.0 );
		}
	
		//! Set instrument parameters for a particular frequency.
		public override function setFrequency(frequency:Number):void {
			var freakency:Number = frequency;
			if ( frequency <= 0.0 ) {
				throw new Error("BlowHole: setFrequency parameter is less than or equal to zero!");
				freakency = 220.0;
			}
		
			// Delay = length - approximate filter delay.
			var delay:Number = (Stk.sampleRate() / freakency) * 0.5 - 3.5;
			delay -= delays_[0].getDelay() + delays_[2].getDelay();
		
			if (delay <= 0.0) delay = 0.3;
			else if (delay > length_) delay = length_;
			delays_[1].setDelay(delay);
		}
	
		//! Set the tonehole state (0.0 = closed, 1.0 = fully open).
		public function setTonehole(newValue:Number):void {
			// This method allows setting of the tonehole "open-ness" at
			// any point between "Open" (newValue = 1) and "Closed"
			// (newValue = 0).
			var new_coeff:Number;
		
			if ( newValue <= 0.0 )
				new_coeff = 0.9995;
			else if ( newValue >= 1.0 )
				new_coeff = thCoeff_;
			else
				new_coeff = (newValue * (thCoeff_ - 0.9995)) + 0.9995;
		
			tonehole_.setA1( -new_coeff );
			tonehole_.setB0( new_coeff );
		}
	
		//! Set the register hole state (0.0 = closed, 1.0 = fully open).
		public function setVent(newValue:Number):void {
			// This method allows setting of the register vent "open-ness" at
			// any point between "Open" (newValue = 1) and "Closed"
			// (newValue = 0).
		
			var gain:Number;
		
			if (newValue <= 0.0)
				gain = 0.0;
			else if (newValue >= 1.0)
				gain = rhGain_;
			else
				gain = newValue * rhGain_;
		
			vent_.setGain( gain );
		}
	
		//! Apply breath pressure to instrument with given amplitude and rate of increase.
		public function startBlowing(amplitude:Number, rate:Number):void {
			envelope_.setRate( rate );
			envelope_.setTarget( amplitude );
		}
	
		//! Decrease breath pressure with given rate of decrease.
		public function stopBlowing(rate:Number):void {
			envelope_.setRate( rate );
			envelope_.setTarget( 0.0 ); 
		}
	
		//! Start a note with the given frequency and amplitude.
		public override function noteOn(frequency:Number, amplitude:Number):void {
			this.setFrequency( frequency );
			this.startBlowing( 0.55 + (amplitude * 0.30), amplitude * 0.005 );
			outputGain_ = amplitude + 0.001;
		
			if(Stk._STK_DEBUG_){
				errorString_ = "BlowHole::NoteOn: frequency = " + frequency + ", amplitude = " + amplitude + ".";
				handleError( StkError.DEBUG_WARNING );
			}
		}
	
		//! Stop a note with the given amplitude (speed of decay).
		public override function noteOff(amplitude:Number):void {
			this.stopBlowing( amplitude * 0.01 );

			if(Stk._STK_DEBUG_){
				errorString_ = "BlowHole::NoteOff: amplitude = " + amplitude + ".";
				handleError( StkError.DEBUG_WARNING );
			}
		}
	
		//! Perform the control change specified by \e number and \e value (0.0 - 128.0).
		public override function controlChange(number:int, value:Number):void {
			var norm:Number = value * ONE_OVER_128;
			if ( norm < 0 ) {
				norm = 0.0;
				errorString_ = "BlowHole::controlChange: control value less than zero ... setting to zero!";
				handleError( StkError.WARNING );
			}
			else if ( norm > 1.0 ) {
				norm = 1.0;
				errorString_ = "BlowHole::controlChange: control value greater than 128.0 ... setting to 128.0!";
				handleError( StkError.WARNING );
			}
		
			if (number == __SK_ReedStiffness_) // 2
				reedTable_.setSlope( -0.44 + (0.26 * norm) );
			else if (number == __SK_NoiseLevel_) // 4
				noiseGain_ = ( norm * 0.4);
			else if (number == __SK_ModFrequency_) // 11
				this.setTonehole( norm );
			else if (number == __SK_ModWheel_) // 1
				this.setVent( norm );
			else if (number == __SK_AfterTouch_Cont_) // 128
				envelope_.setValue( norm );
			else {
				errorString_ = "BlowHole::controlChange: undefined control number (" + number + ")!";
				handleError( StkError.WARNING );
			}
		
			if(Stk._STK_DEBUG_){
				errorString_ = "BlowHole::controlChange: number = " + number + ", value = " + value + ".";
				handleError( StkError.DEBUG_WARNING );
			}
		}
		
		protected override function computeSample():Number {
			var pressureDiff:Number;
			var breathPressure:Number;
			var temp:Number;
		
			// Calculate the breath pressure (envelope + noise + vibrato)
			breathPressure = envelope_.tick(); 
			breathPressure += breathPressure * noiseGain_ * noise_.tick();
			breathPressure += breathPressure * vibratoGain_ * vibrato_.tick();
		
			// Calculate the differential pressure = reflected - mouthpiece pressures
			pressureDiff = delays_[0].lastOut() - breathPressure;
		
			// Do two-port junction scattering for register vent
			var pa:Number = breathPressure + pressureDiff * reedTable_.tick( pressureDiff );
			var pb:Number = delays_[1].lastOut();
			vent_.tick( pa+pb );
		
			lastOutput_ = delays_[0].tick( vent_.lastOut()+pb );
			lastOutput_ *= outputGain_;
		
			// Do three-port junction scattering (under tonehole)
			pa += vent_.lastOut();
			pb = delays_[2].lastOut();
			var pth:Number = tonehole_.lastOut();
			temp = scatter_ * (pa + pb - 2 * pth);
		
			delays_[2].tick( filter_.tick(pa + temp) * -0.95 );
			delays_[1].tick( pb + temp );
			tonehole_.tick( pa + pb - pth + temp );
		
			return lastOutput_;
		}
	
		protected var delays_:Vector.<DelayL> = Vector.<DelayL>([new DelayL(),new DelayL(),new DelayL()]);
		protected var reedTable_:ReedTable = new ReedTable();
		protected var filter_:OneZero = new OneZero();
		protected var tonehole_:PoleZero = new PoleZero();
		protected var vent_:PoleZero = new PoleZero();
		protected var envelope_:Envelope = new Envelope();
		protected var noise_:Noise = new Noise()
		protected var vibrato_:SineWave = new SineWave();
		protected var length_:Number;
		protected var scatter_:Number;
		protected var thCoeff_:Number;
		protected var rhGain_:Number;
		protected var outputGain_:Number;
		protected var noiseGain_:Number;
		protected var vibratoGain_:Number;
	}
}