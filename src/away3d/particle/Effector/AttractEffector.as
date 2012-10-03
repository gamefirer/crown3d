/**
 *	吸引力控制器 
 */
package away3d.particle.Effector
{
	import away3d.particle.Displayer.GpuDisplayer;
	import away3d.particle.Particle;
	import away3d.particle.ParticleSystem;
	
	import flash.geom.Vector3D;
	
	public class AttractEffector implements ParticleEffectorBase
	{
		public var attractPoint : Vector3D = new Vector3D;
		public var force : Number = 0;		// 每秒影响的速度值
		
		private var tmp : Vector3D = new Vector3D;
		
		protected var _particleSystem : ParticleSystem;
		public function setParticleSystem(value : ParticleSystem) : void { _particleSystem = value;	}
		
		public function AttractEffector()
		{
			super();
		}
		
		public function updateParticles(deltaTime : int, partilce : Particle) : void
		{
			var v : Vector3D;
			if(_particleSystem.isWolrdParticle)
			{
				v = _particleSystem.sceneTransform.transformVector(attractPoint);
			}
			else
				v =	attractPoint;
				
			v = v.subtract(partilce.pos);
			if(v.lengthSquared < 100)
			{	// 粒子已经运动到引力点
				partilce.vel = 0;
				return;
			}
			
			v.normalize();
			
			v.scaleBy( force * deltaTime / 1000 );
			
			tmp.copyFrom(partilce.dir);
			tmp.scaleBy(partilce.vel);
			
			tmp = tmp.add(v);
			
			partilce.vel = tmp.length;
			tmp.normalize();
			partilce.dir.copyFrom(tmp);
			
		}
		
		public function updateGpuData(vect4 : Vector.<Number>) : void
		{
			var v : Vector3D;
			v = attractPoint;
			
			vect4[0] = v.x;
			vect4[1] = v.y
			vect4[2] = v.z;
			vect4[3] = force;			
		}
		
		public function initGpuDisplayer(gpuDisplayer : GpuDisplayer) : void
		{
			
		}
	}
}