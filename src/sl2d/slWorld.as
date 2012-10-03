package sl2d
{
	
	import away3d.core.managers.Stage3DProxy;
	import away3d.debug.Debug;
	
	import blade3d.profiler.Profiler;
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display3D.*;
	import flash.display3D.textures.*;
	import flash.geom.*;
	
	import sl2d.display.slBounds;
	import sl2d.display.slButtonGroup;
	import sl2d.display.slCamera;
	import sl2d.renderer.slAGALHelper;
	import sl2d.shader.slShader;
	import sl2d.texture.slTextureFactory;
	import sl2d.utils.*;
	
	public class slWorld
	{
		public static var RenderUI : Boolean = true;		// 是否渲染UI
		private static var _instance : slWorld = null;
		
		private var _viewPort : Rectangle;
		
		private var _gameClass:Class;			// 应用层派生于slView的根节点
		private var _context:Context3D;
		private var _stage3d : Stage3DProxy;
		
		public function slWorld(gameClass:Class)
		{
			if(_instance)
				Debug.assert(false, "only one slWorld");
			_instance = this;
			
			_gameClass = gameClass;
			_viewPort = new Rectangle(0, 0, 1, 1);
		}
		
		public function resizeWorld():void
		{
			var w:int = slGlobal.ViewPortWidth;
			var h:int = slGlobal.ViewPortHeight;
			_viewPort.setTo(0, 0, w, h);
			if(_context == null) 
				return;
			slGlobal.Camera.resizeCameraStage(_viewPort.width, _viewPort.height);
			slGlobal.View.onResizeView(w, h);
		}
		
		private function initialize(stage:Stage):void
		{
			slGlobal.TextureFactory = slTextureFactory.instance();
			slBounds.initFactory(slGlobal.TextureFactory);
			slButtonGroup.setButtonStage(stage);
			slGlobal.Camera = new slCamera(slGlobal.ViewPortWidth, slGlobal.ViewPortHeight)
				
			slGlobal.Helper = new slAGALHelper();
			slGlobal.Helper.setCamera(slGlobal.Camera);
			
			configWorld();
			slGlobal.View = new _gameClass();
			resizeWorld();
			
			slGlobal.isInit = true;
		}
		
		
		private function configWorld():void
		{
			if(!slGlobal.TextureFactory)
				return;
			slGlobal.TextureFactory.setContext(_context);
			slShader.setContext(_context);
			slGlobal.Helper.setContext(_stage3d, _context);
			if(slGlobal.View)
				slGlobal.View.onContextChanged();
		}

		public function setWorldContent(stage3d:Stage3DProxy, context:Context3D, stage:Stage):void
		{
			if(context == null || stage == null) 
				return;
			_context = context;
			_stage3d = stage3d;
			initialize(stage);
		}
		
		public function resetContext(context:Context3D):void
		{
			_context = context;
			configWorld();
		}
		
		public function update(curTime : int, deltaTime : int):void
		{
			if(_context == null || _context.driverInfo == "Disposed")
				return;
			if(!RenderUI)
			{
				return;
			}
			
			slGlobal.WorldUpdateCount ++;
			var count:int = slGlobal.WorldUpdateCount;
				
			slGlobal.CurTime = curTime;
			slGlobal.DeltaTime = deltaTime;
				
			slGlobal.Camera.update();
			slGlobal.ViewPort.setTo(0, 0, slGlobal.ViewPortWidth, slGlobal.ViewPortHeight);
			_context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, slGlobal.Camera.getViewProjectionMatrix(), true);
			
			Profiler.start("View.update");
			slGlobal.View.update();
			Profiler.end("View.update");
			
			slGlobal.View.validateProperty();
			
			Profiler.start("View.render");
			slGlobal.Helper.readyRenderItem();
			slGlobal.View.collectRenderer();
			slGlobal.Helper.executeRender();
			slGlobal.Helper.endRenderItem();
			Profiler.end("View.render");
			
			_context.present();
			
			// clear buffers
			for (var i : uint = 0; i < 8; ++i)
			{
				_stage3d.setSimpleVertexBuffer(i, null, null, 0);
				_stage3d.setTextureAt(i, null);
				_stage3d.setProgram(null);
			}
			
			
		}
		
		
	}
}

