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

package org.rje.glaze.engine.dynamics.forces {
	
	import org.rje.glaze.engine.dynamics.RigidBody;
	import org.rje.glaze.engine.math.Vector2D;
	
	/**
	* ...
	* @author Default
	*/
	public class Spring extends Force{
		
		public var body:RigidBody;
		public var anchor:Vector2D;
		public var stiffness:Number;
		public var restLength:Number;
		public var damping:Number;
		private const f:Vector2D = new Vector2D();
		
		public function Spring( body:RigidBody, anchor:Vector2D, stiffness:Number, restLength:Number = 0, damping:Number = 0 ) {
			super();
			this.body = body;
			this.anchor = anchor;
			this.stiffness = stiffness;
			this.restLength = restLength;
			this.damping = damping;
		}
		
		public override function eval( targetBody:RigidBody ):void {
			
			if (body.isFixed || body.isStatic) return;
			
			var dx:Number, rx:Number;
			var dy:Number, ry:Number;		
			var k:Number, bv:Number;
			
			f.x = f.y = 0;
			
			dx = body.p.x - anchor.x;
			dy = body.p.y - anchor.y;
			
			var l:Number = Math.sqrt(dx * dx + dy * dy) + 1e-6;
			k = -stiffness * (l - restLength);
			f.x = k * (dx / l);
			f.y = k * (dy / l);
			
			if (damping > 0) {
				bv = -damping * (body.v.x * f.x + body.v.y * f.y) /  (f.x * f.x + f.y * f.y);
				f.x += f.x * bv;
				f.y += f.y * bv;
			}
			body.ApplyForces(f, Vector2D.zeroVect);
		}
		
	}
	
}