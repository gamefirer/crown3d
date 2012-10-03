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
	import org.rje.glaze.engine.math.Axis;
	import org.rje.glaze.engine.math.Ray;
	import org.rje.glaze.engine.math.Vector2D;

	import flash.display.Graphics;

	/**
	 * 
	 */
	public class Polygon extends GeometricShape {

		public var verts:Vector2D;
		public var tVerts:Vector2D;
		public var numVerts:int;
		
		public var axes:Axis;
		public var tAxes:Axis;
		public var numAxes:int;
		
		public function Polygon( vertsList:Array , offset:Vector2D , material:Material = null )  {
			super(GeometricShape.POLYGON_SHAPE, material);
			InitShape(offset, vertsList);
		}
		
		public override function InitShape( offset:Vector2D, shapeData1:*, shapeData2:* = null, shapeData3:* = null ):* {
			
			this.offset = offset.clone();
			
			var vertsList:Array = shapeData1 as Array;
			
			var v0:Vector2D, v1:Vector2D, v2:Vector2D;
			var a:Vector2D, 
			    b:Vector2D, 
				n:Vector2D;
			
			var n_verts:Vector2D	,l_verts:Vector2D;
			var n_tVerts:Vector2D	,l_tVerts:Vector2D;
			var n_axes:Axis			,l_axes:Axis;
			var n_tAxes:Axis		,l_tAxes:Axis;					
			
			numVerts = vertsList.length;
			numAxes  = vertsList.length;
			
			area = 0;
			
			for (var i:int = 0; i < numVerts; i++) {
				
				v0 			= vertsList[i];
				v1 			= vertsList[(i + 1) % numVerts];
				v2 			= vertsList[(i + 2) % numVerts];

				a 			= v0.plus(offset);
				b 			= v1.plus(offset);
				n 			= b.minus(a).rightHandNormal().normalize();
				
				n_verts  	= a;
				n_tVerts 	= n_verts.clone();
				
				n_axes   	= new Axis(n, n.dot(a));
				n_tAxes 	= n_axes.clone();
				
				if (i == 0) {
					verts	= n_verts;
					tVerts 	= n_tVerts;
					axes 	= n_axes;
					tAxes	= n_tAxes;
				} else {
					l_verts.next 	= n_verts;
					l_tVerts.next 	= n_tVerts;
					l_axes.next 	= n_axes;
					l_tAxes.next 	= n_tAxes;
				}
				
				l_verts 	= n_verts;
				l_tVerts 	= n_tVerts;
				l_axes		= n_axes;
				l_tAxes		= n_tAxes;
			
				area += v1.x * (v2.y - v0.y);
			}
			area /= -2;
			return null;
		}
		
		public override function UpdateShape( p:Vector2D, rot:Vector2D ):void {
			var v:Vector2D = verts;
			var tv:Vector2D = tVerts;
			
			aabb.l = aabb.t =  4294967296;
			aabb.r = aabb.b = -4294967296;

			while (v) {
				tv.x = p.x + (v.x*rot.x - v.y*rot.y);
				tv.y = p.y + (v.x * rot.y + v.y * rot.x);
				if (tv.x < aabb.l) aabb.l = tv.x;
				if (tv.x > aabb.r) aabb.r = tv.x;
				if (tv.y < aabb.t) aabb.t = tv.y;
				if (tv.y > aabb.b) aabb.b = tv.y;
				v = v.next;
				tv = tv.next;
			}
			
			var a:Axis = axes;
			var ta:Axis = tAxes;
			while (a) {
				ta.n.x = a.n.x * rot.x - a.n.y * rot.y;
				ta.n.y = a.n.x * rot.y + a.n.y * rot.x;
				ta.d   = (p.x * ta.n.x + p.y * ta.n.y) + a.d;
				a = a.next;
				ta = ta.next;
			}
		}
		
		public virtual function valueOnAxis( n:Vector2D , d:Number ):Number {	
			var v:Vector2D = tVerts;
			var min:Number = 4294967296;// Number.MAX_VALUE;
			var result:Number;
			while (v) {
				result = n.x * v.x + n.y * v.y;
				if (result < min) min = result;
				v = v.next;
			}
			return min - d;
		}
		
		public override function IntersectRay( ray:Ray ):Boolean {
			var tfar:Number = ray.range;// Number.POSITIVE_INFINITY;
			var tnear:Number = 0;
			var nnear:Axis;
			var nfar:Axis;
			
			var ta:Axis = tAxes;
			var tv:Vector2D = tVerts;
			
			while (ta) {
				//var D:Vector2D = tv.minus(ray.origin);
				var Dx:Number = tv.x - ray.origin.x;
				var Dy:Number = tv.y - ray.origin.y;
				var denom:Number = Dx * ta.n.x + Dy * ta.n.y;							//D.dot(ta.n);
				var numer:Number = ray.direction.x * ta.n.x + ray.direction.y * ta.n.y;	//ray.direction.dot(ta.n);
				
				if ((numer<0?-numer:numer) < 0.000000001) {
					if (denom < 0)
						return false;
				} else {
					var tclip:Number = denom / numer;
					if (numer < 0) {
						if (tclip > tfar)
							return false;
						if (tclip > tnear) {
							tnear = tclip;
							nnear = ta;
						}
					} else {
						if (tclip < tnear)
							return false;
						if (tclip < tfar) {
							tfar = tclip;
							nfar = ta;
						}
					}
				}
				ta = ta.next;
				tv = tv.next;
			}
			if (!nnear) return false;
			//var t:Number = -(ray.origin.dot(nnear.n) - nnear.d) / (ray.direction.dot(nnear.n));
			var t:Number = -((ray.origin.x * nnear.n.x + ray.origin.y * nnear.n.y) - nnear.d) / (ray.direction.x * nnear.n.x + ray.direction.y * nnear.n.y);
			//return ray.origin.plus(ray.direction.mult(t));
			//return new Vector2D(ray.origin.x + (ray.direction.x * t), ray.origin.y + (ray.direction.y * t));
			return ray.reportResult(this,t,nnear.n);
		}
		
		public override function ContainsPoint( point:Vector2D ):Boolean {
			var a:Axis = tAxes;
			while (a) {
				if (((a.n.x * point.x + a.n.y * point.y) - a.d ) > 0 )
					return false;
				a = a.next;
			}
			return true;
		}
		
		public override function CalculateInertia( m:Number , offset:Vector2D ):Number {
			
			var v0:Vector2D = verts;
			var v1:Vector2D;
			
			var tVertsTemp:Array = new Array();
			
			while (v0) {
				tVertsTemp.push( new Vector2D( v0.x + offset.x , v0.y + offset.y) );
				v0 = v0.next;
			}
			
			var sum1:Number = 0;
			var sum2:Number = 0;
			
			for ( var i:int = 0; i < numVerts; i++) {
	
				v0 	= tVertsTemp[i];
				v1 	= tVertsTemp[(i + 1) % numVerts];
				
				var a:Number = v1.cross(v0);
				var b:Number = v0.dot(v0) + v0.dot(v1) + v1.dot(v1);
				
				sum1 += a * b;
				sum2 += a;
			}
			
			return (m * sum1) / (6 * sum2);
			
		}

		public override function draw( g:Graphics ):void {
			var v:Vector2D = tVerts;
			g.lineStyle(lineWidth, lineColour);
			g.beginFill( actualFillColour, isSensor ? 0.5 : 1 );
			g.moveTo(v.x, v.y);
			while (v!=null) {
				g.lineTo(v.x, v.y);
				v = v.next;
			}
			g.lineTo(tVerts.x, tVerts.y);
			g.endFill();
		}
		
		public static function createRectangle( w:Number , h:Number ):Array {
			var rect:Array = new Array();
			rect.push( new Vector2D( -w / 2, -h / 2) );
			rect.push( new Vector2D( -w / 2,  h / 2) );
			rect.push( new Vector2D(  w / 2,  h / 2) );
			rect.push( new Vector2D(  w / 2, -h / 2) );	
			return rect;
		}
		
		public static function createBlobConvexPoly( numVerts:int , radius:Number , rotation:Number = 0 ):Array {
			var blob:Array = new Array();
			for (var i:int = 0; i <numVerts ; i++) {
				var angle:Number = ( -2 * Math.PI * i) / (numVerts);
				angle += rotation;
				blob[i] = new Vector2D(radius * Math.cos(angle), radius * Math.sin(angle));
			}
			return blob;
		}
		
	}
	
}
