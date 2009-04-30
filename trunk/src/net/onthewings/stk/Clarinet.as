package net.onthewings.stk
{
	import net.onthewings.stk.OneZero;
	import net.onthewings.stk.ReedTable;
	/***************************************************/
	/*! \class Clarinet
			\brief STK clarinet physical model class.
	
			This class implements a simple clarinet
			physical model, as discussed by Smith (1986),
			McIntyre, Schumacher, Woodhouse (1983), and
			others.
	
			This is a digital waveguide model, making its
			use possibly subject to patents held by Stanford
			University, Yamaha, and others.
	
			Control Change Numbers: 
				 - Reed Stiffness = 2
				 - Noise Gain = 4
				 - Vibrato Frequency = 11
				 - Vibrato Gain = 1
				 - Breath Pressure = 128
	
			by Perry R. Cook and Gary P. Scavone, 1995 - 2007.
	*/
	/***************************************************/
	public class Clarinet extends Instrmnt
	{
		include "SKINI_msg.as"
		
		//! Class constructor, taking the lowest desired playing frequency.
		/*!
			An StkError will be thrown if the rawwave path is incorrectly set.
		*/
		public function Clarinet(lowestFrequency:Number):void {
			super();
			length_ = Stk.sampleRate() / lowestFrequency + 1;
			delayLine_.setMaximumDelay( length_ );
			delayLine_.setDelay( length_ / 2.0 );
			reedTable_.setOffset(0.7);
			reedTable_.setSlope(-0.3);
		
			vibrato_.setFrequency(5.735);
			outputGain_ = 1.0;
			noiseGain_ = 0.2;
			vibratoGain_ = 0.1;
		}
	
		//! Class destructor.
		public override function destruct():void{
			
		}
	
		//! Reset and clear all internal state.
		public function clear():void{
			delayLine_.clear();
			filter_.tick( 0.0 );
		}
	
		//! Set instrument parameters for a particular frequency.
		public override function setFrequency(frequency:Number):void{
			var freakency:Number = frequency;
			if ( frequency <= 0.0 ) {
				errorString_ = "Clarinet::setFrequency: parameter is less than or equal to zero!";
				handleError( StkError.WARNING );
				freakency = 220.0;
			}
		
			// Delay = length - approximate filter delay.
			var delay:Number = (Stk.sampleRate() / freakency) * 0.5 - 1.5;
			if (delay <= 0.0) delay = 0.3;
			else if (delay > length_) delay = length_;
			delayLine_.setDelay(delay);
		}
	
		//! Apply breath pressure to instrument with given amplitude and rate of increase.
		public function startBlowing(amplitude:Number, rate:Number):void{
			envelope_.setRate(rate);
			envelope_.setTarget(amplitude); 
		}
	
		//! Decrease breath pressure with given rate of decrease.
		public function stopBlowing(rate:Number):void{
			envelope_.setRate(rate);
			envelope_.setTarget(0.0);
		}
	
		//! Start a note with the given frequency and amplitude.
		public override function noteOn(frequency:Number, amplitude:Number):void {
			this.setFrequency(frequency);
			this.startBlowing(0.55 + (amplitude * 0.30), amplitude * 0.005);
			outputGain_ = amplitude + 0.001;
		
			if(Stk._STK_DEBUG_){
				errorString_ = "Clarinet::NoteOn: frequency = " + frequency + ", amplitude = " + amplitude + '.';
				handleError( StkError.DEBUG_WARNING );
			}
		}
	
		//! Stop a note with the given amplitude (speed of decay).
		public override function noteOff(amplitude:Number):void {
			this.stopBlowing( amplitude * 0.01 );

			if (Stk._STK_DEBUG_){
				errorString_ = "Clarinet::NoteOff: amplitude = " + amplitude + '.';
				handleError( StkError.DEBUG_WARNING );
			}
		}
	
		//! Perform the control change specified by \e number and \e value (0.0 - 128.0).
		public override function controlChange(number:int, value:Number):void{
			var norm:Number = value * ONE_OVER_128;
			if ( norm < 0 ) {
				norm = 0.0;
				errorString_ = "Clarinet::controlChange: control value less than zero ... setting to zero!";
				handleError( StkError.WARNING );
			}
			else if ( norm > 1.0 ) {
				norm = 1.0;
				errorString_ = "Clarinet::controlChange: control value greater than 128.0 ... setting to 128.0!";
				handleError( StkError.WARNING );
			}
		
			if (number == __SK_ReedStiffness_) // 2
				reedTable_.setSlope(-0.44 + ( 0.26 * norm ));
			else if (number == __SK_NoiseLevel_) // 4
				noiseGain_ = (norm * 0.4);
			else if (number == __SK_ModFrequency_) // 11
				vibrato_.setFrequency((norm * 12.0));
			else if (number == __SK_ModWheel_) // 1
				vibratoGain_ = (norm * 0.5);
			else if (number == __SK_AfterTouch_Cont_) // 128
				envelope_.setValue(norm);
			else {
				errorString_ = "Clarinet::controlChange: undefined control number (" + number + ")!";
				handleError( StkError.WARNING );
			}
		
			if(Stk._STK_DEBUG_){
				errorString_ = "Clarinet::controlChange: number = " + number + ", value = " + value + '.';
				handleError( StkError.DEBUG_WARNING );
			}
		}
	
	
		protected override function computeSample():Number {
			var pressureDiff:Number;
			var breathPressure:Number;
		
			// Calculate the breath pressure (envelope + noise + vibrato)
			breathPressure = envelope_.tick(); 
			breathPressure += breathPressure * noiseGain_ * noise_.tick();
			breathPressure += breathPressure * vibratoGain_ * vibrato_.tick();
		
			// Perform commuted loss filtering.
			pressureDiff = -0.95 * filter_.tick(delayLine_.lastOut());
		
			// Calculate pressure difference of reflected and mouthpiece pressures.
			pressureDiff = pressureDiff - breathPressure;
		
			// Perform non-linear scattering using pressure difference in reed function.
			lastOutput_ = delayLine_.tick(breathPressure + pressureDiff * reedTable_.tick(pressureDiff));
		
			// Apply output gain.
			lastOutput_ *= outputGain_;
		
			return lastOutput_;
		}
	
		protected var delayLine_:DelayL = new DelayL();
		protected var reedTable_:ReedTable = new ReedTable();
		protected var filter_:OneZero = new OneZero();
		protected var envelope_:Envelope = new Envelope();
		protected var noise_:Noice = new Noice();
		protected var vibrato_:SineWave = new SineWave();
		protected var length_:Number;
		protected var outputGain_:Number;
		protected var noiseGain_:Number;
		protected var vibratoGain_:Number;
	}
}