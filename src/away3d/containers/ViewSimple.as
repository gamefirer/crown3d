/**
 *	渲染简单对象用的View 
 */
package away3d.containers
{
	import away3d.arcane;
	import away3d.cameras.Camera3D;
	import away3d.core.managers.Stage3DManager;
	import away3d.core.managers.Stage3DProxy;
	import away3d.core.render.DefaultRenderer;
	import away3d.core.render.RendererBase;
	import away3d.core.traverse.EntityCollector;
	import away3d.textures.Texture2DBase;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.utils.getTimer;
	
	use namespace arcane;
	
	public class ViewSimple extends Sprite
	{
		private var _width : Number = 0;
		private var _height : Number = 0;
		private var _localPos : Point = new Point();
		private var _globalPos : Point = new Point();
		
		protected var _aspectRatio : Number;
		private var _time : Number = 0;
		private var _deltaTime : uint;
		
		protected var _scene : Scene3D;					// 场景
		protected var _camera : Camera3D;				// 摄像机
		protected var _renderer : RendererBase;		// 渲染器
		protected var _entityCollector : EntityCollector;	// 采集器
		
		private var _viewScissoRect:Rectangle;				//  矩形裁剪范围
		private var _addedToStage:Boolean;
		private var _stage3DManager : Stage3DManager;
		
		protected var _stage3DProxy : Stage3DProxy;
		private var _forceSoftware : Boolean;
		protected var _parentIsStage : Boolean;
		
		protected var _backBufferInvalid : Boolean = true;
		private var _background : Texture2DBase;
		private var _antiAlias : uint;
		private var _backgroundColor : uint = 0x000000;
		private var _backgroundAlpha : Number = 1;
		
		public function ViewSimple(scene : Scene3D = null, camera : Camera3D = null, renderer : RendererBase = null, forceSoftware:Boolean = false)
		{
			super();
			
			_scene = scene || new Scene3D();
			_camera = camera || new Camera3D();
			_renderer = renderer || new DefaultRenderer();
			_forceSoftware = forceSoftware;
			
			// 创建采集器
			_entityCollector = _renderer.createEntityCollector();
			
			_viewScissoRect = new Rectangle();
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
			addEventListener(Event.ADDED, onAdded, false, 0, true);
			
			_camera.partition = _scene.partition;
		}
		
		public function get stage3DProxy() : Stage3DProxy
		{
			return _stage3DProxy;
		}
		
		public function set stage3DProxy(stage3DProxy:Stage3DProxy) : void
		{
			_stage3DProxy = stage3DProxy;
			_renderer.stage3DProxy = _stage3DProxy;
			
			super.x = _stage3DProxy.x;
			
			_localPos.x = _stage3DProxy.x;
			_globalPos.x = parent? parent.localToGlobal(_localPos).x : _stage3DProxy.x;
			
			super.y = _stage3DProxy.y;
			
			_localPos.y = _stage3DProxy.y;
			_globalPos.y = parent? parent.localToGlobal(_localPos).y : _stage3DProxy.y;
			
			_viewScissoRect = new Rectangle(_stage3DProxy.x, _stage3DProxy.y, _stage3DProxy.width, _stage3DProxy.height);
		}
		
		public function get background() : Texture2DBase
		{
			return _background;
		}
		
		public function set background(value : Texture2DBase) : void
		{
			_background = value;
			_renderer.background = _background;
		}
		
		public function get renderer() : RendererBase
		{
			return _renderer;
		}
		
		public function set renderer(value : RendererBase) : void
		{
			_renderer.dispose();
			_renderer = value;
			_entityCollector = _renderer.createEntityCollector();
			_renderer.stage3DProxy = _stage3DProxy;
			_renderer.antiAlias = _antiAlias;			// 反走样
			_renderer.backgroundR = ((_backgroundColor >> 16) & 0xff) / 0xff;
			_renderer.backgroundG = ((_backgroundColor >> 8) & 0xff) / 0xff;
			_renderer.backgroundB = (_backgroundColor & 0xff) / 0xff;
			_renderer.backgroundAlpha = _backgroundAlpha;
			_renderer.viewWidth = _width;
			_renderer.viewHeight = _height;
			
			invalidateBackBuffer();
		}
		
		private function invalidateBackBuffer() : void
		{
			_backBufferInvalid = true;
		}
		
		public function get antiAlias() : uint
		{
			return _antiAlias;
		}
		
		public function set antiAlias(value : uint) : void
		{
			_antiAlias = value;
			_renderer.antiAlias = value;
			
			invalidateBackBuffer();
		}
		
		public function get backgroundColor() : uint
		{
			return _backgroundColor;
		}
		
		public function set backgroundColor(value : uint) : void
		{
			_backgroundColor = value;
			_renderer.backgroundR = ((value >> 16) & 0xff) / 0xff;
			_renderer.backgroundG = ((value >> 8) & 0xff) / 0xff;
			_renderer.backgroundB = (value & 0xff) / 0xff;
		}
		
		public function get backgroundAlpha() : Number
		{
			return _backgroundAlpha;
		}
		
		public function set backgroundAlpha(value : Number) : void
		{
			if (value > 1)
				value = 1;
			else if (value < 0)
				value = 0;
			
			_renderer.backgroundAlpha = value;
			_backgroundAlpha = value;
		}
		
		public function get camera() : Camera3D
		{
			return _camera;
		}
		
		public function set camera(camera:Camera3D) : void
		{
			_camera = camera;
			
			if (_scene)
				_camera.partition = _scene.partition;
		}
		
		public function get scene() : Scene3D
		{
			return _scene;
		}
		
		public function set scene(scene:Scene3D) : void
		{
			_scene = scene;
			
			if (_camera)
				_camera.partition = _scene.partition;
		}
		
		override public function get width() : Number
		{
			return _width;
		}
		
		override public function set width(value : Number) : void
		{
			if (_stage3DProxy && _stage3DProxy.usesSoftwareRendering && value > 2048)
				value = 2048;
			
			if (_width == value)
				return;
			
			_width = value;
			_aspectRatio = _width/_height;
			
			_renderer.viewWidth = value;
			
			_viewScissoRect.width = value;
			
			invalidateBackBuffer();
		}
		
		override public function get height() : Number
		{
			return _height;
		}
		
		override public function set height(value : Number) : void
		{
			if (_stage3DProxy && _stage3DProxy.usesSoftwareRendering && value > 2048)
				value = 2048;
			
			if (_height == value)
				return;
			
			_height = value;
			_aspectRatio = _width/_height;
			
			_renderer.viewHeight = value;
			
			_viewScissoRect.height = value;
			
			invalidateBackBuffer();
		}
		
		override public function set x(value : Number) : void
		{
			super.x = value;
			
			_localPos.x = value;
			_globalPos.x = parent? parent.localToGlobal(_localPos).x : value;
			_viewScissoRect.x = value;
			
			if (_stage3DProxy)
				_stage3DProxy.x = _globalPos.x;
		}
		
		override public function set y(value : Number) : void
		{
			super.y = value;
			
			_localPos.y = value;
			_globalPos.y = parent? parent.localToGlobal(_localPos).y : value;
			_viewScissoRect.y = value;
			
			if (_stage3DProxy)
				_stage3DProxy.y = _globalPos.y;
		}
		
		override public function set visible(value : Boolean) : void
		{
			super.visible = value;
			
			if (_stage3DProxy)
				_stage3DProxy.visible = value;
		}
		
		protected function updateBackBuffer() : void
		{
			if (_stage3DProxy.context3D) 
			{
				if( _width && _height )
				{
					if (_stage3DProxy.usesSoftwareRendering)
					{
						if (_width > 2048) _width = 2048;
						if (_height > 2048) _height = 2048;
					}
					
					_stage3DProxy.configureBackBuffer(_width, _height, _antiAlias, true);
					_backBufferInvalid = false;
				} 
				else
				{
					width = stage.stageWidth;
					height = stage.stageHeight;
				}
			}
		}
		
		public function get deltaTime() : uint
		{
			return _deltaTime;
		}
		
		public function get time() : uint
		{
			return _time;
		}
		
		public function render() : void
		{
			//if context3D has Disposed by the OS,don't render at this frame
			if (!stage3DProxy.recoverFromDisposal()) {
				_backBufferInvalid = true;
				return;
			}
			
			// reset or update render settings
			if (_backBufferInvalid)
				updateBackBuffer();
			
			if (!_parentIsStage)
				updateGlobalPos();
			
			updateTime();
			
			_entityCollector.clear();
			_entityCollector.time = time;
			_entityCollector.deltaTime = deltaTime;
			
			updateViewSizeData();
			
			// collect stuff to render
			_scene.traversePartitions(_entityCollector);
			
			// 渲染
			_renderer.render(_entityCollector);
			
			// clean up data for this render
			_entityCollector.cleanUp();
			
		}
		
		protected function updateGlobalPos() : void
		{
			var globalPos : Point = parent.localToGlobal(_localPos);
			if (_globalPos.x != globalPos.x) 
				_stage3DProxy.x = globalPos.x;
			if (_globalPos.y != globalPos.y) 
				_stage3DProxy.y = globalPos.y;
			_globalPos = globalPos;
		}
		
		protected function updateTime() : void
		{
			var time : Number = getTimer();
			if (_time == 0) _time = time;
			_deltaTime = time - _time;
			_time = time;
		}
		
		private function updateViewSizeData() : void
		{
			_camera.lens.aspectRatio = _aspectRatio;
			_entityCollector.camera = _camera;
			
			_renderer.textureRatioX = 1;
			_renderer.textureRatioY = 1;
		}
		
		public function dispose() : void
		{
			_stage3DProxy.dispose();
			_renderer.dispose();
			
			_stage3DProxy = null;
			_renderer = null;
			_entityCollector = null;
		}
		
		public function project(point3d : Vector3D) : Vector3D
		{
			var v : Vector3D = _camera.project(point3d);
			
			v.x = (v.x + 1.0)*_width/2.0;
			v.y = (v.y + 1.0)*_height/2.0;
			
			return v;
		}
		
		public function unproject(mX : Number, mY : Number, mZ : Number = 0) : Vector3D
		{
			return _camera.unproject((mX * 2 - _width)/_width, (mY * 2 - _height)/_height, mZ);
		}
		
		public function getRay(mX : Number, mY : Number, mZ : Number = 0) : Vector3D
		{
			return _camera.getRay((mX * 2 - _width)/_width, (mY * 2 - _height)/_height, mZ);
		}
		
		arcane function get entityCollector() : EntityCollector
		{
			return _entityCollector;
		}
		
		private function onAddedToStage(event : Event) : void
		{
			if (_addedToStage)
				return;
			
			_addedToStage = true;
			
			_stage3DManager = Stage3DManager.getInstance(stage);
			if (!_stage3DProxy) 
				_stage3DProxy = _stage3DManager.getFreeStage3DProxy( _forceSoftware);
			
			_stage3DProxy.x = _globalPos.x;
			_stage3DProxy.y = _globalPos.y;
			
			if (_width == 0) 
				width = stage.stageWidth;
			if (_height == 0) 
				height = stage.stageHeight;
			
			_renderer.stage3DProxy = _stage3DProxy;
		}
		
		private function onAdded(event : Event) : void
		{
			_parentIsStage = (parent == stage);
			_globalPos = parent.localToGlobal(new Point(x, y));
			if (_stage3DProxy)
			{
				_stage3DProxy.x = _globalPos.x;
				_stage3DProxy.y = _globalPos.y;
			}
		}
		
	}
}