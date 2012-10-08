/*
 *	粒子系统
 */
package away3d.particle
{
	import away3d.animators.IAnimator;
	import away3d.arcane;
	import away3d.cameras.Camera3D;
	import away3d.containers.View3D;
	import away3d.core.base.Geometry;
	import away3d.core.base.IRenderable;
	import away3d.core.base.SubGeometry;
	import away3d.core.managers.Stage3DProxy;
	import away3d.core.partition.EntityNode;
	import away3d.core.partition.ParticleSystemNode;
	import away3d.core.partition.RenderableNode;
	import away3d.core.traverse.EntityCollector;
	import away3d.core.traverse.PartitionTraverser;
	import away3d.entities.Entity;
	import away3d.library.assets.AssetType;
	import away3d.library.assets.IAsset;
	import away3d.materials.DefaultMaterialBase;
	import away3d.materials.MaterialBase;
	import away3d.materials.methods.BasicColorMethod;
	import away3d.particle.Displayer.GpuDisplayer;
	import away3d.particle.Displayer.NormalDisplayer;
	import away3d.particle.Displayer.ParticleDisplayerBase;
	import away3d.particle.Effector.ParticleEffectorBase;
	import away3d.particle.Emitter.ParticleEmitterBase;
	
	import blade3d.profiler.Profiler;
	
	import flash.display.BlendMode;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.getTimer;
	
	use namespace arcane;
	
	public class ParticleSystem extends Entity implements IRenderable
	{
		public static var useGpuParticle : Boolean = true;
		
		private var _material : MaterialBase;				// 粒子的材质
		protected var _emitter : ParticleEmitterBase;					// 发射器
		protected var _effectors : Vector.<ParticleEffectorBase>;		// 控制器
		protected var _displayer : ParticleDisplayerBase;				// 显示器
		protected var _useGpu : Boolean;								// 该粒子系统是否使用了GPU渲染
		
		// 粒子相关参数
		protected var _Particles : Vector.<Particle>;		// 粒子
		protected var _maxParticleNumber : int;			// 最大粒子数
		protected var _particleNum : int = 1;				// 当前粒子数
		protected var _lastParticleIndex : int = -1;		// 上次创建的粒子的index
		protected var _IsEmit : Boolean = true;			// 是否发射粒子
		
		// 粒子系统参数
		protected var _maxLiveIndex : int = -1;				// 存活粒子最大index
		protected var _vertexData : Vector.<Number>;			// vertex
		protected var _vertexColorData : Vector.<Number>;		// vertex color
		protected var _uvData : Vector.<Number>;				// uv
		protected var _twoSide : Boolean = false;				// 双面渲染
		protected var _isWolrdParticle : Boolean = true;		// 粒子是否在World空间中运动
		protected var _isBillBoard : Boolean = true;			// 粒子是否为公告板模式
		protected var _particleOrient : int = 0;				// 非billboard粒子的朝向( 0朝x 1朝y 2朝z)
		protected var _infiniteBounds : Boolean = false;		// 无限boundingbox(使该粒子不受booudingbox裁剪)
						
		// boundingBox
		protected var updateBoundingBox : int = 0;
		protected var _min : Vector3D = new Vector3D(-1,-1,-1);
		protected var _max : Vector3D = new Vector3D(1,1,1);
		
		public function ParticleSystem(material : MaterialBase,
									   emitter : ParticleEmitterBase,
									   max : int = 20,
									   usdDisplayer : ParticleDisplayerBase = null,
										geo : Geometry = null)
		{
			super();
			
			_maxParticleNumber = max;
			
			_Particles = new Vector.<Particle>(max, true);
					
			// 发射器			
			_emitter = emitter;
			if(_emitter)
				_emitter.particleSystem = this;
			// 控制器
			_effectors = new Vector.<ParticleEffectorBase>;
			
			// 显示器
			_useGpu = false;
			if(usdDisplayer)
				_displayer = usdDisplayer;
			else
			{
				if(useGpuParticle)
				{
					_displayer = new GpuDisplayer(this, geo);
					_useGpu = true;
				}
				else
					_displayer = new NormalDisplayer(this);
			}
			// 材质设定
			this.material = material;		// 在创建displayer后
			
//			showBounds = true;
		}
		
		public override function get assetType() : String
		{
			return AssetType.PARTICLE_SYSTEM;
		}
		
		public function get animator() : IAnimator
		{
			return null;
		}
		
		public function addEffector(effector : ParticleEffectorBase) : void
		{
			_effectors.push(effector);
			effector.setParticleSystem(this);
		}
		
		public function removeEffector(effector:ParticleEffectorBase):Boolean
		{
			var index:int = _effectors.indexOf(effector)
			if(index<0)return false
			_effectors[index].setParticleSystem(null); // 测试这样是否可以
			_effectors.splice( index,1);
		    return true
		}
		
		public function getEffectors() : Vector.<ParticleEffectorBase>
		{
			return _effectors;
		}
		
		public function get particleNum() : int { return _particleNum; }
		public function set particleNum(value : int) : void { _particleNum = value; }
		public function get twoSide() : Boolean { return _twoSide; }
		public function set twoSide(value : Boolean) : void { _twoSide = value; }
		public function get isWolrdParticle() : Boolean { return _isWolrdParticle; }
		public function set isWolrdParticle(value : Boolean) : void { _isWolrdParticle = value; }
		public function get isBillBoard() : Boolean { return _isBillBoard; }
		public function set isBillBoard(value : Boolean) : void { _isBillBoard = value; }
		public function get particleOrient() : int { return _particleOrient; }
		public function set particleOrient(value : int) : void { _particleOrient = value; }
		public function set emitter(value : ParticleEmitterBase) : void {_emitter = value;}
		public function get emitter() : ParticleEmitterBase {return _emitter;}
		public function get isEmit() : Boolean { return _IsEmit; }
		public function set isEmit(value : Boolean) : void { _IsEmit = value; if(_IsEmit && _emitter) _emitter.restart(); }
		public function get displayer() : ParticleDisplayerBase {return _displayer;}
		public function set displayer(value : ParticleDisplayerBase) : void { _displayer = value; }
		
		public function set infiniteBounds(value : Boolean) : void
		{
			_infiniteBounds = value;
			if(_infiniteBounds)
			{
				_bounds.fromExtremes(-100000, -100000, -100000, 100000, 100000, 100000);		// 一个很大的boundingbox
			}
			else
			{
			}
		}
		
		public function GenerateParticle() : Particle
		{
			var i:int;
			var getI:int;
			if(_useGpu)
			{	// gpu渲染时，可以使用任意位置的粒子，以内存换创建速度
				i = _lastParticleIndex+1;
				if(i >= _maxParticleNumber) i=0; 
				getI = -1;
				while( (getI < 0) && (i != (_lastParticleIndex)) )
				{
					if(!_Particles[i])
						_Particles[i] = new Particle(i);
					
					if( _Particles[i].IsDead() )
					{
						getI = i;
					}
					i++;
					if(i >= _maxParticleNumber) i=0; 
				}
				
				if(getI > _maxLiveIndex)
				{
					_maxLiveIndex = getI;
				}
				
				if(getI >= 0)
				{
					_lastParticleIndex = getI;
					//Debug.bltrace("live");
					return _Particles[getI];
				}
				else
					return null;
			}
			else
			{
				// 非gpu渲染时，确保粒子的生成是由最小的index开始,以利用死亡的粒子(减少update时的遍历数)
				i = 0;
				getI = -1;
				while( (getI < 0) && (i < _maxParticleNumber) )
				{
					if(!_Particles[i])
						_Particles[i] = new Particle(i);
					
					if( _Particles[i].IsDead() )
					{
						getI = i;
					}
					i++;
				}
				
				if(getI > _maxLiveIndex)
				{
					_maxLiveIndex = getI;
				}
				
				if(getI >= 0)
				{
					_lastParticleIndex = getI;
					//Debug.bltrace("live");
					return _Particles[getI];
				}
				else
					return null;
			}
		}
		// 停止粒子发射(if immediately==true, 现存的粒子也死亡)
		public function Stop(immediately : Boolean) : void
		{
			isEmit = false;
			if(immediately)
			{	// 所有粒子死亡
				var i:int;
				for(i=0; i<=_maxLiveIndex; i++)
				{
					_Particles[i].Dead();
				}				
			}
			
			if(displayer)
				displayer.Stop(immediately);		// 有可能在调用stop前，该粒子就被释放了
			
			if(immediately)
				_maxLiveIndex = -1;
		}
		
		public function Start() : void 
		{
			isEmit = true;
			
			// 初始一个很大的boundingbox，几帧以后再更新
			_bounds.fromExtremes(-100000, -100000, -100000, 100000, 100000, 100000);
			_boundsInvalid = false;
			updateBoundingBox = 1;
			
		}
		
		private var _curTime : uint = 0;
		private var _deltaTime : uint = 0;
		private var _lastUpdateTime : uint = 0;
		override public function update(curTime : uint, deltaTime : uint):void
		{
			_curTime = curTime;
			_deltaTime = deltaTime;
			super.update(curTime, deltaTime);
		}

		override public function preRender(traverser : EntityCollector) : void		// 渲染前,被调用
		{	
			super.preRender(traverser);
			if(_lastUpdateTime == _curTime)
				return;
			_lastUpdateTime = _curTime;
			
			Update(_curTime, _deltaTime, traverser);
		}
		
		protected function Update(currentTime : int, deltaTime : int, traverser : PartitionTraverser) : void
		{
			Profiler.start("ParticleSystem:Update");
			
			//Debug.bltrace("cT=" + currentTime + " dt=" + deltaTime);
			
			// 更新粒子
			Profiler.start("ParticleSystem:UpdateParticles");
			UpdateParticles(deltaTime);
			Profiler.end("ParticleSystem:UpdateParticles");
			
			// 更新发射器
			Profiler.start("ParticleSystem:emitter");
			if(_emitter && _IsEmit)
				_emitter.Update(currentTime, deltaTime);
			Profiler.end("ParticleSystem:emitter");
			
			// 更新粒子的控制器
			Profiler.start("ParticleSystem:effector");
			if(!_useGpu)
				UpdateEffector(deltaTime);
			Profiler.end("ParticleSystem:effector");
			
			Profiler.start("ParticleSystem:displayer");
			if(_displayer)
				_displayer.render(traverser);
			Profiler.end("ParticleSystem:displayer");
			
			// 更新boundingbox
			UpdateBounds();
			Profiler.end("ParticleSystem:Update");
		}
		
		protected function UpdateEffector(deltaTime : int) : void
		{
			for(var pi:int=0; pi<=maxLiveParticleIndex; pi++)
			{
				if(!particles[pi].IsDead())
				{
					for(var ei:int = 0; ei<_effectors.length; ei++ )
					{
						_effectors[ei].updateParticles(deltaTime, particles[pi]);
					}
				}
			}		
		}
		
		protected function UpdateParticles(deltaTime : int) : void
		{
			var i:int;
			var nowMaxLiveIndex : int = -1;
			// 更新粒子
			for(i=0; i<=_maxLiveIndex; i++)
			{
				if(_Particles[i].IsDead())
				{	// dead
					
				}
				else
				{
					nowMaxLiveIndex = i;
					if(_useGpu)
						_Particles[i].UpdateForGpu(deltaTime);
					else
						_Particles[i].Update(deltaTime);
				}		
			}
			if(nowMaxLiveIndex < _maxLiveIndex)
			{
				_maxLiveIndex = nowMaxLiveIndex;
			}
		}
		
		static protected var tmpP : Vector3D = new Vector3D;		// 计算用暂存变量
		
		protected function UpdateBounds() : void
		{
			var isUpdateBoundingBox : Boolean = false;
			if( updateBoundingBox++ % 10 == 0 )			// 每10帧更新一次BoundingBox
			{
				isUpdateBoundingBox = true;
				_min.setTo(-1,-1,-1);
				_max.setTo(1,1,1);
			}
			else
				return;
			
			var size:int=0;
			var i:uint;
			for(i=0; i<=_maxLiveIndex; i++)
			{
				if(_Particles[i].IsDead())
					continue;
				
				var p : Particle = _Particles[i];
				
				tmpP.copyFrom(p.pos);
				if(isWolrdParticle)
					tmpP = inverseSceneTransform.transformVector(tmpP);
				
				// 更新包围框
				if(_min.x > tmpP.x ) _min.x = tmpP.x;
				if(_min.y > tmpP.y ) _min.y = tmpP.y;
				if(_min.z > tmpP.z ) _min.z = tmpP.z;
				if(_max.x < tmpP.x ) _max.x = tmpP.x;
				if(_max.y < tmpP.y ) _max.y = tmpP.y;
				if(_max.z < tmpP.z ) _max.z = tmpP.z;
				
				if(size < p.sizeX) size = p.sizeX;
				if(size < p.sizeY) size = p.sizeY;								
				
				_boundsInvalid = true;
			}
			
			_min.x -= size;
			_min.y -= size;
			_min.z -= size;
			_max.x += size;
			_max.y += size;
			_max.z += size;
			
//			Debug.bltrace("UpdateBounds "+_min+" "+_max);
		}
		
		
		public function get material() : MaterialBase
		{
			if(_displayer)
				return _displayer.material;
			else
				return null;
		}
		
		public function set material(value : MaterialBase) : void
		{
			if(_displayer)
				_displayer.material = value;
		}
		
		public static function modifyMaterial(mat : MaterialBase) : void
		{
			mat.repeat = true;
			mat.blendMode = BlendMode.ADD;		// 透明贴图
			mat.bothSides = true;				// 粒子要双面渲染
			DefaultMaterialBase(mat).normalMethod.normalMap = null;		// 无normal map
			DefaultMaterialBase(mat).specularMethod = null;
//			DefaultMaterialBase(mat).colorMethod = new BasicColorMethod;	// 顶点色
			if(!DefaultMaterialBase(mat).colorTransform)
				DefaultMaterialBase(mat).colorTransform = new ColorTransform;
		}
		
		override protected function createEntityPartitionNode() : EntityNode
		{
			return new ParticleSystemNode(this);
		}
		// 更新BoundingBox		
		override protected function updateBounds() : void
		{
			if(_infiniteBounds)
			{
				_boundsInvalid = false;
			}
			else
			{
				_bounds.fromExtremes(_min.x, _min.y, _min.z, _max.x, _max.y, _max.z);
				_boundsInvalid = false;
			}
		}
		
		public function get numTriangles() : uint
		{
			if(_useGpu)
				return _maxParticleNumber*GpuDisplayer(_displayer).trianglesPerParticle;			// 使用gpu时，渲染所有粒子
			else
				return _particleNum*2;
		}
		
		public function getVertexBuffer(stage3DProxy : Stage3DProxy) : VertexBuffer3D
		{
			return _displayer.getVertexBuffer(stage3DProxy);
		}
		
		public function getVertexColorBuffer(stage3DProxy : Stage3DProxy) : VertexBuffer3D
		{
			return _displayer.getVertexColorBuffer(stage3DProxy);
		}
		
		public function getUVBuffer(stage3DProxy : Stage3DProxy) : VertexBuffer3D
		{
			return _displayer.getUVBuffer(stage3DProxy);
		}
		
		public function getIndexBuffer(stage3DProxy : Stage3DProxy) : IndexBuffer3D
		{
			return _displayer.getIndexBuffer(stage3DProxy);
		}
		
		public function getSecondaryUVBuffer(stage3DProxy : Stage3DProxy) : VertexBuffer3D
		{
			return null;
		}
		
		public function getVertexNormalBuffer(stage3DProxy : Stage3DProxy) : VertexBuffer3D
		{
			return null;
		}
		
		public function getVertexTangentBuffer(stage3DProxy : Stage3DProxy) : VertexBuffer3D
		{
			return null;
		}
		
		public function get vertexBufferOffset() : int
		{
			return 0;
		}
		
		public function get colorBufferOffset() : int
		{
			return 0;
		}
		
		public function get normalBufferOffset() : int
		{
			return 0;
		}
		
		public function get tangentBufferOffset() : int
		{
			return 0;
		}
		
		public function get UVBufferOffset() : int
		{
			return 0;
		}
		
		public function get secondaryUVBufferOffset() : int
		{
			return 0;
		}
		
		public function getCustomBuffer(stage3DProxy : Stage3DProxy) : VertexBuffer3D
		{
			return null;
		}
		
		public function get UVData():Vector.<Number>
		{
			return null;
		}
		
		public function get vertexData():Vector.<Number> 
		{
			return _vertexData;
		}
		
		public function get indexData():Vector.<uint>
		{
			return _displayer.indexData;
		}
		
		public function get uvTransform() : Matrix { return null; }
		public function get sourceEntity() : Entity { return this; }
		
//		public function get animation() : AnimationBase { return _nullAnimation;	}
//		public function get animationState() : AnimationStateBase	{ return _animationState; }
		
		public function get castsShadows() : Boolean { return false; }
		public function get mouseDetails() : Boolean { return false; }
		
		public function get maxParticleNumber() : int {return _maxParticleNumber;}
		public function get maxLiveParticleIndex() : int {return _maxLiveIndex;}
		public function get particles() : Vector.<Particle> {return _Particles;}
		
		override public function dispose() : void
		{
			if(_displayer)
			{
				_displayer.dispose();
				_displayer = null;
			}
			
			super.dispose();
		}
	}
}