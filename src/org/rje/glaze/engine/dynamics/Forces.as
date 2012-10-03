// glaze - 2D rigid body dynamics & game engine
// Copyright (c) 2008, Richard Jewson
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

package org.rje.glaze.engine.dynamics {
	import org.rje.glaze.engine.math.Vector2D;

	/**
	 * 
	 */
	public class Forces {
		
		public function Forces() {
			
		}
		
		public static function LinearAttractor( body:RigidBody , forceLocation:Vector2D , forceStrength:Number ):void {
			var forceVector:Vector2D = forceLocation.minus(body.p);
			forceVector.normalizeEquals();
			forceVector.multEquals(forceStrength);
			body.ApplyForces(forceVector, Vector2D.zeroVect);
		}

		public static function InverseSqrAttractor( body:RigidBody , forceLocation:Vector2D , forceStrength:Number ):void {
			var forceVector:Vector2D = forceLocation.minus(body.p);
			var length:Number = forceVector.magnitude();
			if (length == 0) length = 0.0001;
			forceVector.multEquals(1 / length);
			forceVector.multEquals(forceStrength / (length/100) );
			body.ApplyForces(forceVector, Vector2D.zeroVect);
		}
		
		public static function directedSpring(body:RigidBody, upAngle:Number, stiffness:Number, damping:Number):void {
			var delta:Number = upAngle - body.a;
			if (body.w > 0) {
				
				if (delta < -Math.PI) {
					body.t += stiffness * ( delta + (Math.PI * 2 ) ) - damping * body.w;
					return;
				}
			} else {
				if (delta > Math.PI) {
					body.t += stiffness * ( delta - (Math.PI * 2 ) ) - damping * body.w;
					return;
				}
			}
			//if (Math.abs(upAngle-body.a)>Math.PI*1.75)
			
			body.t += stiffness * ( upAngle - body.a ) - damping * body.w;
			//body.t += stiffness * ( upAngle - body.a ) - damping * body.w;
			
		}
		
		public static function Spring2( body:RigidBody, anchor:Vector2D, stiffness:Number, restLength:Number = 0, damping:Number = 0 ):void {
			var f:Vector2D = new Vector2D();
			var dx:Number, rx:Number;
			var dy:Number, ry:Number;		
			var k:Number, bv:Number;
			
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
		
		public static function DampendSpring( a:RigidBody , b:RigidBody , anchr1:Vector2D, anchr2:Vector2D, rlen:Number , k:Number , dmp:Number , dt:Number ):void {
			var r1:Vector2D = new Vector2D(anchr1.x * a.rot.x - anchr1.y * a.rot.y, anchr1.x * a.rot.y + anchr1.y * a.rot.x);
			var r2:Vector2D = new Vector2D(anchr2.x * b.rot.x - anchr2.y * b.rot.y, anchr2.x * b.rot.y + anchr2.y * b.rot.x);

			//var delta:Vector2D = new Vector2D( (b.p.x + r2.x) - (a.p.x + r1.x) , (b.p.y + r2.y) - (a.p.y + r1.y) );
			var delta:Vector2D = b.p.plus(r2).minus(a.p.plus(r1));
			
			
			//cpVect delta = cpvsub(cpvadd(b->p, r2), cpvadd(a->p, r1));
			
			var dist:Number = Math.sqrt(delta.x * delta.x + delta.y * delta.y) + 1e-6;;
			
			//var n:Vector2D = dist==0 ? Vector2D.zeroVect.clone() : new Vector2D( delta.x * (1 / dist) , delta.y * (1 / dist) );
			//var n:Vector2D = delta.mult(1 / dist);
			var n:Vector2D = delta.mult(1 / dist);
			
			var fSpring:Number = (dist - rlen) * k;
			
			//cpVect v1 = cpvadd(a - > v, cpvmult(cpvperp(r1), a - > w));
			var v1:Vector2D = r1.rightHandNormal().multEquals(a.w).plusEquals(a.v);
			//cpVect v2 = cpvadd(b->v, cpvmult(cpvperp(r2), b->w));
			var v2:Vector2D = r2.rightHandNormal().multEquals(b.w).plusEquals(b.v);
			//cpFloat vrn = cpvdot(cpvsub(v2, v1), n);
			var vrn:Number = v2.minus(v1).dot(n);

			//cpFloat f_damp = vrn*cpfmin(dmp, 1.0f/(dt*(a->m_inv + b->m_inv)));
			var fDamp:Number = vrn * Math.min(dmp, 1 / (dt * (a.m_inv + b.m_inv)));
			
			//var fDamp:Number = vrn * dmp;
			
			// Apply!
			//cpVect f = cpvmult(n, f_spring + f_damp);
			//var f:Vector2D = new Vector2D( n.x * (fSpring + fDamp) , n.y * (fSpring + fDamp));
			var f:Vector2D = n.mult(fSpring + fDamp);

			a.ApplyForces(f, r1);
			b.ApplyForces(f.mult( -1), r2);
			/*	
			var vrn:Number = ((b.v.x + ( -r2.y * b.w)) - (a.v.x + ( -r1.y * a.w)) * n.x) + ((b.v.y + (  r2.x * b.w)) - (a.v.y + (  r1.x * a.w)) * n.y)
			
			var fDamp:Number = vrn * Math.min(dmp, 1 / (dt * (a.m_inv + b.m_inv)));
			
			var f:Vector2D = new Vector2D( n.x * (fSpring + fDamp) , n.y * (fSpring + fDamp));
			
			a.ApplyForces(f, r1);
			b.ApplyForces(f.mult( -1), r2);
			*/
		}
		
		
	}
	
}
