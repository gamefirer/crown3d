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
	
	import flash.geom.Point;

	/**
	 * 2D Vector class (linked list enabled)
	 * Used hold the x,y values of a vector.  Contains many util functions that are often
	 * inlined for performance reasons.
	 */
	public class Vector2D {
		
		/**
		 * X Axis component of this vector
		 */
		public var x:Number;
		
		/**
		 * Y Axis component of this vector
		 */
		public var y:Number;
		
		/**
		 * Linked list pointer.
		 */
		public var next:Vector2D;
		
		/**
		 * Arbitary flag.  Used by the Enhanced collision detector to find contact points in 1 pass. 
		 */
		public var flag:Boolean;
	
		public function Vector2D(px:Number = 0, py:Number = 0) {
			x = px;
			y = py;
		}
		
		public function clone():Vector2D {
			return new Vector2D(this.x,this.y);
		}
		
		public function setTo(px:Number, py:Number):void {
			x = px;
			y = py;
		}
		
		public function copy(v:Vector2D):void {
			x = v.x;
			y = v.y;
		}
	
		public function dot(v:Vector2D):Number {
			return x * v.x + y * v.y;
		}
			
		public function cross(v:Vector2D):Number {
			return x * v.y - y * v.x;
		}
		
		public function plus(v:Vector2D):Vector2D {
			return new Vector2D(x + v.x, y + v.y); 
		}
	
		public function plusEquals(v:Vector2D):Vector2D {
			x += v.x;
			y += v.y;
			return this;
		}
		
		public function minus(v:Vector2D):Vector2D {
			return new Vector2D(x - v.x, y - v.y);    
		}
	
		public function minusEquals(v:Vector2D):Vector2D {
			x -= v.x;
			y -= v.y;
			return this;
		}
	
		public function mult(s:Number):Vector2D {
			return new Vector2D(x * s, y * s);
		}
	
		public function multEquals(s:Number):Vector2D {
			x *= s;
			y *= s;
			return this;
		}
	
		public function times(v:Vector2D):Vector2D {
			return new Vector2D(x * v.x, y * v.y);
		}
		
		public function timesEquals(v:Vector2D):Vector2D {
			x *= v.x;
			y *= v.y;
			return this;
		}

		public function div(s:Number):Vector2D {
			if (s == 0) s = 0.0001;
			return new Vector2D( x / s , y / s );
		}
		
		public function divEquals(s:Number):Vector2D {
			if (s == 0) s = 0.0001;
			x /= s;
			y /= s;
			return this;
		}
		
		public function magnitude():Number {
			return Math.sqrt(x * x + y * y);
		}
		
		public function distance(v:Vector2D):Number {
			var delta:Vector2D = this.minus(v);
			return delta.magnitude();
		}

		public function normalize():Vector2D {
			 var m:Number = magnitude();
			 if (m == 0) m = 0.0001;
			 return mult(1 / m);
		}
		
		public function normalizeEquals():Vector2D {
			 var m:Number = magnitude();
			 if (m == 0) m = 0.0001;
			 return multEquals(1 / m);
		}		
		
		public function leftHandNormal():Vector2D {
			return new Vector2D(this.y,-this.x);
		}
		
		public function rightHandNormal():Vector2D {
			return new Vector2D(-this.y,this.x);
		}
		
		public function clampMax( max:Number ):Vector2D {
			var l:Number = magnitude();
			if (l>max) {
				multEquals(max/l);
			}
			return this;
		}
		
		public function abs():Vector2D {
			return new Vector2D( (this.x < 0) ? -this.x : this.x, (this.y < 0) ? -this.y : this.y);
		}
		
		public function interpEquals( blend:Number , v:Vector2D ):Vector2D {
			this.x = this.x + blend * (v.x - this.x);
			this.y = this.y + blend * (v.y - this.y);
			return this;
		}
		
		public function projectOnto( v:Vector2D ):Vector2D {
			var dp:Number = this.dot(v);
			var f:Number  = dp / ( v.x*v.x + v.y*v.y );
			return new Vector2D( f*v.x , f*v.y);
		}
		
		public function angle( v:Vector2D ):Number {
			return Math.atan2( this.cross(v), this.dot(v) );
		}
		
		public static function forAngle( a:Number ):Vector2D {
			return new Vector2D(Math.cos(a), Math.sin(a));
		}
		
		public function forAngleEquals( a:Number ):void {
			this.x = Math.cos(a);
			this.y = Math.sin(a);
		}
		
		public function rotateByVector(v:Vector2D):Vector2D {
 	        return new Vector2D(this.x * v.x - this.y * v.y, this.x * v.y + this.y * v.x);
 	    }
		
		public function rotate(angle:Number):Vector2D {
			var a:Number = angle * Math.PI / 180;
			var cos:Number = Math.cos(a);
			var sin:Number = Math.sin(a);
			return new Vector2D( (cos*x) - (sin*y) , (cos*y) + (sin*x) );
		}
				
		public function rotateAbout( angle:Number , point:Vector2D ):Vector2D {			
			var d:Vector2D = this.minus(point).rotate(angle);
			this.x = point.x + d.x;
			this.y = point.y + d.y;
			return this;
		}
		
		public function rotateEquals(angle:Number):Vector2D {
			var a:Number = angle * Math.PI / 180;
			//var a:Number = angle;
			var cos:Number = Math.cos(a);
			var sin:Number = Math.sin(a);
			var rx:Number  = (cos*x) - (sin*y);
			var ry:Number  = (cos*y) + (sin*x);
			this.x = rx;
			this.y = ry;
			return this;
		}
		
		public static function createVectorArray( len:int ):Array {
			var vectorArray:Array = new Array();
			for (var i:int = 0; i < len; i++) {
				vectorArray[i] = new Vector2D(0, 0);
			}
			return vectorArray;
		}
		
		public function equalsZero():Boolean {
			return (this.x == 0 && this.y == 0);
		}
		
		public function toPoint():Point {
			return new Point(x,y);
		}
		
		public function toString():String {
			return (x + ":" + y);
		}
		
		public static function fromString( str:String ):Vector2D {
			if (str==null)
				return null;
			var vectorParts:Array = str.split(":");
			if ((vectorParts==null)||(vectorParts.length!=2))
				return null;
			var xVal:Number = parseFloat( vectorParts[0] );
			var yVal:Number = parseFloat( vectorParts[1] );
			if ( (isNaN(xVal)) || (isNaN(yVal)) )
				return null;
			return new Vector2D( xVal , yVal  );
		}
		
		public static const zeroVect:Vector2D = new Vector2D(0, 0);
		
	}
}
