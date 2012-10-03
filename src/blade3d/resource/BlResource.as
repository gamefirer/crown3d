/**
 *	资源对象基类 
 */
package blade3d.resource
{
	import away3d.errors.AbstractMethodError;

	public class BlResource
	{
		// 加载类型
		static public var LOAD_TYPE_DELAY : int = 0;		// 需要时再加载
		static public var LOAD_TYPE_AUTO : int = 1;		// 逐步自动再加载
		static public var LOAD_TYPE_MUST : int = 2;		// 必须加载好再卡似乎
		
		// 资源状态
		static public var LOAD_UNLOAD : int = 0;			// 未加载
		static public var LOAD_LOADING : int = 1;			// 加载中
		static public var LOAD_LOADED : int = 2;			// 已加载
		static public var LOAD_ERROR : int = 3;			// 加载失败
		
		protected var _url:String;			// 资源的url
		
		protected var loadState:int = LOAD_UNLOAD;		// 资源状态
		
		public var loadType:int;			// 加载类型
		
		private var _loadCallBack : Vector.<Function> = new Vector.<Function>;
		
		public var userObject : *;
		
		public function get resType() : int {return BlResourceManager.TYPE_NONE;}
		public function get url() : String {return _url;} 
		public function get isLoaded() : Boolean {return (loadState == LOAD_LOADED || loadState == LOAD_ERROR);}
		public function get res() : * {throw new AbstractMethodError();return null;}
		
		public function BlResource(url:String)
		{
			_url = url;
		}
		// 加载该资源
		public function load():void
		{
			if(loadState != LOAD_UNLOAD)
				return;
			
			loadState = LOAD_LOADING;
			
			_loadImp();		// 开始加载
		}
		
		// 加载资源并等待回调 callBack(res:BlResource)
		public function asycLoad(callBack:Function = null):void
		{
			if(isLoaded)
				callBack(this);
			else
			{
				_loadCallBack.push(callBack);
				load();
			}
		}
		
		protected function _loadImp():void
		{
			throw new AbstractMethodError();
		}
		
		protected function _loadEnd(success:Boolean):void
		{
			if(success)
				loadState = LOAD_LOADED;
			else
				loadState = LOAD_ERROR;
			BlResourceManager.instance().onResourceLoaded(this);
			
			for(var i:int=0; i<_loadCallBack.length; i++)
			{
				_loadCallBack[i](this);
			}
			_loadCallBack.length = 0;
		}
		
	
	}
}