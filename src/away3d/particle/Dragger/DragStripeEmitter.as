/**
 *	拖拽式条带发射器(目前只拖一个条)
 */
package away3d.particle.Dragger
{
	import away3d.core.traverse.PartitionTraverser;
	import away3d.particle.Particle;
	import away3d.particle.StripeSystem;
	
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;

	public class DragStripeEmitter extends StripeEmitterBase
	{
		private const zeroVector3D : Vector3D = new Vector3D(0, 0, 0);
		
		public var color : uint = 0xffffff;	// 颜色
		public var alpha : Number = 1;			// 透明度
		
		public function DragStripeEmitter(stripeSystem : StripeSystem = null)
		{		
			super(stripeSystem);
		}
		
		override public function Update(deltaTime : int, traverser : PartitionTraverser) : void
		{
			if(!_stripeSystem)
				return;
			// 每帧为每条带生成一个粒子
			var si : int;
//			for(si=0; si<stripeNum; si++)
			for(si=0; si<1; si++)			// 只能拖一个条
			{
				var indexOrder : Vector.<int> = getIndexOrder(si);
				
				var newParticle : Particle = _stripeSystem.GenerateParticle();
				if(!newParticle)
				{	// 无粒子可用,则把条带中最后一个粒子,放到前面来
					var lasti :int;
					for(lasti = indexOrder.length-1; lasti>=0; lasti--)
					{
						if(indexOrder[lasti] >= 0 )
							break;
					}
					if(lasti >= 0)
					{
						newParticle = _stripeSystem.particles[indexOrder[lasti]];
						indexOrder[lasti] = -1;
					}
				}
				
				// 重新对index排序, 并处理死亡的粒子
				var ri:int;
				var validParticleCount : int = 0;
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
				setStripeParticleNum(si, validParticleCount);
								
				// 设置粒子属性
				if(newParticle)
				{
					newParticle.reset();
					if(_stripeSystem.isWolrdParticle)
					{
						newParticle.pos.copyFrom(_stripeSystem.scenePosition);
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
//				var logStr :String = "";
//				for(ri=0; ri<indexOrder.length; ri++)
//				{
//					logStr += indexOrder[ri];
//					logStr += " ";
//				}
//				Debug.bltrace(logStr);
			}
		}
	}
}