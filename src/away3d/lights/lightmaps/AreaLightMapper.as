/*
 *	场景灯光贴图渲染器
 */
package away3d.lights.lightmaps
{
	import away3d.arcane;
	import away3d.cameras.Camera3D;
	import away3d.cameras.lenses.OrthographicLens;
	import away3d.cameras.lenses.OrthographicOffCenterLens;
	import away3d.containers.Scene3D;
	import away3d.core.managers.Stage3DProxy;
	import away3d.core.render.DepthRenderer;
	import away3d.core.render.LightMapRenderer;
	import away3d.core.traverse.EntityCollector;
	import away3d.core.traverse.LightCasterCollector;
	import away3d.debug.Debug;
	import away3d.events.Stage3DEvent;
	import away3d.lights.LightBase;
	import away3d.materials.utils.DefaultMaterialManager;
	import away3d.textures.BitmapTextureCache;
	import away3d.textures.RenderTexture;
	import away3d.textures.TextureProxyBase;
	import away3d.utils.Away3DConfig;
	
	import blade3d.BlConfiguration;
	import blade3d.profiler.Profiler;
	
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.TextureBase;
	import flash.geom.Matrix3D;
	
	use namespace arcane;
	
	public class AreaLightMapper
	{
		protected var _lightCamera : Camera3D;			// lightmap的投影camera
		protected var _casterCollector : LightCasterCollector;
		
		private var _lightMap : TextureProxyBase;			// lightmap texture
		private var _lightMapSize : uint = Away3DConfig.LightMapSize;		// lightmap 贴图大小
		protected var _light : LightBase;			// 该lightmap的投影灯
		
		public function AreaLightMapper(light : LightBase)
		{
			_light = light;
			_casterCollector = new LightCasterCollector();
			
			// 创建投影camera
			_lightCamera = new Camera3D;
			_lightCamera.name = "texLightCamera";
			_lightCamera.lens = new OrthographicOffCenterLens(-10, -10, 10, 10);		// 正交投影
		}
		
		public function get lightMap() : TextureProxyBase
		{
			return _lightMap ||= createLightTexture();
		}
		
		public function get lightMapSize() : uint
		{
			return _lightMapSize;
		}
		
		public function set lightMapSize(value : uint) : void
		{
			if (value == _lightMapSize) return;
			_lightMapSize = value;
			
			_lightMap.dispose();
			_lightMap = null;
		}
		
		public function dispose() : void
		{
			_casterCollector = null;
			if (_lightMap)
				_lightMap.dispose();
			_lightMap = null;
		}
		
		arcane function get lightProjection() : Matrix3D
		{
			return _lightCamera.viewProjection;
		}
		
		// 创建lightmap的texture
		private function createLightTexture() : TextureProxyBase
		{
			return new RenderTexture(_lightMapSize, _lightMapSize);
		}
		// 渲染灯光贴图
		arcane function renderLightMap(stage3DProxy : Stage3DProxy, entityCollector : EntityCollector, renderer : LightMapRenderer) : void
		{
			Profiler.start("renderLightMap");
			_lightMap ||= createLightTexture();
			updateLightProjection(entityCollector.camera);
			drawLightMap(_lightMap.getTextureForStage3D(stage3DProxy), entityCollector.scene, renderer);	// 渲染LightMap
			Profiler.end("renderLightMap");
			
		}
		// 计算LightMap的投影矩阵和视锥体
		private var _mtx : Matrix3D = new Matrix3D();
		private var _localFrustum : Vector.<Number> = new Vector.<Number>(24);
		private function updateLightProjection(viewCamera : Camera3D) : void
		{
			var lightLens : OrthographicOffCenterLens = OrthographicOffCenterLens(_lightCamera.lens);
			lightLens.near = 100;
			lightLens.far = 10000;
			
			var shadowWide : Number;
			
			if(!BlConfiguration.editorMode)
			{
				shadowWide = 2000;	// 视锥体大小
				lightLens.minX = -shadowWide;
				lightLens.maxX = shadowWide;
				lightLens.minY = -shadowWide;
				lightLens.maxY = shadowWide;
				
				_lightCamera.transform = _light.sceneTransform;
			}
			else
			{
				var i : uint , j : uint;
				var x2 : Number, y2 : Number;
				var xN : Number, yN : Number, zN : Number;
				var xF : Number, yF : Number, zF : Number;
				var minX : Number = Number.POSITIVE_INFINITY, minY : Number = Number.POSITIVE_INFINITY, minZ : Number = Number.POSITIVE_INFINITY;
				var maxX : Number = Number.NEGATIVE_INFINITY, maxY : Number = Number.NEGATIVE_INFINITY, maxZ : Number = Number.NEGATIVE_INFINITY;
				
				_mtx.copyFrom(_light.inverseSceneTransform);
				_mtx.prepend(viewCamera.sceneTransform);
				_mtx.transformVectors(viewCamera.lens.frustumCorners, _localFrustum);
				
				i = 0;
				j = 12;
				while (i < 12)
				{
					xN = _localFrustum[i++];
					yN = _localFrustum[i++];
					zN = _localFrustum[i++];
					xF = _localFrustum[j++];
					yF = _localFrustum[j++];
					zF = _localFrustum[j++];
					if (xN < minX) minX = xN;
					if (xN > maxX) maxX = xN;
					if (yN < minY) minY = yN;
					if (yN > maxY) maxY = yN;
					if (zN < minZ) minZ = zN;
					if (zN > maxZ) maxZ = zN;
					if (xF < minX) minX = xF;
					if (xF > maxX) maxX = xF;
					if (yF < minY) minY = yF;
					if (yF > maxY) maxY = yF;
					if (zF < minZ) minZ = zF;
					if (zF > maxZ) maxZ = zF;
				}
				
				shadowWide = Math.abs(minX);
				shadowWide = Math.max(shadowWide, Math.abs(maxX));
				shadowWide = Math.max(shadowWide, Math.abs(minZ));
				shadowWide = Math.max(shadowWide, Math.abs(maxZ));
				if(shadowWide > 8000)
					shadowWide = 8000;
				
				lightLens.minX = -shadowWide
				lightLens.maxX = shadowWide;
				lightLens.minY = -shadowWide;
				lightLens.maxY = shadowWide;
				
				_lightCamera.transform = _light.sceneTransform;
				
			}
		}
		
		private function drawLightMap(target : TextureBase, scene : Scene3D, renderer : LightMapRenderer) : void
		{
			_casterCollector.clear();
			_casterCollector.camera = _lightCamera;
			scene.traversePartitions(_casterCollector);			// 搜索要渲染的灯
			renderer.render(_casterCollector, target);
			_casterCollector.cleanUp();
		}
		
	} // class AreaLightMapper
} // package