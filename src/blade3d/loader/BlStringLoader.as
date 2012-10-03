/**
 *	字符串资源加载器 
 */
package blade3d.loader
{
	import blade3d.resource.BlResourceManager;
	
	import flash.net.URLLoaderDataFormat;

	public class BlStringLoader extends BlResourceLoader
	{
		public function BlStringLoader(manager:BlResourceLoaderManager)
		{
			super(manager);
			dataFormat = URLLoaderDataFormat.TEXT;
		}
		
		override public function get resType():int {return BlResourceManager.TYPE_STRING;}
		
		override protected function callBack(error:int):void
		{
			var str:String;
			if(error != 0)
				str = null;
			else
				str = data as String;
			
			// callback
			for(var i:int = 0; i < _callBacks.length; i++)
			{
				_callBacks[i](str);
			}
			
			reset();
		}
	}
}