/**
 *	条带的显示器 
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
	import away3d.particle.Dragger.StripeEmitterBase;
	import away3d.particle.Emitter.ParticleEmitterBase;
	import away3d.particle.Particle;
	import away3d.particle.ParticleSystem;
	import away3d.particle.StripeSystem;
	
	import flash.display.BlendMode;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	use namespace arcane;
	
	public class StripeDisplayer implements ParticleDisplayerBase
	{
		private var _geometry : SubGeometry;	
		private var _material : MaterialBase;					// 条带的材质
		
		private var _vertexData : Vector.<Number>;			// vertex
		private var _vertexColorData : Vector.<Number>;		// vertex color
		private var _uvData : Vector.<Number>;				// uv
		
		public function StripeDisplayer(stripeSystem:StripeSystem=null)
		{
			setParticleSystem(stripeSystem);
			
			createGeometry();
		}
		
		protected var _stripeSystem : StripeSystem;
		public function setParticleSystem(value:ParticleSystem):void
		{
			if(!(value is StripeSystem))
				throw new Error("stripesystem error");
			_stripeSystem = StripeSystem(value);
		}
		
		// 创建渲染用的subgeometry
		private function createGeometry() : void
		{
			var maxParticleNumber : uint = _stripeSystem.maxParticleNumber;
			
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
			
			var indexData : Vector.<uint> = new Vector.<uint>(maxParticleNumber*6, true);
			
			for(i=0;i<maxParticleNumber;i++)
			{
				indexData[i*6] = i*4;			// 0 1 2
				indexData[i*6+1] = i*4+1;
				indexData[i*6+2] = i*4+2;
				indexData[i*6+3] = i*4;			// 0 2 3
				indexData[i*6+4] = i*4+2;
				indexData[i*6+5] = i*4+3;
			}				
			_geometry.updateIndexData(indexData);
			
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
		
		public function render(traverser:PartitionTraverser):void
		{
			var _dragger : StripeEmitterBase = _stripeSystem.dragger;
			// 所有的粒子拉成一个条状
			if(!_dragger)
				return;
			
			var cam : Camera3D = EntityCollector(traverser).camera;
			
			var camMat : Matrix3D = cam.sceneTransform;
			
			var camVector : Vector3D = cam.unprojectRay(0, 0);
			camVector.normalize();
			
			var _Particles : Vector.<Particle> = _stripeSystem.particles;
			
			var si:int;
			var i:int;
			var j:int;
			var lpi:int;
			var pi:int;
			var vi:int = 0;
			
			for(si=0; si<_dragger.stripeNum; si++)
			{
				var indexOrder : Vector.<int> = _dragger.getIndexOrder(si);
				var validParticleCount : int = _dragger.getStripeParticleNum(si);
				
				lpi = -1;
				pi = 0;
				
				var lp : Particle;
				var p : Particle;
				for(i=0; i<indexOrder.length; i++)
				{
					if(indexOrder[i] < 0)
						break;
					if(_Particles[indexOrder[i]].IsDead())
						throw new Error("particle error");
					
					if(lpi < 0)
					{
						p = _Particles[indexOrder[i]];
						
						dirX.copyFrom(_stripeSystem.wideDir);
						dirX.scaleBy(0.5);			// 拉伸方向
						dirX.scaleBy(p.sizeX);	// 拉伸大小
						
						var firstp : Particle = _Particles[indexOrder[i]];				// 当前粒子
						tmpMat.copyFrom(firstp.rotMat);
						tmpMat.append(_stripeSystem.inverseSceneTransform);
						dirX = tmpMat.deltaTransformVector(dirX);
						dirX.normalize();
						
						dirY.copyFrom(dirX);	// dirY保存上一个粒子的拉伸方向
						
					}					
					else if(lpi >= 0)
					{	
						// dirY 为上一个粒子的拉伸方向, dirX 为当前粒子的拉伸方向
						// 0---1  0---1
						// |   |  |   |
						// 3---2  3---2
						lp = _Particles[indexOrder[lpi]];			// 上一个粒子
						p = _Particles[indexOrder[i]];				// 当前粒子
						//Debug.bltrace(lp.pos + p.pos);
						
						// tmpD2为拉伸方向
						if(_stripeSystem.isBillBoard)
						{
							if(!_stripeSystem.wideParallel || lpi==0)
							{
								tmpD2.copyFrom(p.pos);
								tmpD2.decrementBy(lp.pos);
								tmpD2.normalize();
								tmpD2 = tmpD2.crossProduct(camVector);
								tmpD2.normalize();								
							}
						}
						else
						{
							tmpD2.copyFrom(_stripeSystem.wideDir);
						}						

						// 计算旋转
						dirX.copyFrom(tmpD2);	// 拉伸方向

						dirX.scaleBy(0.5);	
						dirX.scaleBy(lp.sizeX);	// 拉伸大小
						
						tmpMat.copyFrom(p.rotMat);
						tmpMat.append(_stripeSystem.inverseSceneTransform);
						dirX = tmpMat.deltaTransformVector(dirX);
							
						if(_stripeSystem.isBillBoard && lpi==0)
						{
							dirY.copyFrom(dirX);
						}
												
						if( dirX.dotProduct(dirY) < 0 )	// 为防止条带转向时，发生渲染错误。采用此狡猾的做法，但还没想清楚为什么。。。
						{
							dirY.negate();
						}
						
						if(dirY.lengthSquared == 0)		// 防止条带停止时,弯折
							dirY.copyFrom(dirX);
						
						// 开始构造面
						
						// p0
						tmpP.copyFrom(lp.pos);
												
						tmpD.copyFrom(dirY);
						tmpP.incrementBy(tmpD);

						if(_stripeSystem.isWolrdParticle)
							tmpP = _stripeSystem.inverseSceneTransform.transformVector(tmpP);
						
						_vertexData[vi*12] = tmpP.x;
						_vertexData[vi*12+1] = tmpP.y;
						_vertexData[vi*12+2] = tmpP.z;
						if(_stripeSystem.isTimedUV)
							_uvData[vi*8] = lp.pastTime / (lp.pastTime + lp.remainTime);
						else
							_uvData[vi*8] = Number(lpi) / (validParticleCount-1);
						_uvData[vi*8+1] = 0.0;
						
						_uvData[vi*8] *= lp.su;
						_uvData[vi*8+1] *= lp.sv;
						
						_uvData[vi*8] += lp.u;
						_uvData[vi*8+1] += lp.v;
						
						// p1
						tmpP.copyFrom(p.pos);
												
						tmpD.copyFrom(dirX);		
						tmpP.incrementBy(tmpD);

						if(_stripeSystem.isWolrdParticle)
							tmpP = _stripeSystem.inverseSceneTransform.transformVector(tmpP);
						
						_vertexData[vi*12+3] = tmpP.x;
						_vertexData[vi*12+4] = tmpP.y;
						_vertexData[vi*12+5] = tmpP.z;
						if(_stripeSystem.isTimedUV)
							_uvData[vi*8+2] = p.pastTime / (p.pastTime + p.remainTime);
						else
							_uvData[vi*8+2] = Number(lpi+1) / (validParticleCount-1);
						_uvData[vi*8+3] = 0.0;
						
						_uvData[vi*8+2] *= p.su;
						_uvData[vi*8+3] *= p.sv;
						
						_uvData[vi*8+2] += p.u;
						_uvData[vi*8+3] += p.v;
						
						// p2
						tmpP.copyFrom(p.pos);
												
						tmpD.copyFrom(dirX);		
						tmpP.decrementBy(tmpD);

						if(_stripeSystem.isWolrdParticle)
							tmpP = _stripeSystem.inverseSceneTransform.transformVector(tmpP);
						
						_vertexData[vi*12+6] = tmpP.x;
						_vertexData[vi*12+7] = tmpP.y;
						_vertexData[vi*12+8] = tmpP.z;
						if(_stripeSystem.isTimedUV)
							_uvData[vi*8+4] = p.pastTime / (p.pastTime + p.remainTime);
						else
							_uvData[vi*8+4] = Number(lpi+1) / (validParticleCount-1);						
						_uvData[vi*8+5] = 1.0;
						
						_uvData[vi*8+4] *= p.su;
						_uvData[vi*8+5] *= p.sv;
						
						_uvData[vi*8+4] += p.u;
						_uvData[vi*8+5] += p.v;
						
						// p3
						tmpP.copyFrom(lp.pos);
												
						tmpD.copyFrom(dirY);
						tmpP.decrementBy(tmpD);
						
						if(_stripeSystem.isWolrdParticle)
							tmpP = _stripeSystem.inverseSceneTransform.transformVector(tmpP);
						
						_vertexData[vi*12+9] = tmpP.x;
						_vertexData[vi*12+10] = tmpP.y;
						_vertexData[vi*12+11] = tmpP.z;
						if(_stripeSystem.isTimedUV)
							_uvData[vi*8+6] = lp.pastTime / (lp.pastTime + lp.remainTime);
						else
							_uvData[vi*8+6] = Number(lpi) / (validParticleCount-1);
						_uvData[vi*8+7] = 1.0;
						
						_uvData[vi*8+6] *= lp.su;
						_uvData[vi*8+7] *= lp.sv;
						
						_uvData[vi*8+6] += lp.u;
						_uvData[vi*8+7] += lp.v;
						
						// ...
						dirY.copyFrom(dirX);
						
						// 更新顶点色
						_vertexColorData[vi*16] = Number((lp.color >> 16) & 0xff) / 0xff;		// 0
						_vertexColorData[vi*16+1] = Number((lp.color >> 8) & 0xff) / 0xff;
						_vertexColorData[vi*16+2] = Number(lp.color & 0xff) / 0xff;
						_vertexColorData[vi*16+3] = lp.alpha;
						
						_vertexColorData[vi*16+4] = Number((p.color >> 16) & 0xff) / 0xff;		// 1
						_vertexColorData[vi*16+5] = Number((p.color >> 8) & 0xff) / 0xff;
						_vertexColorData[vi*16+6] = Number(p.color & 0xff) / 0xff;
						_vertexColorData[vi*16+7] = p.alpha;
						
						_vertexColorData[vi*16+8] = Number((p.color >> 16) & 0xff) / 0xff;		// 2
						_vertexColorData[vi*16+9] = Number((p.color >> 8) & 0xff) / 0xff;
						_vertexColorData[vi*16+10] = Number(p.color & 0xff) / 0xff;
						_vertexColorData[vi*16+11] = p.alpha;
						
						_vertexColorData[vi*16+12] = Number((lp.color >> 16) & 0xff) / 0xff;	// 3
						_vertexColorData[vi*16+13] = Number((lp.color >> 8) & 0xff) / 0xff;
						_vertexColorData[vi*16+14] = Number(lp.color & 0xff) / 0xff;
						_vertexColorData[vi*16+15] = lp.alpha;
					
						vi++;
					}
					
					lpi = pi;
					pi++;					
				}				
			}
			
			_stripeSystem.particleNum = vi;
			//Debug.bltrace("particle=" + _ParticleNum);
			_geometry.updateVertexData(_vertexData);
			_geometry.updateUVData(_uvData);
			_geometry.updateVertexColorData(_vertexColorData);
				
		}
		
		public function Stop(immediately:Boolean):void
		{
		}
		
		public function get material():MaterialBase 
		{
			return _material;
		}
		
		public function set material(value:MaterialBase):void
		{
			if (value == _material) return;
			if (_material) 	_material.removeOwner(_stripeSystem);
			_material = value;
			
			ParticleSystem.modifyMaterial(_material);
			
			if (_material) _material.addOwner(_stripeSystem);
		}
		
		public function getVertexBuffer(stage3DProxy:Stage3DProxy):VertexBuffer3D 
		{
			return _geometry.getVertexBuffer(stage3DProxy);
		}
		
		public function getVertexColorBuffer(stage3DProxy:Stage3DProxy):VertexBuffer3D 
		{
			return _geometry.getVertexColorBuffer(stage3DProxy);
		}
		
		public function getUVBuffer(stage3DProxy:Stage3DProxy):VertexBuffer3D 
		{
			return _geometry.getUVBuffer(stage3DProxy);
		}
		
		public function getIndexBuffer(stage3DProxy:Stage3DProxy):IndexBuffer3D 
		{
			return _geometry.getIndexBuffer(stage3DProxy);
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
				_material.removeOwner(_stripeSystem);
				_material = null;
			}
			
		}
	}
}