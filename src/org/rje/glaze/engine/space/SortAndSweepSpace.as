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
	import away3d.debug.Profiler;
	
	import org.rje.glaze.engine.collision.shapes.AABB;
	import org.rje.glaze.engine.collision.shapes.GeometricShape;
	import org.rje.glaze.engine.math.Ray;
	import org.rje.glaze.engine.math.Vector2D;

	/**
	 * 
	 */
	public class SortAndSweepSpace extends Space {
		
		public function SortAndSweepSpace( fps:int , pps:int , worldBoundary:AABB = null ) {
			super(fps,pps,worldBoundary);
			broadphaseCounter.name += " Sort&Sweep";
		}
		
		public function Sort(head:GeometricShape):GeometricShape {
			if (!head) return null;
			var h:GeometricShape = head, p:GeometricShape, n:GeometricShape, m:GeometricShape, i:GeometricShape;
			n = h.next;
			while (n) {
				m = n.next;
				p = n.prev;
				broadphaseCounter.counter++;
				
				if (p.aabb.t > n.aabb.t) {
					i = p;
					
					while (i.prev) {
						broadphaseCounter.counter++;
						if (i.prev.aabb.t > n.aabb.t)
							i = i.prev;
						else
							break;
					}
					if (m) {
						p.next = m;
						m.prev = p;
					} else
						p.next = null;
					
					if (i == h) {
						n.prev = null;
						n.next = i;
						
						i.prev = n;
						h = n;
					} else {
						n.prev = i.prev;
						i.prev.next = n;
						
						n.next = i;
						i.prev = n;
					}
				}
				n = m;
			}
			return h;
		}
		
		public override function broadPhase():void {
			
			Profiler.start("Sort");
			activeShapes = Sort(activeShapes);				// 根据AABB排序
			Profiler.end("Sort");
			
			var shape1:GeometricShape = activeShapes;
			var shape2:GeometricShape;
			var shape3:GeometricShape = staticShapes;
			var shape4:GeometricShape;
			
			while (shape1) {
				shape2 = shape1.next;
				while (shape2) {
					broadphaseCounter.counter++;
					if (shape2.aabb.t > shape1.aabb.b) break;
					if (shape1.aabb.l <= shape2.aabb.r) {
						if (shape1.aabb.r >= shape2.aabb.l) {
							narrowPhase(shape1, shape2);			// 动态物理间碰撞
						}
					}
					shape2 = shape2.next;
				}	
				
				while (shape3) {
					broadphaseCounter.counter++;
					if (shape3.aabb.t > shape1.aabb.b) break;
					if (shape3.aabb.t <= shape1.aabb.b) {
						if (shape1.aabb.t <= shape3.aabb.b) {
							break;
						}
					}
					shape3 = shape3.next;
				}
				
				shape4 = shape3;
				while (shape4) {
					broadphaseCounter.counter++;
					if (shape4.aabb.t > shape1.aabb.b) break;
					if (shape1.aabb.l <= shape4.aabb.r) {
						if (shape1.aabb.r >= shape4.aabb.l) {
							narrowPhase(shape1, shape4);		// 动态物体和静态物体间碰撞
						}
					}
					shape4 = shape4.next;					
				}				
				shape1 = shape1.next;
			}
//			Debug.bltrace("broadphaseCounter="+broadphaseCounter.counter);
			broadphaseCounter.endCycle();
		}
		
		public override function syncBroadphase():void {
			staticShapes = Sort(staticShapes);
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
		
		/*
		public override function castRay( ray:Ray ):Boolean {
			var rayDirDown:Boolean = ray.direction.y > 0;
			var lastShape:GeometricShape = findClosestShape( ray.origin, activeShapes);
			if (rayDirDown) {
				
			}
			return ray.intersectInRange;
		}
		
		public function findClosestShape( origin:Vector2D, head:GeometricShape ):GeometricShape {
			var shape:GeometricShape = head;
			var lastshape:GeometricShape;
			while (head) {
				if (shape.aabb.t > origin.y) return shape;
				lastshape = shape;
				shape = shape.next;
			}
			return lastshape;
		}
		*/
	}
	
}
