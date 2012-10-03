package away3d.core.traverse
{
	import away3d.arcane;
	import away3d.core.base.IRenderable;
	import away3d.core.data.RenderableListItem;
	import away3d.debug.Debug;
	import away3d.entities.Entity;
	import away3d.entities.Sprite3D;
	import away3d.library.assets.AssetType;
	import away3d.lights.LightBase;
	import away3d.materials.MaterialBase;
	import away3d.particle.ParticleSystem;
	
	use namespace arcane;
	
	
	public class LightCasterCollector extends EntityCollector
	{
		public function LightCasterCollector()
		{
		}
		
		override public function applySkyBox(renderable : IRenderable) : void
		{
		}
		
		override public function applyRenderable(renderable : IRenderable) : void
		{
			var material : MaterialBase;
			_numTriangles += renderable.numTriangles;
			
			material = renderable.material;
			if (material)
			{
				var item : RenderableListItem = _renderableListItemPool.getItem();
				item.renderable = renderable;
				item.next = _opaqueRenderableHead;
				item.zIndex = renderable.zIndex;
				item.renderOrderId = renderable.material._uniqueId;
				item.renderPriority = renderable.material.renderPriority;		// 渲染优先级
				
				if(renderable.sourceEntity.renderLayer == Entity.SceneLight_Layer)
				{	// 场景灯层
					item.next = _lightMapRenderableHead;
					_lightMapRenderableHead = item;
					++_numTexLights;
				}
			}
		}
		
		override public function applyParticle(particleSystem : ParticleSystem) : void
		{
			
		}
		
		override public function get layerMask() : uint 
		{
			return Entity.SceneLight_Layer;
		}
		
		
	}
	
} // package