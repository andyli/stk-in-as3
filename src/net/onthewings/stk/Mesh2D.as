package net.onthewings.stk
{
	import __AS3__.vec.Vector;
	
	/***************************************************/
	/*! \class Mesh2D
			\brief Two-dimensional rectilinear waveguide mesh class.
	
			This class implements a rectilinear,
			two-dimensional digital waveguide mesh
			structure.	For details, see Van Duyne and
			Smith, "Physical Modeling with the 2-D Digital
			Waveguide Mesh", Proceedings of the 1993
			International Computer Music Conference.
	
			This is a digital waveguide model, making its
			use possibly subject to patents held by Stanford
			University, Yamaha, and others.
	
			Control Change Numbers: 
				 - X Dimension = 2
				 - Y Dimension = 4
				 - Mesh Decay = 11
				 - X-Y Input Position = 1
	
			by Julius Smith, 2000 - 2002.
			Revised by Gary Scavone for STK, 2002.
	*/
	/***************************************************/
	public class Mesh2D extends Instrmnt
	{
		include "SKINI_msg.as"
		
		public static const NXMAX:int = 12;
		public static const NYMAX:int = 12;
		public static const VSCALE:Number = 0.5;
		
		//! Class constructor, taking the x and y dimensions in samples.
		public function Mesh2D(nX:int, nY:int):void	{
			super();
			
			this.setNX(nX);
			this.setNY(nY);
		
			var pole:Number = 0.05;
		
			var i:int;
			for (i=0; i<NYMAX; ++i) {
				filterY_[i] = new OnePole();
				filterY_[i].setPole( pole );
				filterY_[i].setGain( 0.99 );
			}
		
			for (i=0; i<NXMAX; ++i) {
				filterX_[i] = new OnePole();
				filterX_[i].setPole( pole );
				filterX_[i].setGain( 0.99 );
			}
		
			this.clearMesh();
		
			counter_=0;
			xInput_ = 0;
			yInput_ = 0;
		}
		
		//! Class destructor.
		public override function destruct():void {
			super.destruct();
		}
	
		//! Reset and clear all internal state.
		public function clear():void {
			this.clearMesh();

			var i:int;
			for (i=0; i<NY_; ++i)
				filterY_[i].clear();
		
			for (i=0; i<NX_; ++i)
				filterX_[i].clear();
		
			counter_=0;
		} 
	
		//! Set the x dimension size in samples.
		public function setNX(lenX:int):void {
			NX_ = lenX;
			if ( lenX < 2 ) {
				errorString_ = "Mesh2D::setNX(" + lenX + "): Minimum length is 2!";
				handleError( StkError.WARNING );
				NX_ = 2;
			}
			else if ( lenX > NXMAX ) {
				errorString_ = "Mesh2D::setNX(" + lenX + "): Maximum length is " + NXMAX + '!';
				handleError( StkError.WARNING );
				NX_ = NXMAX;
			}
		}
	
		//! Set the y dimension size in samples.
		public function setNY(lenY:int):void {
			NY_ = lenY;
			if ( lenY < 2 ) {
				errorString_ = "Mesh2D::setNY(" + lenY + "): Minimum length is 2!";
				handleError( StkError.WARNING );
				NY_ = 2;
			}
			else if ( lenY > NYMAX ) {
				errorString_ = "Mesh2D::setNY(" + lenY + "): Maximum length is " + NXMAX + '!';
				handleError( StkError.WARNING );
				NY_ = NYMAX;
			}
		}
	
		//! Set the x, y input position on a 0.0 - 1.0 scale.
		public function setInputPosition(xFactor:Number, yFactor:Number):void {
			if ( xFactor < 0.0 ) {
				errorString_ = "Mesh2D::setInputPosition xFactor value is less than 0.0!";
				handleError( StkError.WARNING );
				xInput_ = 0;
			}
			else if ( xFactor > 1.0 ) {
				errorString_ = "Mesh2D::setInputPosition xFactor value is greater than 1.0!";
				handleError( StkError.WARNING );
				xInput_ = NX_ - 1;
			}
			else
				xInput_ = Math.floor(xFactor * (NX_ - 1));
		
			if ( yFactor < 0.0 ) {
				errorString_ = "Mesh2D::setInputPosition yFactor value is less than 0.0!";
				handleError( StkError.WARNING );
				yInput_ = 0;
			}
			else if ( yFactor > 1.0 ) {
				errorString_ = "Mesh2D::setInputPosition yFactor value is greater than 1.0!";
				handleError( StkError.WARNING );
				yInput_ = NY_ - 1;
			}
			else
				yInput_ = Math.floor(yFactor * (NY_ - 1));
		}
	
		//! Set the loss filters gains (0.0 - 1.0).
		public function setDecay(decayFactor:Number):void {
			var gain:Number = decayFactor;
			if ( decayFactor < 0.0 ) {
				errorString_ = "Mesh2D::setDecay: decayFactor value is less than 0.0!";
				handleError( StkError.WARNING );
				gain = 0.0;
			}
			else if ( decayFactor > 1.0 ) {
				errorString_ = "Mesh2D::setDecay decayFactor value is greater than 1.0!";
				handleError( StkError.WARNING );
				gain = 1.0;
			}
		
			var i:int;
			for (i=0; i<NYMAX; ++i)
				filterY_[i].setGain( gain );
		
			for (i=0; i<NXMAX; ++i)
				filterX_[i].setGain( gain );
		}
	
		//! Impulse the mesh with the given amplitude (frequency ignored).
		public override function noteOn(frequency:Number, amplitude:Number):void {
			// Input at corner.
			if ( counter_ & 1 ) {
				vxp1_[xInput_][yInput_] += amplitude;
				vyp1_[xInput_][yInput_] += amplitude;
			}
			else {
				vxp_[xInput_][yInput_] += amplitude;
				vyp_[xInput_][yInput_] += amplitude;
			}
		
			if(Stk._STK_DEBUG_){
				errorString_ = "Mesh2D::NoteOn: frequency = " + frequency + ", amplitude = " + amplitude + ".";
				handleError( StkError.DEBUG_WARNING );
			}
		}
	
		//! Stop a note with the given amplitude (speed of decay) ... currently ignored.
		public override function noteOff(amplitude:Number):void {
			if(Stk._STK_DEBUG_){
				errorString_ = "Mesh2D::NoteOff: amplitude = " + amplitude + ".";
				handleError( StkError.DEBUG_WARNING );
			}
		}
	
		//! Calculate and return the signal energy stored in the mesh.
		public function energy():Number {
			// Return total energy contained in wave variables Note that some
			// energy is also contained in any filter delay elements.
		
			var x:int, y:int;
			var t:Number;
			var e:Number = 0;
			if ( counter_ & 1 ) { // Ready for Mesh2D::tick1() to be called.
				for (x=0; x<NX_; x++) {
					for (y=0; y<NY_; y++) {
						t = vxp1_[x][y];
						e += t*t;
						t = vxm1_[x][y];
						e += t*t;
						t = vyp1_[x][y];
						e += t*t;
						t = vym1_[x][y];
						e += t*t;
					}
				}
			}
			else { // Ready for Mesh2D::tick0() to be called.
				for (x=0; x<NX_; x++) {
					for (y=0; y<NY_; y++) {
						t = vxp_[x][y];
						e += t*t;
						t = vxm_[x][y];
						e += t*t;
						t = vyp_[x][y];
						e += t*t;
						t = vym_[x][y];
						e += t*t;
					}
				}
			}
		
			return(e);
		}
	
		//! Input a sample to the mesh and compute one output sample.
		public function inputTick( input:Number ):Number {
			if ( counter_ & 1 ) {
				vxp1_[xInput_][yInput_] += input;
				vyp1_[xInput_][yInput_] += input;
				lastOutput_ = tick1();
			}
			else {
				vxp_[xInput_][yInput_] += input;
				vyp_[xInput_][yInput_] += input;
				lastOutput_ = tick0();
			}
		
			counter_++;
			return lastOutput_;
		}
	
		//! Perform the control change specified by \e number and \e value (0.0 - 128.0).
		public override function controlChange(number:int, value:Number):void {
			var norm:Number = value * ONE_OVER_128;
			if ( norm < 0 ) {
				norm = 0.0;
				errorString_ = "Mesh2D::controlChange: control value less than zero ... setting to zero!";
				handleError( StkError.WARNING );
			}
			else if ( norm > 1.0 ) {
				norm = 1.0;
				errorString_ = "Mesh2D::controlChange: control value greater than 128.0 ... setting to 128.0!";
				handleError( StkError.WARNING );
			}
		
			if (number == 2) // 2
				this.setNX( Math.floor(norm * (NXMAX-2) + 2) );
			else if (number == 4) // 4
				this.setNY( Math.floor(norm * (NYMAX-2) + 2) );
			else if (number == 11) // 11
				this.setDecay( 0.9 + (norm * 0.1) );
			else if (number == __SK_ModWheel_) // 1
				this.setInputPosition( norm, norm );
			else {
				errorString_ = "Mesh2D::controlChange: undefined control number (" + number + ")!";
				handleError( StkError.WARNING );
			}
		
			if(Stk._STK_DEBUG_){
				errorString_ = "Mesh2D::controlChange: number = " + number + ", value = " + value + ".";
				handleError( StkError.DEBUG_WARNING );
			}
		}
	
		protected override function computeSample():Number {
			lastOutput_ = ((counter_ & 1) ? this.tick1() : this.tick0());
			counter_++;
			return lastOutput_;
		}
	
		protected function tick0():Number {
			var x:int, y:int;
			var outsamp:Number = 0;
		
			// Update junction velocities.
			for (x=0; x<NX_-1; x++) {
				for (y=0; y<NY_-1; y++) {
					v_[x][y] = ( vxp_[x][y] + vxm_[x+1][y] + 
					vyp_[x][y] + vym_[x][y+1] ) * VSCALE;
				}
			}		
		
			// Update junction outgoing waves, using alternate wave-variable buffers.
			for (x=0; x<NX_-1; x++) {
				for (y=0; y<NY_-1; y++) {
					var vxy:Number = v_[x][y];
					// Update positive-going waves.
					vxp1_[x+1][y] = vxy - vxm_[x+1][y];
					vyp1_[x][y+1] = vxy - vym_[x][y+1];
					// Update minus-going waves.
					vxm1_[x][y] = vxy - vxp_[x][y];
					vym1_[x][y] = vxy - vyp_[x][y];
				}
			}		
		
			// Loop over velocity-junction boundary faces, update edge
			// reflections, with filtering.	We're only filtering on one x and y
			// edge here and even this could be made much sparser.
			for (y=0; y<NY_-1; y++) {
				vxp1_[0][y] = filterY_[y].tick(vxm_[0][y]);
				vxm1_[NX_-1][y] = vxp_[NX_-1][y];
			}
			for (x=0; x<NX_-1; x++) {
				vyp1_[x][0] = filterX_[x].tick(vym_[x][0]);
				vym1_[x][NY_-1] = vyp_[x][NY_-1];
			}
		
			// Output = sum of outgoing waves at far corner.	Note that the last
			// index in each coordinate direction is used only with the other
			// coordinate indices at their next-to-last values.	This is because
			// the "unit strings" attached to each velocity node to terminate
			// the mesh are not themselves connected together.
			outsamp = vxp_[NX_-1][NY_-2] + vyp_[NX_-2][NY_-1];
		
			return outsamp;
		}
		protected function tick1():Number {
			var x:int, y:int;
			var outsamp:Number = 0;
		
			// Update junction velocities.
			for (x=0; x<NX_-1; x++) {
				for (y=0; y<NY_-1; y++) {
					v_[x][y] = ( vxp1_[x][y] + vxm1_[x+1][y] + 
					vyp1_[x][y] + vym1_[x][y+1] ) * VSCALE;
				}
			}
		
			// Update junction outgoing waves, 
			// using alternate wave-variable buffers.
			for (x=0; x<NX_-1; x++) {
				for (y=0; y<NY_-1; y++) {
					var vxy:Number = v_[x][y];
		
					// Update positive-going waves.
					vxp_[x+1][y] = vxy - vxm1_[x+1][y];
					vyp_[x][y+1] = vxy - vym1_[x][y+1];
		
					// Update minus-going waves.
					vxm_[x][y] = vxy - vxp1_[x][y];
					vym_[x][y] = vxy - vyp1_[x][y];
				}
			}
		
			// Loop over velocity-junction boundary faces, update edge
			// reflections, with filtering.	We're only filtering on one x and y
			// edge here and even this could be made much sparser.
			for (y=0; y<NY_-1; y++) {
				vxp_[0][y] = filterY_[y].tick(vxm1_[0][y]);
				vxm_[NX_-1][y] = vxp1_[NX_-1][y];
			}
			for (x=0; x<NX_-1; x++) {
				vyp_[x][0] = filterX_[x].tick(vym1_[x][0]);
				vym_[x][NY_-1] = vyp1_[x][NY_-1];
			}
		
			// Output = sum of outgoing waves at far corner.
			outsamp = vxp1_[NX_-1][NY_-2] + vyp1_[NX_-2][NY_-1];
		
			return outsamp;
		}
		protected function clearMesh():void {
			var x:int, y:int;
			for (x=0; x<NXMAX-1; x++) {
					v_[x] = new Vector.<Number>(NYMAX);
				for (y=0; y<NYMAX-1; y++) {
					v_[x][y] = 0;
				}
			}
			for (x=0; x<NXMAX; x++) {
				vxp_[x] = new Vector.<Number>(NYMAX);
				vxm_[x] = new Vector.<Number>(NYMAX);
				vyp_[x] = new Vector.<Number>(NYMAX);
				vym_[x] = new Vector.<Number>(NYMAX);
				vxp1_[x] = new Vector.<Number>(NYMAX);
				vxm1_[x] = new Vector.<Number>(NYMAX);
				vyp1_[x] = new Vector.<Number>(NYMAX);
				vym1_[x] = new Vector.<Number>(NYMAX);
				for (y=0; y<NYMAX; y++) {
		
					vxp_[x][y] = 0;
					vxm_[x][y] = 0;
					vyp_[x][y] = 0;
					vym_[x][y] = 0;
		
					vxp1_[x][y] = 0;
					vxm1_[x][y] = 0;
					vyp1_[x][y] = 0;
					vym1_[x][y] = 0;
				}
			}
		}
	
		protected var NX_:int, NY_:int;
		protected var xInput_:int, yInput_:int;
		protected var filterX_:Vector.<OnePole> = new Vector.<OnePole>(NXMAX);
		protected var filterY_:Vector.<OnePole> = new Vector.<OnePole>(NYMAX);
		protected var v_:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>(NXMAX-1); // junction velocities
		protected var vxp_:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>(NXMAX);	 // positive-x velocity wave
		protected var vxm_:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>(NXMAX);	 // negative-x velocity wave
		protected var vyp_:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>(NXMAX);	 // positive-y velocity wave
		protected var vym_:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>(NXMAX);	 // negative-y velocity wave
	
		// Alternate buffers
		protected var vxp1_:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>(NXMAX);	// positive-x velocity wave
		protected var vxm1_:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>(NXMAX);	// negative-x velocity wave
		protected var vyp1_:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>(NXMAX);	// positive-y velocity wave
		protected var vym1_:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>(NXMAX);	// negative-y velocity wave
	
		protected var counter_:int; // time in samples
	}
}