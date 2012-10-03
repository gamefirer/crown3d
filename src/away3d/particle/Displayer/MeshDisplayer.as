/**
 *	用mesh来表示粒子的显示器 
 */
package away3d.particle.Displayer
{
	import away3d.core.managers.Stage3DProxy;
	import away3d.core.traverse.PartitionTraverser;
	import away3d.entities.Mesh;
	import away3d.materials.DefaultMaterialBase;
	import away3d.materials.MaterialBase;
	import away3d.materials.methods.BasicColorMethod;
	import away3d.particle.Particle;
	import away3d.particle.ParticleSystem;
	
	import bl.managers.blSceneManager;
	import bl.scene.blScene;
	import bl.scene.blWorld;
	
	import flash.display.BlendMode;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.ColorTransform;
	
	public class MeshDisplayer implements ParticleDisplayerBase
	{
		private var _meshModel : Mesh;				// mesh原型
		private var _material : MaterialBase;		// mesh的材质
		private var _meshPool : Vector.<Mesh> = new Vector.<Mesh>;	
		
		public function MeshDisplayer(particleSystem:ParticleSystem=null)
		{
			setParticleSystem(particleSystem);
		}
		
		protected var _particleSystem : ParticleSystem;
		public function setParticleSystem(value:ParticleSystem):void	{ _particleSystem = value; }
		
		// 设置Mesh原型
		public function set meshModel(value : Mesh) : void
		{
			if(!value)
				return;
			
			_meshModel = value;			
			_material = _meshModel.material;
			if(_material)
				modifyMaterial(_material);
		}
		
		private function modifyMaterial(material : MaterialBase) : void
		{
			material.repeat = true;
			material.blendMode = BlendMode.ADD;		// 透明贴图
			material.bothSides = true;				// 粒子要双面渲染
			material.lights = null;					// 不受灯光影响
			DefaultMaterialBase(material).normalMethod.normalMap = null;		// 无normal map
			DefaultMaterialBase(material).specularMethod = null;
			DefaultMaterialBase(material).colorMethod = new BasicColorMethod;	// 顶点色
			if(!DefaultMaterialBase(material).colorTransform)
				DefaultMaterialBase(material).colorTransform = new ColorTransform;
		}
		
		public function Stop(immediately : Boolean) : void 
		{
			if(immediately)
			{	
				for(var i:int=0; i<_meshPool.length; i++)
				{
					_meshPool[i].visible = false;
				}
			}
		}
		
		private function allocateMesh() : void
		{
			var newMesh : Mesh = Mesh(_meshModel.clone());
			_meshPool.push(newMesh);
			
			newMesh.visible = false;			
		}
		
		public function render(traverser:PartitionTraverser):void
		{
			if(!_meshModel || !_particleSystem)
				return;
			
			// 根据粒子计算mesh
			var i:int;
			var pooli:int = 0;
			var pMesh : Mesh;
			
			var _Particles : Vector.<Particle> = _particleSystem.particles;
			
			for(i=0; i<=_particleSystem.maxLiveParticleIndex; i++)
			{
				if(_Particles[i].IsDead())
					continue;
				
				var p : Particle = _Particles[i];
				
				while(pooli >= _meshPool.length)
				{
					allocateMesh();
				}
				
				pMesh = _meshPool[pooli];
				pMesh.visible = true;
				
				pMesh.position = p.pos;
				pMesh.scaleXYZ(p.sizeX);
				pMesh.rotationY = p.rot;
				
				if(_particleSystem.isWolrdParticle)
				{
					blWorld.getInstance().scene.addOthers(pMesh);
				}
				else
				{
					_particleSystem.addChild(pMesh);
				}
				
				pooli++;
			}
			// 隐藏多余的mesh
			for( ; pooli < _meshPool.length; pooli++)
			{
				pMesh = _meshPool[pooli];
				pMesh.visible = false;
				pMesh.detachParent();
			}
		}
		
		public function get material():MaterialBase
		{
			return null;		// return null 使particlesystem对象不渲染
		}
		
		public function set material(value:MaterialBase):void
		{
			
		}
		
		public function getVertexBuffer(stage3DProxy:Stage3DProxy):VertexBuffer3D {return null;}
		public function getVertexColorBuffer(stage3DProxy:Stage3DProxy):VertexBuffer3D {return null;}
		public function getUVBuffer(stage3DProxy:Stage3DProxy):VertexBuffer3D {return null;}
		public function getIndexBuffer(stage3DProxy:Stage3DProxy):IndexBuffer3D {return null;}
		
		public function dispose() : void
		{
			_meshModel.dispose(false);
			for(var mi:int=0; mi<_meshPool.length; mi++)
			{
				_meshPool[mi].dispose(false);
			}
		}
	}
}