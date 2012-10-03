/**
 *	binary数据 
 */
package blade3d.resource
{
	import blade3d.loader.BlResourceLoaderManager;
	
	import flash.utils.ByteArray;

	public class BlBinaryResource extends BlResource
	{
		override public function get resType() : int {return BlResourceManager.TYPE_BYTEARRAY;}
		
		private var _ba : ByteArray;
		
		public function BlBinaryResource(url:String)
		{
			super(url);
		}
		
		public function get ba() : ByteArray {return _ba;}
		override public function get res() : * {return _ba;}
		
		override protected function _loadImp():void
		{
			BlResourceManager.instance().loaderManager.loadResource(_url, resType, OnBinaryData);
		}
		
		private function OnBinaryData(ba:ByteArray):void
		{
			_ba = ba;
			
			_loadEnd(ba != null);
		}
	}
}