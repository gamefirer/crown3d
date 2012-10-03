// glaze - 2D rigid body dynamics & game engine
// Copyright (c) 2010, Richard Jewson
// 
// This project also contains work derived from the Chipmunk & APE physics engines.  
// 
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// * Redistributions of source code must retain the above copyright notice,
//   this list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
// CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

package org.rje.glaze.engine.dynamics 
{
	import blade3d.physics.blPhyOwner;
	
	import flash.display.Graphics;
	
	import mx.core.mx_internal;
	
	import org.rje.glaze.engine.collision.shapes.GeometricShape;
	import org.rje.glaze.engine.dynamics.forces.Force;
	import org.rje.glaze.engine.math.Vector2D;
	import org.rje.glaze.engine.space.Space;

	/**
	 * 
	 */
	public class RigidBody {

		protected var _owner : blPhyOwner;		// 物理对象的拥有者
		
		public var m : Number;			// Body Mass 
		public var m_inv : Number;		// Body inverse mass

		public var i : Number;			// Moment of inertia
		public var i_inv : Number;		// Moment of inertia inverse
		
		// Linear components of
		public const p : Vector2D = new Vector2D();			// Position
		public const v : Vector2D = new Vector2D();			// Velocity
		public const f : Vector2D = new Vector2D();			// Force
		public const v_bias : Vector2D = new Vector2D();     // 速度的修正 used internally for penetration/joint correction

		public var maxVelocityScalar : Number = 1000;
		public var maxVelocityScalarSqr : Number = 1000 * 1000;

		public var canSleep : Boolean;
		public var isSleeping : Boolean;
		public var checked : uint;

		public var motion : Number = 0.0002;
		public static var bias : Number = 0.99332805041467;
		public static const sleepEpsilon : Number = 0.001;

		// Angular components of motion
		public var a : Number;			// angle
		public var w : Number;			// angular velocity
		public var t : Number;			// torque
		public var w_bias : Number;		// used internally for penetration/joint correction

		public var space : Space;

		//public var arbiters:Array;
		public var arbiters : ArbiterProxy;

		//public var rotationLocked:Boolean;
		private var storedInertia : Number = -1;

		// Unit length 
		public const rot : Vector2D = new Vector2D(); 

		//Collision Type (unused)
		public var collision_type : uint;		
		//Group id
		public var group : uint;
		//Layer bitmask
		public var layers : uint;	

		public var collisionProcessingMask : uint = 7;

		public var isFixed : Boolean;
		public var isStatic : Boolean;
		public var isBlockable : Boolean = false;			// 是否受到阻挡

		private var calcMassInertia : Boolean;
		public var memberShapes : Vector.<GeometricShape>;

		protected var forceGenerators : Vector.<Force>;
		
		public var bodyID : uint = 0;
		public static var nextBodyID : uint = 0;

		public var next : RigidBody;
		public var prev : RigidBody;

		public static const STATIC_BODY : int = 0;
		public static const DYNAMIC_BODY : int = 1;
		public static const FIXED_DYNAMIC_BODY : int = 2;

		public function RigidBody( type : int = DYNAMIC_BODY, m : Number = -1 , i : Number = -1 ) {
			
			bodyID = nextBodyID++;
			
			switch (type) {
				case STATIC_BODY: 			
					isStatic = true;   
					isFixed = false; 
					break;
				case DYNAMIC_BODY:			
					isStatic = false;  
					isFixed = false; 
					break;
				case FIXED_DYNAMIC_BODY:	
					isStatic = false;  
					isFixed = true;  
					break;
			}
			
			this.calcMassInertia = (m < 0) || (i < 0);
			
			if (isStatic) {
				this.calcMassInertia = false;
				setMass(Number.POSITIVE_INFINITY);
				setMoment(Number.POSITIVE_INFINITY);
			} else if (!calcMassInertia) {
				setMass(m);
				setMoment(i);
			}
			
			//setMaxVelocity(150);
			
			a = w = t = w_bias = 0;
			
			memberShapes = new Vector.<GeometricShape>();
			
			arbiters = new ArbiterProxy();
			arbiters.next = arbiters;
			arbiters.prev = arbiters;
			arbiters.sentinel = true;
			
			group = 0;
			layers = 0xFFFF;
			
			setAngle(0);
			
			collisionProcessingMask = 0;
		}

		public function registerSpace( space : Space ) : void {
			this.space = space;
		}

		public function unregisterSpace() : void {
			this.space = null;
		}
		
		public function get owner() : blPhyOwner { return _owner; }

		public function addShape( shape : GeometricShape , updateMI : Boolean = true ) : GeometricShape {

			shape.registerBody(this);

			memberShapes.push(shape);
			
			if (space) space.addShape(shape);
			
			if (calcMassInertia && updateMI) calculateMassInertia();
			
			return shape;
		}

		public function removeShape( shape : GeometricShape , updateMI : Boolean = true ) : void {
			
			var index : int = memberShapes.indexOf(shape);
			if (index >= 0)
				memberShapes.splice(index, 1);
			
			if (space) space.removeShape(shape);	
				
			if (calcMassInertia && updateMI) calculateMassInertia();
		}

		public function addArbiter( arb : Arbiter ) : void {
			var newProxy : ArbiterProxy;
			
			if (ArbiterProxy.arbiterProxyPool) {
				newProxy = ArbiterProxy.arbiterProxyPool;
				ArbiterProxy.arbiterProxyPool = ArbiterProxy.arbiterProxyPool.next;
			} else {
				newProxy = new ArbiterProxy();
			}
			newProxy.arbiter = arb;
			
			newProxy.prev = arbiters;
			newProxy.next = arbiters.next;
			arbiters.next = newProxy;
			newProxy.next.prev = newProxy;
		}

		public function getArbiter( id1 : uint , id2 : uint ) : Arbiter {
			var arbProxy : ArbiterProxy;
			for (arbProxy = arbiters.next;arbProxy.sentinel != true;arbProxy = arbProxy.next ) {
				if ((arbProxy.arbiter.id1 == id1) && (arbProxy.arbiter.id2 == id2)) return arbProxy.arbiter;
				if ((arbProxy.arbiter.id1 == id2) && (arbProxy.arbiter.id2 == id1)) return arbProxy.arbiter;
			}
			return null;
		}		

		public function removeArbiter( arb : Arbiter ) : void {
			
			var arbProxy : ArbiterProxy;
			for (arbProxy = arbiters.next;arbProxy.sentinel != true;arbProxy = arbProxy.next ) {
				if (arbProxy.arbiter == arb) {
					arbProxy.prev.next = arbProxy.next;
					arbProxy.next.prev = arbProxy.prev;
					arbProxy.next = ArbiterProxy.arbiterProxyPool;
					ArbiterProxy.arbiterProxyPool = arbProxy;
					return;
				}
			}
		}

		public function setMass( m : Number) : void {
			this.m = m;
			this.m_inv = 1 / m;
		}

		public function setMoment( i : Number) : void {
			this.i = i;
			this.i_inv = 1 / i;
		}

		public function set rotationLocked( value : Boolean ) : void {
			if (value) {
				storedInertia = i;
				setMoment(Number.POSITIVE_INFINITY);
			} else {
				setMoment(storedInertia);
				storedInertia = -1;
			}
		}

		public function get rotationLocked() : Boolean {
			return (storedInertia != -1); 		
		}

		public function setMaxVelocity( mv : Number) : void {
			if (mv >= 0) {
				maxVelocityScalar = mv;
				maxVelocityScalarSqr = maxVelocityScalar * maxVelocityScalar;
			} else {
				maxVelocityScalar = -1;
				maxVelocityScalarSqr = -1;
			}
		}

		public function calculateMassInertia() : void {
			var newMass : Number = 0;
			var newMomementInertia : Number = 0;
			var shape : GeometricShape;
			for each (shape in memberShapes) {
				newMass += shape.mass;
				newMomementInertia += shape.CalculateInertia(shape.mass, shape.offset);
			}
			setMass(newMass);
			setMoment(newMomementInertia);
		}

		public function setAngle( a : Number) : void {
			this.a = a % 6.28318530717; //(2*Pi)
			//this.rot.forAngleEquals(this.a);
			rot.x = Math.cos(a);
			rot.y = Math.sin(a);
		}

		public function slew(pos : Vector2D, dt : Number) : void {
			//cpVect delta = cpvsub(body->p, pos);
			//body->v = cpvmult(delta, 1.0/dt);
			var delta:Vector2D = p.minus(pos);
			v.copy(delta.multEquals(1/dt));
		}

		public function UpdateVelocity( persistantMasslessForce : Vector2D, force : Vector2D, damping : Number, dt : Number) : void {
			
			if (forceGenerators) {
				for each (var forceGenerator : Force in forceGenerators) {
					forceGenerator.eval(this);
				}
			}
			
			if (isSleeping || isFixed) return;
			
			v.x = (v.x * damping) + ( (persistantMasslessForce.x + ((force.x + f.x) * m_inv) ) * dt);
			v.y = (v.y * damping) + ( (persistantMasslessForce.y + ((force.y + f.y) * m_inv) ) * dt);
			w = (w * damping) + (t * i_inv * dt);
			checked = 0;
			if (maxVelocityScalarSqr > 0) {
				var scalarVelocitySqr : Number = v.x * v.x + v.y * v.y;
				
				if (scalarVelocitySqr > maxVelocityScalarSqr) {
					var factor : Number = maxVelocityScalar / Math.sqrt(scalarVelocitySqr);
					v.x *= factor;
					v.y *= factor;
				}
			}
		}
		
		public var realV:Vector2D = new Vector2D;		// 实际速度
		public var biasV:Vector2D= new Vector2D;

		public function UpdatePosition( dt : Number) : void {
			
			if(false)
			{
				// v_bais只改变速度方向,不改变速度大小
				
				realV.x = v.x + v_bias.x;
				realV.y = v.y + v_bias.y;
	//			Debug.bltrace("v1="+realV.x.toFixed(2)+" "+realV.y.toFixed(2));
				realV = realV.normalize();
				realV = realV.mult(v.magnitude());
	//			Debug.bltrace("v2="+realV.x.toFixed(2)+" "+realV.y.toFixed(2));
				p.x += (realV.x * dt);
				p.y += (realV.y * dt);
				
				biasV.x = v_bias.x;
				biasV.y = v_bias.y;
			}
			else
			{
				realV.x = v.x + v_bias.x;
				realV.y = v.y + v_bias.y;
				biasV.x = v_bias.x;
				biasV.y = v_bias.y;
				
				p.x += ((v.x + v_bias.x) * dt);		// old code
				p.y += ((v.y + v_bias.y) * dt);
			}
						
			motion = (bias * motion) + ((1 - bias) * (v.x * v.x + v.y * v.y + w * w));
			
			if (motion > (10 * sleepEpsilon)) motion = 10 * sleepEpsilon;
			
			canSleep = motion < sleepEpsilon;		// 如果移动距离太小，则进入睡眠
			if (!canSleep) isSleeping = false;

			setAngle(a + ((w + w_bias) * dt));
			
			v_bias.x = v_bias.y = 0;
			w_bias = 0;
		}

		public function sleep() : void {
			v.x = v.y = w = 0;
			isSleeping = true;
			var arbProxy : ArbiterProxy;
			for (arbProxy = arbiters.next;arbProxy.sentinel != true;arbProxy = arbProxy.next ) {
				arbProxy.arbiter.sleeping = true;
			}
		}	

		public function wake( stamp : int ) : void {
			motion = 10 * sleepEpsilon;
			canSleep = isSleeping = false;
			var arbProxy : ArbiterProxy;
			for (arbProxy = arbiters.next;arbProxy.sentinel != true;arbProxy = arbProxy.next ) {
				arbProxy.arbiter.sleeping = false;
				arbProxy.arbiter.stamp = stamp;
			}
		}		

		public function resetForces() : void {
			f.x = f.y = t = 0;
		}

		public function ApplyImpulse( j : Vector2D , r : Vector2D ) : void {
			if (isSleeping) wake(space.stamp);
			v.x += (j.x * m_inv);
			v.y += (j.y * m_inv);
			w += i_inv * (r.x * j.y - r.y * j.x);
		}

		public function ApplyBiasImpulse( j : Vector2D , r : Vector2D ) : void {
			if (isSleeping) wake(space.stamp);
			v_bias.x += (j.x * m_inv);
			v_bias.y += (j.y * m_inv);
			w_bias += i_inv * (r.x * j.y - r.y * j.x);
		}

		public function ApplyForces( force : Vector2D , r : Vector2D) : void {
			if (isSleeping) wake(space.stamp);
			f.x += (force.x * m_inv);
			f.y += (force.y * m_inv);
			t = i_inv * (r.x * force.y - r.y * force.x);
		}

		public function AddForceGenerator( force:Force ):Force {
			if (!force) return null;
			if (!forceGenerators) {
				forceGenerators = new Vector.<Force>();
			}
			forceGenerators[forceGenerators.length] = force;
			return force;
		}

		public function RemoveForceGenerator( force:Force ):void {
			if (!force) return;
			var i : int = forceGenerators.indexOf(force);
			if (i>=0) forceGenerators.splice(i, 1);
		}

		public function draw( g : Graphics ) : void {
			for each (var shape : GeometricShape in memberShapes) {
				shape.draw(g);
			}
		}
		
		public virtual function onStep( stepDT : int ) : void {
		}		

		public virtual function onPhysicsStep( physicsStepDT : int ) : void {
		}		

		public function onStartCollision(body : RigidBody) : void {
			if(_owner)
				_owner.onStartCollision(this, body);
		}

		public function onCollision(body : RigidBody) : void {
			if(_owner)
				_owner.onCollision(this, body);
		}

		public function onEndCollision(body : RigidBody) : void {
			if(_owner)
				_owner.onEndCollision(this, body);
		}		
	}
}
