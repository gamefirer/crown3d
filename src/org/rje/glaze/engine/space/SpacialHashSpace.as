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

package org.rje.glaze.engine.space 
{
	import org.rje.glaze.engine.collision.shapes.AABB;
	import org.rje.glaze.engine.collision.shapes.GeometricShape;
	import org.rje.glaze.engine.math.PrimeNumber;
	import org.rje.glaze.engine.math.Ray;
	import org.rje.glaze.engine.math.Vector2D;

	/**
	 * 
	 */
	public class SpacialHashSpace extends Space {
		
		public var numBuckets:int;
		public var gridsize:Number;
		public var invGridsize:Number;
		
		public var activeBuckets:Vector.<Vector.<GeometricShape>>;
		public var staticBuckets:Vector.<Vector.<GeometricShape>>;
									   
		public const hashValue1:uint = 1640531513;//2185031351
		public const hashValue2:uint = 2654435789;
		
		public function SpacialHashSpace( fps:int , pps:int , worldBoundary:AABB = null , numBuckets:int = 257 , gridsize:Number = 50 ) {
			super(fps,pps,worldBoundary);
			broadphaseCounter.name += " Spacial Hash";
			this.numBuckets = PrimeNumber.next_prime(numBuckets);
			this.gridsize = gridsize;
			this.invGridsize = 1/gridsize;
			activeBuckets = new Vector.<Vector.<GeometricShape>>(numBuckets, false);
			staticBuckets = new Vector.<Vector.<GeometricShape>>(numBuckets, false);
			
			for (var i:int = 0; i < numBuckets; i++) {
				activeBuckets[i] = new Vector.<GeometricShape>;
				staticBuckets[i] = new Vector.<GeometricShape>;
			}
		}
		
		public function hashShapes( shapes:GeometricShape , bucket:Vector.<Vector.<GeometricShape>> ):void {
			var thisBucket:Vector.<GeometricShape>;
			for (var z:int = 0; z < numBuckets; z++) {
				thisBucket = bucket[z];
				thisBucket.length = 0;
				broadphaseCounter.counter++;
			}			
//			var i:uint , j:uint;
			var i:int , j:int;					// jerryO modify(支持负数空间)
			var l:int, r:int , b:int, t:int;
			
			var shape:GeometricShape = shapes;
			while (shape) {
				l = int(shape.aabb.l*invGridsize);
				r = int(shape.aabb.r*invGridsize);
				b = int(shape.aabb.b*invGridsize);
				t = int(shape.aabb.t*invGridsize);
				for (i = l; i <= r ; i++) {
					for (j = t; j <= b ; j++) {
						var hash:uint = (i * hashValue1)^(j * hashValue2);
						hash %= numBuckets;
						thisBucket = bucket[int(hash)];
						thisBucket[thisBucket.length] = shape;
						broadphaseCounter.counter++;
					}
				}
				shape = shape.next;
			}			
		}
		
		public override function syncBroadphase():void {
			hashShapes(staticShapes, staticBuckets);
		}
		
		public override function broadPhase():void {

			hashShapes(activeShapes, activeBuckets);
			
			var i:int , j:int, k:int, z:int;
			
			var s1:GeometricShape;
			var s2:GeometricShape;
			var s3:GeometricShape;

			for (z = 0; z < numBuckets; z++) {
				
				var thisActiveBucket:Vector.<GeometricShape> = activeBuckets[z];
				var thisActiveBucketLen:int = thisActiveBucket.length;
				var thisStaticBucket:Vector.<GeometricShape> = staticBuckets[z];
				var thisStaticBucketLen:int = thisStaticBucket.length;
				
				for (i = 0; i < thisActiveBucketLen; i++) {
					s1 = thisActiveBucket[i];
					
					for (j = i + 1; j < thisActiveBucketLen; j++) {
						s2 = thisActiveBucket[j];
						broadphaseCounter.counter++;
						if (s2.aabb.l <= s1.aabb.r) {
							if (s1.aabb.l <= s2.aabb.r) {
								if (s2.aabb.t <= s1.aabb.b) {
									if (s1.aabb.t <= s2.aabb.b) {
										narrowPhase(s1,s2);			// 动态物体间碰撞
									}
								}
							}
						}
					}
					
					for (k = 0; k < thisStaticBucketLen; k++) {
						s3 = thisStaticBucket[k];
						if (s3.aabb.l <= s1.aabb.r) {
							if (s1.aabb.l <= s3.aabb.r) {
								if (s3.aabb.t <= s1.aabb.b) {
									if (s1.aabb.t <= s3.aabb.b) {
										narrowPhase(s1,s3);			// 动态物体和静态物体的碰撞
									}
								}
							}
						}
					}
					
				}
			}
//			Debug.bltrace("broadphaseCounter="+broadphaseCounter.counter);
			broadphaseCounter.endCycle();
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
