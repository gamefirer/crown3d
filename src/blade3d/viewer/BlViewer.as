/**
 *	渲染简单对象用的View 
 */
package blade3d.viewer
{
	import away3d.arcane;
	import away3d.cameras.Camera3D;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.Scene3D;
	import away3d.core.managers.Stage3DManager;
	import away3d.core.managers.Stage3DProxy;
	import away3d.core.render.DefaultRenderer;
	import away3d.core.render.RendererBase;
	import away3d.core.traverse.EntityCollector;
	import away3d.textures.RenderTexture;
	import away3d.textures.Texture2DBase;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.utils.getTimer;
	
	use namespace arcane;
	
	public class BlViewer
	{
		
		private var _renderTexture : RenderTexture;
		private var _renderTextureInvalid : Boolean = true;
		
		private var _width : Number = 0;
		private var _height : Number = 0;
		
		protected var _aspectRatio : Number;
		private var _time : Number = 0;
		private var _deltaTime : uint;
		
		protected var _scene : Scene3D;							// 场景
		protected var _camera : Camera3D;						// 摄像机
		protected var _renderer : RendererBase;				// 渲染器
		protected var _entityCollector : EntityCollector;		// 采集器
		protected var _renderNode : ObjectContainer3D;		// 渲染对象(由外部维护)
		
		protected var _stage3DProxy : Stage3DProxy;
		
		private var _background : Texture2DBase;
		private var _antiAlias : uint;
		private var _backgroundColor : uint = 0x000000;
		private var _backgroundAlpha : Number = 1;
	
		public var visible : Boolean = true;
		public function get renderTexture() : RenderTexture {return _renderTexture;}
		public function get deltaTime() : uint {return _deltaTime;}
		public function get time() : uint {return _time;}
		
		public function BlViewer(scene : Scene3D = null, camera : Camera3D = null, renderer : RendererBase = null)
		{
			_scene = scene || new Scene3D();
			_camera = camera || new Camera3D();
			_renderer = renderer || new DefaultRenderer();
			
			// 创建采集器
			_entityCollector = _renderer.createEntityCollector();
			
			_camera.partition = _scene.partition;
		}
		
		public function setRenderNode(node:ObjectContainer3D):void
		{
			if(_renderNode)
				_scene.removeChild(_renderNode);
			
			_renderNode = node;
			
			if(_renderNode)
				_scene.addChild(_renderNode);
		}
		
		public function get stage3DProxy() : Stage3DProxy
		{
			return _stage3DProxy;
		}
		
		public function set stage3DProxy(stage3DProxy:Stage3DProxy) : void
		{
			_stage3DProxy = stage3DProxy;
			_renderer.stage3DProxy = _stage3DProxy;
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
			
			invalidateRenderTexture();
		}
		
		private function invalidateRenderTexture() : void
		{
			_renderTextureInvalid = true;
		}
		
		public function get antiAlias() : uint
		{
			return _antiAlias;
		}
		
		public function set antiAlias(value : uint) : void
		{
			_antiAlias = value;
			_renderer.antiAlias = value;
			
			invalidateRenderTexture();
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
		
		public function get width() : Number
		{
			return _width;
		}
		
		public function set width(value : Number) : void
		{
			if (_stage3DProxy && _stage3DProxy.usesSoftwareRendering && value > 2048)
				value = 2048;
			
			if (_width == value)
				return;
			
			_width = value;
			_aspectRatio = _width/_height;
			
			_renderer.viewWidth = value;
			
			invalidateRenderTexture();
		}
		
		public function get height() : Number
		{
			return _height;
		}
		
		public function set height(value : Number) : void
		{
			if (_stage3DProxy && _stage3DProxy.usesSoftwareRendering && value > 2048)
				value = 2048;
			
			if (_height == value)
				return;
			
			_height = value;
			_aspectRatio = _width/_height;
			
			_renderer.viewHeight = value;
			
			invalidateRenderTexture();
		}
		
		public function set x(value : Number) : void
		{
			
		}
		
		public function set y(value : Number) : void
		{
			
		}
		
		public function render(time:uint, deltaTime:uint) : void
		{
			if(!visible)
				return;
			
			if (!stage3DProxy.recoverFromDisposal())
			{
				_renderTextureInvalid = true;
				return;
			}
			
			// 更新渲染对象
			if(_renderTextureInvalid)
				createRenderTexture();
		
//			if (!_parentIsStage)
//				updateGlobalPos();
			
			_entityCollector.clear();
			_entityCollector.time = time;
			_entityCollector.deltaTime = deltaTime;
			
			updateViewSizeData();
			
			// collect stuff to render
			_scene.traversePartitions(_entityCollector);
			
			// 渲染
			_renderer.render(_entityCollector, renderTexture.getTextureForStage3D(_stage3DProxy));
			
			// clean up data for this render
			_entityCollector.cleanUp();
			
		}
		
		private function createRenderTexture():void
		{
			if(_renderTexture)
				_renderTexture.dispose();
			
			_renderTexture = new RenderTexture(_width, _height);
			_renderTextureInvalid = false;
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
			_renderer.dispose();
			_renderer = null;
			
			_stage3DProxy = null;
			_entityCollector = null;
			_renderNode = null;
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
		
		public function get entityCollector() : EntityCollector
		{
			return _entityCollector;
		}
		
		
	}
}