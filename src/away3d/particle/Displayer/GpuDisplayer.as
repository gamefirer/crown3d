/**
 *	用GPU进行计算的粒子渲染器 
 */
package away3d.particle.Displayer
{
	import away3d.arcane;
	import away3d.core.base.SubGeometry;
	import away3d.core.managers.Context3DProxy;
	import away3d.core.managers.Stage3DProxy;
	import away3d.core.traverse.PartitionTraverser;
	import away3d.events.Stage3DEvent;
	import away3d.materials.GpuParticleMaterial;
	import away3d.materials.MaterialBase;
	import away3d.particle.Effector.ParticleEffectorBase;
	import away3d.particle.Particle;
	import away3d.particle.ParticleSystem;
	
	import flash.display3D.Context3D;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Vector3D;
	
	use namespace arcane;
	
	public class GpuDisplayer implements ParticleDisplayerBase
	{
		private var _material : GpuParticleMaterial;					// 粒子的材质
		
		protected var _listeningForDispose : Vector.<Stage3DProxy> = new Vector.<Stage3DProxy>(8);
		// index buffer
		protected var _indexBuffer : Vector.<IndexBuffer3D> = new Vector.<IndexBuffer3D>(8);
		protected var _indexBufferContext : Vector.<Context3D> = new Vector.<Context3D>(8);
		protected var _indexBufferDirty : Vector.<Boolean> = new Vector.<Boolean>(8);
		
		// vertextBuffers
		protected var _vertexBuffer : Vector.<VertexBuffer3D> = new Vector.<VertexBuffer3D>(8);		// va0
		protected var _vertexBuffer1 : Vector.<VertexBuffer3D> = new Vector.<VertexBuffer3D>(8);		// va1(u,v, dx,dy) 偏移方向sizex,sizey = -1 or 1
		protected var _vertexBuffer2 : Vector.<VertexBuffer3D> = new Vector.<VertexBuffer3D>(8);		// va2(starttime, lifetime, ?, ?)
		protected var _vertexBuffer3 : Vector.<VertexBuffer3D> = new Vector.<VertexBuffer3D>(8);		// va3(Vx, Vy, Vz, ?)
		protected var _vertexBuffer4 : Vector.<VertexBuffer3D> = new Vector.<VertexBuffer3D>(8);
		
		// Context
		protected var _vertexBufferContext : Vector.<Context3D> = new Vector.<Context3D>(8);
		protected var _vertexBufferContext1 : Vector.<Context3D> = new Vector.<Context3D>(8);
		protected var _vertexBufferContext2 : Vector.<Context3D> = new Vector.<Context3D>(8);
		protected var _vertexBufferContext3 : Vector.<Context3D> = new Vector.<Context3D>(8);
		protected var _vertexBufferContext4 : Vector.<Context3D> = new Vector.<Context3D>(8);
		
		// dirty flags
		protected var _vertexBufferDirty : Vector.<Boolean> = new Vector.<Boolean>(8);
		protected var _vertexBufferDirty1 : Vector.<Boolean> = new Vector.<Boolean>(8);
		protected var _vertexBufferDirty2 : Vector.<Boolean> = new Vector.<Boolean>(8);
		protected var _vertexBufferDirty3 : Vector.<Boolean> = new Vector.<Boolean>(8);
		protected var _vertexBufferDirty4 : Vector.<Boolean> = new Vector.<Boolean>(8);
		
		
		protected var _maxIndex : int = -1;
		
		private var _vertexData0 : Vector.<Number>;			// vertex
		private var _vertexData1 : Vector.<Number>;			// vertex1
		private var _vertexData2 : Vector.<Number>;			// vertex2
		private var _vertexData3 : Vector.<Number>;			// vertex3
		private var _vertexData4 : Vector.<Number>;			// vertex4
		
		private var _indexData : Vector.<uint>;				// index
		
		private var _maxVertexNum : uint;
		private var _maxIndexNum : uint;
		
		// effector相关值
		private var _updateEffector : Boolean = false;
		public var scaleU : Number = 1.0;
		public var scaleV : Number = 1.0;
		
		private var _particleSystem : ParticleSystem;
		public function setParticleSystem(value : ParticleSystem) : void { _particleSystem = value; }
		
		
		public function get indexData() : Vector.<uint> {return _indexData;}
		
		public function GpuDisplayer(particleSystem:ParticleSystem=null)
		{
			setParticleSystem(particleSystem);
			
			createGeometry();
		}
		
		private function createGeometry() : void
		{
			var maxParticleNumber : uint = _particleSystem.maxParticleNumber;
			
			// 创建VertexBuffer, IndexBuffer, UVBuffer
			// 0---1
			// |   |
			// 3---2
			var i:int;
			var j:int;
			
			_maxVertexNum = maxParticleNumber*4;		// 一个粒子4个顶点
			// 创建VertexBuffer			
			_vertexData0 = new Vector.<Number>(_maxVertexNum*3, true);	// 3(x,y,z)
			
			for(i=0;i<maxParticleNumber;i++)
			{
				_vertexData0[i*12+0] = -50;
				_vertexData0[i*12+1] = 50;
				_vertexData0[i*12+2] = 0;
				
				_vertexData0[i*12+3] = 50;
				_vertexData0[i*12+4] = 50;
				_vertexData0[i*12+5] = 0;
				
				_vertexData0[i*12+6] = 50;
				_vertexData0[i*12+7] = -50;
				_vertexData0[i*12+8] = 0;
				
				_vertexData0[i*12+9] = -50;
				_vertexData0[i*12+10] = -50;
				_vertexData0[i*12+11] = 0;

			}
			// vertexBuffer1( u, v, sizeX, sizeY )
			_vertexData1 = new Vector.<Number>(_maxVertexNum*4, true);
			for(i=0;i<maxParticleNumber;i++)
			{
				_vertexData1[i*16] = 0.0;
				_vertexData1[i*16+1] = 0.0;
				_vertexData1[i*16+2] = -100;
				_vertexData1[i*16+3] = 100;
				
				_vertexData1[i*16+4] = 1.0;
				_vertexData1[i*16+5] = 0.0;
				_vertexData1[i*16+6] = 100;
				_vertexData1[i*16+7] = 100;
				
				_vertexData1[i*16+8] = 1.0;
				_vertexData1[i*16+9] = 1.0;
				_vertexData1[i*16+10] = 100;
				_vertexData1[i*16+11] = -100;
				
				_vertexData1[i*16+12] = 0.0;
				_vertexData1[i*16+13] = 1.0;
				_vertexData1[i*16+14] = -100;
				_vertexData1[i*16+15] = -100;
			}
			// vertextBuffer2
			_vertexData2 = new Vector.<Number>(_maxVertexNum*4, true);
			for(i=0;i<maxParticleNumber;i++)
			{
				_vertexData2[i*16] = 0.0;
				_vertexData2[i*16+1] = 0.0;
				_vertexData2[i*16+2] = -100;
				_vertexData2[i*16+3] = 100;
				
				_vertexData2[i*16+4] = 0.0;
				_vertexData2[i*16+5] = 0.0;
				_vertexData2[i*16+6] = 100;
				_vertexData2[i*16+7] = 100;
				
				_vertexData2[i*16+8] = 0.0;
				_vertexData2[i*16+9] = 0.0;
				_vertexData2[i*16+10] = 100;
				_vertexData2[i*16+11] = -100;
				
				_vertexData2[i*16+12] = 0.0;
				_vertexData2[i*16+13] = 0.0;
				_vertexData2[i*16+14] = -100;
				_vertexData2[i*16+15] = -100;
			}
			// vertexBuffer3
			_vertexData3 = new Vector.<Number>(_maxVertexNum*4, true);
			for(i=0;i<maxParticleNumber;i++)
			{
				_vertexData3[i*16] = 0;
				_vertexData3[i*16+1] = 0;
				_vertexData3[i*16+2] = 0;
				_vertexData3[i*16+3] = 0;
				
				_vertexData3[i*16+4] = 0;
				_vertexData3[i*16+5] = 0;
				_vertexData3[i*16+6] = 0;
				_vertexData3[i*16+7] = 0;
				
				_vertexData3[i*16+8] = 0;
				_vertexData3[i*16+9] = 0;
				_vertexData3[i*16+10] = 0;
				_vertexData3[i*16+11] = 0;
				
				_vertexData3[i*16+12] = 0;
				_vertexData3[i*16+13] = 0;
				_vertexData3[i*16+14] = 0;
				_vertexData3[i*16+15] = 0;
			}
			
			// vertexBuffer4 颜色(r, g, b, a)
			_vertexData4 = new Vector.<Number>(_maxVertexNum*4, true);
			for(i=0;i<maxParticleNumber;i++)
			{
				_vertexData4[i*16] = 0;
				_vertexData4[i*16+1] = 0;
				_vertexData4[i*16+2] = 0;
				_vertexData4[i*16+3] = 0;
				
				_vertexData4[i*16+4] = 0;
				_vertexData4[i*16+5] = 0;
				_vertexData4[i*16+6] = 0;
				_vertexData4[i*16+7] = 0;
				
				_vertexData4[i*16+8] = 0;
				_vertexData4[i*16+9] = 0;
				_vertexData4[i*16+10] = 0;
				_vertexData4[i*16+11] = 0;
				
				_vertexData4[i*16+12] = 0;
				_vertexData4[i*16+13] = 0;
				_vertexData4[i*16+14] = 0;
				_vertexData4[i*16+15] = 0;
			}
			// 创建 indexbuffer
			_maxIndexNum = maxParticleNumber*6;			// 一个粒子6个index
			_indexData = new Vector.<uint>(_maxIndexNum, true);
			
			for(i=0;i<maxParticleNumber;i++)
			{
				_indexData[i*6] = i*4;			// 0 1 2
				_indexData[i*6+1] = i*4+1;
				_indexData[i*6+2] = i*4+2;
				_indexData[i*6+3] = i*4;			// 0 2 3
				_indexData[i*6+4] = i*4+2;
				_indexData[i*6+5] = i*4+3;
			}				
			
			
			invalidateBuffers(_indexBufferDirty);
			invalidateBuffers(_vertexBufferDirty);
			invalidateBuffers(_vertexBufferDirty1);
			invalidateBuffers(_vertexBufferDirty2);
			invalidateBuffers(_vertexBufferDirty3);
			invalidateBuffers(_vertexBufferDirty4);
		
		}
		
		public function render(traverser:PartitionTraverser):void
		{
			if(!_particleSystem) return;
			
			var i:int;
			
			// 更新粒子的生命
			var liveCount : uint = 0;
			var _Particles : Vector.<Particle> = _particleSystem.particles;
			
			for(i=0; i<=_particleSystem.maxLiveParticleIndex; i++)
			{
				var p : Particle = _Particles[i];				
//				_vertexData2[i*16] = p.pastTime;
//				_vertexData2[i*16+4] = p.pastTime;
//				_vertexData2[i*16+8] = p.pastTime;
//				_vertexData2[i*16+12] = p.pastTime;
				
//				Debug.bltrace(p.pastTime);
				if(!p.IsDead())
					liveCount++;
			}
			_particleSystem.particleNum = liveCount;
			
//			invalidateBuffers(_vertexBufferContext2);
			
			// 更新时间
			GpuParticleMaterial(material).currentTime = traverser.time;
		}
		
		public function effectorDirty() : void
		{
			_updateEffector = false;
		}
		
		private function updateEffector() : void
		{
			var effectors : Vector.<ParticleEffectorBase> = _particleSystem.getEffectors();
			for(var ei:int=0; ei<effectors.length; ei++)
			{
				effectors[ei].initGpuDisplayer(this);
			}
		}
		
		private static var tmpVec3 : Vector3D = new Vector3D;
		
		public function initGpuParticle(newParticle:Particle) : void
		{
			if(!_updateEffector)
			{
				updateEffector();
				_updateEffector = true;
			}
			
			var index:int = newParticle.index;
			// va0 粒子的位置
			_vertexData0[index*12+0] = newParticle.pos.x;
			_vertexData0[index*12+1] = newParticle.pos.y;
			_vertexData0[index*12+2] = newParticle.pos.z;
			
			_vertexData0[index*12+3] = newParticle.pos.x;
			_vertexData0[index*12+4] = newParticle.pos.y;
			_vertexData0[index*12+5] = newParticle.pos.z;
			
			_vertexData0[index*12+6] = newParticle.pos.x;
			_vertexData0[index*12+7] = newParticle.pos.y;
			_vertexData0[index*12+8] = newParticle.pos.z;
			
			_vertexData0[index*12+9] = newParticle.pos.x;
			_vertexData0[index*12+10] = newParticle.pos.y;
			_vertexData0[index*12+11] = newParticle.pos.z;
			
			invalidateBuffers(_vertexBufferDirty);
			
			// va1 粒子的初始uv和sizeX,sizeY偏移
			_vertexData1[index*16] = 0.0;
			_vertexData1[index*16+1] = 0.0;
			_vertexData1[index*16+2] = -newParticle.sizeX/2;
			_vertexData1[index*16+3] = newParticle.sizeY/2;
			
			_vertexData1[index*16+4] = scaleU;
			_vertexData1[index*16+5] = 0.0;
			_vertexData1[index*16+6] = newParticle.sizeX/2;
			_vertexData1[index*16+7] = newParticle.sizeY/2;
			
			_vertexData1[index*16+8] = scaleU;
			_vertexData1[index*16+9] = scaleV;
			_vertexData1[index*16+10] = newParticle.sizeX/2;
			_vertexData1[index*16+11] = -newParticle.sizeY/2;
			
			_vertexData1[index*16+12] = 0.0;
			_vertexData1[index*16+13] = scaleV;
			_vertexData1[index*16+14] = -newParticle.sizeX/2;
			_vertexData1[index*16+15] = -newParticle.sizeY/2;
			
			invalidateBuffers(_vertexBufferDirty1);
			
			
			// va2 粒子生命期
			var liftTime : int = newParticle.pastTime + newParticle.remainTime
			_vertexData2[index*16] = newParticle.startTime;
			_vertexData2[index*16+1] = liftTime;
			_vertexData2[index*16+2] = newParticle.rot;
			_vertexData2[index*16+3] = newParticle.rotVel;
			
			_vertexData2[index*16+4] = newParticle.startTime;
			_vertexData2[index*16+5] = liftTime;
			_vertexData2[index*16+6] = newParticle.rot;
			_vertexData2[index*16+7] = newParticle.rotVel;
			
			_vertexData2[index*16+8] = newParticle.startTime;
			_vertexData2[index*16+9] = liftTime;
			_vertexData2[index*16+10] = newParticle.rot;
			_vertexData2[index*16+11] = newParticle.rotVel;
			
			_vertexData2[index*16+12] = newParticle.startTime;
			_vertexData2[index*16+13] = liftTime;
			_vertexData2[index*16+14] = newParticle.rot;
			_vertexData2[index*16+15] = newParticle.rotVel;
			
			invalidateBuffers(_vertexBufferDirty2);
			
			// va3 粒子速度
			tmpVec3.copyFrom(newParticle.dir);
			tmpVec3.scaleBy(newParticle.vel);
			
			_vertexData3[index*16] = tmpVec3.x;
			_vertexData3[index*16+1] = tmpVec3.y;
			_vertexData3[index*16+2] = tmpVec3.z;
			_vertexData3[index*16+3] = 0;
			
			_vertexData3[index*16+4] = tmpVec3.x;
			_vertexData3[index*16+5] = tmpVec3.y;
			_vertexData3[index*16+6] = tmpVec3.z;
			_vertexData3[index*16+7] = 0;
			
			_vertexData3[index*16+8] = tmpVec3.x;
			_vertexData3[index*16+9] = tmpVec3.y;
			_vertexData3[index*16+10] = tmpVec3.z;
			_vertexData3[index*16+11] = 0;
			
			_vertexData3[index*16+12] = tmpVec3.x;
			_vertexData3[index*16+13] = tmpVec3.y;
			_vertexData3[index*16+14] = tmpVec3.z;
			_vertexData3[index*16+15] = 0;
			
			invalidateBuffers(_vertexBufferDirty3);
			
			// va4 粒子颜色
			_vertexData4[index*16] = newParticle.r;
			_vertexData4[index*16+1] = newParticle.g;
			_vertexData4[index*16+2] = newParticle.b;
			_vertexData4[index*16+3] = newParticle.alpha;
			
			_vertexData4[index*16+4] = newParticle.r;
			_vertexData4[index*16+5] = newParticle.g;
			_vertexData4[index*16+6] = newParticle.b;
			_vertexData4[index*16+7] = newParticle.alpha;
			
			_vertexData4[index*16+8] = newParticle.r;
			_vertexData4[index*16+9] = newParticle.g;
			_vertexData4[index*16+10] = newParticle.b;
			_vertexData4[index*16+11] = newParticle.alpha;
			
			_vertexData4[index*16+12] = newParticle.r;
			_vertexData4[index*16+13] = newParticle.g;
			_vertexData4[index*16+14] = newParticle.b;
			_vertexData4[index*16+15] = newParticle.alpha;
			
			invalidateBuffers(_vertexBufferDirty4);
			
		}
		
		public function Stop(immediately:Boolean):void
		{
			if(immediately)
			{	// 所有粒子死亡
				var i:int;
				var _Particles : Vector.<Particle> = _particleSystem.particles;
				
				for(i=0; i<=_particleSystem.maxLiveParticleIndex; i++)
				{
					var p : Particle = _Particles[i];				
					_vertexData2[i*16] = 0;
					_vertexData2[i*16+4] = 0;
					_vertexData2[i*16+8] = 0;
					_vertexData2[i*16+12] = 0;
				}
				invalidateBuffers(_vertexBufferDirty2);
			}
		}
		
		public function get material():MaterialBase
		{
			return _material;
		}
		
		public function set material(value:MaterialBase):void
		{			
			if (value == _material) return;
			if (_material)
			{
				_material.removeOwner(_particleSystem);
				GpuParticleMaterial(_material).setParitlceSystem(null);
			}
			
			if(!value)
			{
				_material = null;
				return;
			}
						
			if(!(value is GpuParticleMaterial))
			{
				throw new Error("is not GpuPartilceMaterial");
				return;
			}
			
			_material = GpuParticleMaterial(value);
			
			// 设置粒子的属性
			GpuParticleMaterial(_material).setParitlceSystem(_particleSystem);
			
			if (_material) _material.addOwner(_particleSystem);
		}
		
		public function getUVBuffer(stage3DProxy : Stage3DProxy) : VertexBuffer3D {return null;}
		
		public function getVertexBuffer(stage3DProxy:Stage3DProxy):VertexBuffer3D
		{
			var contextIndex : int = stage3DProxy._stage3DIndex;
			var context : Context3D = stage3DProxy._context3D;
			
			if (_vertexBufferContext[contextIndex] != context || !_vertexBuffer[contextIndex]) 
			{
				if(_vertexBuffer[contextIndex])
				{
					Context3DProxy.disposeVertexBuffer(_vertexBuffer[contextIndex]);
				}
				
				_vertexBuffer[contextIndex] = Context3DProxy.createVertexBuffer(_maxVertexNum, 3);
				_vertexBufferContext[contextIndex] = context;
				_vertexBufferDirty[contextIndex] = true;
			}
			
			if(_vertexBufferDirty[contextIndex])
			{
				Context3DProxy.uploadVertexBufferFromVector(_vertexBuffer[contextIndex], _vertexData0, 0, _maxVertexNum);
				_vertexBufferDirty[contextIndex] = false;
			}
			
			return _vertexBuffer[contextIndex];
		}
		
		public function getVertexColorBuffer(stage3DProxy:Stage3DProxy):VertexBuffer3D
		{
			return null;
		}
		
		public function getVertexBuffer1(stage3DProxy:Stage3DProxy):VertexBuffer3D
		{
			var contextIndex : int = stage3DProxy._stage3DIndex;
			var context : Context3D = stage3DProxy._context3D;
			
			if (_vertexBufferContext1[contextIndex] != context || !_vertexBuffer1[contextIndex]) 
			{
				if(_vertexBuffer1[contextIndex])
				{
					Context3DProxy.disposeVertexBuffer(_vertexBuffer1[contextIndex]);
				}
				
				_vertexBuffer1[contextIndex] = Context3DProxy.createVertexBuffer(_maxVertexNum, 4);
				_vertexBufferContext1[contextIndex] = context;
				_vertexBufferDirty1[contextIndex] = true;
			}
			
			if(_vertexBufferDirty1[contextIndex])
			{
				Context3DProxy.uploadVertexBufferFromVector(_vertexBuffer1[contextIndex], _vertexData1, 0, _maxVertexNum);
				_vertexBufferDirty1[contextIndex] = false;
			}
			
			return _vertexBuffer1[contextIndex];
		}
		
		public function getVertexBuffer2(stage3DProxy:Stage3DProxy):VertexBuffer3D
		{
			var contextIndex : int = stage3DProxy._stage3DIndex;
			var context : Context3D = stage3DProxy._context3D;
			
			if (_vertexBufferContext2[contextIndex] != context || !_vertexBuffer2[contextIndex]) 
			{
				if(_vertexBuffer2[contextIndex])
				{
					Context3DProxy.disposeVertexBuffer(_vertexBuffer2[contextIndex]);
				}
				_vertexBuffer2[contextIndex] = Context3DProxy.createVertexBuffer(_maxVertexNum, 4);
				_vertexBufferContext2[contextIndex] = context;
				_vertexBufferDirty2[contextIndex] = true;
			}
			
			if(_vertexBufferDirty2[contextIndex])
			{
				Context3DProxy.uploadVertexBufferFromVector(_vertexBuffer2[contextIndex], _vertexData2, 0, _maxVertexNum);
				_vertexBufferDirty2[contextIndex] = false;
			}
			
			return _vertexBuffer2[contextIndex];
		}
		
		public function getVertexBuffer3(stage3DProxy:Stage3DProxy):VertexBuffer3D
		{
			var contextIndex : int = stage3DProxy._stage3DIndex;
			var context : Context3D = stage3DProxy._context3D;
			
			if (_vertexBufferContext3[contextIndex] != context || !_vertexBuffer3[contextIndex]) 
			{
				if(_vertexBuffer3[contextIndex])
				{
					Context3DProxy.disposeVertexBuffer(_vertexBuffer3[contextIndex]);
				}
				_vertexBuffer3[contextIndex] = Context3DProxy.createVertexBuffer(_maxVertexNum, 4);
				_vertexBufferContext3[contextIndex] = context;
				_vertexBufferDirty3[contextIndex] = true;
			}
			
			if(_vertexBufferDirty3[contextIndex])
			{
				Context3DProxy.uploadVertexBufferFromVector(_vertexBuffer3[contextIndex], _vertexData3, 0, _maxVertexNum);
				_vertexBufferDirty3[contextIndex] = false;
			}
			
			return _vertexBuffer3[contextIndex];
		}
		
		public function getVertexBuffer4(stage3DProxy:Stage3DProxy):VertexBuffer3D
		{
			var contextIndex : int = stage3DProxy._stage3DIndex;
			var context : Context3D = stage3DProxy._context3D;
			
			if (_vertexBufferContext4[contextIndex] != context || !_vertexBuffer4[contextIndex]) 
			{
				if(_vertexBuffer4[contextIndex])
				{
					Context3DProxy.disposeVertexBuffer(_vertexBuffer4[contextIndex]);
				}
				_vertexBuffer4[contextIndex] = Context3DProxy.createVertexBuffer(_maxVertexNum, 4);
				_vertexBufferContext4[contextIndex] = context;
				_vertexBufferDirty4[contextIndex] = true;
			}
			
			if(_vertexBufferDirty4[contextIndex])
			{
				Context3DProxy.uploadVertexBufferFromVector(_vertexBuffer4[contextIndex], _vertexData4, 0, _maxVertexNum);
				_vertexBufferDirty4[contextIndex] = false;
			}
			
			return _vertexBuffer4[contextIndex];
		}
		
		public function getIndexBuffer(stage3DProxy:Stage3DProxy):IndexBuffer3D
		{
			var contextIndex : int = stage3DProxy._stage3DIndex;
			var context : Context3D = stage3DProxy._context3D;
			
			if (_indexBufferContext[contextIndex] != context || !_indexBuffer[contextIndex]) 
			{
				// 释放旧ib
				if(_indexBuffer[contextIndex])
				{
					Context3DProxy.disposeIndexBuffer(_indexBuffer[contextIndex]);
					_indexBuffer[contextIndex] = null;
				}
				_indexBuffer[contextIndex] = Context3DProxy.createIndexBuffer(_maxIndexNum);
				_indexBufferContext[contextIndex] = context;
				_indexBufferDirty[contextIndex] = true;
			}
			
			if(_indexBufferDirty[contextIndex])
			{
				Context3DProxy.uploadIndexBufferFromVector(_indexBuffer[contextIndex], _indexData, 0, _maxIndexNum);
				_indexBufferDirty[contextIndex] = false;
			}
			
			return _indexBuffer[contextIndex];
		}
		
		protected function invalidateBuffers(buffers : Vector.<Boolean>) : void
		{
			for (var i : int = 0; i < buffers.length; ++i)
				buffers[i] = true;
		}
		
		public function dispose() : void
		{
			disposeForStage3D(Context3DProxy.stage3DProxy);
			
			if(material)
			{
				material = null;
			}
			
			_particleSystem = null;
		}
		
		protected function disposeForStage3D(stage3DProxy : Stage3DProxy) : void
		{
			var index : int = stage3DProxy._stage3DIndex;
			if (_vertexBuffer[index]) 
			{
				Context3DProxy.disposeVertexBuffer(_vertexBuffer[index]);
				_vertexBuffer[index] = null;
			}
			if (_vertexBuffer1[index]) 
			{
				Context3DProxy.disposeVertexBuffer(_vertexBuffer1[index]);
				_vertexBuffer1[index] = null;
			}
			if (_vertexBuffer2[index]) 
			{
				Context3DProxy.disposeVertexBuffer(_vertexBuffer2[index]);
				_vertexBuffer2[index] = null;
			}
			if (_vertexBuffer3[index]) 
			{
				Context3DProxy.disposeVertexBuffer(_vertexBuffer3[index]);
				_vertexBuffer3[index] = null;
			}
			if (_vertexBuffer4[index]) 
			{
				Context3DProxy.disposeVertexBuffer(_vertexBuffer4[index]);
				_vertexBuffer4[index] = null;
			}
			if (_indexBuffer[index]) 
			{
				Context3DProxy.disposeIndexBuffer(_indexBuffer[index]);
				_indexBuffer[index] = null;
			}
		}
	}
}