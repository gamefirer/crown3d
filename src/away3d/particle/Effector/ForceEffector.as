/**
 *	力场控制器,对粒子加某个方向的力
 */
package away3d.particle.Effector
{
	import away3d.particle.Displayer.GpuDisplayer;
	import away3d.particle.Particle;
	import away3d.particle.ParticleSystem;
	
	import flash.geom.Vector3D;
	
	public class ForceEffector implements ParticleEffectorBase
	{
		public var forceDir : Vector3D = new Vector3D;
		public var force : Number = 0;		// 每秒影响的速度值
		
		protected var _particleSystem : ParticleSystem;
		public function setParticleSystem(value : ParticleSystem) : void { _particleSystem = value;	}
		
		public function ForceEffector()
		{
			super();
		}
		
		private static var tmpVect3 : Vector3D = new Vector3D;
		
		public function updateParticles(deltaTime : int, partilce : Particle) : void
		{
			var v : Vector3D
			if(_particleSystem.isWolrdParticle)
				v = _particleSystem.sceneTransform.deltaTransformVector(forceDir);
			else
				v =	forceDir;
			
			v.normalize();
			v.scaleBy( force * deltaTime / 1000 );
			
			tmpVect3.copyFrom(partilce.dir);
			tmpVect3.scaleBy(partilce.vel);
			
			tmpVect3 = tmpVect3.add(v);
			
			partilce.vel = tmpVect3.length;
			tmpVect3.normalize();
			partilce.dir.copyFrom(tmpVect3);
			
		}
		
		public function updateGpuData(vect4 : Vector.<Number>) : void
		{
			vect4[0] = forceDir.x * force;
			vect4[1] = forceDir.y * force;
			vect4[2] = forceDir.z * force;
			
		}
		
		public function initGpuDisplayer(gpuDisplayer : GpuDisplayer) : void
		{
			
		}
	}
}