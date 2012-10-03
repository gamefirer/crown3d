/**
 *	粒子的透明度控制器 
 */
package away3d.particle.Effector
{
	import away3d.materials.passes.GpuParticlePass;
	import away3d.particle.Displayer.GpuDisplayer;
	import away3d.particle.Particle;
	import away3d.particle.ParticleSystem;
	
	public class AlphaEffector implements ParticleEffectorBase
	{
		private var keyFrameLifeTime : Vector.<Number> = new Vector.<Number>;
		private var A : Vector.<int> = new Vector.<int>;
		
		protected var _particleSystem : ParticleSystem;
		public function setParticleSystem(value : ParticleSystem) : void { _particleSystem = value;	}
			
		public function AlphaEffector()
		{
			super();
		}
		
		public function addKeyFrame(lifePercent : Number, a : int) : void
		{
			if(lifePercent < 0) lifePercent = 0;
			if(lifePercent > 1) lifePercent = 1;
			var i:int = 0;
			while(i<keyFrameLifeTime.length && lifePercent > keyFrameLifeTime[i])
			{
				i++;
			}
			
			keyFrameLifeTime.splice(i, 0, lifePercent);
			A.splice(i, 0, a);
		}
		
		public function keyFrameCount() : uint
		{
			return keyFrameLifeTime.length;
		}
		
		public function updateParticles(deltaTime : int, partilce : Particle) : void
		{
			if(keyFrameLifeTime.length <= 0)
				return;
			
			var lifePercent : Number = partilce.pastTime / (partilce.pastTime + partilce.remainTime);
			var a : int;
			
			var len : uint = keyFrameLifeTime.length;
			
			if(lifePercent <= keyFrameLifeTime[0] || keyFrameLifeTime.length == 1)
			{
				a = A[0];
			}
			else if( lifePercent >= keyFrameLifeTime[len-1] )
			{
				a = A[len-1];
			 
			}
			else
			{
				var i : int = 1;
				while(i<len && lifePercent > keyFrameLifeTime[i])
				{
					i++;
				}
				
				var pro : Number = (lifePercent - keyFrameLifeTime[i-1]) / (keyFrameLifeTime[i] - keyFrameLifeTime[i-1]);
				
				a = A[i-1]*(1-pro) + A[i]*pro;
				
			}
			partilce.alpha = Number(a)/255;
			
			
		}
		
		public function updateGpuData(vect44 : Vector.<Number>) : void
		{
			var i:uint=0;
			var ki:uint=0;
			
			while(i < GpuParticlePass.gpuEffectorKeyFrameMax)
			{
				if(ki < keyFrameLifeTime.length)
				{
					vect44[i*4] = Number(A[ki]) / 0xff;
					vect44[i*4+3] = keyFrameLifeTime[ki];
				}
				else
				{
					vect44[i*4] = Number(A[keyFrameLifeTime.length-1]) / 0xff;
					vect44[i*4+3] = keyFrameLifeTime[keyFrameLifeTime.length-1];
				}
				
				if(i==0)
					vect44[i*4+3] = 0;
				else if(i == GpuParticlePass.gpuEffectorKeyFrameMax-1)
					vect44[i*4+3] = 1;
				
				if(i==0 && keyFrameLifeTime[ki] > 0)
				{
					
				}
				else
				{
					ki++;
				}
				i++;
			}
		}
		
		public function initGpuDisplayer(gpuDisplayer : GpuDisplayer) : void
		{
			
		}
		
	}
}