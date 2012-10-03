package org.rje.glaze.engine.dynamics.constraints {
	import flash.display.Graphics;

	import org.rje.glaze.engine.math.Vector2D;
	import org.rje.glaze.engine.dynamics.RigidBody;

	/**
	 * @author Richard.Jewson
	 */
	 //cpVect anchr1, cpVect anchr2, cpFloat restLength, cpFloat stiffness, cpFloat damping
	public class DampedSpring extends Constraint {
		
		private var anchor1 : Vector2D;
		private var anchor2 : Vector2D;
		private var restLength : Number;
		private var stiffness : Number;
		private var damping : Number;
		
		private var r1:Vector2D;
		private var r2:Vector2D;

		private var n:Vector2D;
		private var nMass:Number;
		private var target_vrn:Number;
		private var v_coef:Number;

		public function DampedSpring(a : RigidBody, b : RigidBody, anchor1:Vector2D, anchor2:Vector2D, restLength:Number, stiffness:Number, damping:Number) {
			super(a, b);
			this.anchor1 = anchor1;
			this.anchor2 = anchor2;
			this.restLength = restLength;
			this.stiffness = stiffness;
			this.damping = damping;
		}

		override public function PreStep(dt:Number, dt_inv : Number) : void {
			r1 = anchor1.rotateByVector(a.rot);
			r2 = anchor2.rotateByVector(b.rot);
			
//			cpVect delta = cpvsub(cpvadd(b->p, spring->r2), cpvadd(a->p, spring->r1));
			var delta:Vector2D = b.p.plus(r2).minus(a.p.plus(r1));
//			cpFloat dist = cpvlength(delta);
			var dist:Number = delta.magnitude() + 0.000001; 
//			spring->n = cpvmult(delta, 1.0f/(dist ? dist : INFINITY));
			n = delta.mult(1/dist);			
//			cpFloat k = k_scalar(a, b, spring->r1, spring->r2, spring->n);
//			spring->nMass = 1.0f/k;
			var mass_sum:Number = a.m_inv + b.m_inv;
			var r1cn:Number = r1.x * n.y - r1.y * n.x;
			var r2cn:Number = r2.x * n.y - r2.y * n.x;
			var k:Number = ( mass_sum + (a.i_inv * r1cn * r1cn) + (b.i_inv * r2cn * r2cn));
			nMass = 1/k;
//			
//			spring->target_vrn = 0.0f;
			target_vrn = 0;	
//			spring->v_coef = 1.0f - cpfexp(-spring->damping*dt*k);
			v_coef = 1 - Math.exp(-damping*dt*k);		
//			// apply spring force
//			cpFloat f_spring = spring->springForceFunc((cpConstraint *)spring, dist);
			var f_spring:Number = (restLength - dist) * stiffness;
//			apply_impulses(a, b, spring->r1, spring->r2, cpvmult(spring->n, f_spring*dt));	
//			apply_impulses(cpBody *a , cpBody *b, cpVect r1, cpVect r2, cpVect j)
//			{
//				cpBodyApplyImpulse(a, cpvneg(j), r1);
//				cpBodyApplyImpulse(b, j, r2);
//			}
			var j:Vector2D = n.mult(f_spring*dt) ;//cpvmult(spring->n, f_spring*dt)
			a.ApplyImpulse(j.mult(-1), r1);
			b.ApplyImpulse(j, r2);
		}

		override public function ApplyImpuse() : void {
			//cpVect n = spring->n;
			//cpVect r1 = spring->r1;
			//cpVect r2 = spring->r2;
		
			// compute relative velocity
			//cpFloat vrn = normal_relative_velocity(a, b, r1, r2, n) - spring->target_vrn;
			//relative_velocity(cpBody *a, cpBody *b, cpVect r1, cpVect r2){
			//	cpVect v1_sum = cpvadd(a->v, cpvmult(cpvperp(r1), a->w));
			//	cpVect v2_sum = cpvadd(b->v, cpvmult(cpvperp(r2), b->w));
			//	
			//	return cpvsub(v2_sum, v1_sum);
			//}
			//normal_relative_velocity(cpBody *a, cpBody *b, cpVect r1, cpVect r2, cpVect n){
			//	return cpvdot(relative_velocity(a, b, r1, r2), n);
			//}
			var v1_sum:Vector2D = a.v.plus(r1.rightHandNormal().mult(a.w));
			var v2_sum:Vector2D = b.v.plus(r2.rightHandNormal().mult(b.w));
			var vrn:Number = (v2_sum.minus(v1_sum)).dot(n) - target_vrn;
			
			// compute velocity loss from drag
			// not 100% certain this is derived correctly, though it makes sense
			//cpFloat v_damp = -vrn*spring->v_coef;
			var v_damp:Number = -vrn*v_coef;
			//spring->target_vrn = vrn + v_damp;
			target_vrn = vrn + v_damp;
			
			//apply_impulses(a, b, spring->r1, spring->r2, cpvmult(spring->n, v_damp*spring->nMass));
			var j:Vector2D = n.mult(v_damp*nMass) ;//cpvmult(spring->n, f_spring*dt)
			a.ApplyImpulse(j.mult(-1), r1);
			b.ApplyImpulse(j, r2);	
		}

		override public function draw(g : Graphics) : void {
			g.lineStyle(2, 0x000000);
			g.moveTo(a.p.x + anchor1.x, a.p.y + anchor1.y);
			g.lineTo(b.p.x + anchor2.x, b.p.y + anchor2.y);
		}
	}
}
