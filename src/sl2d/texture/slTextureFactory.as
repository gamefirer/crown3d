/**
 *	贴图工厂 
 */
package sl2d.texture
{
	import away3d.core.managers.Context3DProxy;
	import away3d.core.managers.Stage3DProxy;
	
	import flash.display.BitmapData;
	import flash.display3D.*;
	import flash.display3D.textures.*;
	
	import sl2d.utils.HashTable;
	

	public class slTextureFactory 
	{
		private static var _Context:Context3D;
		private static var _Instance:slTextureFactory;
		private var _bmpTexture:HashTable = new HashTable();
		
		public static function instance():slTextureFactory
		{
			if(!_Instance)
				_Instance = new slTextureFactory();
			return _Instance;
		}
		
		public function slTextureFactory()
		{
			
		}
		
		public function setContext(context:Context3D):void
		{
			_Context = context;
			_bmpTexture.eachValue(updateContext);
			function updateContext(texture:slTexture):void
			{
				if(texture){
					texture.reUploadBmd(true);
				}
			}
			
		}
		public function getContextEnable():Boolean
		{
			if(_Context == null)
				return false;
			if(_Context.driverInfo == "Disposed")
				return false;
			return true;
		}
		
		public function createBmpTexture(name:String, data:BitmapData, offsetX:int = 0, offsetY:int = 0):slBmpTexture 
		{
			var target:slBmpTexture = _bmpTexture.getValue(name);
			if(target == null)
			{
				target = new slBmpTexture();
				target.parseBmp(this, data, name, offsetX, offsetY);
				_bmpTexture.put(name, target);
			}
			return target;
		}
		
		
		public function getBmpTexture(name:String):slBmpTexture{
			return _bmpTexture.getValue(name);
		}
		
		public function uploadBmp(bmd:BitmapData, w:uint, h:uint):Texture
		{
			if(getContextEnable() == false)
				return null;
			var texture:Texture = Context3DProxy.createTexture(w, h, Context3DTextureFormat.BGRA, false);
			Context3DProxy.uploadTextureFromBitmapData(texture, bmd);
			return texture;
		}
		

	}
}
