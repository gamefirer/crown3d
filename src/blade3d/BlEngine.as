/**
 *	引擎 
 */
package blade3d
{
	import away3d.containers.View3D;
	import away3d.core.managers.Context3DProxy;
	import away3d.debug.AwayStats;
	import away3d.debug.Debug;
	import away3d.debug.PartitionStats;
	
	import blade3d.avatar.blAvatarManager;
	import blade3d.camera.BlCameraManager;
	import blade3d.editor.BlEditorManager;
	import blade3d.effect.BlEffectManager;
	import blade3d.io.BlInputManager;
	import blade3d.postprocess.BlPostProcessManager;
	import blade3d.profiler.InfoStats;
	import blade3d.profiler.Profiler;
	import blade3d.profiler.ProfilerStats;
	import blade3d.profiler.ViewStats;
	import blade3d.resource.BlResourceManager;
	import blade3d.scene.BlSceneManager;
	import blade3d.ui.slUIManager;
	import blade3d.viewer.BlViewerManager;
	
	import com.greensock.OverwriteManager;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.FocusEvent;

	public class BlEngine
	{
		static private var _sprite:Sprite; 
		static public var mainView:View3D;
		static private var _preInitCount:int = 0;
		static private var _initCount:int = 0;
		static private var _postInitCount:int = 0;
		static private var _initEndCallBack:Function;
		
		static private var _awayStats : AwayStats;
		static private var _infoStats : InfoStats;
		static private var _profilerStats : ProfilerStats;
		static private var _partitionStats : PartitionStats;
//		static private var _viewStats : ViewStats;
		
		static public function getStageWidth() : Number {return _sprite.stage.stageWidth;}
		static public function getStageHeight() : Number {return _sprite.stage.stageHeight;}
		
		public function BlEngine()
		{
		}
		
		static public function init(sprite:Sprite, initEndCallBack:Function=null):View3D
		{
			//    _sprite
			//   /      \
			// view3D   aswing
			_sprite = sprite;
			mainView = new View3D();
			_initEndCallBack = initEndCallBack;
			
			_sprite.stage.scaleMode = StageScaleMode.NO_SCALE ;
			_sprite.stage.align = StageAlign.TOP_LEFT;
			
			_sprite.stage.addEventListener(Event.RESIZE, onResize);
			
			onResize();
									
			__preInit();
			return mainView;
		}
		
		static private function __preInit():void
		{
			_preInitCount++;
			
			OverwriteManager.init(2);
			
			// 初始化资源管理器
			_preInitCount++;
			if(!BlResourceManager.instance().init(onPreInitManagerCallBack))
				Debug.error("BlResourceManager init failed");
			
			onPreInitManagerCallBack(null);
		}
		
		static private function __init():void
		{
			_initCount++;
			
			// 初始化输入管理器
			_initCount++;
			if(!BlInputManager.instance().init(mainView, onInitManagerCallBack))
				Debug.error("BlInputManager init failed");
			
			// 初始化摄像机管理器
			_initCount++;
			if(!BlCameraManager.instance().init(mainView, onInitManagerCallBack))
				Debug.error("BlCameraManager init failed");
			
			// 初始化场景管理器
			_initCount++;
			if(!BlSceneManager.instance().init(mainView, onInitManagerCallBack))
				Debug.error("BlSceneManager init failed");
			
			// 初始化Avatar管理器
			_initCount++;
			if(!blAvatarManager.instance().init(onInitManagerCallBack))
				Debug.error("blAvatarManager init failed");
			
			// 初始化特效管理器
			_initCount++;
			if(!BlEffectManager.instance().init(onInitManagerCallBack))
				Debug.error("BlEffectManager init failed");
			
			// 后期特效管理器
			_initCount++;
			if(!BlPostProcessManager.instance().init(mainView, onInitManagerCallBack))
				Debug.error("BlPostProcessManager init failed");
			
			// 3D视图管理器
			_initCount++;
			if(!BlViewerManager.instance().init(mainView, onInitManagerCallBack))
				Debug.error("BlViewerManager init failed");
			
			// 3DUI管理器
			_initCount++;
			if(!slUIManager.instance().init(mainView, onInitManagerCallBack))
				Debug.error("slUIManager init failed");
			
			
			// 性能分析
			_sprite.addChild(_awayStats = new AwayStats(mainView));
			_sprite.addChild(_partitionStats = new PartitionStats);
			_sprite.addChild(_infoStats = new InfoStats);
//			_sprite.addChild(_viewStats = new ViewStats);
			
			if(Profiler.isProfiler)
			{
				_profilerStats = new ProfilerStats();
				_profilerStats.y = 150;
				_sprite.addChild(_profilerStats);
			}
			
//			_profilerStats.addChild(testView = new View3D);
//			testView.x = 100;
//			testView.y = 100;
//			testView.width = mainView.width/2;
//			testView.height = mainView.height/2;
//			testView.backgroundAlpha = 0.2;
			
			onInitManagerCallBack(null);
		}
		
		static private function __postInit():void
		{
			_postInitCount++;
			
			// 初始化编辑管理器
			_postInitCount++;
			if(!BlEditorManager.instance().init(_sprite, onPostInitManagerCallBack))
				Debug.error("BlEditorManager init failed");
			
			onPostInitManagerCallBack(null);
		}
		
		static private function onPreInitManagerCallBack(manager:Object) : void
		{
			if(manager)
				Debug.log(manager+" init end");
			_preInitCount--;
			if(_preInitCount==0)
			{
				__init();
			}
		}
		
		static private function onInitManagerCallBack(manager:Object) : void
		{
			if(manager)
				Debug.log(manager+" init end");
			_initCount--;
			if(_initCount==0)
			{
				__postInit();
			}
		}
		
		static private function onPostInitManagerCallBack(manager:Object) : void
		{
			if(manager)
				Debug.log(manager+" init end");
			
			_postInitCount--;
			if(_postInitCount==0)
			{
				// 初始化完成回调
				_initEndCallBack();
				
				_sprite.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
		}
		
		static private function onEnterFrame(e:Event):void
		{
			render();
		}
		
		static private function render():void
		{
			Profiler.start("BlEngine.render");
			
			Context3DProxy.reset();
			
			var time : uint = mainView.time;
			var deltaTime : uint = mainView.deltaTime;
			
			BlCameraManager.instance().update(time, deltaTime);		// 摄像机
			
			BlEffectManager.instance().update(time, deltaTime);		// 特效
			
			BlSceneManager.instance().update(time, deltaTime);		// 场景更新
			
			BlViewerManager.instance().render(time, deltaTime);		// 3D视图渲染
			
			mainView.render();			// 3D场景渲染
			
//			_viewStats.render();
//			testView.render();

			slUIManager.instance().render(time, deltaTime);		// 3D ui的渲染
			
			Profiler.end("BlEngine.render");
			
			renderProfiler();
		}
		
		static private function renderProfiler():void
		{
			if(Profiler.isProfiler && ProfilerStats.instance)
			{
				ProfilerStats.instance.render(mainView.time, mainView.deltaTime);
				Profiler.nextFrame();
			}
		}
		
		static private function onResize(event:Event = null):void
		{
			mainView.width = _sprite.stage.stageWidth;
			mainView.height = _sprite.stage.stageHeight;
			
		
			
			// 3d ui resize
			slUIManager.instance().onResize(mainView.width, mainView.height);
			// editor ui resize
			BlEditorManager.instance().onResize(mainView.width, mainView.height);
		}
		
		static public function showProfile(visible:Boolean):void
		{
			if(visible)
			{
//				_awayStats.stop(false);
				_infoStats.stop(false);
				_partitionStats.stop(false);
				Profiler.isProfiler = true;
				
			}
			else
			{
//				_awayStats.stop(true);
				_infoStats.stop(true);
				_partitionStats.stop(true);
				Profiler.isProfiler = false;
			}
			
//			_awayStats.visible = visible;
			_infoStats.visible = visible;
			_partitionStats.visible = visible;
			_profilerStats.visible = visible;
			
		}
		
		
	}
}