/**
 *	地表纹理加载器 
 */
package blade3d.scene
{
	import away3d.entities.Mesh;
	import away3d.materials.methods.TerrainDiffuseMethod2;
	
	import blade3d.resource.BlImageResource;
	import blade3d.resource.BlResource;
	import blade3d.resource.BlResourceManager;
	
	import flash.display.BitmapData;

	public class BlTerrainTextureLoader
	{
		public var terrainMethod : TerrainDiffuseMethod2;
		public var userObject:*;
		
		private var _callBack : Function;
		
		private var _blendTextureUrl : String;
		
		private var _loadCount : int = 0;
		
		
		public function BlTerrainTextureLoader()
		{
		}
		
		public function startLoad(terrainMethod:TerrainDiffuseMethod2, tex:String, tex1:String, tex2:String, tex3:String, tex4:String, callBack : Function, userObject:*) : void
		{
			this.terrainMethod = terrainMethod;
			_callBack = callBack;
			this.userObject = userObject;
			
			incLoadCount();
			
			var texRes:BlImageResource;
			
			if(tex.length > 0)
			{
				_blendTextureUrl = tex;
				incLoadCount();
				texRes = BlResourceManager.instance().findImageResource(tex);
				texRes.asycLoad(onTexLoaded);
			}
			if(tex1.length > 0)
			{
				incLoadCount();
				texRes = BlResourceManager.instance().findImageResource(tex1);
				texRes.asycLoad(onTex1Loaded);
			}
			if(tex2.length > 0)
			{
				incLoadCount();
				texRes = BlResourceManager.instance().findImageResource(tex2);
				texRes.asycLoad(onTex2Loaded);
			}
			if(tex3.length > 0)
			{
				incLoadCount();
				texRes = BlResourceManager.instance().findImageResource(tex3);
				texRes.asycLoad(onTex3Loaded);
			}
			if(tex4.length > 0)
			{
				incLoadCount();
				texRes = BlResourceManager.instance().findImageResource(tex4);
				texRes.asycLoad(onTex4Loaded);
			}
			
			onLoaded();
		}
		// 载入混合贴图
		private function onTexLoaded(res:BlResource) : void
		{
			terrainMethod.setTerrainBlendTextrue(BlImageResource(res).bmpData);
			onLoaded();
		}
		
		private function onTex1Loaded(res:BlResource) : void
		{
			terrainMethod.setTextureLayer(0, BlImageResource(res).bmpData);
			onLoaded();
		}
		
		private function onTex2Loaded(res:BlResource) : void
		{
			terrainMethod.setTextureLayer(1, BlImageResource(res).bmpData);
			onLoaded();
		}
		
		private function onTex3Loaded(res:BlResource) : void
		{
			terrainMethod.setTextureLayer(2, BlImageResource(res).bmpData);
			onLoaded();
		}
		
		private function onTex4Loaded(res:BlResource) : void
		{
			terrainMethod.setTextureLayer(3, BlImageResource(res).bmpData);
			onLoaded();
		}
		
		private function incLoadCount() : void
		{
			_loadCount++;
		}
		
		private function onLoaded() : void
		{
			_loadCount--;
			if(_loadCount == 0)
			{
				onLoadComplete();
			}
		}
		
		private function onLoadComplete() : void
		{
			_callBack(this);
		}
		// 重新加载地表混合贴图 (编辑器用功能,暂不支持)
//		public function reloadBlendTexture() : void
//		{
//			blAssetsLoader.recycle(_blendTextureUrl);
//			blAssetsLoader.getTextureFromURL(_blendTextureUrl, 0, onReloadBlendTexture);
//		}
//		
//		private function onReloadBlendTexture(tag : int, bm : BitmapData) : void
//		{
//			if(bm)
//			{
//				_terrainMethod.setTerrainBlendTextrue(bm);
//			}
//			
//		}
	}
	
}