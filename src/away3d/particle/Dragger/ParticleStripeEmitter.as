/**
 *	粒子式条带发射器(以一个粒子系统中的每个粒子为拖拽器)
 */
package away3d.particle.Dragger
{
	import away3d.core.traverse.PartitionTraverser;
	import away3d.particle.Particle;
	import away3d.particle.ParticleSystem;
	import away3d.particle.StripeSystem;
	
	import flash.geom.Vector3D;
	
	public class ParticleStripeEmitter extends StripeEmitterBase
	{
		private var _attachedParticleSystem : ParticleSystem;
		
		private const zeroVector3D : Vector3D = new Vector3D(0, 0, 0);
		public var color : uint = 0xffffff;	// 颜色
		public var alpha : Number = 1;			// 透明度
		
		public function ParticleStripeEmitter(stripeSystem:StripeSystem = null)
		{
			super(stripeSystem);
		}
		
		public function attachParticleSystem(particleSystem : ParticleSystem) : void
		{
			_attachedParticleSystem = particleSystem;
		}
		
		static protected var tmpP : Vector3D = new Vector3D;		// 计算用暂存变量
		
		override public function Update(deltaTime : int, traverser : PartitionTraverser) : void
		{
			if(!_stripeSystem || !_attachedParticleSystem)
				return;
			
			var _attachedParticles : Vector.<Particle> = _attachedParticleSystem.particles;
			
			// 每个粒子对应一个条带
			var si : int;
			for(si=0; si<stripeNum; si++)
			{
				var indexOrder : Vector.<int> = getIndexOrder(si);
				
				var newParticle : Particle = null;
				// 该粒子存活则，继续拖条带		
				if(si <= _attachedParticleSystem.maxLiveParticleIndex)
				{
					var attachedParticle : Particle = _attachedParticles[si];
					if(!attachedParticle.IsDead())
					{
						newParticle = _stripeSystem.GenerateParticle();
						
					}
				}
				
				// 重新对index排序, 并处理死亡的粒子
				var ri:int;
				var validParticleCount : int = 0;
				
				if(newParticle)
				{	// 拖条带
					for(ri=indexOrder.length-1; ri>0; ri--)
					{
						if(indexOrder[ri-1] >= 0 && _stripeSystem.particles[indexOrder[ri-1]].IsDead())
							indexOrder[ri-1] = -1;
						
						indexOrder[ri] = indexOrder[ri-1];
						if(indexOrder[ri] >= 0)
							validParticleCount++;
					}
					
					indexOrder[0] = newParticle.index;
					validParticleCount++;
				}
				else
				{	// 不拖条带
					for(ri=indexOrder.length-1; ri>=0; ri--)
					{
						if(indexOrder[ri] >= 0 && _stripeSystem.particles[indexOrder[ri]].IsDead())
							indexOrder[ri] = -1;
						
						if(indexOrder[ri] >= 0)
							validParticleCount++;
					}
				}
				
				setStripeParticleNum(si, validParticleCount);
								
				// 设置粒子属性
				if(newParticle)
				{
					newParticle.reset();
					if(_stripeSystem.isWolrdParticle)
					{
						if(_attachedParticleSystem.isWolrdParticle)
							tmpP.copyFrom(attachedParticle.pos);
						else
						{
							tmpP = _attachedParticleSystem.sceneTransform.transformVector(attachedParticle.pos);
						}
												
						newParticle.pos.copyFrom(tmpP);
						newParticle.rotMat.copyFrom(_stripeSystem.sceneTransform);
						newParticle.rotMat.copyRowFrom(3, zeroVector3D);		// 去掉位移
					}
					else
					{
						newParticle.pos.setTo(0, 0, 0);
						newParticle.rotMat.identity();
					}
					newParticle.remainTime = dragTime;
					newParticle.dir = new Vector3D(0, 1, 0);
					newParticle.sizeX = width;
					newParticle.sizeY = width;
					newParticle.color = color;
					newParticle.alpha = alpha;
				}
				
				// Debug.bltrace
//				if(true)
//				{
//					var logStr :String = si+":";
//					for(ri=0; ri<indexOrder.length; ri++)
//					{
//						logStr += indexOrder[ri];
//						logStr += " ";
//					}
//					Debug.bltrace(logStr);
//				}
			}
		}
	}
}