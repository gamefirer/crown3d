package away3d.materials.utils
{
	import away3d.core.base.*;
	import away3d.materials.*;
	import away3d.textures.*;
	
	import flash.display.*;
	/**
	 * @author robbateman
	 */
	public class DefaultMaterialManager
	{
		private static var _defaultTextureBitmapData:BitmapData;
		private static var _defaultTexture:BitmapTexture;
		
		public static function getDefaultMaterial(renderable:IMaterialOwner = null):TextureMaterial
		{
			if (!_defaultTexture)
				createDefaultTexture();
			
			var defultMaterial : TextureMaterial = createDefaultMaterial();
			return defultMaterial;
		}
		
		public static function getDefaultTexture(renderable:IMaterialOwner = null):BitmapTexture
		{
			if (!_defaultTexture)
				createDefaultTexture();
			
			return _defaultTexture;
		}
		
		public static function getDefaultBitmapData():BitmapData
		{
			if (!_defaultTexture)
				createDefaultTexture();
			
			return _defaultTextureBitmapData;
		}
		
		private static function createDefaultTexture():void
		{
			_defaultTextureBitmapData = new BitmapData(8, 8, false, 0x0);
			
			//create chekerboard
			var i:uint, j:uint;
			for (i=0; i<8; i++) {
				for (j=0; j<8; j++) {
					if ((j & 1) ^ (i & 1))
						_defaultTextureBitmapData.setPixel(i, j, 0XFFFFFF);
				}
			}
			
			_defaultTexture = new BitmapTexture(_defaultTextureBitmapData);	 // 全局唯一默认材质
		}
		
		private static function createDefaultMaterial():TextureMaterial
		{
			var defaultMaterial : TextureMaterial = new TextureMaterial(_defaultTexture);
			defaultMaterial.mipmap = false;
			defaultMaterial.smooth = false;
			return defaultMaterial;
		}
	}
}
