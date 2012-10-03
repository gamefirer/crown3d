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
	import org.rje.glaze.engine.dynamics.Material;
	import org.rje.glaze.engine.math.Ray;
	import org.rje.glaze.engine.math.Vector2D;

	import flash.display.Graphics;

	/**
	 * 
	 */
	public class Segment extends GeometricShape {
		
		public var a:Vector2D;
		public var b:Vector2D;
		public var n:Vector2D;
		
		public var r:Number;
		
		public var tA:Vector2D;
		public var tB:Vector2D;
		public var tN:Vector2D;
		public var tNneg:Vector2D;
		public var tNdottA:Number;
		
		public function Segment( a:Vector2D , b:Vector2D, r:Number, material:Material = null ) {
			super(GeometricShape.SEGMENT_SHAPE, material);
			this.offset = new Vector2D();
			InitShape(offset, a, b, r);
		}
		
		public override function InitShape( offset:Vector2D, shapeData1:*, shapeData2:* = null, shapeData3:* = null ):* {	
			this.a = Vector2D(shapeData1).clone();
			this.b = Vector2D(shapeData2).clone();
			var length:Vector2D = this.b.minus(this.a);
			this.n = length.normalize().rightHandNormal();
			this.r = Number(shapeData3);
			this.area = r * length.magnitude();
			
			this.tA = new Vector2D();
			this.tB = new Vector2D();
			this.tN = new Vector2D();
			this.tNneg = new Vector2D();
			
			return null;
		}
		
		public override function UpdateShape( p:Vector2D, rot:Vector2D ):void {
			
			tA.x = p.x + (a.x * rot.x - a.y * rot.y);
			tA.y = p.y + (a.x * rot.y + a.y * rot.x);
			tB.x = p.x + (b.x * rot.x - b.y * rot.y);
			tB.y = p.y + (b.x * rot.y + b.y * rot.x);
			tN.x = n.x * rot.x - n.y * rot.y;
			tN.y = n.y * rot.y + n.y * rot.x;
			tNneg.x = -tN.x;
			tNneg.y = -tN.y;
			tNdottA = tN.x * tA.x + tN.y * tA.y;
			
			if(tA.x < tB.x){
				aabb.l = tA.x - r;
				aabb.r = tB.x + r;
			} else {
				aabb.l = tB.x - r;
				aabb.r = tA.x + r;
			}
			
			if(tA.y < tB.y){
				aabb.t = tA.y - r;
				aabb.b = tB.y + r;
			} else {
				aabb.t = tB.y - r;
				aabb.b = tA.y + r;
			}
		}
		
		public function valueOnAxis( n:Vector2D , d:Number ):Number {
			var vA:Number = n.dot(tA) - r;
			var vB:Number = n.dot(tB) - r;
			
			if (vA < vB) {
				return vA - d;
			} else {
				return vB - d;
			}
		}
		
		public override function ContainsPoint(point:Vector2D):Boolean {
			return false;
		}
		
		public override function IntersectRay( ray:Ray ):Boolean {
            //Make sure the lines aren't parallel
            if ((ray.direction.y) / (ray.direction.x) != (b.y - a.y) / (b.x - a.x)) {
                var d:Number = (((ray.direction.x) * (b.y - a.y)) - (ray.direction.y) * (b.x - a.x));
                if (d != 0) {
                    var r:Number = (((ray.origin.y - a.y) * (b.x - a.x)) - (ray.origin.x - a.x) * (b.y - a.y)) / d;
                    if (r >= 0) {
						var s:Number = (((ray.origin.y - a.y) * (ray.direction.x)) - (ray.origin.x - a.x) * (ray.direction.y)) / d;
                        if (s >= 0 && s <= 1) 
							return ray.reportResult(this,r,(((tN.x * ray.origin.x + tN.y * ray.origin.y) - (tA.x * tN.x + tA.y * tN.y)) < 0)? tNneg : tN );
                    }
                }
            }
            return false;		
		}
		
		public override function CalculateInertia( m:Number , offset:Vector2D ):Number {
			return 1;
		}
		
		public override function draw( g:Graphics ):void {
			g.lineStyle(r * 2, lineColour);
			g.moveTo(tA.x, tA.y);
			g.lineTo(tB.x, tB.y);
			g.lineTo(tA.x, tA.y);
		}
	}
	
}
