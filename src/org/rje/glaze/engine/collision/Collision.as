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

package org.rje.glaze.engine.collision {
	import org.rje.glaze.engine.collision.shapes.*;
	import org.rje.glaze.engine.dynamics.*;
	import org.rje.glaze.engine.math.*;	

	public class Collision implements ICollide {
		
		public static const hash_coef:uint = 3344921057;
		
		public function Collision() {
			
		}

		/** 
		 * Narrow phase collision between two polygons
		 */	
		public function poly2poly( shape1:Polygon , shape2:Polygon ,arb:Arbiter ):Boolean {
			
			var v:Vector2D;
			var vertValOnAxis:Number;
			var minValOnAxis:Number;
			
			var minPen1:Number = -4294967296;// Number.MAX_VALUE;
			var minAxis1:Axis;
			
			var first:Boolean = true;
			
			//First, project shape 2 vertices onto shape 1 axes & find MSA
			var a:Axis = shape1.tAxes;
			while (a) {
				
				//Inline code
				//result = shape2.valueOnAxis(a.n,a.d);
				minValOnAxis = 4294967296;// Number.MAX_VALUE;
				v = shape2.tVerts;
				while (v) { 
					
					vertValOnAxis = (a.n.x * v.x + a.n.y * v.y) - a.d;
					if (first||v.flag) {
						v.flag = vertValOnAxis <= 0;
					}
					if (vertValOnAxis < minValOnAxis) minValOnAxis = vertValOnAxis;
					v = v.next;
				}
				//End inline
				
				//No penetration on this axis, early out
				if (minValOnAxis > 0) return false; 
				if (minValOnAxis > minPen1) {
					minPen1 = minValOnAxis;
					minAxis1 = a;
				}
				first = false;
				a = a.next;
			}

			var minPen2:Number = -4294967296;// Number.MAX_VALUE;
			var minAxis2:Axis;
			first = true;

			//Second, project shape 1 vertices onto shape 2 axes & find MSA
			a = shape2.tAxes;
			while (a) {
				//Inline code
				//result = shape1.valueOnAxis(a.n, a.d);
				minValOnAxis = 4294967296;// Number.MAX_VALUE;
				v = shape1.tVerts;
				while (v) { 
					vertValOnAxis = (a.n.x * v.x + a.n.y * v.y) - a.d;
					if (first||v.flag) {
						v.flag = vertValOnAxis <= 0;
					} 
					if (vertValOnAxis < minValOnAxis) minValOnAxis = vertValOnAxis;
					v = v.next;
				}
				//minValOnAxis -= a.d;
				//End inline
				
				//No penetration on this axis, early out
				if (minValOnAxis > 0) return false;
				if (minValOnAxis > minPen2) {
					minPen2 = minValOnAxis;
					minAxis2 = a;
				}
				first = false;
				a = a.next;
			}

			if (arb.isSensor) return true;

			//Process contact points
			
			var axis:Axis;
			var nCoef:Number;
			var dist:Number;
			
			if (minPen1 > minPen2) {
				axis = minAxis1;
				nCoef = 1;
				dist = minPen1;
			} else {
				axis = minAxis2;
				nCoef = -1;
				dist = minPen2;				
			}
			
			var i:int = 0;
			var c:int = 0;
			v = shape1.tVerts;
			while (v) {
				if (v.flag) {
					arb.injectContact(v.x, v.y, axis.n.x, axis.n.y, nCoef, dist, (shape1.shapeID << 8) | i );// (shape1.shapeID * 3344921057) ^ (i * 3344921057) );
					if (++c > 1) return true;  //never more than 2 support points?
				}
				i++;
				v = v.next;
			}
			i = 0;
			v = shape2.tVerts;
			while (v) {
				if (v.flag) {
					arb.injectContact( v.x, v.y, axis.n.x, axis.n.y, nCoef, dist, (shape2.shapeID << 8) | i ); // (shape2.shapeID * 3344921057) ^ (i * 3344921057)) ;
					if (++c > 1) return true; //never more than 2 support points?
				}
				i++;
				v = v.next;
			}
		
			return true;
		}
		

		/** 
		 * Narrow phase collision between two circles
		 */	
		public function circle2circle( circle1:Circle , circle2:Circle , arb:Arbiter ):Boolean {
			return circle2circleQuery(arb , circle1.tC, circle2.tC, circle1.r, circle2.r);
		}

		/** 
		 * Circle/Circle test used by several collision functions
		 */	
		public function circle2circleQuery( arb:Arbiter, p1:Vector2D , p2:Vector2D , r1:Number , r2:Number ):Boolean {
			
			var minDist:Number = r1+r2;
			var x:Number = p2.x - p1.x;
			var y:Number = p2.y - p1.y;
			var distSqr:Number = x * x + y * y;
			if (distSqr >= (minDist * minDist) ) return false;
			var dist:Number = Math.sqrt(distSqr) + 0.0000001;
			var invDist:Number = 1 / dist;
			var deltaFact:Number = 0.5 + (r1 - 0.5 * minDist) / dist;			
			arb.injectContact( p1.x + x * deltaFact , 
							   p1.y + y * deltaFact ,
							   x * invDist,
							   y * invDist,
							   1,
							   dist - minDist,
							   0);
			return true;
		}
				
		/** 
		 * Narrow phase collision between circle and line segment
		 */	
		public function circle2segment( circle:Circle , seg:Segment , arb:Arbiter ):Boolean {
			var rsum:Number = circle.r + seg.r;
			var dn:Number = (seg.tN.x * circle.tC.x + seg.tN.y * circle.tC.y) - seg.tNdottA;
			var dist:Number = ((dn<0)?-dn:dn) - rsum;
			if (dist > 0) return false;
	
			var dt:Number 		= -(seg.tN.x * circle.tC.y - seg.tN.y * circle.tC.x);
			var dtMin:Number 	= -(seg.tN.x * seg.tA.y - seg.tN.y * seg.tA.x);
			var dtMax:Number 	= -(seg.tN.x * seg.tB.y - seg.tN.y * seg.tB.x);
			
			if (dt < (dtMin-rsum)) {
				if (dt < (dtMin - circle.r)) {
					return false;
				} else {
					return circle2circleQuery(arb, circle.tC, seg.tA, circle.r, seg.r);
				}
			} else {
				if (dt < dtMax) {
					var n:Vector2D = (dn < 0)? seg.tN : seg.tNneg;
					var factor:Number = circle.r + dist * 0.5;
					arb.injectContact(   circle.tC.x + (n.x * factor) ,
										 circle.tC.y + (n.y * factor) ,
										 n.x,
										 n.y,
										 1,
										 dist, 
										 0 );
					return true;
				} else {
					if (dt < (dtMax + rsum)) {
						return circle2circleQuery(arb,circle.tC, seg.tB, circle.r, seg.r);
					}
				}
			}
			return false;
		}

		/** 
		 * Finds the support points between a line segment and polygon
		 */			
		public function findPolyPointsBehindSegment( seg:Segment , poly:Polygon , pDist:Number , coef:Number , arb:Arbiter ):void {

			var dta:Number = seg.tN.x * seg.tA.y - seg.tN.y * seg.tA.x;
			var dtb:Number = seg.tN.x * seg.tB.y - seg.tN.y * seg.tB.x;
			var n:Vector2D = (coef < 0)? seg.tNneg : seg.tN;
			var tV:Vector2D = poly.tVerts;
			var i:int = 0;
			var c:int = 0;
			while (tV) {
				var vdotN:Number =  tV.x * n.x + tV.y * n.y;
				if ( vdotN < seg.tNdottA * coef + seg.r) {
					var dt:Number = seg.tN.x * tV.y - seg.tN.y * tV.x;
					if ( dta >= dt && dt >= dtb) {
						arb.injectContact(tV.x, tV.y, n.x, n.y, 1, pDist, (poly.shapeID << 8) | i );
						if (++c > 1) return;  //never more than 2 support points?
					}
				}
				i++;
				tV = tV.next;
			}
		}

		/** 
		 * Narrow phase collision between a line segment and polygon
		 */	
		public function segment2poly( seg:Segment , poly:Polygon , arb:Arbiter):Boolean {

			var minNorm:Number = poly.valueOnAxis(seg.tN,     seg.tNdottA ) - seg.r;
			if (minNorm > 0) return false;
			var minNeg:Number  = poly.valueOnAxis(seg.tNneg, -seg.tNdottA ) - seg.r;
			if (minNeg > 0) return false;
			
			var tA:Axis = poly.tAxes;
			var polyMin:Number = -4294967296;// -Number.MAX_VALUE;
			var mini:Axis;
			
			while (tA) {
				//INLINE
				//var dist:Number = seg.valueOnAxis(tA.n, tA.d);
				var vA:Number = (tA.n.x * seg.tA.x + tA.n.y * seg.tA.y) - seg.r;
				var vB:Number = (tA.n.x * seg.tB.x + tA.n.y * seg.tB.y) - seg.r;
				var dist:Number = (vA < vB)?vA - tA.d:vB - tA.d;
				//END INLINE
				if (dist > 0) {
					return false;
				} else if (dist>polyMin) {
					polyMin = dist;
					mini = tA;
				}
				tA = tA.next;
			}
			
			//Ugly but technicaly faster.  If you want to something nice to read try Shakespeare
			//var va:Vector2D =  new Vector2D( seg.tA.x + ( -mini.n.x * seg.r) , seg.tA.y + ( -mini.n.y * seg.r) );
			//if (!((va.y < poly.aabb.t) || (va.y > poly.aabb.b) || (va.x < poly.aabb.l) || (va.x > poly.aabb.r)) && poly.ContainsPoint(va)) 
			//	arb.injectContact(va.x, va.y, mini.n, -1, polyMin, (seg.shapeID * 3344921057)^(0 * 3344921057) );			
			var a:Axis;
			var vx:Number = seg.tA.x + ( -mini.n.x * seg.r);
			var vy:Number = seg.tA.y + ( -mini.n.y * seg.r);
			if (vy >= poly.aabb.t) {
				if (vy<=poly.aabb.b) {
					if (vx<=poly.aabb.r) {
						if (vx >= poly.aabb.l) {
							//if (poly1.ContainsPoint(v)) {
							a = poly.tAxes;
							while (a) {
								if (((a.n.x * vx + a.n.y * vy) - a.d ) > 0 )
									break;
								a = a.next;
							}
							if (!a) {
								arb.injectContact(vx, vy, mini.n.x, mini.n.y, -1, polyMin, (seg.shapeID << 8) | 0 );// (seg.shapeID * 3344921057) ^ (0 * 3344921057) );
							}
						}
					}
				}
			}
			
			//Or Dickens....
			//var vb:Vector2D =  new Vector2D( seg.tB.x + ( -mini.n.x * seg.r) , seg.tB.y + ( -mini.n.y * seg.r) );
			//if (!((vb.y < poly.aabb.t) || (vb.y > poly.aabb.b) || (vb.x < poly.aabb.l) || (vb.x > poly.aabb.r)) && poly.ContainsPoint(vb)) 
			//	arb.injectContact(vb.x, vb.y, mini.n, -1, polyMin, (seg.shapeID * 3344921057)^(1 * 3344921057) );
			vx = seg.tB.x + ( -mini.n.x * seg.r);
			vy = seg.tB.y + ( -mini.n.y * seg.r);
			if (vy >= poly.aabb.t) {
				if (vy<=poly.aabb.b) {
					if (vx<=poly.aabb.r) {
						if (vx >= poly.aabb.l) {
							//if (poly1.ContainsPoint(v)) {
							a = poly.tAxes;
							while (a) {
								if (((a.n.x * vx + a.n.y * vy) - a.d ) > 0 )
									break;
								a = a.next;
							}
							if (!a) {
								arb.injectContact(vx, vy, mini.n.x, mini.n.y, -1, polyMin, (seg.shapeID << 8) | 1 );// (seg.shapeID * 3344921057) ^ (0 * 3344921057) );
							}
						}
					}
				}
			}
			
			polyMin -= arb.collision_slop;
			
			if (minNorm >= polyMin || minNeg >= polyMin) {
				if (minNorm > minNeg) {
					findPolyPointsBehindSegment(seg, poly, minNorm, 1, arb);
				} else {
					findPolyPointsBehindSegment(seg, poly, minNeg, -1, arb);
				}
			}
			
			return true;
			
		}

		/** 
		 * Narrow phase collision between a circle and polygon
		 */	
		public function circle2poly( circle:Circle , poly:Polygon , arb:Arbiter):Boolean {
			
			var miniA:Axis;
			var miniV:Vector2D;
			
			var tA:Axis = poly.tAxes;
			var tV:Vector2D = poly.tVerts;
			// 圆和每条边的距离检测
			var dist:Number;
			var min:Number = -4294967296;// -Number.MAX_VALUE;
			while (tA) {
				dist = (tA.n.x * circle.tC.x + tA.n.y * circle.tC.y) - tA.d - circle.r;
				if (dist > 0)
					return false;
				if (dist > min) {
					min = dist;
					miniA = tA;
					miniV = tV;
				}
				tA = tA.next;
				tV = tV.next;
			}

			var n:Vector2D = miniA.n;
			var a:Vector2D = miniV;
			var b:Vector2D = a.next || poly.tVerts;
					
			var dtb:Number = n.x * b.y - n.y * b.x;
			var dt:Number  = n.x * circle.tC.y - n.y * circle.tC.x;
			
			//Debug.bltrace("c="+circle.shapeID+" "+"p="+poly.shapeID);
			
			if (dt < dtb) 
				return circle2circleQuery(arb, circle.tC, b, circle.r, 0);
			
			var dta:Number = n.x * a.y - n.y * a.x;	
				
			if (dt < dta) {
				var factor:Number = circle.r + ( min / 2);
				arb.injectContact( circle.tC.x - (n.x * factor), circle.tC.y - (n.y * factor), n.x, n.y , -1, min, 0) ;				
				return true;
			} 
				
			return circle2circleQuery(arb, circle.tC, a, circle.r, 0);
		}
		
	}
	
}
