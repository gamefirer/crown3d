/**
 *	场景 
 */
package blade3d.scene
{
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.Scene3D;
	import away3d.entities.EditHelper;
	import away3d.entities.Mesh;
	import away3d.entities.Sprite3D;
	
	import blade3d.BlConfiguration;
	import blade3d.avatar.blAvatarMesh;
	import blade3d.effect.BlEffect;
	import blade3d.physics.blPhysics;
	
	import flash.geom.Vector3D;

	public class BlScene extends Scene3D
	{
		static public var LOAD_DISPOSE : int = -1;
		static public var LOAD_NONE : int = 0;
		static public var LOAD_PARSING : int = 1;
		static public var LOAD_LOADING : int = 2;
		static public var LOAD_LOADED : int = 3;
		
		
		private var _loadState : int = LOAD_NONE;			// 加载状态
		
		private var _sceneParser : BlSceneParser = null;
		private var _sceneLoader : BlSceneLoader = null;
		private var _sceneSaver : BlSceneSaver = null;
		
		public var name : String;
		
		private var _physics : blPhysics;			// 该场景的物理空间
		
		private var _sceneNode : ObjectContainer3D;			// 场景加载物绑定于此
		private var _characterNode : ObjectContainer3D;		// 角色绑定于此
		private var _editorNode : ObjectContainer3D;			// 编辑器用物体绑定于此
		private var _otherNode : ObjectContainer3D;
		
		
		public function BlScene(name:String)
		{
			super();
			this.name = name;
			_sceneGraphRoot.name = name;
			
			_sceneNode = new ObjectContainer3D;
			_sceneNode.name = "scene_node";
			_sceneGraphRoot.addChild(_sceneNode);
			
			_characterNode = new ObjectContainer3D;
			_characterNode.name = "character_node";
			_sceneGraphRoot.addChild(_characterNode);
			
			_otherNode = new ObjectContainer3D;
			_otherNode.name = "other_node";
			_sceneGraphRoot.addChild(_otherNode);
			
			_editorNode = new ObjectContainer3D;
			_editorNode.name = "editor_node";
			_sceneGraphRoot.addChild(_editorNode);
			
			
			_physics = new blPhysics(this);		// 创建该场景的物理空间
			
			parseScene();
		}
		
		public function get rootNode() : ObjectContainer3D {return _sceneGraphRoot;}
		public function get sceneNode() : ObjectContainer3D {return _sceneNode;}
		public function get physics() : blPhysics {return _physics;}
		public function get loader() : BlSceneLoader {return _sceneLoader;}
		
		public function dispose():void
		{
			_loadState = LOAD_DISPOSE;
			if(_sceneLoader)
				_sceneLoader.stopLoad();
			
			// 释放场景物体
			_sceneGraphRoot.dispose();
			
			if(_sceneLoader)
				_sceneLoader.dispose();
		}
		
		public function parseScene():void
		{
			if(_loadState == LOAD_DISPOSE)
				return;
			BlSceneManager.instance().dispatchEvent(new BlSceneEvent(BlSceneEvent.SCENE_LOAD_START, this));
			// 开始解析
			_loadState = LOAD_PARSING;
			_sceneParser = new BlSceneParser(this);
			_sceneParser.parse(onParseEnd);
		}
		
		private function onParseEnd():void
		{
			if(_loadState == LOAD_DISPOSE)
				return;
			// 解析完毕，开始加载
			_loadState = LOAD_LOADING;
			_sceneLoader = new BlSceneLoader(this, _sceneParser);
			_sceneLoader.load(onLoadEnd);
			
		}
		
		private function onLoadEnd():void
		{
			if(_loadState == LOAD_DISPOSE)
				return;
			
			_loadState = LOAD_LOADED;
			BlSceneManager.instance().dispatchEvent(new BlSceneEvent(BlSceneEvent.SCENE_LOAD_END, this));
		}
	
		public function saveScene():void
		{
			if(!_sceneParser.xml) return;
			
			_sceneSaver ||= new BlSceneSaver(this);
			_sceneSaver.processOldXml(_sceneParser.xml);
			_sceneSaver.saveToFile();
		}
		
		public function addCharacter(character:blAvatarMesh):void
		{
			_characterNode.addChild(character);
		}
		
		public function addObject(obj:ObjectContainer3D):void
		{
			_otherNode.addChild(obj);
		}
		
		public function addEditor(obj:ObjectContainer3D):void
		{
			_editorNode.addChild(obj);
		}
		// 为某物体添加编辑辅助器
		public function addHelperFor(obj:ObjectContainer3D):void
		{
			if(!BlConfiguration.editorMode)		// 只在编辑模式有效
				 return;
			
			if(obj is Sprite3D || obj is BlEffect)
			{
				var helper : EditHelper = new EditHelper(obj);
				_editorNode.addChild(helper);
			}
		}
		
		// 获得某个位置的地形高度
		public function getTerrainHeight(x : Number, y : Number) : Number
		{
			//Profiler.start("GetTerrainHeight");
			var res : Number = 0;
			res = _sceneLoader.getTerrainHeight(x, y);
			
			//Profiler.end();
			return res + 5;		// 抬高5,以免角色的脚埋入地下
			
		}
		
		// 通过屏幕上一点,获得对应地形上的位置
		public function getTerrainPosByScreenPoint(x : Number, y : Number) : Vector3D
		{
			if(!_sceneLoader)
				return null;
			return _sceneLoader.getTerrainPosByScreenPoint(x, y);
		}
		
		public function getTerrainPosByScreenPointNoNull(x : Number, y : Number) : Vector3D
		{
			if(!_sceneLoader)
				return new Vector3D();
			return _sceneLoader.getTerrainPosByScreenPointNoNull(x, y);
		}
	}
}