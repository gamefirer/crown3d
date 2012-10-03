/**
 *	发射器基类 
 * 	初始位置，发射率
 */
package a3dparticle.emitter
{
	import a3dparticle.ParticlesContainer;
	import a3dparticle.generater.DefaultSingleGenerater;
	import a3dparticle.generater.GeneraterBase;
	import a3dparticle.generater.SingleGenerater;
	import a3dparticle.particle.ParticleParam;
	import a3dparticle.particle.ParticleSample;
	import a3dparticle.utils.rFloat;
	import a3dparticle.utils.rInt;
	
	import flash.geom.Vector3D;

	public class EmitterBase
	{
		static public var EMITTER_TYPE_RECTANGLE : int = 1;		// 矩形发射器
		static public var EMITTER_TYPE_SPHERE : int = 2;			// 球形发射器
		
		public var parent : ParticlesContainer;		// 所属的粒子系统
		
		public var loop : Boolean = true;				// 循环发射
		public var maxParitleNumber : int = 10;		// 最大粒子数
		public var emitterRate : int = 10;				// 每秒发射率
		
		public var period : uint = 0;					// 周期(ms)
		public var emitPeriod : uint = 0;				// 发射周期(ms)
		public var lifeTime : rInt = new rInt(1000);	// 粒子生命期(ms)
			
		private var _generater : GeneraterBase;
		
		public function EmitterBase()
		{
		}
		
		public function get particlesSamples():Vector.<ParticleSample>
		{
			if(!_generater)
			{
				_generater = new SingleGenerater(parent.sampler, maxParitleNumber);
			}
			return _generater.particlesSamples;
		}
		
		public function initParticleParam(param:ParticleParam):void
		{
			param.startTime = 1.0/emitterRate*param.index;		// 粒子开始时间
			param.duringTime = Number(lifeTime.rand) / 1000;					// 粒子持续时间
			param.sleepTime = 0;
			
			if(loop)
			{
				if(period > emitPeriod)
					param.sleepTime = Number(period - emitPeriod) / 1000;
			}
			
			// 设置初始位置
			initPosition(param);
		}
		
		protected function initPosition(param:ParticleParam):void
		{
			
		}
		
	}
}