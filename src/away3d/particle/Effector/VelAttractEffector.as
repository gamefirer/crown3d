/**
 *	速度吸引器 
 */
package away3d.particle.Effector
{
	import away3d.particle.Displayer.GpuDisplayer;
	import away3d.particle.Particle;
	import away3d.particle.ParticleSystem;
	
	import flash.geom.Vector3D;
	
	public class VelAttractEffector implements ParticleEffectorBase
	{
		public var attractPoint : Vector3D = new Vector3D;
		public var vel : Number = 0;		// 速度值
		
		protected var _particleSystem : ParticleSystem;
		public function setParticleSystem(value : ParticleSystem) : void { _particleSystem = value;	}
		
		public function VelAttractEffector()
		{
			super();
		}
		
		public function updateParticles(deltaTime:int, partilce:Particle):void
		{
		}
		
		public function updateGpuData(vect4 : Vector.<Number>) : void
		{
			var v : Vector3D;
			v = attractPoint;
			
			vect4[0] = v.x;
			vect4[1] = v.y
			vect4[2] = v.z;
			vect4[3] = vel;			
		}
		
		public function initGpuDisplayer(gpuDisplayer:GpuDisplayer):void
		{
		}
	}
}