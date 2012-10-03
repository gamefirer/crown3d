package sl2d.texture
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	
	import sl2d.slGlobal;

	public class slBmpTexture extends slTexture
	{
		public function slBmpTexture()
		{
		}
		
		public function parseBmp(factory:slTextureFactory, bmd:BitmapData, key:String, offsetX:int = 0, offsetY:int = 0):void
		{
			deepDispose();
			initBitmap(factory, bmd, key, offsetX, offsetY);
		}
		
		private function initBitmap(factory:slTextureFactory, bmd:BitmapData, refrenceKey:String, offsetX:int = 0, offsetY:int = 0):void
		{
			initialize(factory, refrenceKey);
			if(bmd == null) return;
			var width:uint = FixSpan(bmd.width);
			var height:uint = FixSpan(bmd.height);
			setUV(0, Vector.<Number>([0, 0, bmd.width / width, bmd.height / height, offsetX, offsetY, bmd.width, bmd.height]));
			createSingleTexture(factory, bmd);
			_validate = true;
		}
		
	}
}