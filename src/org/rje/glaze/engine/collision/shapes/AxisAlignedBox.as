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
	import org.rje.glaze.engine.math.Vector2D;

	import flash.display.Graphics;

	/**
	 * 
	 */
	public class AxisAlignedBox extends GeometricShape {
		
		public var c : Vector2D;
		public var halfWidth : Vector2D;

		public var tC : Vector2D;		
		
		public function AxisAlignedBox(halfWidths:Vector2D, offset : Vector2D) {
			super(GeometricShape.AXIS_ALIGNED_BOX_SHAPE, null);
			InitShape(offset, halfWidths);
		}
		
		public override function InitShape( offset : Vector2D, shapeData1 : *, shapeData2 : * = null, shapeData3 : * = null ) : * {
			isSensor = true;
			this.offset = offset.clone();
			c = offset.clone();
			halfWidth = shapeData1 as Vector2D;
			area = ( halfWidth.x * 2 ) * (halfWidth.y * 2);
			tC = c.clone();
			return null;
		}

		public override function UpdateShape( p : Vector2D, rot : Vector2D ) : void {
			tC.x = p.x + (c.x * rot.x - c.y * rot.y);
			tC.y = p.y + (c.x * rot.y + c.y * rot.x);
			aabb.l = tC.x - halfWidth.x;
			aabb.r = tC.x + halfWidth.x;
			aabb.t = tC.y - halfWidth.y;
			aabb.b = tC.y + halfWidth.y;
		}		
		
		public override function ContainsPoint(point : Vector2D) : Boolean {
			return aabb.containsPoint(point);
		}

		public override function IntersectRay( ray : Ray ) : Boolean {
			return aabb.IntersectRay(ray);
		}

		
		public override function CalculateInertia( m : Number , offset : Vector2D ) : Number {
			//TODO not sure about this...
			return (1 / 2) * m * (area) + m * offset.dot(offset);
		}

		public override function draw( g : Graphics ) : void {
			g.lineStyle(lineWidth, lineColour );
			g.beginFill(body.canSleep ? 0xE6DC64 : fillColour , isSensor ? 0.5 : 1);
			g.drawRect(aabb.l, aabb.t, aabb.r - aabb.l, aabb.b - aabb.t);
			g.endFill();
		}		
	}
}
