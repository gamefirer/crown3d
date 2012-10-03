/**
 *	光照图渲染器 
 */
package away3d.core.render
{
	import away3d.arcane;
	import away3d.cameras.Camera3D;
	import away3d.core.data.RenderableListItem;
	import away3d.core.traverse.EntityCollector;
	import away3d.materials.MaterialBase;
	
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.textures.TextureBase;

	use namespace arcane;
	
	public class LightMapRenderer extends RendererBase
	{
		private var _activeMaterial : MaterialBase;
		
		public function LightMapRenderer(renderToTexture:Boolean=false)
		{
			super(renderToTexture);
		}
		
		override protected function draw(entityCollector : EntityCollector, target : TextureBase) : void
		{
			_context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE);		// 加色
			_context.setCulling( Context3DTriangleFace.NONE );
			_context.setDepthTest(false, Context3DCompareMode.ALWAYS);
			
			drawRenderables(entityCollector.lightMapRenderableHead, entityCollector);
			
			if (_activeMaterial)
				_activeMaterial.deactivateForLightMap(_stage3DProxy);
			
			_activeMaterial = null;
		}
		
		private function drawRenderables(item : RenderableListItem, entityCollector : EntityCollector) : void
		{
			var camera : Camera3D = entityCollector.camera;
			var item2 : RenderableListItem;
			
			while (item) 
			{
				_activeMaterial = item.renderable.material;
				
				_activeMaterial.activateForLightMap(_stage3DProxy, camera);
				item2 = item;
				do 
				{
					_activeMaterial.renderLightMap(item2.renderable, _stage3DProxy, camera);
					item2 = item2.next;
				} 
				while(item2 && item2.renderable.material == _activeMaterial);
				
				_activeMaterial.deactivateForLightMap(_stage3DProxy);
				item = item2;
			}
		}
	}
}