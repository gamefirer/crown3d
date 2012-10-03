package blade3d.scene
{
	import away3d.containers.View3D;
	import away3d.debug.Debug;
	import away3d.debug.Trident;
	import away3d.entities.Mesh;
	import away3d.lights.DirectionalLight;
	import away3d.lights.shadowmaps.NearDirectionalShadowMapper;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.primitives.PlaneGeometry;
	import away3d.primitives.WireframePlane;
	
	import blade3d.BlManager;
	import blade3d.profiler.Profiler;
	import blade3d.resource.BlResource;
	import blade3d.resource.BlResourceConfig;
	import blade3d.resource.BlResourceManager;
	import blade3d.resource.BlStringResource;
	
	import flash.utils.Dictionary;

	public class BlSceneManager extends BlManager
	{
		static private var _instance : BlSceneManager;
		
		private var _view3D : View3D;
		
		private var _sceneNames : Vector.<String> = new Vector.<String>;
		private var _sceneMap : Dictionary = new Dictionary;
		private var _testScene : BlScene;
		public var testTrident : Trident;
		private var _currentScene : BlScene = null;
		
		// 太阳光
		private var _whiteLight : DirectionalLight;		
		private var _lightPicker : StaticLightPicker;
		// 贴图灯 
		private var _texLight : DirectionalLight;
		
		public function BlSceneManager() : void
		{
			if(_instance)
				Debug.error("BlSceneManager error");
		}
		
		static public function instance() : BlSceneManager
		{
			if(!_instance)
				_instance = new BlSceneManager();
			return _instance;
		}
		
		public function get sceneNames() : Vector.<String> {return _sceneNames;}
		public function set currentScene(scene:BlScene):void
		{
			if(_currentScene == scene) return;
			if(_currentScene)
			{
				_currentScene.removeChild(_whiteLight);
				_currentScene.removeChild(_texLight);
			}
			
			_currentScene = scene;
			if(_currentScene)
			{
				_currentScene.addChild(_whiteLight);
				_currentScene.addChild(_texLight);
			}
			
			_view3D.scene = _currentScene ? _currentScene : _testScene;
		}
		public function get currentScene():BlScene {return _currentScene;}
		public function get texLight():DirectionalLight {return _texLight;}
		public function get whiteLight():DirectionalLight {return _whiteLight;}
		public function get lightPicker():StaticLightPicker {return _lightPicker;}
		
		public function init(view:View3D, callBack:Function):Boolean
		{
			_view3D  = view;
			_initCallBack = callBack;
			
			// 读取场景配置
			var sceneDesc : BlStringResource = BlResourceManager.instance().findStringResource(BlResourceConfig.scene_dir + "scene.txt");
			if(!sceneDesc.isLoaded)
				sceneDesc.asycLoad(onSceneDescribe);
					
			
			return true;
		}
		
		private function onSceneDescribe(res:BlResource):void
		{
			// 加载场景列表
			var strArray : Array = BlStringResource(res).str.split(/\s/);
			var filterStrArray : Array = strArray.filter(function(element:*, index:int, arr:Array):Boolean {
				return (element.length != 0 && element.charAt(0) != '#'); });
			
			var sceneName : String;
			var fileName : String;
			for(var i:int=0; i<filterStrArray.length; i++)
			{
				sceneName = filterStrArray[i];
				
				_sceneNames.push(sceneName);
			}
			
			// 创建太阳光灯
			createSceneLight();
			// 创建初始场景
			createTestScene();
			
			_initCallBack(this);
		}
		// 创建默认的灯
		private function createSceneLight():void
		{
			// 太阳灯
			_whiteLight = new DirectionalLight(-10, -20, 10);
			_whiteLight.name = "sunlight";
			_whiteLight.color = 0x909090;
			_whiteLight.castsShadows = true;
			_whiteLight.ambient = 1;
			_whiteLight.ambientColor = 0xa0a0a0;
			_whiteLight.shadowMapper = new NearDirectionalShadowMapper(.2);
			
			_lightPicker = new StaticLightPicker([whiteLight]);
			// 贴图灯
			_texLight = new DirectionalLight(0, -200, 1);
			_texLight.y = 1000;
			_texLight.name = "texlight";
			_texLight.castsLightMap = true;
			
		}
		// 创建默认的测试场景
		private function createTestScene():void
		{
			_testScene = new BlScene("test");;
			currentScene = _testScene;
			_sceneNames.push("test");
		}
		
		public function showScene(name:String):void
		{
			// 该场景不存在
			if(!IsExistScene(name))
			{
				Debug.log("scene "+name+" is no exist");
				return;
			}
			
			if(currentScene && currentScene.name == name)
				return;
			
			// 关闭当前场景
			if(currentScene)
			{
				dispatchEvent(new BlSceneEvent(BlSceneEvent.SCENE_LEAVE, currentScene));
				destoryScene(currentScene);		// 销毁前一个场景
			}
			
			// 打开新场景
			if(_sceneMap[name] == null)
			{
				_sceneMap[name] = new BlScene(name);
			}
			
			// 进入新场景
			currentScene = _sceneMap[name];
			
			dispatchEvent(new BlSceneEvent(BlSceneEvent.SCENE_ENTER, currentScene));
			
		}
		
		public function IsExistScene(name:String):Boolean
		{
			for(var i:int=0; i<_sceneNames.length; i++)
			{
				if(_sceneNames[i] == name)
					return true;
			}
			return false;
		}
		
		private function destoryScene(scene : BlScene):void
		{
			dispatchEvent(new BlSceneEvent(BlSceneEvent.SCENE_DISPOSE, scene));
			
			if(currentScene == scene)
				currentScene = null;
			
			delete _sceneMap[scene.name];
			scene.dispose();
		}
		
		public function update(time:uint, deltaTime:uint):void
		{
			Profiler.start("update");
			if(currentScene)
				currentScene.update(time, deltaTime);
			Profiler.end("update");
		}
		
	}
}