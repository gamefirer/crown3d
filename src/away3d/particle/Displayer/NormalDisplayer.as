/**
 *	普通的粒子显示器 
 */
package away3d.particle.Displayer
{
	import away3d.arcane;
	import away3d.cameras.Camera3D;
	import away3d.core.base.SubGeometry;
	import away3d.core.managers.Stage3DProxy;
	import away3d.core.traverse.EntityCollector;
	import away3d.core.traverse.PartitionTraverser;
	import away3d.materials.DefaultMaterialBase;
	import away3d.materials.MaterialBase;
	import away3d.materials.methods.BasicColorMethod;
	import away3d.particle.Particle;
	import away3d.particle.ParticleSystem;
	
	import flash.display.BlendMode;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	use namespace arcane;
	
	public class NormalDisplayer implements ParticleDisplayerBase
	{
		private var _geometry : SubGeometry;	
		private var _material : MaterialBase;					// 粒子的材质
		private var _indexData : Vector.<uint>;				// index
		private var _vertexData : Vector.<Number>;				// vertex
		private var _vertexColorData : Vector.<Number>;		// vertex color
		private var _uvData : Vector.<Number>;					// uv
		
		private var _particleSystem : ParticleSystem;
		public function setParticleSystem(value : ParticleSystem) : void { _particleSystem = value; }
		
		public function NormalDisplayer(particleSystem:ParticleSystem=null)
		{
			setParticleSystem(particleSystem);
			
			createGeometry();
		}
		// 创建渲染用的subgeometry
		private function createGeometry() : void
		{
			var maxParticleNumber : uint = _particleSystem.maxParticleNumber;
			
			_geometry = new SubGeometry();
			_geometry.autoDeriveVertexNormals = false;
			_geometry.autoDeriveVertexTangents = false;
			// 创建VertexBuffer, IndexBuffer, UVBuffer
			// 0---1
			// |   |
			// 3---2
			var i:int;
			_vertexData = new Vector.<Number>(maxParticleNumber*12, true);			//4*3
			_geometry.updateVertexData(_vertexData);
			
			_vertexColorData = new Vector.<Number>(maxParticleNumber*16, true);		// 4*4(4个顶点,每个顶点4个颜色)
			_geometry.updateVertexColorData(_vertexColorData);
			
			for(i=0;i<maxParticleNumber*4;i++)
			{
				_vertexColorData[i*4] = 1;
				_vertexColorData[i*4+1] = 1;
				_vertexColorData[i*4+2] = 1;
				_vertexColorData[i*4+3] = 1;
			}
			
			_indexData = new Vector.<uint>(maxParticleNumber*6, true);
			
			for(i=0;i<maxParticleNumber;i++)
			{
				_indexData[i*6] = i*4;			// 0 1 2
				_indexData[i*6+1] = i*4+1;
				_indexData[i*6+2] = i*4+2;
				_indexData[i*6+3] = i*4;			// 0 2 3
				_indexData[i*6+4] = i*4+2;
				_indexData[i*6+5] = i*4+3;
			}				
			_geometry.updateIndexData(_indexData);
			
			_uvData = new Vector.<Number>(maxParticleNumber*8, true);		//4*2
			for(i=0;i<maxParticleNumber;i++)
			{
				_uvData[i*8] = 0.0;
				_uvData[i*8+1] = 0.0;
				_uvData[i*8+2] = 1.0;
				_uvData[i*8+3] = 0.0;
				_uvData[i*8+4] = 1.0;
				_uvData[i*8+5] = 1.0;
				_uvData[i*8+6] = 0.0;
				_uvData[i*8+7] = 1.0;					
			}
			_geometry.updateUVData(_uvData);
		}
		
		// 计算用暂存变量
		static protected var dirX : Vector3D = new Vector3D;
		static protected var dirY : Vector3D = new Vector3D;
		static protected var tmpP : Vector3D = new Vector3D;
		static protected var tmpD : Vector3D = new Vector3D;
		static protected var tmpD2 : Vector3D = new Vector3D;
		static protected var tmpMat : Matrix3D = new Matrix3D;
		
		public function render(traverser : PartitionTraverser) : void
		{
			var cam : Camera3D = EntityCollector(traverser).camera;
			
			tmpMat.copyFrom(cam.sceneTransform);
			tmpD.setTo(0, 0, 0);
			tmpMat.copyRowFrom(3, tmpD);
			tmpMat.append(_particleSystem.inverseSceneTransform);
			tmpMat.copyRowFrom(3, tmpD);			// tmpMat = camre矩阵 * inv SceneTransform
			
			
			var i:int;
			var j:int;
			var pi:int = 0;
			
			var _Particles : Vector.<Particle> = _particleSystem.particles;
			//			Profiler.start("render:for");
			for(i=0; i<=_particleSystem.maxLiveParticleIndex; i++)
			{
				if(_Particles[i].IsDead())
					continue;
				// 0---1
				// |   |
				// 3---2
				var p : Particle = _Particles[i];
				
				// 计算旋转
				if(_particleSystem.isBillBoard)
				{
					dirX.setTo(0.5, 0, 0);
					dirY.setTo(0, 0.5, 0);
					
					tmpD2.copyFrom(dirX);
					dirX.x = tmpD2.x * Math.cos(p.rot) - tmpD2.y * Math.sin(p.rot);
					dirX.y = tmpD2.x * Math.sin(p.rot) + tmpD2.y * Math.cos(p.rot)
					
					tmpD2.copyFrom(dirY);
					dirY.x = tmpD2.x * Math.cos(p.rot) - tmpD2.y * Math.sin(p.rot);
					dirY.y = tmpD2.x * Math.sin(p.rot) + tmpD2.y * Math.cos(p.rot);
				}
				else
				{
					switch(_particleSystem.particleOrient)
					{
						case 0:		// 面向X
						{
							dirX.setTo(0, 0.5, 0);
							dirY.setTo(0, 0, 0.5);
							// 旋转
							tmpD2.copyFrom(dirX);
							dirX.y = tmpD2.y * Math.cos(p.rot) - tmpD2.z * Math.sin(p.rot);
							dirX.z = tmpD2.y * Math.sin(p.rot) + tmpD2.z * Math.cos(p.rot)
							
							tmpD2.copyFrom(dirY);
							dirY.y = tmpD2.y * Math.cos(p.rot) - tmpD2.z * Math.sin(p.rot);
							dirY.z = tmpD2.y * Math.sin(p.rot) + tmpD2.z * Math.cos(p.rot);
							break;
						}
						case 1:		// 面向Y
						{
							dirX.setTo(0.5, 0, 0);
							dirY.setTo(0, 0, 0.5);
							// 旋转
							tmpD2.copyFrom(dirX);
							dirX.x = tmpD2.x * Math.cos(p.rot) - tmpD2.z * Math.sin(p.rot);
							dirX.z = tmpD2.x * Math.sin(p.rot) + tmpD2.z * Math.cos(p.rot)
							
							tmpD2.copyFrom(dirY);
							dirY.x = tmpD2.x * Math.cos(p.rot) - tmpD2.z * Math.sin(p.rot);
							dirY.z = tmpD2.x * Math.sin(p.rot) + tmpD2.z * Math.cos(p.rot);
							break;
						}
						case 2:		// 面向Z
						{
							dirX.setTo(0.5, 0, 0);
							dirY.setTo(0, 0.5, 0);
							// 旋转
							tmpD2.copyFrom(dirX);
							dirX.x = tmpD2.x * Math.cos(p.rot) - tmpD2.y * Math.sin(p.rot);
							dirX.y = tmpD2.x * Math.sin(p.rot) + tmpD2.y * Math.cos(p.rot)
							
							tmpD2.copyFrom(dirY);
							dirY.x = tmpD2.x * Math.cos(p.rot) - tmpD2.y * Math.sin(p.rot);
							dirY.y = tmpD2.x * Math.sin(p.rot) + tmpD2.y * Math.cos(p.rot);
							break;
						}
						case 3:	// Y轴向billboard
						{
							dirY.setTo(0, 1, 0);
							
							tmpD2.setTo(0, 0, 1);
							tmpD2 = cam.sceneTransform.deltaTransformVector(tmpD2);
							dirX = tmpD2.crossProduct(dirY);
							dirX.normalize();
							if(p.rot != 0)
							{
								// 旋转
								tmpD2 = dirX.crossProduct(dirY);
								tmpD2.normalize();
								
								tmpMat.identity();			// 非billboard无需tmpMat
								tmpMat.appendRotation(p.rot * 180, tmpD2);
								
								dirX = tmpMat.deltaTransformVector(dirX);
								dirY = tmpMat.deltaTransformVector(dirY);
								dirX.normalize();
								dirY.normalize();
							}
							
							dirX.scaleBy(0.5);
							dirY.scaleBy(0.5);
							
							break;
						}
						case 4:
						default:		// 平行于运动方向
						{
							tmpD2.setTo(0, 0, 1);
							tmpD2 = cam.sceneTransform.deltaTransformVector(tmpD2);		// camera z
							
							if(_particleSystem.isWolrdParticle)
								tmpD.copyFrom(p.dir);
							else
								tmpD = _particleSystem.sceneTransform.deltaTransformVector(p.dir);
							
							dirX = tmpD2.crossProduct(tmpD);
							dirX.negate();
							dirX.normalize();
							
							dirY = tmpD2.crossProduct(dirX);
							dirY.normalize();
							
							dirX.scaleBy(0.5);
							dirY.scaleBy(0.5);
							
							dirX = _particleSystem.inverseSceneTransform.deltaTransformVector(dirX);
							dirY = _particleSystem.inverseSceneTransform.deltaTransformVector(dirY);
							
							break;
						}
					}
				}
				
				
				//Debug.bltrace("rot=" +p.rot.toFixed(2) + " " + dirX + " " + dirY);
				if(_particleSystem.isBillBoard)
				{	
					dirX = tmpMat.deltaTransformVector(dirX);	// billboard to camera
					dirY = tmpMat.deltaTransformVector(dirY);
				}
				
				// p0
				tmpP.copyFrom(p.pos);
				if(_particleSystem.isWolrdParticle)
					tmpP = _particleSystem.inverseSceneTransform.transformVector(tmpP);
				
				tmpD.copyFrom(dirX);		
				tmpD.scaleBy(p.sizeX);		// 大小
				tmpP.decrementBy(tmpD);
				tmpD.copyFrom(dirY);
				tmpD.scaleBy(p.sizeY);
				tmpP.incrementBy(tmpD);
				
				_vertexData[pi*12] = tmpP.x;
				_vertexData[pi*12+1] = tmpP.y;
				_vertexData[pi*12+2] = tmpP.z;
				
				_uvData[pi*8] = 0.0 + p.u;
				_uvData[pi*8+1] = 0.0 + p.v;
				
				// p1
				tmpP.copyFrom(p.pos);
				if(_particleSystem.isWolrdParticle)
					tmpP = _particleSystem.inverseSceneTransform.transformVector(tmpP);
				
				tmpD.copyFrom(dirX);
				tmpD.scaleBy(p.sizeX);
				tmpP.incrementBy(tmpD);
				tmpD.copyFrom(dirY);
				tmpD.scaleBy(p.sizeY);
				tmpP.incrementBy(tmpD);
				
				_vertexData[pi*12+3] = tmpP.x;
				_vertexData[pi*12+4] = tmpP.y;
				_vertexData[pi*12+5] = tmpP.z;
				
				_uvData[pi*8+2] = p.su + p.u;
				_uvData[pi*8+3] = 0.0 + p.v;
				
				
				// p2
				tmpP.copyFrom(p.pos);
				if(_particleSystem.isWolrdParticle)
					tmpP = _particleSystem.inverseSceneTransform.transformVector(tmpP);
				
				tmpD.copyFrom(dirX);
				tmpD.scaleBy(p.sizeX);
				tmpP.incrementBy(tmpD);
				tmpD.copyFrom(dirY);
				tmpD.scaleBy(p.sizeY);
				tmpP.decrementBy(tmpD);
				
				_vertexData[pi*12+6] = tmpP.x;
				_vertexData[pi*12+7] = tmpP.y;
				_vertexData[pi*12+8] = tmpP.z;
				
				_uvData[pi*8+4] = p.su + p.u;
				_uvData[pi*8+5] = p.sv + p.v;
				
				
				// p3
				tmpP.copyFrom(p.pos);
				if(_particleSystem.isWolrdParticle)
					tmpP = _particleSystem.inverseSceneTransform.transformVector(tmpP);
				
				tmpD.copyFrom(dirX);
				tmpD.scaleBy(p.sizeX);
				tmpP.decrementBy(tmpD);
				tmpD.copyFrom(dirY);
				tmpD.scaleBy(p.sizeY);
				tmpP.decrementBy(tmpD);
				
				_vertexData[pi*12+9] = tmpP.x;
				_vertexData[pi*12+10] = tmpP.y;
				_vertexData[pi*12+11] = tmpP.z;
				
				_uvData[pi*8+6] = 0.0 + p.u;
				_uvData[pi*8+7] = p.sv + p.v;	
				
				
				// 更新顶点色
				for(j=0; j<4; j++)
				{
					_vertexColorData[pi*16+j*4] = Number((p.color >> 16) & 0xff) / 0xff;
					_vertexColorData[pi*16+j*4+1] = Number((p.color >> 8) & 0xff) / 0xff;
					_vertexColorData[pi*16+j*4+2] = Number(p.color & 0xff) / 0xff;
					_vertexColorData[pi*16+j*4+3] = p.alpha;
				}
				
				pi++;
			}
			//			Profiler.end("render:for");
			
			_particleSystem.particleNum = pi;
			//Debug.bltrace("particle=" + _ParticleNum);
			_geometry.updateVertexData(_vertexData);
			_geometry.updateVertexColorData(_vertexColorData);
			_geometry.updateUVData(_uvData);
		}
		
		public function get material() : MaterialBase
		{
			return _material;
		}
		
		public function set material(value : MaterialBase) : void
		{
			if (value == _material) return;
			if (_material) 	_material.removeOwner(_particleSystem);
			_material = value;
			
			ParticleSystem.modifyMaterial(_material);
			
			if (_material) _material.addOwner(_particleSystem);
		}
		
		public function Stop(immediately : Boolean) : void {}
		
		public function getVertexBuffer(stage3DProxy : Stage3DProxy) : VertexBuffer3D
		{
			return _geometry.getVertexBuffer(stage3DProxy);
		}
		
		public function getVertexColorBuffer(stage3DProxy : Stage3DProxy) : VertexBuffer3D
		{
			return _geometry.getVertexColorBuffer(stage3DProxy);
		}
		
		public function getUVBuffer(stage3DProxy : Stage3DProxy) : VertexBuffer3D
		{
			return _geometry.getUVBuffer(stage3DProxy);
		}
		
		public function getIndexBuffer(stage3DProxy : Stage3DProxy) : IndexBuffer3D
		{
			return _geometry.getIndexBuffer(stage3DProxy);
		}
		
		public function get indexData() : Vector.<uint> 
		{
			return _indexData;
		}
		
		public function dispose() : void
		{
			if(_geometry)
			{
				_geometry.dispose();
				_geometry = null;
			}
			
			if(_material)
			{
				_material.removeOwner(_particleSystem);
				_material = null;
			}
			
		}
		
	}
}