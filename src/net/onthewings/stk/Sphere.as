package net.onthewings.stk
{
	/***************************************************/
	/*! \class Sphere
			\brief STK sphere class.
	
			This class implements a spherical ball with
			radius, mass, position, and velocity parameters.
	
			by Perry R. Cook, 1995 - 2004.
	*/
	/***************************************************/
	public class Sphere extends Stk
	{	
		//! Constructor taking an initial radius value.
		public function Sphere(radius:Number = 1.0):void {
			super();
			radius_ = radius;
			mass_ = 1.0;
		}
		
		//! Class destructor.
		public function destruct():void {
			
		}
	
		//! Set the 3D center position of the sphere.
		public function setPosition(x:Number, y:Number, z:Number):void {
			position_.setXYZ(x, y, z);
		}
	
		//! Set the 3D velocity of the sphere.
		public function setVelocity(x:Number, y:Number, z:Number):void {
			velocity_.setXYZ(x, y, z);
		}
	
		//! Set the radius of the sphere.
		public function setRadius(radius:Number):void {
			radius_ = radius;
		}
	
		//! Set the mass of the sphere.
		public function setMass(mass:Number):void {
			mass_ = mass;
		}
	
		//! Get the current position of the sphere as a 3D vector.
		public function getPosition():Vector3D {
			return position_;
		}
	
		//! Get the relative position of the given point to the sphere as a 3D vector.
		public function getRelativePosition(position:Vector3D):Vector3D {
			workingVector_.setXYZ(position.getX() - position_.getX(),
								  position.getY() - position_.getY(),	
								  position.getZ() - position_.getZ());
			return workingVector_;
		}
	
		//! Set the velcoity of the sphere as a 3D vector.
		public function getVelocity(velocity:Vector3D):Number {
			velocity.setXYZ( velocity_.getX(), velocity_.getY(), velocity_.getZ() );
			return velocity_.getLength();
		}
	
		//! Returns the distance from the sphere boundary to the given position (< 0 if inside).
		public function isInside(position:Vector3D):Number {
			// Return directed distance from aPosition to spherical boundary ( <
			// 0 if inside).
			var distance:Number;
			var tempVector:Vector3D;
		
			tempVector = this.getRelativePosition( position );
			distance = tempVector.getLength();
			return distance - radius_;
		}
	
		//! Get the current sphere radius.
		public function getRadius():Number {
			return radius_;
		}
	
		//! Get the current sphere mass.
		public function getMass():Number {
			return mass_;
		}
	
		//! Increase the current sphere velocity by the given 3D components.
		public function addVelocity(x:Number, y:Number, z:Number):void {
			velocity_.setX(velocity_.getX() + x);
			velocity_.setY(velocity_.getY() + y);
			velocity_.setZ(velocity_.getZ() + z);
		}
	
		//! Move the sphere for the given time increment.
		public function tick(timeIncrement:Number):void {
			position_.setX(position_.getX() + (timeIncrement * velocity_.getX()));
			position_.setY(position_.getY() + (timeIncrement * velocity_.getY()));
			position_.setZ(position_.getZ() + (timeIncrement * velocity_.getZ()));
		}
		 
		protected var position_:Vector3D = new Vector3D();
		protected var velocity_:Vector3D = new Vector3D();
		protected var workingVector_:Vector3D = new Vector3D();
		protected var radius_:Number;
		protected var mass_:Number;
	}
}