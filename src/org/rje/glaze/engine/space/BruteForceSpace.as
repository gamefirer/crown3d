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

package org.rje.glaze.engine.space {
	import org.rje.glaze.engine.collision.shapes.AABB;
	import org.rje.glaze.engine.collision.shapes.GeometricShape;
	import org.rje.glaze.engine.math.Ray;
	import org.rje.glaze.engine.math.Vector2D;

	/**
	 * 
	 */
	public class BruteForceSpace extends Space {
		
		public function BruteForceSpace( fps:int , pps:int , worldBoundary:AABB = null ) {
			super(fps,pps,worldBoundary);
			broadphaseCounter.name += " Brute Force";
		}
		
		public override function broadPhase():void {
			var s1:GeometricShape = activeShapes;
			var s2:GeometricShape, s3:GeometricShape;
			while (s1) {
				s2 = s1.next;
				while (s2) {
					broadphaseCounter.counter++;
					if (s2.aabb.l <= s1.aabb.r) {
						if (s1.aabb.l <= s2.aabb.r) {
							if (s2.aabb.t <= s1.aabb.b) {
								if (s1.aabb.t <= s2.aabb.b) {
									narrowPhase(s1,s2);
								}
							}
						}
					}
					s2 = s2.next;
				}
				s3 = staticShapes;
				while (s3) {
					broadphaseCounter.counter++;
					if (s3.aabb.l <= s1.aabb.r) {
						if (s1.aabb.l <= s3.aabb.r) {
							if (s3.aabb.t <= s1.aabb.b) {
								if (s1.aabb.t <= s3.aabb.b) {
									narrowPhase(s1,s3);
								}
							}
						}
					}
					s3 = s3.next;
				}
				s1 = s1.next;
			}
			broadphaseCounter.endCycle();
		}
		
		public override function syncBroadphase():void {
		}
		
		public override function castRay( ray:Ray ):Boolean {
			var shape:GeometricShape = activeShapes;
			while (shape) {
				ray.testShape(shape);
				shape = shape.next;
			}
			
			shape = staticShapes;
			while (shape) {
				ray.testShape(shape);
				shape = shape.next;
			}
			
			return ray.intersectInRange;
		}
		
		public override function getShapeAtPoint( point:Vector2D ):GeometricShape {
			var shape:GeometricShape = activeShapes;
			while (shape) {
				if (shape.ContainsPoint(point)) {
					return shape;
				}
				shape = shape.next;
			}
			
			shape = staticShapes;
			while (shape) {
				if (shape.ContainsPoint(point)) {
					return shape;
				}
				shape = shape.next;
			}
			
			return null;
		}		
		
	}
	
}