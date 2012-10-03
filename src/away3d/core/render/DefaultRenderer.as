package away3d.core.render
{
	import away3d.arcane;
	import away3d.cameras.Camera3D;
	import away3d.core.base.IRenderable;
	import away3d.core.data.RenderableListItem;
	import away3d.core.managers.Stage3DProxy;
	import away3d.core.traverse.EntityCollector;
	import away3d.lights.DirectionalLight;
	import away3d.lights.LightBase;
	import away3d.lights.PointLight;
	import away3d.materials.MaterialBase;
	
	import blade3d.profiler.Profiler;
	
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.textures.TextureBase;
	import flash.geom.Rectangle;

	use namespace arcane;

	/**
	 * The DefaultRenderer class provides the default rendering method. It renders the scene graph objects using the
	 * materials assigned to them.
	 */
	public class DefaultRenderer extends RendererBase
	{
		private static var RTT_PASSES : int = 1;			// 渲染到贴图
		private static var SCREEN_PASSES : int = 2;		// 渲染到屏幕
		private static var ALL_PASSES : int = 3;
		private var _activeMaterial : MaterialBase;
		private var _distanceRenderer : DepthRenderer;
		private var _depthRenderer : DepthRenderer;			// 渲染深度图的渲染器
		private var _lightMapRenderer: LightMapRenderer;		// 渲染lightmap的渲染器

		public function get lightMapRenderer() : LightMapRenderer {return _lightMapRenderer;}
		/**
		 * Creates a new DefaultRenderer object.
		 * @param antiAlias The amount of anti-aliasing to use.
		 * @param renderMode The render mode to use.
		 */
		public function DefaultRenderer()
		{
			super();
			_depthRenderer = new DepthRenderer();
			_distanceRenderer = new DepthRenderer(false, true);
			_lightMapRenderer = new LightMapRenderer();
			_lightMapRenderer.backgroundR = 0.1;
			_lightMapRenderer.backgroundG = 0.1;
			_lightMapRenderer.backgroundB = 0.1;
		}

		arcane override function set stage3DProxy(value : Stage3DProxy) : void
		{
			super.stage3DProxy = value;
			_lightMapRenderer.stage3DProxy = _distanceRenderer.stage3DProxy = _depthRenderer.stage3DProxy = value;
		}

		protected override function executeRender(entityCollector : EntityCollector, target : TextureBase = null, scissorRect : Rectangle = null, surfaceSelector : int = 0) : void
		{
			Profiler.start("updateLights");
			updateLights(entityCollector);
			Profiler.end("updateLights");

			// otherwise RTT will interfere with other RTTs
			if (target) {
				drawRenderables(entityCollector.opaqueRenderableHead, entityCollector, RTT_PASSES);
				drawRenderables(entityCollector.blendedRenderableHead, entityCollector, RTT_PASSES);
			}

			super.executeRender(entityCollector, target, scissorRect, surfaceSelector);
		}

		private function updateLights(entityCollector : EntityCollector) : void
		{
			var dirLights : Vector.<DirectionalLight> = entityCollector.directionalLights;
			var pointLights : Vector.<PointLight> = entityCollector.pointLights;
			var len : uint, i : uint;
			var light : LightBase;

			// 渲染场景灯光贴图
			len = dirLights.length;
			for (i = 0; i < len; ++i) {
				light = dirLights[i];
				if (light.castsLightMap && light.visible)
					light.lightMapper.renderLightMap(_stage3DProxy, entityCollector, _lightMapRenderer);
			}
			
			// 渲染阴影贴图
			len = dirLights.length;
			for (i = 0; i < len; ++i) {
				light = dirLights[i];
				if (light.castsShadows && light.visible)
					light.shadowMapper.renderDepthMap(_stage3DProxy, entityCollector, _depthRenderer);
			}

			len = pointLights.length;
			for (i = 0; i < len; ++i) {
				light = pointLights[i];
				if (light.castsShadows)
					light.shadowMapper.renderDepthMap(_stage3DProxy, entityCollector, _distanceRenderer);
			}
		}

		/**
		 * @inheritDoc
		 */
		override protected function draw(entityCollector : EntityCollector, target : TextureBase) : void
		{
			Profiler.start("draw");
			// 渲染天空盒
			if (entityCollector.skyBox)
			{
				if (_activeMaterial) _activeMaterial.deactivate(_stage3DProxy);
				_activeMaterial = null;
				drawSkyBox(entityCollector);
			}
			
			_context.setDepthTest(true, Context3DCompareMode.LESS);
			_context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
			
			var which : int = target? SCREEN_PASSES : ALL_PASSES;
			// 渲染不透明物体
			Profiler.start("draw opaque");
			drawRenderables(entityCollector.opaqueRenderableHead, entityCollector, which);
			Profiler.end("draw opaque");
			// 渲染地表贴花
			Profiler.start("draw decal");
			drawRenderables(entityCollector.decalRenderableHead, entityCollector, which);
			Profiler.end("draw decal");
			// 渲染透明物体
			Profiler.start("draw blend");
			drawRenderables(entityCollector.blendedRenderableHead, entityCollector, which);
			Profiler.end("draw blend");
			
			// 渲染粒子和特效
			Profiler.start("draw particle");
			drawRenderables(entityCollector.particleRenderableHead, entityCollector, which);
			Profiler.end("draw particle");
			
			// 渲染编辑器物体
			Profiler.start("draw editor");
			drawRenderables(entityCollector.editorRenderableHead, entityCollector, which);
			Profiler.end("draw editor");
			
			if (_activeMaterial)
				_activeMaterial.deactivate(_stage3DProxy);
			
			_context.setDepthTest(false, Context3DCompareMode.LESS);
			
			_activeMaterial = null;
			Profiler.end("draw");
		}

		/**
		 * Draw the skybox if present.
		 * @param entityCollector The EntityCollector containing all potentially visible information.
		 */
		private function drawSkyBox(entityCollector : EntityCollector) : void
		{
			var skyBox : IRenderable = entityCollector.skyBox;
			var material : MaterialBase = skyBox.material;
			var camera : Camera3D = entityCollector.camera;

			material.activatePass(0, _stage3DProxy, camera, _textureRatioX, _textureRatioY);
			material.renderPass(0, skyBox, _stage3DProxy, entityCollector);
			material.deactivatePass(0, _stage3DProxy);
		}

		/**
		 * Draw a list of renderables.
		 * @param renderables The renderables to draw.
		 * @param entityCollector The EntityCollector containing all potentially visible information.
		 */
		private function drawRenderables(item : RenderableListItem, entityCollector : EntityCollector, which : int) : void
		{
			var numPasses : uint;
			var j : uint;
			var camera : Camera3D = entityCollector.camera;
			var item2 : RenderableListItem;

			while (item) {
				_activeMaterial = item.renderable.material;
				_activeMaterial.updateMaterial(_context);

				numPasses = _activeMaterial.numPasses;
				j = 0;

				do {
					item2 = item;

					var rttMask : int = _activeMaterial.passRendersToTexture(j)? 1 : 2;

					if ((rttMask & which) != 0) 
					{
						Profiler.start("activatePass");
						_activeMaterial.activatePass(j, _stage3DProxy, camera, _textureRatioX, _textureRatioY);
						Profiler.end("activatePass");
						do
						{
							Profiler.start("renderPass");
							_activeMaterial.renderPass(j, item2.renderable, _stage3DProxy, entityCollector);
							Profiler.end("renderPass");
							item2 = item2.next;
						}
						while (item2 && item2.renderable.material == _activeMaterial);
						Profiler.start("deactivatePass");
						_activeMaterial.deactivatePass(j, _stage3DProxy);
						Profiler.end("deactivatePass");
					}
					else do 
					{
						item2 = item2.next;
					}
					while (item2 && item2.renderable.material == _activeMaterial);

				} while (++j < numPasses);

				item = item2;
			}
		}


		arcane override function dispose() : void
		{
			super.dispose();
			_depthRenderer.dispose();
			_distanceRenderer.dispose();
			_lightMapRenderer.dispose();
			_depthRenderer = null;
			_distanceRenderer = null;
			_lightMapRenderer = null;
		}
	}
}
