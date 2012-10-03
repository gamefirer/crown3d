/**
 *	贴图资源模型 
 */
package blade3d.resource
{
	import flash.display.BitmapData;
	import flash.utils.ByteArray;

	public class BlImageResource extends BlResource
	{
		override public function get resType() : int {return BlResourceManager.TYPE_IMAGE;}
		
		private var _bmpData : BitmapData;
		
		public function get bmpData() : BitmapData {return _bmpData;}
		override public function get res() : * {return _bmpData;}
		
		public function BlImageResource(url:String)
		{
			super(url);
		}
		
		override protected function _loadImp():void
		{
			BlResourceManager.instance().loaderManager.loadResource(_url, resType, OnImageData);
		}
		
		private function OnImageData(bmpData:BitmapData):void
		{
			_bmpData = bmpData;
			
			_loadEnd(_bmpData != null);
		}
	}
}