/**
 *	模型文件加载器 
 */
package blade3d.loader
{
	import away3d.core.base.Geometry;
	
	import blade3d.resource.BlResourceManager;
	
	import flash.net.URLLoaderDataFormat;
	import flash.utils.ByteArray;

	public class BlModelLoader extends BlResourceLoader
	{
		public function BlModelLoader(manager:BlResourceLoaderManager)
		{
			super(manager);
			dataFormat = URLLoaderDataFormat.BINARY;
		}
		
		override public function get resType():int {return BlResourceManager.TYPE_MESH;}
		
		override protected function callBack(error:int):void
		{
			if(error != 0)
			{
				// callback null
				for(var ei:int = 0; ei < _callBacks.length; ei++)
				{
					_callBacks[ei](null);
				}
				
				reset();
				return;
			}
			
			// 解析模型数据
			var ba:ByteArray = data as ByteArray;
		
			var parser : Bl3DSParser = new Bl3DSParser(onGeometry);
			parser.parseAsync(ba, 30);
		}
		
		private function onGeometry(geo:Geometry, texUrls:Vector.<String>):void
		{
			// callback
			for(var i:int = 0; i < _callBacks.length; i++)
			{
				_callBacks[i](geo, texUrls);
			}
			
			reset();
		}
	}
}