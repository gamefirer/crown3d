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

package org.rje.glaze.engine.dynamics.constraints {
	import org.rje.glaze.engine.dynamics.RigidBody;
	import org.rje.glaze.engine.math.Vector2D;

	import flash.display.Graphics;

	/**
	 * 
	 */
	public class PinJoint extends Constraint {

		private var anchor1 : Vector2D;
		private var anchor2 : Vector2D;

		private var r1:Vector2D;
		private var r2:Vector2D;
		
		private var dist:Number;
		
		private var jnAcc:Number;		
		private var jnMax:Number;
		private var bias:Number;

		private var n:Vector2D;
		private var nMass:Number;
		
		public function PinJoint(a:RigidBody , b:RigidBody , anchor1:Vector2D, anchor2:Vector2D) {
			super(a, b);
			this.anchor1 = anchor1;
			this.anchor2 = anchor2;

			jnAcc = bias = 0;
			n = new Vector2D();
			
			var p1:Vector2D = new Vector2D(anchor1.x * a.rot.x - anchor1.y * a.rot.y, anchor1.x * a.rot.y + anchor1.y * a.rot.x);
			var p2:Vector2D = new Vector2D(anchor2.x * b.rot.x - anchor2.y * b.rot.y, anchor2.x * b.rot.y + anchor2.y * b.rot.x);
			
			p1.plusEquals(a.p);
			p2.plusEquals(b.p);
			
			dist = p2.minus(p1).magnitude();
			
		}
		
		public override function PreStep( dt:Number, dt_inv:Number ):void {
			r1 = anchor1.rotateByVector(a.rot);
			r2 = anchor2.rotateByVector(b.rot);
			
//			joint->r1 = cpvrotate(joint->anchr1, a->rot);
			//FIXME uncomment this
			//r1.x = anchor1.x * a.rot.x - anchor1.y * a.rot.y;
			//r1.y = anchor1.x * a.rot.y + anchor1.y * a.rot.x;
//			joint->r2 = cpvrotate(joint->anchr2, b->rot);
			//FIXME uncomment this
			//r2.x = anchor2.x * b.rot.x - anchor2.y * b.rot.y;
			//r2.y = anchor2.x * b.rot.y + anchor2.y * b.rot.x;

//			cpVect delta = cpvsub(cpvadd(b->p, joint->r2), cpvadd(a->p, joint->r1));			
			var dX:Number = (b.p.x + r2.x) - (a.p.x + r1.x);
			var dY:Number = (b.p.y + r2.y) - (a.p.y + r1.y);

//			cpFloat dist = cpvlength(delta);			
			var ldist:Number = Math.sqrt(dX * dX + dY * dY);

//			joint->n = cpvmult(delta, 1.0f/(dist ? dist : (cpFloat)INFINITY));
			var nzldist:Number = (ldist == 0 ) ? Number.POSITIVE_INFINITY : ldist;
			n.x = dX * (1 / nzldist);
			n.y = dY * (1 / nzldist);			

//			// calculate mass normal
//			joint->nMass = 1.0f/k_scalar(a, b, joint->r1, joint->r2, joint->n);
			var mass_sum:Number = a.m_inv + b.m_inv;
			var r1cn:Number = r1.x * n.y - r1.y * n.x;
			var r2cn:Number = r2.x * n.y - r2.y * n.x;
			nMass = 1 / ( mass_sum + (a.i_inv * r1cn * r1cn) + (b.i_inv * r2cn * r2cn));
		
//			// calculate bias velocity
//			cpFloat maxBias = joint->constraint.maxBias;
			var maxBias:Number = maxBias;
//			joint->bias = cpfclamp(-joint->constraint.biasCoef*dt_inv*(dist - joint->dist), -maxBias, maxBias);	
//			cpfmin(cpfmax(f, min), max)		
			bias = Math.min(Math.max(-biasCoef * dt_inv * (ldist - dist), -maxBias) , maxBias);
			
//			// compute max impulse
//			joint->jnMax = J_MAX(joint, dt);
			jnMax = maxForce * dt;

//			// apply accumulated impulse
//			cpVect j = cpvmult(joint->n, joint->jnAcc);
			var jx:Number = (n.x * jnAcc);
			var jy:Number = (n.y * jnAcc);

//			apply_impulses(a, b, joint->r1, joint->r2, j);
			//INLINE Function
			//a.body.ApplyImpulse( j1.mult(-1), contact.r1);
			a.v.x += (-jx * a.m_inv);
			a.v.y += (-jy * a.m_inv);
			a.w += a.i_inv * (r1.x * -jy - r1.y * -jx);								
			
			//INLINE Function
			//b.body.ApplyImpulse( j1, contact.r2);
			b.v.x += (jx * b.m_inv);
			b.v.y += (jy * b.m_inv);
			b.w += b.i_inv * (r2.x * jy - r2.y * jx);
		
		}
		
		public override function ApplyImpuse():void {
//			// compute relative velocity
//			cpFloat vrn = normal_relative_velocity(a, b, joint->r1, joint->r2, n);
			var v1_sum:Vector2D = a.v.plus(r1.rightHandNormal().mult(a.w));
			var v2_sum:Vector2D = b.v.plus(r2.rightHandNormal().mult(b.w));
			var vrn:Number = (v2_sum.minus(v1_sum)).dot(n);
			
//			// compute normal impulse
//			cpFloat jn = (joint->bias - vrn)*joint->nMass;
			var jn:Number = (bias - vrn) * nMass;
		
//			cpFloat jnOld = joint->jnAcc;
			var jnOld:Number = jnAcc;
//			joint->jnAcc = cpfclamp(jnOld + jn, -joint->jnMax, joint->jnMax);
			jnAcc =  Math.min(Math.max(jnOld + jn, -jnMax) , jnMax);
//			jn = joint->jnAcc - jnOld;
			jn = jnAcc - jnOld;
//			
//			// apply impulse
//			apply_impulses(a, b, joint->r1, joint->r2, cpvmult(n, jn));
			var j:Vector2D = n.mult(jn);
			a.ApplyImpulse(j.mult(-1), r1);
			b.ApplyImpulse(j, r2);				
		}
		
		public override function draw( g:Graphics ):void {
			g.lineStyle(2, 0x333333);
			g.moveTo(a.p.x + r1.x , a.p.y + r1.y);
			g.lineTo(b.p.x + r2.x , b.p.y + r2.y);
		}
		
	}
	
}
