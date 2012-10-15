/**
 *	闪电式带状条带发射器 
 */
package away3d.particle.Dragger
{
	import away3d.cameras.Camera3D;
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Object3D;
	import away3d.core.traverse.EntityCollector;
	import away3d.core.traverse.PartitionTraverser;
	import away3d.particle.Particle;
	import away3d.particle.StripeSystem;
	
	import flash.geom.Vector3D;
	
	public class LightingStripeEmitter extends StripeEmitterBase
	{
		private const zeroVector3D : Vector3D = new Vector3D(0, 0, 0);
		
		public var shakeTime : int = 1000;		// 抖动的时间间隔
		public var shakeAmp : Number = 0;		// 抖动幅度
		public var color : uint = 0xffffff;	// 颜色
		public var alpha : Number = 1;			// 透明度
		public var lifeTime : Number = 1000;		// 粒子的生命时间(条带的粒子并不死亡，但会用此时间做各种动画)
		
		public var lightingPoint1 : ObjectContainer3D;
		public var lightingPoint2 : ObjectContainer3D;
		
		private var _lastShakeTime : int = -1;
		
		private var tmpVec : Vector3D = new Vector3D;
		
		public function LightingStripeEmitter(stripeSystem:StripeSystem = null)
		{
			super(stripeSystem);
		}
		
		override public function Update(deltaTime : int, traverser : PartitionTraverser) : void
		{
			if(!_stripeSystem)
				return;
			
			var si : int;
			for(si=0; si<stripeNum; si++)
			{
				// 对每个条
				var indexOrder : Vector.<int> = getIndexOrder(si);
				
				// 创建和销毁粒子
				for(var oi:int=0; oi<indexOrder.length; oi++)
				{
//					if(oi >= particleCount )
//					{
//						
//						if(indexOrder[oi] >= 0)
//						{
//							_stripeSystem.particles[indexOrder[oi]].lifeTime = -1;
//							indexOrder[oi] = -1;							
//						}
//						continue;
//					}
					
					if(indexOrder[oi] == -1)
					{
						var newParticle : Particle = _stripeSystem.GenerateParticle();
						if(newParticle)
						{
							newParticle.reset();
							newParticle.remainTime = lifeTime;
							newParticle.noDead = true;
							indexOrder[oi] = newParticle.index;
						}
						else
							indexOrder[oi] = indexOrder[0];
					}					
				}
				setStripeParticleNum(si, indexOrder.length);
				
				var isShake : Boolean = false;
				if(_lastShakeTime < 0)
					isShake = true;
				else if( _lastShakeTime > shakeTime )
				{
					_lastShakeTime %= shakeTime;
					isShake = true;
				}
				
				if(lightingPoint1 && lightingPoint2)
				{
					// 计算抖动方向
					var p1 : Particle = _stripeSystem.particles[indexOrder[0]];
					var p2 : Particle = _stripeSystem.particles[indexOrder[indexOrder.length-1]];
					
					var stripeDir : Vector3D = p2.pos.subtract(p1.pos);
					
					var cam : Camera3D = EntityCollector(traverser).camera;
					var camVector : Vector3D = cam.unprojectRay(0, 0);
					camVector.normalize();
					
					var shakeDir : Vector3D = stripeDir.crossProduct(camVector);
					shakeDir.normalize();			// 抖动方向
					
					var lightingDir : Vector3D = lightingPoint2.scenePosition.subtract( lightingPoint1.scenePosition );		// 闪电方向
					
					// 设置粒子属性				
					for(var pi:int=0; pi<indexOrder.length; pi++)
					{
						var p : Particle = _stripeSystem.particles[indexOrder[pi]];
							
						// 位置
						tmpVec.copyFrom(lightingDir);
						p.pos.copyFrom(lightingPoint1.scenePosition);
						tmpVec.scaleBy(Number(pi)/(indexOrder.length-1))
						p.pos = p.pos.add( tmpVec );
							
						// 抖动偏移
						if(isShake)
						{
							p.shake = shakeAmp*(Math.random()*2 - 1);
						}
						tmpVec.copyFrom(shakeDir);
						tmpVec.scaleBy(p.shake);
						p.pos = p.pos.add(tmpVec);
						
						// 旋转
						p.rotMat.copyFrom(_stripeSystem.sceneTransform);
						p.rotMat.copyRowFrom(3, zeroVector3D);		// 去掉位移
						
						p.dir = new Vector3D(0, 1, 0);
						p.sizeX = width;
						p.sizeY = width;
						p.color = color;
						p.alpha = alpha;
					}
				}
			
				_lastShakeTime += deltaTime;
				
				// Debug.bltrace
//				if(true)
//				{
//					var logStr :String = si+":";
//					for(var ri:int=0; ri<indexOrder.length; ri++)
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