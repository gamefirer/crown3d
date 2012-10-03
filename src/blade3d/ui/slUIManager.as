/**
 *	3DUI管理器 
 */
package blade3d.ui
{
	import away3d.containers.View3D;
	import away3d.core.managers.Context3DProxy;
	import away3d.core.managers.Stage3DManager;
	import away3d.debug.Debug;
	import away3d.events.Stage3DEvent;
	
	import blade3d.BlManager;
	import blade3d.profiler.Profiler;
	
	import sl2d.slGlobal;
	import sl2d.slWorld;
	
	public class slUIManager extends BlManager
	{
		static private var _instance : slUIManager;
		
		private var _view3D : View3D;
		
		public function slUIManager()
		{
			if(_instance)
				Debug.error("slUIManager error");
		}
		
		static public function instance() : slUIManager
		{
			if(!_instance)
				_instance = new slUIManager();
			return _instance;
		}
		
		public function get frame() : slUIFrame {return slUIFrame(slGlobal.View);}
		
		public function init(view:View3D, callBack:Function):Boolean
		{
			_view3D  = view;
			_initCallBack = callBack;
			
			// 创建3D ui
			if(Stage3DManager.getInstance(_view3D.stage).getStage3DProxy(0).context3D)
				createSlWorld();
			Context3DProxy.stage3DProxy.addEventListener(Stage3DEvent.CONTEXT3D_CREATED, onContextUpdate);
			
			_initCallBack(this);
			return true;
		}
		
		private function createSlWorld():void
		{
			// 创建slWorld
			slGlobal.World = new slWorld(slUIFrame);
			slGlobal.World.setWorldContent(Context3DProxy.stage3DProxy, Context3DProxy.context3D, _view3D.stage);
			// resize
			slGlobal.ViewPortWidth = _view3D.width;
			slGlobal.ViewPortHeight = _view3D.height;
			slGlobal.World.resizeWorld();
		}
		
		private function onContextUpdate(event : Stage3DEvent) : void
		{
			if(slGlobal.isInit)
				slGlobal.World.resetContext(Context3DProxy.context3D);
			else
				createSlWorld();
		}
		
		public function onResize(w : uint ,h : uint) : void
		{
			slGlobal.ViewPortWidth = w;
			slGlobal.ViewPortHeight = h;
			if(slGlobal.World)
			{
				slGlobal.World.resizeWorld();
			}
		}
		
		public function render(time:uint, deltaTime:uint):void
		{
			Profiler.start("updateUI");
			slGlobal.World.update(time, deltaTime);		// 渲染游戏内UI
			Profiler.end("updateUI");
		}
	}
}