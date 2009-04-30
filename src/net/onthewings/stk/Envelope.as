package net.onthewings.stk 
{
	import net.onthewings.stk.Generator;
	import net.onthewings.stk.StkError;
	
	/***************************************************/
	/*! \class Envelope
			\brief STK envelope base class.

			This class implements a simple envelope
			generator which is capable of ramping to
			a target value by a specified \e rate.
			It also responds to simple \e keyOn and
			\e keyOff messages, ramping to 1.0 on
			keyOn and to 0.0 on keyOff.

			by Perry R. Cook and Gary P. Scavone, 1995 - 2007.
	*/
	/***************************************************/
	public class Envelope extends Generator
	{
		//! Default constructor.
		public function Envelope() 
		{
			super();
			target_ = 0.0;
			value_ = 0.0;
			rate_ = 0.001;
			state_ = 0;
			this.addSampleRateAlert( this );
		}
		
		//! Copy constructor.
		public function clone():Envelope {
			return new Envelope();
		}

		//! Class destructor.
		public override function destruct():void 
		{
			super.destruct();
			this.removeSampleRateAlert( this );
		}

		//! Assignment operator.
		public function _assign ( e:Envelope ):void {
			if ( this != e ) {
				target_ = e.target_;
				value_ = e.value_;
				rate_ = e.rate_;
				state_ = e.state_;
			}
		}

		//! Set target = 1.
		public function keyOn():void {
			target_ = 1.0;
			if (value_ != target_) state_ = 1;
		}

		//! Set target = 0.
		public function keyOff():void {
			target_ = 0.0;
			if (value_ != target_) state_ = 1;
		}

		//! Set the \e rate.
		public function setRate(rate:Number):void {
			if (rate < 0.0) {
				errorString_ = "Envelope::setRate: negative rates not allowed ... correcting!";
				handleError( StkError.WARNING );
				rate_ = -rate;
			} else {
				rate_ = rate;
			}
		}

		//! Set the \e rate based on a time duration.
		public function setTime(time:Number):void {
			if (time < 0.0) {
				errorString_ = "Envelope::setTime: negative times not allowed ... correcting!";
				handleError( StkError.WARNING );
				rate_ = 1.0 / (-time * Stk.sampleRate());
			}
			else {
				rate_ = 1.0 / (time * Stk.sampleRate());
			}
		}

		//! Set the target value.
		public function setTarget(target:Number):void {
			target_ = target;
			if (value_ != target_) state_ = 1;
		}

		//! Set current and target values to \e aValue.
		public function setValue(value:Number):void {
			state_ = 0;
			target_ = value;
			value_ = value;
		}

		//! Return the current envelope \e state (0 = at target, 1 otherwise).
		public function getState():int {
			return state_;
		}

		protected override function computeSample():Number {
			if (state_) {
				if (target_ > value_) {
					value_ += rate_;
					if (value_ >= target_) {
						value_ = target_;
						state_ = 0;
					}
				}
				else {
					value_ -= rate_;
					if (value_ <= target_) {
						value_ = target_;
						state_ = 0;
					}
				}
			}

			lastOutput_ = value_;
			return value_;
		}
		protected override function sampleRateChanged( newRate:Number, oldRate:Number ):void {
			if ( !ignoreSampleRateChange_ )
				rate_ = oldRate * rate_ / newRate;
		}

		protected var value_:Number;
		protected var target_:Number;
		protected var rate_:Number;
		protected var state_:int;
	}
	
}