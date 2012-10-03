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

package org.rje.glaze.engine.collision.shapes {
	import org.rje.glaze.engine.math.Ray;

	import flash.display.Graphics;

	import org.rje.glaze.engine.math.Vector2D;

	/*
	 * Axis Aligned Bounding Box Class
	 * Used to create retangular proxy for shapes, mainly used for fast overlap checking
	 */
	public class AABB {
		
		public var l:Number;
		public var b:Number;
		public var r:Number;
		public var t:Number;
		
		public var radiusSqr:Number;
		
		public function AABB( l:Number = 0 , b:Number = 0, r:Number = 0  , t:Number = 0) {
			this.l = l;
			this.b = b;
			this.r = r;
			this.t = t;
		}
		
		public function intersects( aabb:AABB ):Boolean {
			return !(aabb.l > r || aabb.r < l || aabb.t > b || aabb.b < t);
		}
		
		public function intersects2( aabb:AABB ):Boolean {
			return (l<=aabb.r && aabb.l<=r && t<=aabb.b && aabb.t<=b);
		}
		
		public function expand( aabb:AABB ):void {
			if (aabb.l < this.l) this.l = aabb.l;
			if (aabb.r > this.r) this.r = aabb.r;
			if (aabb.t < this.t) this.t = aabb.t;
			if (aabb.b > this.b) this.b = aabb.b;
		}
		
		public function containsPoint(point:Vector2D):Boolean {
			return ((point.x>=l) && (point.x<=r) && (point.y>=t) && (point.y<=b));
		}

//bool rayAABBIntersect1D(float start, float dir, float length, float min, float max, float& enter, float& exit)
//{
//    // ray parallel to direction
//    if(fabs(dir) < 1.0E-8) 
//        return (start >= min && start <= max);
//
//    // intersection params
//    float t0, t1;
//    t0 = (min - start) / dir;
//    t1 = (max - start) / dir;
//
//    // sort intersections
//    if(t0 > t1) swap(t0, t1);
//
//    // reduce interval
//    if(t0 > enter) enter = t0;
//    if(t1 < exit) exit = t1;
//
//    // ray misses the box
//    if(exit < enter) 
//        return false;
//
//    // intersections outside ray boundaries
//    if(exit < 0.0f || enter > length) 
//        return false;
//
//    return true;
//}
		//FIXME replace Object for Class or member variables
		private function rayAABBIntersect1D(start:Number, dir:Number, length:Number, min:Number, max:Number, enterexit:Object):Boolean {
		    // ray parallel to direction
		    if(Math.abs(dir) < 1.0E-8) 
		        return (start >= min && start <= max);
		
		    // intersection params
		    var t0:Number, t1:Number;
		    t0 = (min - start) / dir;
		    t1 = (max - start) / dir;
		
		    // sort intersections
		    if(t0 > t1) {
		    	//Swaped code
			    // reduce interval
		    	if(t1 > enterexit.enter) enterexit.enter = t1;
		    	if(t0 < enterexit.exit) enterexit.exit = t0;
		    } else {
			    // reduce interval
		    	if(t0 > enterexit.enter) enterexit.enter = t0;
		    	if(t1 < enterexit.exit) enterexit.exit = t1;		    	
		    }
		
		    // ray misses the box
		    if(enterexit.exit < enterexit.enter) 
		        return false;
		
		    // intersections outside ray boundaries
		    if(enterexit.exit < 0.0 || enterexit.enter > length) 
		        return false;
		
		    return true;
		}

//
//bool rayAABBIntersect(Vector start, Vector dir, float length, Vector min, Vector max, Vector& penter, Vector& pexit)
//{
//    float enter = -INFINITY, exit = INFINITY;
//
//    if(!rayAABBIntersect1D(start.x, dir.x, length, min.x, max.x, enter, exit))
//        return false;
//
//    if(!rayAABBIntersect1D(start.y, dir.y, length, min.y, max.y, enter, exit))
//        return false;
//    
//    if(!rayAABBIntersect1D(start.z, dir.z, length, min.z, max.z, enter, exit))
//        return false;
//
//    penter = start + dir * enter;
//    pexit  = start + dir * exit;
//    return true;
//}
		public function IntersectRay( ray : Ray ) : Boolean {
			//var enter:Number = Number.NEGATIVE_INFINITY, exit:Number = Number.POSITIVE_INFINITY;
			var enterexit:Object = {enter:Number.NEGATIVE_INFINITY, exit:Number.POSITIVE_INFINITY};
			if(!rayAABBIntersect1D(ray.origin.x, ray.direction.x, ray.range, l, r, enterexit)) return false;
			if(!rayAABBIntersect1D(ray.origin.y, ray.direction.y, ray.range, t, b, enterexit)) return false;
			//FIXME Return the correct ray normal
			return ray.reportResult(null, enterexit.enter, ray.returnNormal ? new Vector2D() : new Vector2D());
			
			//return false;
		}

		public function draw(g:Graphics) : void {
			g.lineStyle(1, 0x000000);
			g.drawRect(l, t, r - l, b - t);
		}

		
		public function toString():String {
			return ("l=" + l + " b=" + b + " r=" + r + " t=" + t );
		}

		public static function createAt( x:Number, y:Number, xExtent:Number , yExtent:Number ):AABB {
			return new AABB( x - xExtent, y + yExtent, x + xExtent, y - yExtent );
		}
		
	}
	
}
