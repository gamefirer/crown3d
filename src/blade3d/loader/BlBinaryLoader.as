/**
 *	binary原始数据加载器 
 */
package blade3d.loader
{
	import blade3d.resource.BlResourceManager;
	
	import flash.net.URLLoaderDataFormat;
	import flash.utils.ByteArray;

	public class BlBinaryLoader extends BlResourceLoader
	{
		public function BlBinaryLoader(manager:BlResourceLoaderManager)
		{
			super(manager);
			dataFormat = URLLoaderDataFormat.BINARY;
		}
		
		override public function get resType():int {return BlResourceManager.TYPE_BYTEARRAY;}
		
		override protected function callBack(error:int):void
		{
			var ba:ByteArray;
			if(error != 0)
				ba = null;
			else
				ba = data as ByteArray;
			
			// callback
			for(var i:int = 0; i < _callBacks.length; i++)
			{
				_callBacks[i](ba);
			}
			
			reset();
		}
	}
}