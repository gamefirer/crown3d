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

package org.rje.glaze.engine.math {
	import org.rje.glaze.engine.collision.shapes.GeometricShape;
	import org.rje.glaze.engine.dynamics.RigidBody;

	/**
	 * 
	 */
	public class Ray {
		
		public var origin:Vector2D;
		public var target:Vector2D;
		public var direction:Vector2D;

		public var fdirection:Vector2D;
		
		public var castingBody:RigidBody;
		
		public var range:Number;
		public var rangeSqr:Number;
		
		public var endpoint:Vector2D;
		
		public var isSegment:Boolean;
		
		public var returnNormal:Boolean;
	
		public var lastIntersectResult:Boolean;
		public var lastIntersectDistance:Number;
		public var lastIntersectShape:GeometricShape;
		
		public var intersectInRange:Boolean;
		public var closestIntersectDistance:Number;
		public var closestIntersectNormal:Vector2D;
		public var closestIntersectShape:GeometricShape;
		
		public function Ray(origin:Vector2D , target:Vector2D , castingBody:RigidBody = null , range:Number = Number.POSITIVE_INFINITY) {
			reset(origin, target, castingBody, range);
//			this.origin = origin;
//			this.target = target;
//			direction = target.minus(origin).normalize();
//			fdirection = direction.abs();
//			
//			this.castingBody = castingBody;
//			closestIntersectDistance = Number.POSITIVE_INFINITY;
//			
//			if (range < Number.POSITIVE_INFINITY) { 
//				isSegment = true;
//				endpoint = origin.plus(direction.mult(range));
//			} 
//			
//			this.range = range;
//			this.rangeSqr = range * range;
		}
		
		public function reset(origin:Vector2D , target:Vector2D , castingBody:RigidBody = null , range:Number = Number.POSITIVE_INFINITY) : void {
			this.origin = origin;
			this.target = target;
			direction = target.minus(origin).normalize();
			fdirection = direction.abs();
			
			this.castingBody = castingBody;
			closestIntersectDistance = Number.POSITIVE_INFINITY;
			
			if (range < Number.POSITIVE_INFINITY) { 
				isSegment = true;
				endpoint = origin.plus(direction.mult(range));
			}
			
			this.range = range;
			this.rangeSqr = range * range;
		}
		
		public function testShape(shape:GeometricShape):Boolean {
			lastIntersectResult = false;  
			if (castingBody && shape.body == castingBody) { 
				return false;
			}
			return shape.IntersectRay(this);
		}
		
		public function reportResult( shape:GeometricShape , dist:Number , normal:Vector2D = null ):Boolean {
			
			if (dist>=range) {
				lastIntersectResult = false;
				return false;
			}
			intersectInRange = true;
			lastIntersectResult = true;
			lastIntersectDistance = dist;
			lastIntersectShape = shape;
			
			if (dist < closestIntersectDistance) {
				closestIntersectDistance = dist;
				closestIntersectShape = shape;
				closestIntersectNormal = normal;
			}
			
			return true;
		}
		
		public function get lastIntersectPoint():Vector2D {
			return new Vector2D(origin.x + (direction.x * lastIntersectDistance), origin.y + (direction.y * lastIntersectDistance));
		}
		
		public function get closestIntersectPoint():Vector2D {
			return new Vector2D(origin.x + (direction.x * closestIntersectDistance), origin.y + (direction.y * closestIntersectDistance));
		}
		
		/*
		public function intersectAABB( aabb:AABB ):Boolean {
			var Dx:Number = origin.x - aabb.xCenter;
			var Dy:Number = origin.y - aabb.yCenter;

			//if ( range && (Dx*Dx+Dy*Dy)>rangeSqr ) return false
			if ((((Dx<0)?-Dx:Dx) > aabb.xExtent) && ((Dx * direction.x) >= 0)) return false;
			if ((((Dy<0)?-Dy:Dy) > aabb.yExtent) && ((Dy * direction.y) >= 0)) return false;	
			var f:Number = direction.x * Dy - direction.y * Dx;	
			if (f < 0) f = -f;
			if (f > (aabb.xExtent * fdirection.y + aabb.yExtent * fdirection.x) ) return false;
			return true;
		}
		*/
		
	}
	
}
