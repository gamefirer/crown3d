package org.rje.glaze.engine.dynamics.constraints {
	import org.rje.glaze.engine.dynamics.RigidBody;

	/**
	 * @author Richard.Jewson
	 */
	public class DampedRotarySpring extends Constraint {
		
		public var restAngle : Number;
		public var stiffness : Number;
		public var damping : Number;
		
		private var iSum : Number;
		private var w_coef : Number;
		private var target_wrn : Number;

		
		public function DampedRotarySpring(a : RigidBody, b : RigidBody, restAngle:Number, stiffness:Number, damping:Number) {
			super(a, b);
			this.restAngle = restAngle;
			this.stiffness = stiffness;
			this.damping = damping;
		}

		
		override public function PreStep(dt : Number, dt_inv : Number) : void {
//			cpFloat moment = a->i_inv + b->i_inv;
			var moment:Number = a.i_inv + b.i_inv;
//			spring->iSum = 1.0f/moment;
			iSum = 1/moment;
//			spring->w_coef = 1.0f - cpfexp(-spring->damping*dt*moment);
			w_coef = 1 - Math.exp(-damping * dt * moment);
//			spring->target_wrn = 0.0f;
			target_wrn = 0;			
			// apply spring torque
//			cpFloat j_spring = spring->springTorqueFunc((cpConstraint *)spring, a->a - b->a)*dt;
			var j_spring:Number = (((a.a - b.a) - restAngle) * stiffness) * dt;//(relativeAngle - spring->restAngle)*spring->stiffness
//			a->w -= j_spring*a->i_inv;
			a.w -= j_spring * a.i_inv;
//			b->w += j_spring*b->i_inv;
			b.w += j_spring * b.i_inv;
		}

		
		override public function ApplyImpuse() : void {
			// compute relative velocity
			//cpFloat wrn = a->w - b->w;//normal_relative_velocity(a, b, r1, r2, n) - spring->target_vrn;
			var wrn:Number = a.w - b.w;
			// compute velocity loss from drag
			// not 100% certain this is derived correctly, though it makes sense
			//cpFloat w_damp = wrn*spring->w_coef;
			var w_damp:Number = wrn * w_coef;
			//spring->target_wrn = wrn - w_damp;
			target_wrn = wrn - w_damp;
			//cpFloat j_damp = w_damp*spring->iSum;
			var j_damp:Number = w_damp * iSum;
			//a->w -= j_damp*a->i_inv;
			a.w -= j_damp * a.i_inv;
			//b->w += j_damp*b->i_inv;
			b.w += j_damp * b.i_inv;
		}
	}
}
