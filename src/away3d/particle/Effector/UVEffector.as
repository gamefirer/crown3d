/**
 *	粒子的UV控制器 
 */
package away3d.particle.Effector
{
	import away3d.materials.passes.GpuParticlePass;
	import away3d.particle.Displayer.GpuDisplayer;
	import away3d.particle.Particle;
	import away3d.particle.ParticleSystem;
	
	public class UVEffector implements ParticleEffectorBase
	{
		
		public var scaleU : Number = 1.0;
		public var scaleV : Number = 1.0;
		
		public var smoothU : Boolean = true;
		public var smoothV : Boolean = true;
		
		protected var _particleSystem : ParticleSystem;
		
		private var keyFrameLifeTime : Vector.<Number> = new Vector.<Number>;
		private var U : Vector.<Number> = new Vector.<Number>;
		private var V : Vector.<Number> = new Vector.<Number>;
		
		public function setParticleSystem(value : ParticleSystem) : void { _particleSystem = value;	}
		
		public function UVEffector()
		{
			super();
		}
		
		
		public function addKeyFrame(lifePercent : Number, u : Number, v : Number) : void
		{
			if(lifePercent < 0) lifePercent = 0;
			if(lifePercent > 1) lifePercent = 1;
			var i:int = 0;
			while(i<keyFrameLifeTime.length && lifePercent > keyFrameLifeTime[i])
			{
				i++;
			}
			
			keyFrameLifeTime.splice(i, 0, lifePercent);
			U.splice(i, 0, u);
			V.splice(i, 0, v);
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
			
			var u : Number;
			var v : Number;
			
			var len : uint = keyFrameLifeTime.length;
			
			if(lifePercent <= keyFrameLifeTime[0])
			{
				u = U[0];
				v = V[0];
			}
			else if( lifePercent >= keyFrameLifeTime[len-1] )
			{
				u = U[len-1];
				v = V[len-1];
			}
			else
			{
				var i : int = 1;
				while(i<len && lifePercent > keyFrameLifeTime[i])
				{
					i++;
				}
				
				var pro : Number = (lifePercent - keyFrameLifeTime[i-1]) / (keyFrameLifeTime[i] - keyFrameLifeTime[i-1]);
				
				if(smoothU)
				{
					u = U[i-1]*(1-pro) + U[i]*pro;
				}
				else
				{
					u = U[i-1];
				}
				
				if(smoothV)
				{
					v = V[i-1]*(1-pro) + V[i]*pro;
				}
				else
				{
					v = V[i-1];
				}
				
			}
			
			partilce.u = u;
			partilce.v = v;
			partilce.su = scaleU;
			partilce.sv = scaleV;
			
			
		}
		
		public function updateGpuData(vect44 : Vector.<Number>) : void
		{
			var i:uint=0;
			var ki:uint=0;
			
			while(i < GpuParticlePass.gpuUVKeyFrameMax)
			{
				if(ki < keyFrameLifeTime.length)
				{
					vect44[i*4] = U[ki];
					vect44[i*4+1] = V[ki];
					vect44[i*4+3] = keyFrameLifeTime[ki];
				}
				else
				{
					vect44[i*4] = U[keyFrameLifeTime.length-1];
					vect44[i*4+1] = V[keyFrameLifeTime.length-1];
					vect44[i*4+3] = keyFrameLifeTime[keyFrameLifeTime.length-1];
				}
				
				if(i==0)
					vect44[i*4+3] = 0;
				else if(i == GpuParticlePass.gpuUVKeyFrameMax-1)
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
			gpuDisplayer.scaleU = scaleU;
			gpuDisplayer.scaleV = scaleV;
		}
	}
}

class Keyframe
{
	public var liftTimePercent : Number;
	public var U : Number;
	public var V : Number;
}
