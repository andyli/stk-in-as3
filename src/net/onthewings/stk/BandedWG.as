package net.onthewings.stk
{
	import __AS3__.vec.Vector;
	
	/***************************************************/
	/*! \class BandedWG
	    \brief Banded waveguide modeling class.
	
	    This class uses banded waveguide techniques to
	    model a variety of sounds, including bowed
	    bars, glasses, and bowls.  For more
	    information, see Essl, G. and Cook, P. "Banded
	    Waveguides: Towards Physical Modelling of Bar
	    Percussion Instruments", Proceedings of the
	    1999 International Computer Music Conference.
	
	    Control Change Numbers: 
	       - Bow Pressure = 2
	       - Bow Motion = 4
				 - Strike Position = 8 (not implemented)
				 - Vibrato Frequency = 11
				 - Gain = 1
				 - Bow Velocity = 128
				 - Set Striking = 64
				 - Instrument Presets = 16
					 - Uniform Bar = 0
					 - Tuned Bar = 1
					 - Glass Harmonica = 2
					 - Tibetan Bowl = 3
	
			by Georg Essl, 1999 - 2004.
			Modified for Stk 4.0 by Gary Scavone.
	*/
	/***************************************************/
	public class BandedWG extends Instrmnt
	{
		include "SKINI_msg.as"
		public static const MAX_BANDED_MODES:int = 20;
		
		//! Class constructor.
		public function BandedWG():void	{
			super();
			
			for (var i:Number = 0 ; i < bandpass_.length ; ++i){
				bandpass_[i] = new BiQuad();
			}
			for (i = 0 ; i < bandpass_.length ; ++i){
				delay_[i] = new DelayL();
			}
			
			doPluck_ = true;

			bowTable_.setSlope( 3.0 );
			adsr_.setAllTimes( 0.02, 0.005, 0.9, 0.01);
		
			frequency_ = 220.0;
			this.setPreset(0);
		
			bowPosition_ = 0;
			baseGain_ = 0.999;
			
			integrationConstant_ = 0.0;
			trackVelocity_ = false;
		
			bowVelocity_ = 0.0;
			bowTarget_ = 0.0;
		
			strikeAmp_ = 0.0;
		}
		
		//! Class destructor.
		public override function destruct():void {
			super.destruct();
		}
	
		//! Reset and clear all internal state.
		public function clear():void {
			for (var i:int=0; i<nModes_; i++) {
				delay_[i].clear();
				bandpass_[i].clear();
			}
		}
	
		//! Set strike position (0.0 - 1.0).
		public function setStrikePosition(position:Number):void {
			strikePosition_ = delay_[0].getDelay() * position / 2.0;
		}
	
		//! Select a preset.
		public function setPreset(preset:int):void {
			var i:int;
			switch (preset){
		
			case 1: // Tuned Bar
				presetModes_ = 4;
				modes_[0] = 1.0;
				modes_[1] = 4.0198391420;
				modes_[2] = 10.7184986595;
				modes_[3] = 18.0697050938;
		
				for (i=0; i<presetModes_; i++) {
					basegains_[i] = Math.pow(0.999,i+1);
					excitation_[i] = 1.0;
				}
		
				break;
		
			case 2: // Glass Harmonica
				presetModes_ = 5;
				modes_[0] = 1.0;
				modes_[1] = 2.32;
				modes_[2] = 4.25;
				modes_[3] = 6.63;
				modes_[4] = 9.38;
				// modes_[5] = 12.22;
		
				for (i=0; i<presetModes_; i++) {
					basegains_[i] = Math.pow(0.999, i+1);
					excitation_[i] = 1.0;
				}
				/*
					baseGain_ = 0.99999;
					for (i=0; i<presetModes_; i++) 
					gains_[i]= pow(baseGain_, delay_[i].getDelay()+i);
				*/
		
				break;
			 
			case 3: // Tibetan Prayer Bowl (ICMC'02)
				presetModes_ = 12;
				modes_[0]=0.996108344;
				basegains_[0]=0.999925960128219;
				excitation_[0]=11.900357/10.0;
				modes_[1]=1.0038916562;
				basegains_[1]=0.999925960128219;
				excitation_[1]=11.900357/10.;
				modes_[2]=2.979178;
				basegains_[2]=0.999982774366897;
				excitation_[2]=10.914886/10.;
				modes_[3]=2.99329767;
				basegains_[3]=0.999982774366897;
				excitation_[3]=10.914886/10.;
				modes_[4]=5.704452;
				basegains_[4]=1.0; //0.999999999999999999987356406352;
				excitation_[4]=42.995041/10.;
				modes_[5]=5.704452;
				basegains_[5]=1.0; //0.999999999999999999987356406352;
				excitation_[5]=42.995041/10.;
				modes_[6]=8.9982;
				basegains_[6]=1.0; //0.999999999999999999996995497558225;
				excitation_[6]=40.063034/10.;
				modes_[7]=9.01549726;
				basegains_[7]=1.0; //0.999999999999999999996995497558225;
				excitation_[7]=40.063034/10.;
				modes_[8]=12.83303;
				basegains_[8]=0.999965497558225;
				excitation_[8]=7.063034/10.;
				modes_[9]=12.807382;
				basegains_[9]=0.999965497558225;
				excitation_[9]=7.063034/10.;
				modes_[10]=17.2808219;
				basegains_[10]=0.9999999999999999999965497558225;
				excitation_[10]=57.063034/10.;
				modes_[11]=21.97602739726;
				basegains_[11]=0.999999999999999965497558225;
				excitation_[11]=57.063034/10.;
		
				break;	
		
			default: // Uniform Bar
				presetModes_ = 4;
				modes_[0] = 1.0;
				modes_[1] = 2.756;
				modes_[2] = 5.404;
				modes_[3] = 8.933;
		
				for (i=0; i<presetModes_; i++) {
					basegains_[i] = Math.pow(0.9, i+1);
					excitation_[i] = 1.0;
				}
		
				break;
			}
		
			nModes_ = presetModes_;
			setFrequency( frequency_ );
		}
	
		//! Set instrument parameters for a particular frequency.
		public override function setFrequency(frequency:Number):void {
			frequency_ = frequency;
			if ( frequency <= 0.0 ) {
				errorString_ = "BandedWG::setFrequency: parameter is less than or equal to zero!";
				handleError( StkError.WARNING );
				frequency_ = 220.0;
			}
			if (frequency_ > 1568.0) frequency_ = 1568.0;
		
			var radius:Number;
			var base:Number = Stk.sampleRate() / frequency_;
			var length:Number;
			for (var i:int=0; i<presetModes_; i++) {
				// Calculate the delay line lengths for each mode.
				length = Math.floor(base / modes_[i]);
				if ( length > 2.0) {
					delay_[i].setDelay( length );
					gains_[i]=basegains_[i];
					//		gains_[i]=(StkFloat) pow(basegains_[i], 1/((StkFloat)delay_[i].getDelay()));
					//		std::cerr << gains_[i];
				}
				else	{
					nModes_ = i;
					break;
				}
				//	std::cerr << std::endl;
		
				// Set the bandpass filter resonances
				radius = 1.0 - PI * 32 / Stk.sampleRate(); //frequency_ * modes_[i] / Stk::sampleRate()/32;
				if ( radius < 0.0 ) radius = 0.0;
				bandpass_[i].setResonance(frequency_ * modes_[i], radius, true);
		
				delay_[i].clear();
				bandpass_[i].clear();
			}
		
			//int olen = (int)(delay_[0].getDelay());
			//strikePosition_ = (int)(strikePosition_*(length/modes_[0])/olen);
		}
	
		//! Apply bow velocity/pressure to instrument with given amplitude and rate of increase.
		public function startBowing(amplitude:Number, rate:Number):void {
			adsr_.setRate(rate);
			adsr_.keyOn();
			maxVelocity_ = 0.03 + (0.1 * amplitude); 
		}
	
		//! Decrease bow velocity/breath pressure with given rate of decrease.
		public function stopBowing(rate:Number):void {
			adsr_.setRate(rate);
			adsr_.keyOff();
		}
	
		//! Pluck the instrument with given amplitude.
		public function pluck(amplitude:Number):void {
			var j:int;
			var min_len:Number = delay_[nModes_-1].getDelay();
			for (var i:int=0; i<nModes_; i++)
				for(j=0; j<Math.floor(delay_[i].getDelay()/min_len); j++)
					delay_[i].tick( excitation_[i]*amplitude / nModes_ );
		
			//	strikeAmp_ += amplitude;
		}
	
		//! Start a note with the given frequency and amplitude.
		public override function noteOn(frequency:Number, amplitude:Number):void {
			this.setFrequency(frequency);

			if ( doPluck_ )
				this.pluck(amplitude);
			else
				this.startBowing(amplitude, amplitude * 0.001);
		
			if(Stk._STK_DEBUG_){
				errorString_ = "BandedWG::NoteOn: frequency = " + frequency + ", amplitude = " + amplitude + ".";
				handleError( StkError.DEBUG_WARNING );
			}
		}
	
		//! Stop a note with the given amplitude (speed of decay).
		public override function noteOff(amplitude:Number):void {
			if ( !doPluck_ )
			this.stopBowing((1.0 - amplitude) * 0.005);
	
			if(Stk._STK_DEBUG_){
				errorString_ = "BandedWG::NoteOff: amplitude = " + amplitude + ".";
				handleError( StkError.DEBUG_WARNING );
			}
		}
	
		//! Perform the control change specified by \e number and \e value (0.0 - 128.0).
		public override function controlChange(number:int, value:Number):void {
			var norm:Number = value * Stk.ONE_OVER_128;
			if ( norm < 0 ) {
				norm = 0.0;
				errorString_ = "BandedWG::controlChange: control value less than zero ... setting to zero!";
				handleError( StkError.WARNING );
			}
			else if ( norm > 1.0 ) {
				norm = 1.0;
				errorString_ = "BandedWG::controlChange: control value greater than 128.0 ... setting to 128.0!";
				handleError( StkError.WARNING );
			}
		
			if (number == __SK_BowPressure_) { // 2
				if ( norm == 0.0 )
					doPluck_ = true;
				else {
					doPluck_ = false;
					bowTable_.setSlope( 10.0 - (9.0 * norm));
				}
			}
			else if (number == 4)	{ // 4
				if ( !trackVelocity_ ) trackVelocity_ = true;
				bowTarget_ += 0.005 * (norm - bowPosition_);
				bowPosition_ = norm;
				//adsr_.setTarget(bowPosition_);
			}
			else if (number == 8) // 8
				this.setStrikePosition( norm );
			else if (number == __SK_AfterTouch_Cont_) { // 128
				//bowTarget_ += 0.02 * (norm - bowPosition_);
				//bowPosition_ = norm;
				if ( trackVelocity_ ) trackVelocity_ = false;
				maxVelocity_ = 0.13 * norm; 
				adsr_.setTarget(norm);
			}			
			else if (number == __SK_ModWheel_) { // 1
				//		baseGain_ = 0.9989999999 + (0.001 * norm );
				baseGain_ = 0.8999999999999999 + (0.1 * norm);
				//	std::cerr << "Yuck!" << std::endl;
				for (var i:int=0; i<nModes_; i++)
					gains_[i]= basegains_[i]*baseGain_;
				//			gains_[i]=(StkFloat) pow(baseGain_, (int)((StkFloat)delay_[i].getDelay()+i));
			}
			else if (number == __SK_ModFrequency_) // 11
				integrationConstant_ = norm;
			else if (number == __SK_Sustain_)	{ // 64
				if (value < 65) doPluck_ = true;
				else doPluck_ = false;
			}
			else if (number == __SK_Portamento_)	{ // 65
				if (value < 65) trackVelocity_ = false;
				else trackVelocity_ = true;
			}
			else if (number == __SK_ProphesyRibbon_) // 16
				this.setPreset(value);	
			else {
				errorString_ = "BandedWG::controlChange: undefined control number (" + number + ")!";
				handleError( StkError.WARNING );
			}
		
			if(Stk._STK_DEBUG_){
				errorString_ = "BandedWG::controlChange: number = " + number + ", value = " + value + ".";
				handleError( StkError.DEBUG_WARNING );
			}
		}
	
		protected override function computeSample():Number {
			var k:int;

			var input:Number = 0.0;
			if ( doPluck_ ) {
				input = 0.0;
				//	input = strikeAmp_/nModes_;
				//	strikeAmp_ = 0.0;
			}
			else {
				if (integrationConstant_ == 0.0)
					velocityInput_ = 0.0;
				else
					velocityInput_ = integrationConstant_ * velocityInput_;
		
				for (k=0; k<nModes_; k++)
					velocityInput_ += baseGain_ * delay_[k].lastOut();
					
				if ( trackVelocity_ )	{
					bowVelocity_ *= 0.9995;
					bowVelocity_ += bowTarget_;
					bowTarget_ *= 0.995;
				}
				else
					bowVelocity_ = adsr_.tick() * maxVelocity_;
		
				input = bowVelocity_ - velocityInput_;
				input = input * bowTable_.tick(input);
				input = input/nModes_;
			}
		
			var data:Number = 0.0;	
			for (k=0; k<nModes_; k++) {
				bandpass_[k].tick(input + gains_[k] * delay_[k].lastOut());
				delay_[k].tick(bandpass_[k].lastOut());
				data += bandpass_[k].lastOut();
			}
			
			//lastOutput = data * nModes_;
			lastOutput_ = data * 4;
			return lastOutput_;
		}
	
		protected var doPluck_:Boolean;
		protected var trackVelocity_:Boolean;
		protected var nModes_:int;
		protected var presetModes_:int;
		protected var bowTable_:BowTable = new BowTable();
		protected var adsr_:ADSR = new ADSR();
		protected var bandpass_:Vector.<BiQuad> = new Vector.<BiQuad>(MAX_BANDED_MODES);
		protected var delay_:Vector.<DelayL> = new Vector.<DelayL>(MAX_BANDED_MODES);
		protected var maxVelocity_:Number;
		protected var modes_:Vector.<Number> = new Vector.<Number>(MAX_BANDED_MODES);
		protected var frequency_:Number;
		protected var baseGain_:Number;
		protected var gains_:Vector.<Number> = new Vector.<Number>(MAX_BANDED_MODES);
		protected var basegains_:Vector.<Number> = new Vector.<Number>(MAX_BANDED_MODES);
		protected var excitation_:Vector.<Number> = new Vector.<Number>(MAX_BANDED_MODES);
		protected var integrationConstant_:Number;
		protected var velocityInput_:Number;
		protected var bowVelocity_:Number;
		protected var bowTarget_:Number;
		protected var bowPosition_:Number;
		protected var strikeAmp_:Number;
		protected var strikePosition_:int;
		
	}
}