package blade3d.editor
{
	import away3d.core.managers.Context3DProxy;
	import away3d.debug.Debug;
	
	import blade3d.BlConfiguration;
	import blade3d.BlEngine;
	import blade3d.BlManager;
	import blade3d.profiler.Profiler;
	import blade3d.resource.BlResource;
	import blade3d.resource.BlResourceManager;
	import blade3d.utils.BlEditorUtils;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import org.aswing.AsWingConstants;
	import org.aswing.AsWingManager;
	import org.aswing.Container;
	import org.aswing.FlowLayout;
	import org.aswing.Insets;
	import org.aswing.JCheckBox;
	import org.aswing.JFrame;
	import org.aswing.JPanel;
	import org.aswing.JToggleButton;
	import org.aswing.JToolBar;
	import org.aswing.JWindow;
	import org.aswing.border.EmptyBorder;
	import org.aswing.event.FrameEvent;
	import org.aswing.event.InteractiveEvent;

	public class BlEditorManager extends BlManager
	{
		static private var _instance : BlEditorManager;
		
		private var _mustResCount : int;
		
		private var _rootSprite : Sprite;
		public var _resourceEditor : BlResourceEditor;			// 资源界面
		public var _sceneEditor : BlSceneEditor;				// 场景界面
		public var _avatarEditor : BlAvatarEditor;				// avatar界面
		public var _postProcessEditor : BlPostProcessEditor;	// 后期界面
		public var _cameraEditor : BlCameraEditor;				// 摄像机界面
		public var _uiEditor : BlUIEditor;						// 3d ui 界面
		public var _effectEditor : BlEffectEditor;				// 特效编辑界面
		public var _logEditor : BlLogEditor;					// log编辑界面
		
		//bar
		private var _toolbarWindow:JWindow;
		private var _bars:JToolBar;
		private var _resourceBtn:JToggleButton;
		private var _sceneBtn:JToggleButton;
		private var _avatarBtn:JToggleButton;
		private var _postProcessBtn:JToggleButton;
		private var _cameraBtn:JToggleButton;
		private var _uiBtn:JToggleButton;
		private var _effectBtn:JToggleButton;
		private var _logBtn:JToggleButton;
		
		
		public function BlEditorManager()
		{
			if(_instance)
				Debug.error("BlResourceManager error");
		}
		
		static public function instance() : BlEditorManager
		{
			if(!_instance)
				_instance = new BlEditorManager;
			return _instance;
		}
		
		public function rootSprite() : Sprite {return _rootSprite;}
		
		public function showResourceEditor(visible:Boolean):void {if(_resourceEditor) _resourceEditor.visible = visible;}
		public function showSceneEditor(visible:Boolean):void {if(_sceneEditor) _sceneEditor.visible = visible;}
		public function showAvatarEditor(visible:Boolean):void {if(_avatarEditor) _avatarEditor.visible = visible;}
		public function showEffectEditor(visible:Boolean):void {if(_effectEditor) _effectEditor.visible = visible;}
		
		public function init(rootSprite:Sprite, callBack:Function):Boolean
		{
			_rootSprite = rootSprite;
			_initCallBack = callBack;
			
			if(BlConfiguration.editorMode)
			{
				AsWingManager.setRoot(rootSprite);
				
				// 创建资源管理编辑界面
				_resourceEditor = new BlResourceEditor(_rootSprite, "资源");
				_resourceEditor.addEventListener(FrameEvent.FRAME_CLOSING ,onEditorClose);
				_resourceEditor.visible = false;
				
				// 创建场景管理界面
				_sceneEditor = new BlSceneEditor(_rootSprite, "场景");
				_sceneEditor.addEventListener(FrameEvent.FRAME_CLOSING ,onEditorClose);
				_sceneEditor.visible = false;
				
				// 创建Avatar管理界面
				_avatarEditor = new BlAvatarEditor(_rootSprite, "角色");
				_avatarEditor.addEventListener(FrameEvent.FRAME_CLOSING ,onEditorClose);
				_avatarEditor.visible = false;
				
				// 后期特效管理界面
				_postProcessEditor = new BlPostProcessEditor(_rootSprite, "后期");
				_postProcessEditor.addEventListener(FrameEvent.FRAME_CLOSING ,onEditorClose);
				_postProcessEditor.visible = false;
				
				// 摄像机管理界面
				_cameraEditor = new BlCameraEditor(_rootSprite, "摄像机");
				_cameraEditor.addEventListener(FrameEvent.FRAME_CLOSING ,onEditorClose);
				_cameraEditor.visible = false;
				
				// 3d ui 界面
				_uiEditor = new BlUIEditor(_rootSprite, "UI");
				_uiEditor.addEventListener(FrameEvent.FRAME_CLOSING ,onEditorClose);
				_uiEditor.visible = false;
				
				// 特效编辑界面
				_effectEditor = new BlEffectEditor(_rootSprite, "特效");
				_effectEditor.addEventListener(FrameEvent.FRAME_CLOSING ,onEditorClose);
				_effectEditor.visible = false;
				
				// log编辑界面				
				_logEditor = new BlLogEditor(_rootSprite, "日志");
				_logEditor.addEventListener(FrameEvent.FRAME_CLOSING ,onEditorClose);
				_logEditor.visible = false;
				
				addToolBar()
				
				_rootSprite.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);		// stage可以接受全局, sprite则必须有焦点
				
			}
			
			// 加载必要资源
			_mustResCount = 1;
			
			var mustRes:BlResource;
			for each(var mustUrl:String in BlEditorUtils.editMustRes)
			{
				_mustResCount++;
				mustRes = BlResourceManager.instance().findResource(mustUrl);
				mustRes.asycLoad(onMustRes);
			}
			
			onMustRes(null);
			
			return true;
		}
		
		private function onMustRes(res:BlResource):void
		{
			_mustResCount--;
			if(_mustResCount == 0)
				_initCallBack(this);
		}

		
		private function addToolBar():void
		{
			_toolbarWindow = new JWindow(_rootSprite);
			var container:Container = _toolbarWindow.getContentPane();
			
			_bars = new JToolBar(AsWingConstants.HORIZONTAL,0);
			_bars.setLayout( new FlowLayout(AsWingConstants.CENTER,5,2));
			_resourceBtn = new JToggleButton("资源");
			_resourceBtn.addEventListener(InteractiveEvent.SELECTION_CHANGED , onEditorChanged);
			
			_sceneBtn = new JToggleButton("场景");
			_sceneBtn.addEventListener(InteractiveEvent.SELECTION_CHANGED,onEditorChanged);
			
			_avatarBtn = new JToggleButton("角色");
			_avatarBtn.addEventListener(InteractiveEvent.SELECTION_CHANGED,onEditorChanged);
			
			_postProcessBtn = new JToggleButton("后期");
			_postProcessBtn.addEventListener(InteractiveEvent.SELECTION_CHANGED,onEditorChanged);
			
			_cameraBtn = new JToggleButton("摄像机");
			_cameraBtn.addEventListener(InteractiveEvent.SELECTION_CHANGED,onEditorChanged);
			
			_uiBtn = new JToggleButton("UI");
			_uiBtn.addEventListener(InteractiveEvent.SELECTION_CHANGED,onEditorChanged);
			
			_effectBtn = new JToggleButton("特效");
			_effectBtn.addEventListener(InteractiveEvent.SELECTION_CHANGED,onEditorChanged);
			
			_logBtn = new JToggleButton("日志");
			_logBtn.addEventListener(InteractiveEvent.SELECTION_CHANGED,onEditorChanged);
			
			_bars.appendAll(_resourceBtn,_sceneBtn,_avatarBtn,_postProcessBtn,_cameraBtn,_uiBtn,_effectBtn,_logBtn);
			
			container.append(_bars);
			
			_toolbarWindow.setSizeWH(340, 30);
			_toolbarWindow.x = _rootSprite.stage.stageWidth - 340 ;
			_toolbarWindow.y = _rootSprite.stage.stageHeight - 30;
			_toolbarWindow.show();
			
		}		
		
		private function onEditorClose(event:FrameEvent):void
		{
			switch(event.currentTarget)
			{
				case _resourceEditor:
				{
					_resourceBtn.setSelected(false);
					break;
				}
				case _sceneEditor:
				{
					_sceneBtn.setSelected(false);
					break;
				}
				case _avatarEditor:
				{
					_avatarBtn.setSelected(false);
				}
				case _postProcessEditor:
				{
					_postProcessBtn.setSelected(false);
					break;
				}
				case _cameraEditor:
				{
					_cameraBtn.setSelected(false);
					break;
				}
				case _uiEditor:
				{
					_uiBtn.setSelected(false);
					break;
				}
				case _effectEditor:
				{
					_effectBtn.setSelected(false);
					break;
				}
				case _logEditor:
				{
					_logBtn.setSelected(false);
					break;
				}	
				default:
				{
					break;
				}
			}
				
			
		}		
		private function onEditorChanged(event:InteractiveEvent):void
		{
			switch(event.currentTarget)
			{
				case _resourceBtn:
				{
					if(_resourceEditor)
						_resourceEditor.visible = _resourceBtn.isSelected();
					break;
				}
				case _sceneBtn:
				{
					if(_sceneEditor)
						_sceneEditor.visible = _sceneBtn.isSelected();
					break;
				}
				case _avatarBtn:
				{
					if(_avatarEditor)
						_avatarEditor.visible = _avatarBtn.isSelected();
					break;
				}
				case _postProcessBtn:
				{
					if(_postProcessEditor)
						_postProcessEditor.visible = _postProcessBtn.isSelected();
					break;
				}
				case _cameraBtn:
				{
					if(_cameraEditor)
						_cameraEditor.visible = _cameraBtn.isSelected();
					break;
				}
				case _uiBtn:
				{
					if(_uiEditor)
						_uiEditor.visible = _uiBtn.isSelected();
					break;
				}
				case _effectBtn:
				{
					if(_effectEditor)
						_effectEditor.visible = _effectBtn.isSelected();
					break;
				}
				case _logBtn:
				{
					if(_logEditor)
						_logEditor.visible = _logBtn.isSelected();
					break;
				}
				default:
				{
					break;
				}
			}
			

		}
		
		private function onKeyDown(event:KeyboardEvent):void
		{
			if(event.ctrlKey || event.altKey || event.shiftKey)
			{
				if(event.keyCode == Keyboard.NUMBER_1)
				{
					if(_resourceEditor)
						_resourceEditor.visible = !_resourceEditor.visible;
				}
				else if(event.keyCode == Keyboard.NUMBER_2)
				{
					if(_sceneEditor)
						_sceneEditor.visible = !_sceneEditor.visible;
				}
				else if(event.keyCode == Keyboard.NUMBER_3)
				{
					if(_avatarEditor)
						_avatarEditor.visible = !_avatarEditor.visible;
				}
				else if(event.keyCode == Keyboard.NUMBER_4)
				{
					if(_postProcessEditor)
						_postProcessEditor.visible = !_postProcessEditor.visible;
				}
				else if(event.keyCode == Keyboard.NUMBER_5)
				{
					if(_cameraEditor)
						_cameraEditor.visible = !_cameraEditor.visible;
				}
				else if(event.keyCode == Keyboard.NUMBER_6)
				{
					if(_uiEditor)
						_uiEditor.visible = !_uiEditor.visible;
				}
				else if(event.keyCode == Keyboard.NUMBER_7)
				{
					if(_effectEditor)
						_effectEditor.visible = !_effectEditor.visible;
				}
				else if(event.keyCode == Keyboard.NUMBER_0)
				{
					if(_logEditor)
						_logEditor.visible = !_logEditor.visible;
				}
				
				
			}
			else if(event.keyCode == Keyboard.Z)
			{
				Debug.log("z");
				BlEngine.showProfile(!Profiler.isProfiler);
			}
		}
		
		public function onResize(w : uint ,h : uint) : void
		{
			if(_toolbarWindow)
			{
				_toolbarWindow.x = w - 340 ;
				_toolbarWindow.y = h - 30;
			}
		}
	}
}