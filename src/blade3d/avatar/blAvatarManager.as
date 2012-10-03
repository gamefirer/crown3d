/**
 *	Avatar系统的管理类
 *  维护各种族的AvatarStore 
 */
package blade3d.avatar
{
	import away3d.core.managers.Stage3DProxy;
	import away3d.debug.Debug;
	import away3d.entities.Mesh;
	
	import blade3d.BlManager;
	import blade3d.resource.BlResource;
	import blade3d.resource.BlResourceConfig;
	import blade3d.resource.BlResourceManager;
	import blade3d.resource.BlStringResource;
	
	import flash.net.drm.AddToDeviceGroupSetting;
	import flash.utils.Dictionary;
	
	public class blAvatarManager extends BlManager
	{
		private static var _instance : blAvatarManager;
		private var _defaultAvatarNames : Vector.<String>;
		
		private var _isInit : Boolean = false;
		private var _assetCount : int = 0;
		private var _assetNumber : int = 0;
		
		private var _avatarNames : Vector.<String> = new Vector.<String>;	// 所有avatar的name
		private var _AvatarStoreMap : Dictionary = new Dictionary;		// AvatarStore列表
		// 异步加载
		public static var AsycLoading : Boolean = false;		// 是否异步加载Avatar
		private var _unLoadAvatarNames : Vector.<String> = new Vector.<String>;
		private var _asycLoadAvatarNames : Vector.<String> = new Vector.<String>;
		
		
		public function get avatarNames() : Vector.<String> {return _avatarNames;}
		
		public static function instance() : blAvatarManager {
			if(!_instance)
				_instance = new blAvatarManager(); 
			
			return _instance;
		}
		
		public function blAvatarManager()
		{
			// 初始化时，必须加载的Avatar
//			_defaultAvatarNames = new < String > ["default",
//												"zhanshi1",
//												"zhanshi0", 
//												"fashi1", 
//												"fashi0", 
//												"mushi1", 
//												"mushi0"
//			];
		}
		
		public function init(callBack:Function):Boolean
		{
			_initCallBack = callBack;
			
			// 读取角色配置
			var sceneDesc : BlStringResource = BlResourceManager.instance().findStringResource(BlResourceConfig.avatar_dir + "avatar.txt");
			sceneDesc.asycLoad(onAvatarDescribe);
			return true;
		}
		
		private function onAvatarDescribe(res:BlResource):void
		{	// 加载Avatar列表
			var strArray : Array = BlStringResource(res).str.split(/\s/);
			var filterStrArray : Array = strArray.filter(function(element:*, index:int, arr:Array):Boolean {
				return (element.length != 0 && element.charAt(0) != '#'); });
			
			var avatarName : String;
			var fileName : String;
			for(var i:int=0; i<filterStrArray.length; i++)
			{
				avatarName = filterStrArray[i];
				
				_avatarNames.push(avatarName);
				
				_AvatarStoreMap[avatarName] = new blAvatarStore(avatarName);;
			}
			
			_initCallBack(this);
		}
		
		public function getFreeAvatarCount() : int
		{
			var freeCount : int =0;
			for each(var store:blAvatarStore in _AvatarStoreMap)
			{
				freeCount += store.getPoolCount();
			}
			return freeCount;
		}
		
		
		private function incAssetCount() : void
		{
			_assetCount++; _assetNumber++;			
		}
		
		public function getAvatarStoreMap() : Dictionary {return _AvatarStoreMap;}

		public function isAvatarExist(avatarName:String) : Boolean
		{
			for(var i:int = 0; i<_avatarNames.length; i++)
			{
				if(_avatarNames[i] == avatarName)
					return true;
			}
			return false;
		}
		
		// 创建某avatar的一个mesh
		public function createAvatarMesh(avatarName : String) : blAvatarMesh 
		{
			if(!isAvatarExist(avatarName))
			{
				Debug.assert(false, avatarName + " not exist");
				return null;
			}
			
			return _AvatarStoreMap[avatarName].createAvatarMesh();
		}
		/*
		public function initLoad():void
		{
			if(_isInit)
			{
				onInitEnd();
				return;
			}
				
			incAssetCount();
			loadAvatarConfig();		// 载入Avatar
			
			onAssetLoaded();
		}
		
		private function loadAvatarConfig() : void
		{
			// 读取Avatar的配置文件
			incAssetCount();
			blAssetsLoader.getStringFromURL(blStrings.ASSETS_AVATAR_URL + "character.txt", 0, onAvatarConfigDone);
		
		}
		
		private function onAvatarConfigDone(tag : int, avatar_str : String) : void 
		{
			// 加载所有Avatar文件
			var strArray : Array = avatar_str.split(/\s/);
			var filterStrArray : Array = strArray.filter(function(element:*, index:int, arr:Array):Boolean {
				return (element.length != 0 && element.charAt(0) != '#'); });
			
			var avatarName : String;
			var fileName : String;
			for(var i:int=0; i<filterStrArray.length; i++)
			{
				avatarName = filterStrArray[i];
				fileName = blStrings.ASSETS_AVATAR_URL + avatarName + "/avatar" + blStrings.FILE_TYPE_AVATAR;
				
				if(AsycLoading && _defaultAvatarNames.indexOf(avatarName) == -1)
				{
					_unLoadAvatarNames.push(avatarName);
				}
				else
				{
					incAssetCount();
					var avatarLoader : blAvatarLoader = new blAvatarLoader(fileName, avatarName);
					avatarLoader.startParse(null, onAvatarParseDone);
//					Debug.bltrace("parse avatar "+avatarName);
				}
			}
			
			onAssetLoaded();
		}
		
		private function onAvatarParseDone(avatarStore : blAvatarStore) : void
		{	// avatar载入完毕
			_AvatarStoreMap[avatarStore.name] = avatarStore;
			onAssetLoaded();
		}
		
		private function onAvatarLoaded(avatarStore : blAvatarStore) : void {
			onAssetLoaded();
		}
		
		private function onAssetLoaded() : void {
			_assetCount--;
			
			blLoadProceer.getInstance().setAvatarLoadProgress(_assetNumber>2 ? Number(_assetNumber-_assetCount)/_assetNumber : 0);
			
			if(_assetCount == 0)	// 所有资源加载完毕
			{
				for each(var key:Object in _AvatarStoreMap)		// Debug.bltrace
				{
//					Debug.bltrace( "load avatar "+blAvatarStore(key).name );
				}
				onInitEnd();
			}
		}
		
		private function onInitEnd() : void
		{
			_isInit = true;
			_gameState.onManagerLoaded(this);
		}
		
		private function startAsycLoading() : void
		{
			if(!AsycLoading)
				return;
			
			var asycLoadAvatarName : String;
			if(_asycLoadAvatarNames.length > 0)
			{	// 异步加载一个Avatar
				asycLoadAvatarName = _asycLoadAvatarNames.pop();
				asycLoadOne(asycLoadAvatarName);
			}
			else
			{	// 异步加载完毕
//				Debug.bltrace("asyc Avatar Loading End!");
			}
		}
		
		private function asycLoadOne(avatarName:String) : void
		{
			var fileName:String = blStrings.ASSETS_AVATAR_URL + avatarName + "/avatar" + blStrings.FILE_TYPE_AVATAR;
			
			var avatarLoader : blAvatarLoader = new blAvatarLoader(fileName, avatarName);
			avatarLoader.startParse(null, onAsycAvatarParseDone);
//			Debug.bltrace("asyc parse avatar "+avatarName);
		}
		
		private function onAsycAvatarParseDone(avatarStore : blAvatarStore) : void
		{	// avatar载入完毕
			_AvatarStoreMap[avatarStore.name] = avatarStore;
//			Debug.bltrace("asyc parse avatar "+avatarStore.name + " End!");
			
			dispatchEvent(new blAvatarEvent(avatarStore.name));		// 异步加载avatar事件
			
			startAsycLoading();
		}
		
		private function reqAsycAvatar(avatarName : String) : void
		{
			var index : int = _unLoadAvatarNames.indexOf(avatarName);
			if(index < 0)
				return;
			
			_unLoadAvatarNames.splice(index, 1);
			_asycLoadAvatarNames.push(avatarName);
			return;
		}
		
		public function render(curTime : uint, deltaTime : uint):void
		{
			// 异步加载处理
			if(_isInit && _asycLoadAvatarNames.length > 0)
			{
				startAsycLoading();
			}
		}
		*/
		public function reduceCache() : void
		{
			for each(var store:blAvatarStore in _AvatarStoreMap)
			{
				if(store.getPoolCount()<10)
					store.freeMeshPool(1);
				else if(store.getPoolCount()<20)
					store.freeMeshPool(5);
				else if(store.getPoolCount()<50)
					store.freeMeshPool(20);
				else
					store.freeMeshPool(50);
			}
		}
		
	}
}