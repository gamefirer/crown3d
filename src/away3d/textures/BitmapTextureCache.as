/**
 *
 */
package away3d.textures
{
	import away3d.textures.BitmapTexture;

	import flash.display.BitmapData;
	import flash.utils.Dictionary;

	/**
	 * DEPRECRATED along with BitmapMaterial. Will be removed along with BitmapMaterial
	 */
	public class BitmapTextureCache
	{
		private static var _instance : BitmapTextureCache;
		
		public var textureCount : uint = 0;
		private var _textures : Dictionary;
		private var _usages : Dictionary;

		public function BitmapTextureCache(singletonEnforcer : SingletonEnforcer)
		{
			if (!singletonEnforcer) throw new Error("Cannot instantiate a singleton class. Use static getInstance instead.");

			_textures = new Dictionary();
			_usages = new Dictionary();
		}

		public static function instance() : BitmapTextureCache
		{
			return _instance ||= new BitmapTextureCache(new SingletonEnforcer());
		}

		public function getTexture(bitmapData : BitmapData) : BitmapTexture
		{
			var texture : BitmapTexture;
			if (!_textures[bitmapData]) 
			{
				texture = new BitmapTexture(bitmapData);
				_textures[bitmapData] = texture;
				_usages[texture] = 0;
				textureCount++;
			}
			else
				texture = _textures[bitmapData];
				
			_usages[texture]++;
			return _textures[bitmapData];
		}

		public function freeTexture(texture : BitmapTexture) : void
		{
			_usages[texture]--;
			if (_usages[texture] == 0) 
			{
				_textures[BitmapTexture(texture).bitmapData] = null;
				texture.bitmapTextureDispose();		// texture.dispose();
				textureCount--;
			}
		}
	}
}

class SingletonEnforcer {}