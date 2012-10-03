/**
 *	粒子的颜色控制器 
 */
package away3d.particle.Effector
{
	import away3d.materials.passes.GpuParticlePass;
	import away3d.particle.Displayer.GpuDisplayer;
	import away3d.particle.Particle;
	import away3d.particle.ParticleSystem;
	
	public class ColorEffector implements ParticleEffectorBase
	{
		private var keyFrameLifeTime : Vector.<Number> = new Vector.<Number>;
		
		private var R : Vector.<int> = new Vector.<int>;
		private var G : Vector.<int> = new Vector.<int>;
		private var B : Vector.<int> = new Vector.<int>;
		
		protected var _particleSystem : ParticleSystem;
		public function setParticleSystem(value : ParticleSystem) : void { _particleSystem = value;	}
		
		public function ColorEffector()
		{
			super();
		}
		
		public function addKeyFrame(lifePercent : Number, r : int, g : int, b : int) : void
		{
			if(lifePercent < 0) lifePercent = 0;
			if(lifePercent > 1) lifePercent = 1;
			var i:int = 0;
			while(i<keyFrameLifeTime.length && lifePercent > keyFrameLifeTime[i])
			{
				i++;
			}
			
			keyFrameLifeTime.splice(i, 0, lifePercent);
			R.splice(i, 0, r);
			G.splice(i, 0, g);
			B.splice(i, 0, b);
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
			
			var r : int;
			var g : int;
			var b : int;
			
			var len : uint = keyFrameLifeTime.length;
			
			if(lifePercent <= keyFrameLifeTime[0] || keyFrameLifeTime.length == 1)
			{
				r = R[0];
				g = G[0];
				b = B[0];
			}
			else if( lifePercent >= keyFrameLifeTime[len-1] )
			{
				r = R[len-1];
				g = G[len-1];
				b = B[len-1];
			}
			else
			{
				var i : int = 1;
				while(i<len && lifePercent > keyFrameLifeTime[i])
				{
					i++;
				}
				
				var pro : Number = (lifePercent - keyFrameLifeTime[i-1]) / (keyFrameLifeTime[i] - keyFrameLifeTime[i-1]);
				
				r = R[i-1]*(1-pro) + R[i]*pro;
				g = G[i-1]*(1-pro) + G[i]*pro;
				b = B[i-1]*(1-pro) + B[i]*pro;
				
			}
			
			partilce.color = ((r & 0xff) << 16) + ((g & 0xff) << 8) + (b & 0xff);					
		}
		
		public function updateGpuData(vect44 : Vector.<Number>) : void
		{
			var i:uint=0;
			var ki:uint=0;
				
			while(i < GpuParticlePass.gpuEffectorKeyFrameMax)
			{
				if(ki < keyFrameLifeTime.length)
				{
					vect44[i*4] = Number(R[ki]) / 0xff;
					vect44[i*4+1] = Number(G[ki]) / 0xff;
					vect44[i*4+2] = Number(B[ki]) / 0xff;
					vect44[i*4+3] = keyFrameLifeTime[ki];
				}
				else
				{
					vect44[i*4] = Number(R[keyFrameLifeTime.length-1]) / 0xff;
					vect44[i*4+1] = Number(G[keyFrameLifeTime.length-1]) / 0xff;
					vect44[i*4+2] = Number(B[keyFrameLifeTime.length-1]) / 0xff;
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