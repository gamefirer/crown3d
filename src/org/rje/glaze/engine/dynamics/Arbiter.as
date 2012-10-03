// Copyright (c) 2007 Scott Lembcke
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// 

package org.rje.glaze.engine.dynamics {
	import away3d.debug.Debug;
	
	import org.rje.glaze.engine.collision.shapes.GeometricShape;
	import org.rje.glaze.engine.math.Vector2D;

	/**
	 * 
	 */
	public class Arbiter {
		
		//The amount of penetration to reduce in each step. 
		//Values should range from 0 to 1. 
		//Using large values will eliminate penetration in fewer steps, but can cause vibration. 
		//bias_coef defaults to 0.1.
		public static var BIAS_COEF:Number = 0.1;
		
		//The amount that shapes are allowed to penetrate
		//Setting this to zero will work just fine, but using a small positive amount will help prevent oscillating contacts. 
		//collision_slop defaults to 0.1.
		public static var COLLISION_SLOP:Number = 0.1;// 005;// 1;
		
		public var contacts:Contact;
		
		public var a:GeometricShape;
		public var b:GeometricShape;
		
		public var u:Number;
		public var e:Number;
		
		public var target_v:Vector2D;
		
		public var stamp:int;
		public var count:int;

		public var id1:uint;
		public var id2:uint;
		
		public var bias_coef:Number = BIAS_COEF;
		public var collision_slop:Number = COLLISION_SLOP;
		
		public var updated:Boolean;
		
		public var sleeping:Boolean;
		
		//public var newCollision:Boolean;

		public var isSensor:Boolean;
		
		public var next:Arbiter;
		
		//public var checked:Boolean; //TODO sleep
		
		public static var arbiterPool:Arbiter;
		
		public function Arbiter() {
			//arbiters = new ArbiterProxy();
			//arbiters.next = arbiters;
			//arbiters.prev = arbiters;
			//arbiters.sentinel = true;
			
			contacts = null;
			target_v = new Vector2D();
			u = e = 0;
		}
		
		public function assign(a:GeometricShape, b:GeometricShape, stamp:int):void {
			this.a = a;
			this.b = b;
			this.stamp = stamp;
			this.u = this.e = 0;
			target_v.x = target_v.y = 0;
		}
		
		public function toString():String {
			/*
			var s:String = "Arbiter: hash=" + hash +"\n";
			s += " BodyA=" + a.shapeID + " Type=" + a.shapeType +"\n";
			s += " BodyB=" + b.shapeID + " Type=" + b.shapeType +"\n";
			s += " Contacts:\n";
			var contact:Contact = contacts;
			while (contact) {
				s += "  "+contact.toString() + "\n";
				contact = contact.next;
			}
			s += " Sum Impulses=" + SumImpulses().toString() +"\n";
			return s;
			*/
			return null;
		}
		
		public function SumImpulses():Vector2D {
			var sum:Vector2D = new Vector2D;
			var contact:Contact = contacts;
			while (contact) {
				sum.x += contact.n.x * contact.jnAcc;
				sum.y += contact.n.y * contact.jnAcc;
				contact = contact.next;
			}
			return sum;
		}
		
		public function SumImpulsesWithFriction():Vector2D {
			var sum:Vector2D = new Vector2D;
			var contact:Contact = contacts;
			while (contact) {
				sum.x += (contact.n.x * contact.jnAcc)+(-contact.n.y*contact.jnAcc);
				sum.y += (contact.n.y * contact.jnAcc)+(contact.n.x*contact.jnAcc);
				contact = contact.next;
			}
			return sum;
		}

		public function injectContact( pX:Number , pY:Number , nX:Number , nY:Number , nCoef:Number, dist:Number , hash:uint):void {
			
			if (isSensor) return;
			
			var contact:Contact = contacts;
			
			while (contact) {
				if (hash == contact.hash) break;
				contact = contact.next;
			}

			if (!contact) {
				// 添加contact
				if (Contact.contactPool == null) {
					contact = new Contact();					
				} else {
					contact = Contact.contactPool;
					Contact.contactPool = Contact.contactPool.next;
				}
				contactNumber++;
//				Debug.bltrace("add contact "+contactNumber + " " + id1 + " " + id2);
				
				contact.next = contacts;
				contacts = contact;
				contact.hash = hash;
				contact.jnAcc = contact.jtAcc = 0;
			}
			
			contact.p.x = pX;
			contact.p.y = pY;
			contact.n.x = nX * nCoef;
			contact.n.y = nY * nCoef;
			contact.dist = dist;
			//contact.r1.x = contact.r1.y = 0;
			//contact.r2.x = contact.r2.y = 0;
			//contact.r1n.x = contact.r1n.y = 0;
			//contact.r2n.x = contact.r2n.y = 0;
			//contact.nMass = contact.tMass = contact.bounce = contact.jBias = contact.bias = 0;
			contact.updated = true;
		}
		
		private var contactNumber : int = 0;
		
		public function PreStep( dt_inv:Number ):void {
			
			var bodyA:RigidBody = a.body;
			var bodyB:RigidBody = b.body;

			e = a.material.restitution * b.material.restitution;
			u = a.material.friction * b.material.friction;
			
			target_v.x = b.surface_v.x - a.surface_v.x;
			target_v.y = b.surface_v.y - a.surface_v.y;
			
			var mass_sum:Number = bodyA.m_inv + bodyB.m_inv;
			
			var contact:Contact = contacts;
			var lastContact:Contact;

			var maxLoop : int = 50;			// 防止死循环
			while (contact && maxLoop > 0) {
				maxLoop--;
				if (!contact.updated) {
					contactNumber--;
//					Debug.bltrace("del contact "+contactNumber + " " + id1 + " " + id2);
					var oldContact:Contact = contact;
					if (contact==contacts) {
						contact = contacts = contact.next;
					} else if (contact.next == null) {
						contact = lastContact.next = null;
					} else {
						contact = lastContact.next = contact.next;
					}
					oldContact.next = (Contact.contactPool == null) ? null : Contact.contactPool;
					Contact.contactPool = oldContact;		// 释放contacet
					continue;
				}
				
				contact.updated = false;
				
				if(bodyA.isBlockable || bodyB.isBlockable)		// 非block物体，无需计算
				{
					contact.r1.x = contact.p.x - bodyA.p.x;
					contact.r1.y = contact.p.y - bodyA.p.y;
					contact.r2.x = contact.p.x - bodyB.p.x;
					contact.r2.y = contact.p.y - bodyB.p.y;
					
					contact.r1n.x = -contact.r1.y;
					contact.r1n.y =  contact.r1.x;
					contact.r2n.x = -contact.r2.y;
					contact.r2n.y =  contact.r2.x;
					
					var r1cn:Number = contact.r1.x * contact.n.y - contact.r1.y * contact.n.x;
					var r2cn:Number = contact.r2.x * contact.n.y - contact.r2.y * contact.n.x;
					
					var kn:Number = mass_sum + (bodyA.i_inv * r1cn * r1cn) + (bodyB.i_inv * r2cn * r2cn);
					contact.nMass = 1 / kn;
					
					var tx:Number = -contact.n.y;
					var ty:Number = contact.n.x;
	
					var r1ct:Number = contact.r1.x * ty - contact.r1.y * tx;
					var r2ct:Number = contact.r2.x * ty - contact.r2.y * tx;
					var kt:Number = mass_sum + (bodyA.i_inv * r1ct * r1ct) + (bodyB.i_inv * r2ct * r2ct);
					contact.tMass = 1 / kt;
					var corr:Number = contact.dist + collision_slop;
					if (corr > 0) {
						contact.bias = 0;
					} else {
						contact.bias = -bias_coef * dt_inv * corr;
					}
					//contact.bias = -bias_coef * dt_inv * Math.min(0, contact.dist + collision_slop);
					contact.jBias = 0;
					
					var v1x:Number = contact.r1n.x * bodyA.w + bodyA.v.x;
					var v1y:Number = contact.r1n.y * bodyA.w + bodyA.v.y;
					var v2x:Number = contact.r2n.x * bodyB.w + bodyB.v.x;
					var v2y:Number = contact.r2n.y * bodyB.w + bodyB.v.y;
					
					contact.bounce = (contact.n.x * (v2x - v1x) + contact.n.y * (v2y - v1y)) * e;
					
					var cjTx:Number = (contact.n.x * contact.jnAcc) + (tx * contact.jtAcc);
					var cjTy:Number = (contact.n.y * contact.jnAcc) + (ty * contact.jtAcc);
	
					//INLINE Function
					//a.body.ApplyImpulse( j1.mult(-1), contact.r1);
					bodyA.v.x += (-cjTx * bodyA.m_inv);
					bodyA.v.y += (-cjTy * bodyA.m_inv);
					bodyA.w += bodyA.i_inv * (contact.r1.x * -cjTy - contact.r1.y * -cjTx);								
					
					//INLINE Function
					//b.body.ApplyImpulse( j1, contact.r2);
					bodyB.v.x += (cjTx * bodyB.m_inv);
					bodyB.v.y += (cjTy * bodyB.m_inv);
					bodyB.w += bodyB.i_inv * (contact.r2.x * cjTy - contact.r2.y * cjTx);
				}
				
				lastContact = contact;
				contact = contact.next;
				
			}
		}
		
		public function ApplyImpuse():void {
			
			var bodyA:RigidBody = a.body;
			var bodyB:RigidBody = b.body;
			//var bodyAinvMass:Number = bodyA.m_inv;
			//var bodyBinvMass:Number = bodyB.m_inv;
			
			var contact:Contact = contacts;
			if(true)	// blade3d需要的碰撞处理
			{
				if(!bodyA.isBlockable && !bodyB.isBlockable)
					return;
								
				var maxLoop : int = 50;
				while (contact && maxLoop>0)
				{
					var proj : Number;
					var vbx : Number;
					var vby : Number;
					var vx : Number;
					var vy : Number;
					if(bodyA.isBlockable)
					{
//						Debug.bltrace("block");
						vbx = 0;
						vby = 0;
						vx = bodyA.v.x + bodyA.v_bias.x;
						vy = bodyA.v.y + bodyA.v_bias.y;
						
						proj = vx * contact.n.x + vy * contact.n.y;
						if(proj > 0)
						{
							vbx = -contact.n.x * proj;
							vby = -contact.n.y * proj;
						}
						// vbx,vby 为速度在碰撞方向的分量的负值
						
						proj = vbx * bodyA.v_bias.x + vby * bodyA.v_bias.y;
						if( proj >= 0 )
						{						
							bodyA.v_bias.x += vbx;
							bodyA.v_bias.y += vby;
						}
						else
						{	// 如果当前的偏移和要偏移的方向相对，则停止移动
							bodyA.v_bias.x = -bodyA.v.x;
							bodyA.v_bias.y = -bodyA.v.y;
						}
							
					}
					if(bodyB.isBlockable)
					{
						vbx = 0;
						vby = 0;
						vx = bodyB.v.x + bodyB.v_bias.x;
						vy = bodyB.v.y + bodyB.v_bias.y;
						
						proj = vx * -contact.n.x + vy * -contact.n.y;
						if(proj > 0)
						{
							vbx = contact.n.x * proj;
							vby = contact.n.y * proj;							
						}
						
						proj = vbx * bodyB.v_bias.x + vby * bodyB.v_bias.y;
						if( proj >= 0 )
						{						
							bodyB.v_bias.x += vbx;
							bodyB.v_bias.y += vby;
						}
						else
						{
							bodyB.v_bias.x = -bodyB.v.x;
							bodyB.v_bias.y = -bodyB.v.y;
						}
					}
					
					contact = contact.next;
					maxLoop--;
				}
				
			}
			else
			{
				while (contact) {
					//Calculate the relative bias velocities.
					var vbn:Number = (((contact.r2n.x * bodyB.w_bias + bodyB.v_bias.x) - 
									   (contact.r1n.x * bodyA.w_bias + bodyA.v_bias.x)) * contact.n.x) 
								   + (((contact.r2n.y * bodyB.w_bias + bodyB.v_bias.y) - (contact.r1n.y * bodyA.w_bias + bodyA.v_bias.y)) * contact.n.y);
					
					//Calculate and clamp the bias impulse. 
					var jbn:Number = (contact.bias - vbn) * contact.nMass;
					var jbnOld:Number = contact.jBias;
					contact.jBias = jbnOld + jbn;
					if (contact.jBias < 0)
						contact.jBias = 0;
					
					jbn = contact.jBias - jbnOld;
					
					//Apply the bias impulse.
					var cjTx:Number = contact.n.x * jbn;
					var cjTy:Number = contact.n.y * jbn;
					
					//INLINE Function
					//a.body.ApplyBiasImpulse(cjT, contact.r1);
					bodyA.v_bias.x += (-cjTx * bodyA.m_inv);
					bodyA.v_bias.y += (-cjTy * bodyA.m_inv);
					bodyA.w_bias   += bodyA.i_inv * (contact.r1.x * -cjTy - contact.r1.y * -cjTx);				
					
					//INLINE Function
					//b.body.ApplyBiasImpulse(cjT, contact.r2);
					bodyB.v_bias.x += (cjTx * bodyB.m_inv);
					bodyB.v_bias.y += (cjTy * bodyB.m_inv);
					bodyB.w_bias   += bodyB.i_inv * (contact.r2.x * cjTy - contact.r2.y * cjTx);
					
					
					//Calculate the relative velocity.
					var vrx:Number = (contact.r2n.x * bodyB.w + bodyB.v.x) - (contact.r1n.x * bodyA.w + bodyA.v.x);
					var vry:Number = (contact.r2n.y * bodyB.w + bodyB.v.y) - (contact.r1n.y * bodyA.w + bodyA.v.y);				
					
					//Calculate and clamp the normal impulse.
					var jn:Number = -(contact.bounce + (vrx * contact.n.x + vry * contact.n.y) /*vrn*/ ) * contact.nMass;
	
					var jnOld:Number = contact.jnAcc;
					contact.jnAcc = jnOld + jn;
					if (contact.jnAcc < 0) {
						contact.jnAcc = 0;
					}
					jn = contact.jnAcc - jnOld;
					
					//Calculate the relative tangent velocity.
					var vrt:Number = ((vrx + target_v.x) * -contact.n.y) + ((vry + target_v.y) * contact.n.x);
					
					//Calculate and clamp the friction impulse.
					var jtMax:Number = u * contact.jnAcc;
					var jt:Number = -vrt * contact.tMass;
					var jtOld:Number = contact.jtAcc;
					
					contact.jtAcc = jtOld + jt;
					if (contact.jtAcc < -jtMax) {
						contact.jtAcc = -jtMax;
					} else if (contact.jtAcc > jtMax) {
						contact.jtAcc = jtMax;
					}				
					jt = contact.jtAcc - jtOld;
					
					cjTx = (contact.n.x * jn) + ( -contact.n.y * jt);
					cjTy = (contact.n.y * jn) + (  contact.n.x * jt);
					
					//Apply the final impulse.
					//INLINE Function
					//a.body.ApplyImpulse( j1.mult(-1), contact.r1);
					bodyA.v.x += (-cjTx * bodyA.m_inv);
					bodyA.v.y += (-cjTy * bodyA.m_inv);
					bodyA.w += bodyA.i_inv * (contact.r1.x * -cjTy - contact.r1.y * -cjTx);	
					
					//INLINE Function
					//b.body.ApplyImpulse( j1, contact.r2);
					bodyB.v.x += (cjTx * bodyB.m_inv);
					bodyB.v.y += (cjTy * bodyB.m_inv);
					bodyB.w += bodyB.i_inv * (contact.r2.x * cjTy - contact.r2.y * cjTx);
					
					contact = contact.next;
				}			
			}
		}
		
	}
	
}
