package sl2d.texture
{
	import flash.display.BitmapData;
	import flash.utils.Dictionary;
	
	import sl2d.slTextureFactory;

	public class slTeamTexture extends slTexture
	{
		public function slTeamTexture(gcEnable:Boolean = true)
		{
			super(gcEnable);
		}
		
		public function parseBmpList(factory:slTextureFactory, bmpList:Vector.<BitmapData>, key:String, frameToTextureInfo:Dictionary):void{
			deepDispose();
			initBitmap(factory, bmpList, key, frameToTextureInfo);
		}
		
		private function initBitmap(factory:slTextureFactory, bmpList:Vector.<BitmapData>, refrenceKey:String, frameToTextureInfo:Dictionary):void{
			initialize(factory, refrenceKey);
			if(bmpList == null || bmpList == null)
				return;
			createMultipleTexture(factory, refrenceKey, bmpList, frameToTextureInfo);
			_validate = true;
		}
		
		protected function appendBitmapData(factory:slTextureFactory, bmd:BitmapData):void{
			_unit.appendBitmapData(factory, bmd);
		}
		
	}
}