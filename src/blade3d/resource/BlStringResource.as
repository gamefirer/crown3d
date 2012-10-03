/**
 *	字符串数据 
 */
package blade3d.resource
{
	public class BlStringResource extends BlResource
	{
		override public function get resType() : int {return BlResourceManager.TYPE_STRING;}
		
		private var _str : String;
		
		public function BlStringResource(url:String)
		{
			super(url);
		}
		
		public function get str() : String {return _str;}
		public function set str(v:String) : void {_str = v;}
		override public function get res() : * {return _str;}
		
		override protected function _loadImp():void
		{
			BlResourceManager.instance().loaderManager.loadResource(_url, resType, OnStringData);
		}
		
		private function OnStringData(str:String):void
		{
			_str = str;
			
			_loadEnd(str != null);
		}
	}
}