/*
 *	粒子发射器基类
 */
package away3d.particle.Emitter
{
	import away3d.arcane;
	import away3d.errors.AbstractMethodError;
	import away3d.particle.ParticleSystem;
	
	use namespace arcane;
	
	public class ParticleEmitterBase
	{
		protected var _particleSystem : ParticleSystem;
		public var emitPeriod : int = 0;		// 发射周期
		public var emitTime : int = 0;			// 发射时间
		
		protected var _lastTime : int = 0;		// 经过的时间
		protected var _isInEmitTime : Boolean = true;		// 是否在发射的周期中
		
		public function ParticleEmitterBase(particleSystem : ParticleSystem)
		{
			_particleSystem = particleSystem;
		}
		
		public function set particleSystem(value : ParticleSystem) : void
		{
			if(_particleSystem)
			{	// 脱离当前发射器
				_particleSystem.emitter = null;
			}
			_particleSystem = value;
		}
		
		public function get particleSystem() : ParticleSystem
		{
			return _particleSystem;
		}
		
		public function restart() : void
		{
			_lastTime = 0;
		}
		
		public function Update(currentTime : int, deltaTime : int) : void
		{
			
		}
		
		protected function UpdateTime(deltaTime : int) : void
		{
			_lastTime += deltaTime;
			
			if(emitTime >= emitPeriod || emitPeriod <= 0)
				_isInEmitTime = true;
			else
			{
				var remainTime : int = _lastTime % emitPeriod;
				_isInEmitTime = (remainTime <= emitTime);
			}
		}
	}
}