/*
 *	场景灯光(lightmap)用的材质
 */
package away3d.materials
{
	import away3d.arcane;
	import away3d.materials.passes.LightMapPass;
	import away3d.textures.BitmapTexture;
	import away3d.textures.BitmapTextureCache;
	
	import flash.display.BitmapData;
	
	use namespace arcane;
	
	public class SceneLightMaterial extends MaterialBase
	{
		private var _lightMapTexture : BitmapTexture;
		private var _lightColorR : Number = 1.0;
		private var _lightColorG : Number = 1.0;
		private var _lightColorB : Number = 1.0;
		
				
		public function SceneLightMaterial(value : BitmapData)
		{
			if (value == bitmapData) return;
				
			if(_lightMapTexture)
			{
				BitmapTextureCache.instance().freeTexture(_lightMapTexture);
				_lightMapTexture = null
			}
			
			_lightMapTexture = BitmapTextureCache.instance().getTexture(value);
			
			_lightMapPass.lightMapTexture = _lightMapTexture;
		}
		
		public function get bitmapData() : BitmapData
		{
			return _lightMapTexture? _lightMapTexture.bitmapData : null;
		}
		
		public function set bitmapData(bmpData:BitmapData):void
		{
			_lightMapTexture.bitmapData = bmpData;
		}
		
		override public function dispose() : void
		{
			BitmapTextureCache.instance().freeTexture(_lightMapTexture);
			super.dispose();
		}
		
		public function setLightColor(r:Number, g:Number, b:Number) : void
		{
			_lightColorR = r;
			_lightColorG = g;
			_lightColorB = b;
			
			_lightMapPass.setLightColor(r, g, b);
		}
		
		public function setLightIntensity(value : Number) : void
		{
			_lightMapPass.setLightIntensity(value);
		}

		
	} // class	
} // package