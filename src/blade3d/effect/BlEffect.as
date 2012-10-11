/**
 *	特效对象 
 */
package blade3d.effect
{
	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Entity;
	import away3d.particle.ParticleSystem;
	import away3d.particle.StripeSystem;
	import away3d.primitives.SphereGeometry;
	
	import flash.display.BlendMode;
	import flash.geom.Vector3D;

	public class BlEffect extends ObjectContainer3D
	{
		public var lifeTime : int = 2000;				// 特效持续时间
		private var _lastTime : int = 0;				// 已经存在的时间
		private var _isDead : Boolean = false;		// 是否已经死亡
		private var _isDispose : Boolean = false;		// 是否已经被释放
		public var store : BlEffectStore;				// 创建此特效的store
		
		// 粒子
		private var _particles : Vector.<ParticleSystem> = new Vector.<ParticleSystem>;	// 粒子特效
		private var _particlesData : Vector.<ElementData> = new Vector.<ElementData>;
		// 条带
		private var _stripes : Vector.<StripeSystem> = new Vector.<StripeSystem>;			// 条带特效
		private var _stripesData : Vector.<ElementData> = new Vector.<ElementData>;
		
		
		public function BlEffect()
		{
			_particles = new Vector.<ParticleSystem>;
			
		}
		
		public function addParticle(particle : ParticleSystem, startTime : int, endTime : int):void
		{
			_particles.push(particle);
			addChild(particle);
			
			var elementData : ElementData = new ElementData;
			elementData.startTime = startTime;
			elementData.endTime = endTime;
			_particlesData.push(elementData);
		}
		
		public function addStripe(stripe : StripeSystem, startTime : int, endTime : int) : void
		{
			_stripes.push(stripe);
			addChild(stripe);
			
			var elementData : ElementData = new ElementData;
			elementData.startTime = startTime;
			elementData.endTime = endTime;
			_stripesData.push(elementData);
		}
		
		public function onCreate():void
		{
			var i:int;
			for(i = 0; i < _particles.length; i++)
			{
				_particles[i].renderLayer = Entity.Effect_Layer;
			}
			
			for(i = 0; i < _stripes.length; i++)
			{
				_stripes[i].renderLayer = Entity.Effect_Layer;
			}
		}
		
		public function get isDead() : Boolean { return _isDead; }
		public function get isDispose() : Boolean { return _isDispose; }
		
		public function reset() : void
		{
			_lastTime = 0;
			_isDead = false;
		}
		
		public function play() : void
		{
			reset();
			
			var i:int;
			for(i = 0; i < _particles.length; i++)
			{
				if(_particlesData[i].startTime == 0)
				{
					_particles[i].Start();
					_particles[i].playAllAnimators();
					_particles[i].visible = true;
				}
				else
					_particles[i].visible = false;
			}
			
			for(i=0; i<_stripes.length; i++)
			{
				if(_stripesData[i].startTime == 0)
				{
					_stripes[i].Start();
					_stripes[i].playAllAnimators();
					_stripes[i].visible = true;
				}
				else
					_stripes[i].visible = false;
			}
		}
		
		public function stop() : void
		{
			var i:int;
			for(i=0; i<_particles.length; i++)
			{
				_particles[i].Stop(true);
				_particles[i].stopAllAnimators();
			}
			
			for(i=0; i<_stripes.length; i++)
			{
				_stripes[i].Stop(true);
				_stripes[i].stopAllAnimators();
			}
		}
		
		// 回收
		public function recycle():void
		{
			stop();
			
			store.recycle(this);
		}
		// 释放
		override public function dispose() : void
		{
			_isDispose = true;
			//...
			var i:int;
			for(i=0; i<_particles.length; i++)
			{
				_particles[i].dispose();
			}
			_particles.length = 0;
			
			for(i=0; i<_stripes.length; i++)
			{
				_stripes[i].dispose();
			}
			_stripes.length = 0;
			
			super.dispose();
		}
		
		public function updateEff(time:uint, deltaTime:uint):void
		{
			var curLastTime : int = _lastTime + deltaTime;
			// 更新特效元素的状态
			var i:int;
			for(i=0; i<_particles.length; i++)
			{
				if(_particlesData[i].startTime > _lastTime && _particlesData[i].startTime <= curLastTime)
				{
					_particles[i].Start();
					_particles[i].playAllAnimators();
					_particles[i].visible = true;
				}
				if(_particlesData[i].endTime > _lastTime && _particlesData[i].endTime <= curLastTime)
				{
					_particles[i].Stop(true);
					_particles[i].stopAllAnimators();
					_particles[i].visible = false;
				}
			}
			
			for(i=0; i<_stripes.length; i++)
			{
				if(_stripesData[i].startTime > _lastTime && _stripesData[i].startTime <= curLastTime)
				{
					_stripes[i].Start();
					_stripes[i].playAllAnimators();
					_stripes[i].visible = true;
				}
				if(_stripesData[i].endTime > _lastTime && _stripesData[i].endTime <= curLastTime)
				{
					_stripes[i].Stop(true);
					_stripes[i].stopAllAnimators();
					_stripes[i].visible = false;
				}
			}
			
			// 更新自身时间
			_lastTime += deltaTime;
			if(lifeTime>=0 && !_isDead)
			{
				if(_lastTime > lifeTime)
					_isDead = true;
			}
		}
	}
}

class ElementData
{
	public var startTime : int;
	public var endTime : int;
	
	public function ElementData()
	{
	}
}