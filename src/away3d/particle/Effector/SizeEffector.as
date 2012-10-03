/**
 *	粒子大小的控制器 
 */
package away3d.particle.Effector
{
	import away3d.errors.AbstractMethodError;
	import away3d.materials.passes.GpuParticlePass;
	import away3d.particle.Displayer.GpuDisplayer;
	import away3d.particle.Particle;
	import away3d.particle.ParticleSystem;
	
	public class SizeEffector implements ParticleEffectorBase
	{
		private var keyFrameLifeTime : Vector.<Number> = new Vector.<Number>;
		private var SX : Vector.<int> = new Vector.<int>;
		private var SY : Vector.<int> = new Vector.<int>;
		
		protected var _particleSystem : ParticleSystem;
		public function setParticleSystem(value : ParticleSystem) : void { _particleSystem = value;	}
		
		public function SizeEffector()
		{
			super();
		}
		public function addKeyFrame(lifePercent : Number, sizeX : int  , sizeY:int) : void
		{
			if(lifePercent < 0) lifePercent = 0;
			if(lifePercent > 1) lifePercent = 1;
			var i:int = 0;
			while(i<keyFrameLifeTime.length && lifePercent > keyFrameLifeTime[i])
			{
				i++;
			}
			
			keyFrameLifeTime.splice(i, 0, lifePercent);
			SX.splice(i, 0, sizeX);
			SY.splice(i,0,sizeY);
			
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
			var sx : int;
			var sy : int;
			var len : uint = keyFrameLifeTime.length;
			
			if(lifePercent <= keyFrameLifeTime[0] || keyFrameLifeTime.length == 1)
			{
				sx = SX[0];
				sy = SY[0]
			}
			else if( lifePercent >= keyFrameLifeTime[len-1] )
			{
				sx = SX[len-1];
				sy = SY[len-1]
				
			}
			else
			{
				var i : int = 1;
				while(i<len && lifePercent > keyFrameLifeTime[i])
				{
					i++;
				}
				
				var pro : Number = (lifePercent - keyFrameLifeTime[i-1]) / (keyFrameLifeTime[i] - keyFrameLifeTime[i-1]);
				
				sx = SX[i-1]*(1-pro) + SX[i]*pro;
				sy = SY[i-1]*(1-pro) + SY[i]*pro;
			}
			partilce.sizeX = sx;
			partilce.sizeY = sy;
			
		}
		
		public function updateGpuData(vect44 : Vector.<Number>) : void
		{
			var i:uint=0;
			var ki:uint=0;
			
			while(i < GpuParticlePass.gpuEffectorKeyFrameMax)
			{
				if(ki < keyFrameLifeTime.length)
				{
					vect44[i*4] = SX[ki];
					vect44[i*4+1] = SY[ki];
					vect44[i*4+3] = keyFrameLifeTime[ki];
				}
				else
				{
					vect44[i*4] = SX[keyFrameLifeTime.length-1];
					vect44[i*4+1] = SY[keyFrameLifeTime.length-1];
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