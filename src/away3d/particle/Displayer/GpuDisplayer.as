/**
 *	用GPU进行计算的粒子渲染器 
 */
package away3d.particle.Displayer
{
	import away3d.arcane;
	import away3d.core.base.Geometry;
	import away3d.core.base.SubGeometry;
	import away3d.core.managers.Context3DProxy;
	import away3d.core.managers.Stage3DProxy;
	import away3d.core.traverse.PartitionTraverser;
	import away3d.entities.Mesh;
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
		private var _paritlceSubGeo : SubGeometry;					// 粒子所用的模型
		static private var _defaultParticleSubGeo : SubGeometry;		// 默认的模型
		
		// index buffer
		protected var _indexBuffer : Vector.<IndexBuffer3D> = new Vector.<IndexBuffer3D>(8);
		protected var _indexBufferContext : Vector.<Context3D> = new Vector.<Context3D>(8);
		protected var _indexBufferDirty : Vector.<Boolean> = new Vector.<Boolean>(8);
		
		// vertextBuffers
		protected var _vertexBuffer : Vector.<VertexBuffer3D> = new Vector.<VertexBuffer3D>(8);		// va0
		protected var _vertexBuffer1 : Vector.<VertexBuffer3D> = new Vector.<VertexBuffer3D>(8);		// va1(u,v, dx,dy) 偏移方向sizex,sizey = -1 or 1
		protected var _vertexBuffer2 : Vector.<VertexBuffer3D> = new Vector.<VertexBuffer3D>(8);		// va2(starttime, lifetime, ?, ?)
		protected var _vertexBuffer3 : Vector.<VertexBuffer3D> = new Vector.<VertexBuffer3D>(8);		// va3(Vx, Vy, Vz, ?)
		protected var _vertexBuffer4 : Vector.<VertexBuffer3D> = new Vector.<VertexBuffer3D>(8);		// va4
		protected var _vertexBuffer5 : Vector.<VertexBuffer3D> = new Vector.<VertexBuffer3D>(8);		// va5
		
		// Context
		protected var _vertexBufferContext : Vector.<Context3D> = new Vector.<Context3D>(8);
		protected var _vertexBufferContext1 : Vector.<Context3D> = new Vector.<Context3D>(8);
		protected var _vertexBufferContext2 : Vector.<Context3D> = new Vector.<Context3D>(8);
		protected var _vertexBufferContext3 : Vector.<Context3D> = new Vector.<Context3D>(8);
		protected var _vertexBufferContext4 : Vector.<Context3D> = new Vector.<Context3D>(8);
		protected var _vertexBufferContext5 : Vector.<Context3D> = new Vector.<Context3D>(8);
		
		// dirty flags
		protected var _vertexBufferDirty : Vector.<Boolean> = new Vector.<Boolean>(8);
		protected var _vertexBufferDirty1 : Vector.<Boolean> = new Vector.<Boolean>(8);
		protected var _vertexBufferDirty2 : Vector.<Boolean> = new Vector.<Boolean>(8);
		protected var _vertexBufferDirty3 : Vector.<Boolean> = new Vector.<Boolean>(8);
		protected var _vertexBufferDirty4 : Vector.<Boolean> = new Vector.<Boolean>(8);
		protected var _vertexBufferDirty5 : Vector.<Boolean> = new Vector.<Boolean>(8);
		
		
		protected var _maxIndex : int = -1;
		
		private var _vertexData0 : Vector.<Number>;			// vertex
		private var _vertexData1 : Vector.<Number>;			// vertex1
		private var _vertexData2 : Vector.<Number>;			// vertex2
		private var _vertexData3 : Vector.<Number>;			// vertex3
		private var _vertexData4 : Vector.<Number>;			// vertex4
		private var _vertexData5 : Vector.<Number>;			// vertex5
		
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
		public function get trianglesPerParticle() : uint {return _paritlceSubGeo.numTriangles;}
		
		public function GpuDisplayer(particleSystem:ParticleSystem=null, geo:Geometry = null)
		{
			setParticleSystem(particleSystem);
			createDefaultGeometry();
			
			if(geo && geo.subGeometries.length>0)
			{
				_paritlceSubGeo = geo.subGeometries[0];
			}
			
			createGeometry();
		}
		
		private function createDefaultGeometry():void
		{
			if(_defaultParticleSubGeo) return;
			
			_defaultParticleSubGeo = new SubGeometry;
			// 创建VertexBuffer, IndexBuffer, UVBuffer
			// 0---1
			// |   |
			// 3---2
			var vertices : Vector.<Number> = new Vector.<Number>(4*3, true);
			vertices[0] = -1;
			vertices[1] = 1;
			vertices[2] = 0;
			
			vertices[3] = 1;
			vertices[4] = 1;
			vertices[5] = 0;
			
			vertices[6] = 1;
			vertices[7] = -1;
			vertices[8] = 0;
			
			vertices[9] = -1;
			vertices[10] = -1;
			vertices[11] = 0;
			
			var uvs : Vector.<Number> = new Vector.<Number>(4*2, true);
			uvs[0] = 0.0;
			uvs[1] = 0.0;
			
			uvs[2] = 1.0;
			uvs[3] = 0.0;
			
			uvs[4] = 1.0;
			uvs[5] = 1.0;
			
			uvs[6] = 0.0;
			uvs[7] = 1.0;

			var indices : Vector.<uint> = new Vector.<uint>(2*3, true);
			indices[0] = 0;			// 0 1 2
			indices[1] = 1;
			indices[2] = 2;
			indices[3] = 0;			// 0 2 3
			indices[4] = 2;
			indices[5] = 3;
			
			_defaultParticleSubGeo.updateVertexData(vertices);
			_defaultParticleSubGeo.updateUVData(uvs);
			_defaultParticleSubGeo.updateIndexData(indices);
		}
		
		private function createGeometry() : void
		{
			var maxParticleNumber : uint = _particleSystem.maxParticleNumber;
			
			if(!_paritlceSubGeo)
				_paritlceSubGeo = _defaultParticleSubGeo;
			// 根据模型，生成粒子系统顶点数据
			
			var subGeo : SubGeometry = _paritlceSubGeo;
			
			var i:int;
			var j:int;
			var len:int;
			
			_maxVertexNum = maxParticleNumber*subGeo.numVertices;		// 一个粒子n个顶点
			// 创建VertexBuffer(x, y, z, ?)
			_vertexData0 = new Vector.<Number>(_maxVertexNum*3, true);	// (x,y,z)
			
			len = subGeo.numVertices * 3;
			for(i=0;i<maxParticleNumber;i++)
			{
				for(j=0; j<subGeo.numVertices; j++)
				{
					_vertexData0[i*len+j*3+0] = 0;
					_vertexData0[i*len+j*3+1] = 0;
					_vertexData0[i*len+j*3+2] = 0;
				}
			}
			// vertexBuffer1( u, v, sizeX, sizeY )
			len = subGeo.numVertices * 4;
			_vertexData1 = new Vector.<Number>(_maxVertexNum*4, true);
			
			for(i=0;i<maxParticleNumber;i++)
			{
				for(j=0;j<subGeo.numVertices;j++)
				{
					_vertexData1[i*len+j*4+0] = subGeo.UVData[j*2+0];
					_vertexData1[i*len+j*4+1] = subGeo.UVData[j*2+1];
					_vertexData1[i*len+j*4+2] = 100; 
					_vertexData1[i*len+j*4+3] = 100;
				}
			}
			// vertextBuffer2
			_vertexData2 = new Vector.<Number>(_maxVertexNum*4, true);
			for(i=0;i<maxParticleNumber;i++)
			{
				for(j=0;j<subGeo.numVertices;j++)
				{
					_vertexData2[i*len+j*4+0] = 0;
					_vertexData2[i*len+j*4+1] = 0;
					_vertexData2[i*len+j*4+2] = 0; 
					_vertexData2[i*len+j*4+3] = 0;
				}
			}
			// vertexBuffer3
			_vertexData3 = new Vector.<Number>(_maxVertexNum*4, true);
			for(i=0;i<maxParticleNumber;i++)
			{
				for(j=0;j<subGeo.numVertices;j++)
				{
					_vertexData3[i*len+j*4+0] = 0;
					_vertexData3[i*len+j*4+1] = 0;
					_vertexData3[i*len+j*4+2] = 0; 
					_vertexData3[i*len+j*4+3] = 0;
				}
			}
			
			// vertexBuffer4 颜色(r, g, b, a)
			_vertexData4 = new Vector.<Number>(_maxVertexNum*4, true);
			for(i=0;i<maxParticleNumber;i++)
			{
				for(j=0;j<subGeo.numVertices;j++)
				{
					_vertexData4[i*len+j*4+0] = 0;
					_vertexData4[i*len+j*4+1] = 0;
					_vertexData4[i*len+j*4+2] = 0; 
					_vertexData4[i*len+j*4+3] = 0;
				}
			}
			// vertexBuffer5 偏移(ox, oy, oz)
			_vertexData5 = new Vector.<Number>(_maxVertexNum*4, true);
			
			for(i=0;i<maxParticleNumber;i++)
			{
				for(j=0; j<subGeo.numVertices; j++)
				{
					_vertexData5[i*len+j*4+0] = subGeo.vertexData[j*3];
					_vertexData5[i*len+j*4+1] = subGeo.vertexData[j*3+1];
					_vertexData5[i*len+j*4+2] = subGeo.vertexData[j*3+2];
					_vertexData5[i*len+j*4+3] = 1;
				}
			}
			
			// 创建 indexbuffer
			_maxIndexNum = maxParticleNumber*subGeo.numTriangles*3;			// 一个粒子n个index
			_indexData = new Vector.<uint>(_maxIndexNum, true);
			
			len = subGeo.numTriangles*3;
			for(i=0;i<maxParticleNumber;i++)
			{
				for(j=0; j<len; j++)
				{
					_indexData[i*len+j] = subGeo.indexData[j] + subGeo.numVertices*i;
				}
			}				
			
			invalidateBuffers(_indexBufferDirty);
			invalidateBuffers(_vertexBufferDirty);
			invalidateBuffers(_vertexBufferDirty1);
			invalidateBuffers(_vertexBufferDirty2);
			invalidateBuffers(_vertexBufferDirty3);
			invalidateBuffers(_vertexBufferDirty4);
			invalidateBuffers(_vertexBufferDirty5);
		
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
				if(!p.IsDead())
					liveCount++;
			}
			_particleSystem.particleNum = liveCount;
			
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
			
			var i:int;
			var j:int;
			var len:int;
			var subGeo : SubGeometry = _paritlceSubGeo;
			var numVertices : int = subGeo.numVertices;
			
			// va0 粒子的位置
			len = numVertices*3;
			for(i=0; i<numVertices; i++)
			{
				_vertexData0[index*len+i*3] = newParticle.pos.x;
				_vertexData0[index*len+i*3+1] = newParticle.pos.y;
				_vertexData0[index*len+i*3+2] = newParticle.pos.z;
			
			}
			invalidateBuffers(_vertexBufferDirty);
			
			// va1 粒子的初始uv和sizeX,sizeY偏移
			len = numVertices*4;
			for(i=0; i<subGeo.numVertices; i++)
			{
				_vertexData1[index*len+i*4] = subGeo.UVData[i*2] * scaleU;
				_vertexData1[index*len+i*4+1] = subGeo.UVData[i*2+1] * scaleV;
				_vertexData1[index*len+i*4+2] = newParticle.sizeX/2;
				_vertexData1[index*len+i*4+3] = newParticle.sizeY/2;
			}
			
			invalidateBuffers(_vertexBufferDirty1);
			
			
			// va2 粒子生命期
			var liftTime : int = newParticle.pastTime + newParticle.remainTime;
			
			for(i=0; i<subGeo.numVertices; i++)
			{
				_vertexData2[index*len+i*4] = newParticle.startTime;
				_vertexData2[index*len+i*4+1] = liftTime;
				_vertexData2[index*len+i*4+2] = newParticle.rot;
				_vertexData2[index*len+i*4+3] = newParticle.rotVel;
			}
			
			
			invalidateBuffers(_vertexBufferDirty2);
			
			// va3 粒子速度
			tmpVec3.copyFrom(newParticle.dir);
			tmpVec3.scaleBy(newParticle.vel);
			
			for(i=0; i<subGeo.numVertices; i++)
			{
				_vertexData3[index*len+i*4] = tmpVec3.x;
				_vertexData3[index*len+i*4+1] = tmpVec3.y;
				_vertexData3[index*len+i*4+2] = tmpVec3.z;;
				_vertexData3[index*len+i*4+3] = 0;
			}
			
			invalidateBuffers(_vertexBufferDirty3);
			
			// va4 粒子颜色
			for(i=0; i<subGeo.numVertices; i++)
			{
				_vertexData4[index*len+i*4] = newParticle.r;
				_vertexData4[index*len+i*4+1] = newParticle.g;
				_vertexData4[index*len+i*4+2] = newParticle.b;
				_vertexData4[index*len+i*4+3] = newParticle.alpha;
			}
			
			invalidateBuffers(_vertexBufferDirty4);
		}
		
		public function Stop(immediately:Boolean):void
		{
			if(immediately)
			{	// 所有粒子死亡
				var i:int;
				var j:int;
				var subGeo : SubGeometry = _paritlceSubGeo;
				var numVertices : int = subGeo.numVertices;
				var _Particles : Vector.<Particle> = _particleSystem.particles;
				
				for(i=0; i<=_particleSystem.maxLiveParticleIndex; i++)
				{
					var p : Particle = _Particles[i];
					for(j=0; j<numVertices; j++)
					{
						_vertexData2[i*numVertices*4+j*4] = 0;
					}
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
		
		public function getVertexBuffer5(stage3DProxy:Stage3DProxy):VertexBuffer3D
		{
			var contextIndex : int = stage3DProxy._stage3DIndex;
			var context : Context3D = stage3DProxy._context3D;
			
			if (_vertexBufferContext5[contextIndex] != context || !_vertexBuffer5[contextIndex]) 
			{
				if(_vertexBuffer5[contextIndex])
				{
					Context3DProxy.disposeVertexBuffer(_vertexBuffer5[contextIndex]);
				}
				_vertexBuffer5[contextIndex] = Context3DProxy.createVertexBuffer(_maxVertexNum, 4);
				_vertexBufferContext5[contextIndex] = context;
				_vertexBufferDirty5[contextIndex] = true;
			}
			
			if(_vertexBufferDirty5[contextIndex])
			{
				Context3DProxy.uploadVertexBufferFromVector(_vertexBuffer5[contextIndex], _vertexData5, 0, _maxVertexNum);
				_vertexBufferDirty5[contextIndex] = false;
			}
			
			return _vertexBuffer5[contextIndex];
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
			if (_vertexBuffer5[index]) 
			{
				Context3DProxy.disposeVertexBuffer(_vertexBuffer5[index]);
				_vertexBuffer5[index] = null;
			}
			if (_indexBuffer[index]) 
			{
				Context3DProxy.disposeIndexBuffer(_indexBuffer[index]);
				_indexBuffer[index] = null;
			}
		}
	}
}