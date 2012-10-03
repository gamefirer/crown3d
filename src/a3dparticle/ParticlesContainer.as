package a3dparticle
{
	import a3dparticle.animators.ParticleAnimationSet;
	import a3dparticle.animators.ParticleAnimationtor;
	import a3dparticle.animators.actions.ActionBase;
	import a3dparticle.core.ParticlesNode;
	import a3dparticle.core.SubContainer;
	import a3dparticle.emitter.EmitterBase;
	import a3dparticle.generater.GeneraterBase;
	import a3dparticle.particle.ParticleBitmapMaterial;
	import a3dparticle.particle.ParticleParam;
	import a3dparticle.particle.ParticleSample;
	
	import away3d.animators.IAnimationSet;
	import away3d.bounds.AxisAlignedBoundingBox;
	import away3d.bounds.BoundingVolumeBase;
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Object3D;
	import away3d.core.partition.EntityNode;
	import away3d.debug.Debug;
	import away3d.entities.Entity;
	import away3d.materials.utils.DefaultMaterialManager;
	import away3d.primitives.PlaneGeometry;
	

	/**
	 * A container of particles
	 * @author liaocheng.Email:liaocheng210@126.com.
	 */
	public class ParticlesContainer extends Entity
	{
		public var initParticleFun:Function;
		
		// GPU渲染用
		protected var _animator:ParticleAnimationtor;
		protected var _particleAnimation : ParticleAnimationSet;
		
		protected var _isStart:Boolean;		// 是否play中
		protected var _hasGen:Boolean;			// 是否已经生成
		protected var _alwaysInFrustum:Boolean;		// 是否不被裁减
		
		private var _mouseHitMethod:uint;
		
		public var _subContainers : Vector.<SubContainer>;		// 不同的材质，会分为不同的SubContainer
		
		private var _emitter : EmitterBase;			// 发射器
		private var _sampler : ParticleSample;			// 粒子采样器
		
		static private var _defaultSampler : ParticleSample;		// 默认粒子采样器
						
		public function ParticlesContainer(isClone:Boolean=false)
		{
			super();
			if (!isClone)
			{
				_particleAnimation = new ParticleAnimationSet();
				
				_animator = new ParticleAnimationtor(_particleAnimation);
				_subContainers = new Vector.<SubContainer>();
			}
			// 创建默认的粒子采用器
			if(!_defaultSampler)
			{
				var material:ParticleBitmapMaterial = new ParticleBitmapMaterial( DefaultMaterialManager.getDefaultBitmapData() );
				var plane:PlaneGeometry = new PlaneGeometry( 20, 20, 1, 1, false);
				_defaultSampler = new ParticleSample(plane.subGeometries[0], material);
			}
			
			sampler = _defaultSampler;
		}
		
		public function set emitter(em:EmitterBase):void
		{
			if(_emitter == em) return;
			if(_emitter)
				_emitter.parent = null;
			_emitter = em;
			_emitter.parent = this;
			_hasGen = false;
		}
		public function get emitter():EmitterBase
		{
			return _emitter;
		}
		
		public function set sampler(sa:ParticleSample):void
		{
			if(_sampler == sa) return;
			_sampler = sa;
			_hasGen = false;
		}
		public function get sampler():ParticleSample
		{
			return _sampler;
		}
		
		
		
		public function set alwaysInFrustum(value:Boolean):void
		{
			_alwaysInFrustum = value;
		}
		public function get alwaysInFrustum():Boolean
		{
			return _alwaysInFrustum;
		}
		
		public function set playbackSpeed(value:Number):void
		{
			_animator.playbackSpeed = value;
		}
		public function get playbackSpeed():Number
		{
			return _animator.playbackSpeed;
		}
		
		public function set time(value:Number):void
		{
			_animator.absoluteTime = value * 1000;
		}
		public function get time():Number
		{
			return _animator.absoluteTime /1000;
		}
		
		public function addAction(action:ActionBase):void
		{
			if (_hasGen) throw(new Error("can't add action after gen!"));
			_particleAnimation.addAction(action);
		}
		
		public function set startTimeFun(fun:Function):void
		{
			_particleAnimation.startTimeFun = fun;
		}
		
		public function set hasDuringTime(value:Boolean):void
		{
			_particleAnimation.hasDuringTime = value;
		}
		
		public function set hasSleepTime(value:Boolean):void
		{
			_particleAnimation.hasSleepTime = value;
		}
		
		public function set duringTimeFun(fun:Function):void
		{
			_particleAnimation.duringTimeFun = fun;
		}
		
		public function set sleepTimeFun(fun:Function):void
		{
			_particleAnimation.sleepTimeFun = fun;
		}
		
		public function set loop(value:Boolean):void
		{
			_particleAnimation.loop = value;
		}
		
		private function generate():Boolean
		{
			if (_hasGen)
				throw(new Error("has generated!"));
			
			if(!_emitter || !_sampler)
				return false;
			
			_particleAnimation.startGen();

			var _vec:Vector.<ParticleSample> = _emitter.particlesSamples;
			
			var vertexData:Vector.<Number>;
			var uvData:Vector.<Number>;
			var indexData:Vector.<uint>;
			var j:uint;
			var length:uint;
			var param:ParticleParam;
			
			for (var i:uint = 0; i < _vec.length; i++)
			{
				for (j = 0; j < _subContainers.length; j++)
				{
					if (_subContainers[j].particleMaterial == _vec[i].material)
						break;
				}
				if (j == _subContainers.length)
				{
					_subContainers[j] = new SubContainer(this, _vec[i].material);
				}
				
				length = _vec[i].subGem.vertexData.length;
				indexData = _vec[i].subGem.indexData;
				vertexData = _vec[i].subGem.vertexData;
				uvData = _vec[i].subGem.UVData;
				
				_subContainers[j].numTriangles+= _vec[i].subGem.numTriangles;
				indexData.forEach(
					function(index:uint, ...rest):void 
					{
						_subContainers[j].indexData.push(index + _subContainers[j].vertexData.length / 3);
					}
				);
				uvData.forEach(
					function(uv:Number, ...rest):void 
					{
						_subContainers[j].UVData.push(uv); 
					}
				);
				
				param = initParticleParam();
				param.total = _vec.length;			// 最大粒子数
				param.index = i;					// 粒子的index
				param.sample = _vec[i];				// 该粒子的采样器
				
				// 参数设置
				emitter.initParticleParam(param);
				
				// 外置函数配置
				if (initParticleFun != null) 
					initParticleFun(param);
				
				_particleAnimation.genOne(param);
				
				for (var k:uint = 0; k < length; k += 3)
				{
					_subContainers[j].vertexData.push(vertexData[k]);
					_subContainers[j].vertexData.push(vertexData[k + 1]);
					_subContainers[j].vertexData.push(vertexData[k + 2]);
					_particleAnimation.distributeOne(i, k, _subContainers[j]);
				}
			}
			_particleAnimation.finishGen();
			_hasGen = true;
			return true;
		}
		
		protected function initParticleParam():ParticleParam
		{
			return new ParticleParam;
		}
		
		public function start():void
		{
			if(!_hasGen)
			{
				if(!generate())
					Debug.assert(false, "generate error");
			}
			
			_isStart = true;
			_animator.start();
		}
		
		public function stop():void
		{
			_isStart = false;
			_animator.stop();
		}
				
		override protected function createEntityPartitionNode() : EntityNode
		{
			return new ParticlesNode(this);
		}
		
		override protected function getDefaultBoundingVolume():BoundingVolumeBase
		{
			return new AxisAlignedBoundingBox();
		}

		override protected function updateBounds():void
		{
			_bounds.fromExtremes( -100, -100, -100, 100, 100, 100 );
			_boundsInvalid = false;
		}
		
		public function get animation() : IAnimationSet
		{
			return _particleAnimation;
		}
		
		public function get animator() : ParticleAnimationtor
		{
			return _animator;
		}
				
		
		override public function get mouseEnabled() : Boolean
		{
			return false;
		}
		
		override public function set mouseEnabled(value : Boolean) : void
		{
			throw(new Error("the particlesContainer is not interactive!"));
		}
		
		/**
		 * Indicates what picking method to use on this mesh. See MouseHitMethod for available options.
		 */
		public function get mouseHitMethod():uint
		{
			return _mouseHitMethod;
		}

		public function set mouseHitMethod( value:uint ):void
		{
			_mouseHitMethod = value;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function clone() : Object3D
		{
			if (!_hasGen) throw(new Error("can't not clone a object that has not gen!"));
			var clone : ParticlesContainer = new ParticlesContainer(true);
			clone._hasGen = _hasGen;
			clone._particleAnimation = _particleAnimation;
			clone._animator = new ParticleAnimationtor(_particleAnimation);
			clone._subContainers = new Vector.<SubContainer>();
			clone._isStart = _isStart;
			clone.alwaysInFrustum = alwaysInFrustum;
			
			if (_isStart) clone.start();
			for (var j:uint = 0; j < _subContainers.length; j++)
			{
				clone._subContainers[j] = _subContainers[j].clone(clone);
			}
			
			clone.transform = transform;
			clone.pivotPoint = pivotPoint;
			clone.partition = partition;
			clone.bounds = _bounds.clone();
			clone.name = name;

			for (var i:int = 0; i < numChildren; ++i) {
				clone.addChild(ObjectContainer3D(getChildAt(i).clone()));
			}
			return clone;
		}
		
		override public function dispose() : void
		{
			// 释放 action 相关资源
			_particleAnimation.dispose();
			
			// 释放渲染资源
			for(var i:int=0; i<	_subContainers.length; i++)
			{
				_subContainers[i].dispose();
			}
			
			if(_sampler != _defaultSampler)
				_sampler.material.dispose();
			super.dispose();
		}
		
	}

}
