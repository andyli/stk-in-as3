package net.onthewings.stk
{
	/***************************************************/
	/*! \class Vector3D
	    \brief STK 3D vector class.
	
	    This class implements a three-dimensional vector.
	
	    by Perry R. Cook, 1995 - 2004.
	*/
	/***************************************************/
	public class Vector3D extends Stk
	{
		//! Default constructor taking optional initial X, Y, and Z values.
		public function Vector3D(initX:Number=0.0, initY:Number=0.0, initZ:Number=0.0)
		{
			super();
			myX_ = initX;
			myY_ = initY;
			myZ_ = initZ;
		}
	
		//! Class destructor.
		public function destruct():void {
			
		}
	
		//! Get the current X value.
		public function getX():Number {
			return myX_;
		}
	
		//! Get the current Y value.
		public function getY():Number {
			return myY_;
		}
	
		//! Get the current Z value.
		public function getZ():Number {
			return myZ_;
		}
	
		//! Calculate the vector length.
		public function getLength():Number {
			var temp:Number;
			temp = myX_ * myX_;
			temp += myY_ * myY_;
			temp += myZ_ * myZ_;
			temp = Math.sqrt(temp);
			return temp;
		}
	
		//! Set the X, Y, and Z values simultaniously.
		public function setXYZ(x:Number, y:Number, z:Number):void {
			myX_ = x;
			myY_ = y;
			myZ_ = z;
		}
	
		//! Set the X value.
		public function setX(x:Number):void {
			myX_ = x;
		}
	
		//! Set the Y value.
		public function setY(y:Number):void {
			myY_ = y;
		}
	
		//! Set the Z value.
		public function setZ(z:Number):void {
			myZ_ = z;
		}
	
		protected var myX_:Number;
		protected var myY_:Number;
		protected var myZ_:Number;
	}
}