/**
 *	信息显示框 
 */
package blade3d.profiler
{
	import away3d.containers.ObjectContainer3D;
	import away3d.core.managers.Context3DProxy;
	import away3d.entities.Entity;
	import away3d.entities.Mesh;
	import away3d.materials.MaterialBase;
	import away3d.textures.BitmapTextureCache;
	
	import blade3d.avatar.blAvatarStore;
	import blade3d.camera.BlCameraManager;
	import blade3d.effect.BlEffectManager;
	import blade3d.io.BlInputManager;
	import blade3d.loader.BlResourceLoaderManager;
	import blade3d.resource.BlResourceManager;
	import blade3d.scene.BlSceneManager;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Vector3D;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	public class InfoStats extends Sprite
	{
		private static var _INSTANCE : InfoStats;
		
		private const _WIDTH : Number = 150;
		private const _HEIGHT : Number = 200;
		private var _dia_bmp : BitmapData;
		private var _diagram : Sprite;
		
		// 拖动
		private var _drag_dx : Number;
		private var _drag_dy : Number;
		private var _dragging : Boolean = false;
		
		private var _timer : Timer;
		
		private var _data_format : TextFormat;
		private var _label_format : TextFormat;
		
		private var loadMemory_tf : TextField;
		private var cameraName_tf : TextField;
		private var cameraPos_tf : TextField;
		private var cameraRot_tf : TextField;
		private var terrainPos_tf : TextField;			// 鼠标指定的地面位置
		private var vb_ib_tex_tf : TextField;			// vb, ib, tex数
		private var object_tf : TextField;				// 对象数
		private var mat_tf : TextField;				// 材质数
		private var res_tf : TextField;				// 资源数
		private var avatar_tf : TextField;				// avatar数
		private var effect_tf : TextField;				// 特效数
		
		
		public function InfoStats()
		{
			super();
			
			if (_INSTANCE) 
			{
				trace('Creating several statistics windows in one project. Is this intentional?');
			}
			_INSTANCE = this;
			
			y = 400;
			
			scaleX = 1;
			scaleY = 1;
			
			init();
			
			addEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, _onRemovedFromStage);
		}
		
		private function _onAddedToStage(ev : Event) : void
		{
			_timer.start();
			addEventListener(Event.ENTER_FRAME, _onEnterFrame);
		}
		
		private function _onRemovedFromStage(ev : Event) : void
		{
			_timer.stop();
			removeEventListener(TimerEvent.TIMER, _onTimer);
		}
		
		private function _initMisc() : void
		{
			_dia_bmp = new BitmapData(_WIDTH, _HEIGHT, true, 0xff0000);
			_diagram = new Sprite;
			_diagram.graphics.beginBitmapFill(_dia_bmp);
			_diagram.graphics.drawRect(0, 0, _dia_bmp.width, _dia_bmp.height);
			_diagram.graphics.endFill();
			_diagram.y = 0;
			addChild(_diagram);
			
			// 支持拖动
			_diagram.addEventListener(MouseEvent.MOUSE_DOWN, _onDiagramMouseDown);
			
			_timer = new Timer(250, 0);
			_timer.addEventListener(TimerEvent.TIMER, _onTimer);
			
			_label_format = new TextFormat('_sans', 9, 0xffffff, true);
			_data_format = new TextFormat('_sans', 9, 0xffffff, false);
			
		}
		
		private function _initInfo() : void
		{
			// 加载量
			var label_y : int = 0;
			var loadMemory_label_tf : TextField;
			loadMemory_label_tf = new TextField;
			loadMemory_label_tf.defaultTextFormat = _label_format;
			loadMemory_label_tf.autoSize = TextFieldAutoSize.LEFT;
			loadMemory_label_tf.text = 'load:';
			loadMemory_label_tf.x = 10;
			loadMemory_label_tf.y = label_y;
			loadMemory_label_tf.selectable = false;
			loadMemory_label_tf.mouseEnabled = false;
			addChild(loadMemory_label_tf);
			
			loadMemory_tf = new TextField;
			loadMemory_tf.defaultTextFormat = _data_format;
			loadMemory_tf.autoSize = TextFieldAutoSize.LEFT;
			loadMemory_tf.x = loadMemory_label_tf.x + 30;
			loadMemory_tf.y = loadMemory_label_tf.y;
			loadMemory_tf.text = "0";
			loadMemory_tf.selectable = false;
			loadMemory_tf.mouseEnabled = false;
			addChild(loadMemory_tf);
			
			label_y += 10;
			
			// 资源数
			var res_label_tf : TextField;
			res_label_tf = new TextField;
			res_label_tf.defaultTextFormat = _label_format;
			res_label_tf.autoSize = TextFieldAutoSize.LEFT;
			res_label_tf.text = 'img_mod:';
			res_label_tf.x = 10;
			res_label_tf.y = label_y;
			res_label_tf.selectable = false;
			res_label_tf.mouseEnabled = false;
			addChild(res_label_tf);
			
			res_tf = new TextField;
			res_tf.defaultTextFormat = _data_format;
			res_tf.autoSize = TextFieldAutoSize.LEFT;
			res_tf.x = res_label_tf.x + 45;
			res_tf.y = res_label_tf.y;
			res_tf.text = "";
			res_tf.selectable = false;
			res_tf.mouseEnabled = false;
			addChild(res_tf);
			
			label_y += 10;
			
			
			// 当前Camera
			var camera_label_tf : TextField;
			camera_label_tf = new TextField;
			camera_label_tf.defaultTextFormat = _label_format;
			camera_label_tf.autoSize = TextFieldAutoSize.LEFT;
			camera_label_tf.text = 'camera:';
			camera_label_tf.x = 10;
			camera_label_tf.y = label_y;
			camera_label_tf.selectable = false;
			camera_label_tf.mouseEnabled = false;
			addChild(camera_label_tf);
			
			cameraName_tf = new TextField;
			cameraName_tf.defaultTextFormat = _data_format;
			cameraName_tf.autoSize = TextFieldAutoSize.LEFT;
			cameraName_tf.x = camera_label_tf.x + 41;
			cameraName_tf.y = camera_label_tf.y;
			cameraName_tf.text = "";
			cameraName_tf.selectable = false;
			cameraName_tf.mouseEnabled = false;
			addChild(cameraName_tf);
			
			label_y += 10;
			// 当前Camera位置
			var camerapos_label_tf : TextField;
			camerapos_label_tf = new TextField;
			camerapos_label_tf.defaultTextFormat = _label_format;
			camerapos_label_tf.autoSize = TextFieldAutoSize.LEFT;
			camerapos_label_tf.text = 'campos:';
			camerapos_label_tf.x = 10;
			camerapos_label_tf.y = label_y;
			camerapos_label_tf.selectable = false;
			camerapos_label_tf.mouseEnabled = false;
			addChild(camerapos_label_tf);
			
			cameraPos_tf = new TextField;
			cameraPos_tf.defaultTextFormat = _data_format;
			cameraPos_tf.autoSize = TextFieldAutoSize.LEFT;
			cameraPos_tf.x = camerapos_label_tf.x + 41;
			cameraPos_tf.y = camerapos_label_tf.y;
			cameraPos_tf.text = "";
			cameraPos_tf.selectable = false;
			cameraPos_tf.mouseEnabled = false;
			addChild(cameraPos_tf);
			
			label_y += 10;
			// 当前Camear旋转
			var camerarot_label_tf : TextField;
			camerarot_label_tf = new TextField;
			camerarot_label_tf.defaultTextFormat = _label_format;
			camerarot_label_tf.autoSize = TextFieldAutoSize.LEFT;
			camerarot_label_tf.text = 'camrot:';
			camerarot_label_tf.x = 10;
			camerarot_label_tf.y = label_y;
			camerarot_label_tf.selectable = false;
			camerarot_label_tf.mouseEnabled = false;
			addChild(camerarot_label_tf);
			
			cameraRot_tf = new TextField;
			cameraRot_tf.defaultTextFormat = _data_format;
			cameraRot_tf.autoSize = TextFieldAutoSize.LEFT;
			cameraRot_tf.x = camerarot_label_tf.x + 41;
			cameraRot_tf.y = camerarot_label_tf.y;
			cameraRot_tf.text = "";
			cameraRot_tf.selectable = false;
			cameraRot_tf.mouseEnabled = false;
			addChild(cameraRot_tf);
			
			label_y += 10;
			
			// 鼠标的地面位置
			var terrainPos_label_tf : TextField;
			terrainPos_label_tf = new TextField;
			terrainPos_label_tf.defaultTextFormat = _label_format;
			terrainPos_label_tf.autoSize = TextFieldAutoSize.LEFT;
			terrainPos_label_tf.text = 'terrain:';
			terrainPos_label_tf.x = 10;
			terrainPos_label_tf.y = label_y;
			terrainPos_label_tf.selectable = false;
			terrainPos_label_tf.mouseEnabled = false;
			addChild(terrainPos_label_tf);
			
			terrainPos_tf = new TextField;
			terrainPos_tf.defaultTextFormat = _data_format;
			terrainPos_tf.autoSize = TextFieldAutoSize.LEFT;
			terrainPos_tf.x = terrainPos_label_tf.x + 41;
			terrainPos_tf.y = terrainPos_label_tf.y;
			terrainPos_tf.text = "";
			terrainPos_tf.selectable = false;
			terrainPos_tf.mouseEnabled = false;
			addChild(terrainPos_tf);
			
			label_y += 10;
			
			// vertexbuffer 信息
			var vb_label_tf : TextField;
			vb_label_tf = new TextField;
			vb_label_tf.defaultTextFormat = _label_format;
			vb_label_tf.autoSize = TextFieldAutoSize.LEFT;
			vb_label_tf.text = 'vb-ib-tex-p:';
			vb_label_tf.x = 10;
			vb_label_tf.y = label_y;
			vb_label_tf.selectable = false;
			vb_label_tf.mouseEnabled = false;
			addChild(vb_label_tf);
			
			vb_ib_tex_tf = new TextField;
			vb_ib_tex_tf.defaultTextFormat = _data_format;
			vb_ib_tex_tf.autoSize = TextFieldAutoSize.LEFT;
			vb_ib_tex_tf.x = vb_label_tf.x + 60;
			vb_ib_tex_tf.y = vb_label_tf.y;
			vb_ib_tex_tf.text = "";
			vb_ib_tex_tf.selectable = false;
			vb_ib_tex_tf.mouseEnabled = false;
			addChild(vb_ib_tex_tf);
			
			label_y += 10;
			
			// 材质数
			var mat_label_tf : TextField;
			mat_label_tf = new TextField;
			mat_label_tf.defaultTextFormat = _label_format;
			mat_label_tf.autoSize = TextFieldAutoSize.LEFT;
			mat_label_tf.text = 'mat-bmp:';
			mat_label_tf.x = 10;
			mat_label_tf.y = label_y;
			mat_label_tf.selectable = false;
			mat_label_tf.mouseEnabled = false;
			addChild(mat_label_tf);
			
			mat_tf = new TextField;
			mat_tf.defaultTextFormat = _data_format;
			mat_tf.autoSize = TextFieldAutoSize.LEFT;
			mat_tf.x = mat_label_tf.x + 45;
			mat_tf.y = mat_label_tf.y;
			mat_tf.text = "";
			mat_tf.selectable = false;
			mat_tf.mouseEnabled = false;
			addChild(mat_tf);
			
			label_y += 10;
			
			// 对象数
			var object_label_tf : TextField;
			object_label_tf = new TextField;
			object_label_tf.defaultTextFormat = _label_format;
			object_label_tf.autoSize = TextFieldAutoSize.LEFT;
			object_label_tf.text = 'obj-ent-msh:';
			object_label_tf.x = 10;
			object_label_tf.y = label_y;
			object_label_tf.selectable = false;
			object_label_tf.mouseEnabled = false;
			addChild(object_label_tf);
			
			object_tf = new TextField;
			object_tf.defaultTextFormat = _data_format;
			object_tf.autoSize = TextFieldAutoSize.LEFT;
			object_tf.x = object_label_tf.x + 60;
			object_tf.y = object_label_tf.y;
			object_tf.text = "";
			object_tf.selectable = false;
			object_tf.mouseEnabled = false;
			addChild(object_tf);
			
			label_y += 10;
			
			// avatar数
			var avatar_label_tf : TextField;
			avatar_label_tf = new TextField;
			avatar_label_tf.defaultTextFormat = _label_format;
			avatar_label_tf.autoSize = TextFieldAutoSize.LEFT;
			avatar_label_tf.text = 'avatar:';
			avatar_label_tf.x = 10;
			avatar_label_tf.y = label_y;
			avatar_label_tf.selectable = false;
			avatar_label_tf.mouseEnabled = false;
			addChild(avatar_label_tf);
			
			avatar_tf = new TextField;
			avatar_tf.defaultTextFormat = _data_format;
			avatar_tf.autoSize = TextFieldAutoSize.LEFT;
			avatar_tf.x = avatar_label_tf.x + 40;
			avatar_tf.y = avatar_label_tf.y;
			avatar_tf.text = "";
			avatar_tf.selectable = false;
			avatar_tf.mouseEnabled = false;
			addChild(avatar_tf);
			
			label_y += 10;
			
			// 特效数
			var effect_label_tf : TextField;
			effect_label_tf = new TextField;
			effect_label_tf.defaultTextFormat = _label_format;
			effect_label_tf.autoSize = TextFieldAutoSize.LEFT;
			effect_label_tf.text = 'effect:';
			effect_label_tf.x = 10;
			effect_label_tf.y = label_y;
			effect_label_tf.selectable = false;
			effect_label_tf.mouseEnabled = false;
			addChild(effect_label_tf);
			
			effect_tf = new TextField;
			effect_tf.defaultTextFormat = _data_format;
			effect_tf.autoSize = TextFieldAutoSize.LEFT;
			effect_tf.x = effect_label_tf.x + 40;
			effect_tf.y = effect_label_tf.y;
			effect_tf.text = "";
			effect_tf.selectable = false;
			effect_tf.mouseEnabled = false;
			addChild(effect_tf);
			
			label_y += 10;
			
			
		}
		
		private function init() : void
		{
			_initMisc();
			_initInfo();
		}
		
		private function _onTimer(ev : Event) : void
		{
			// 背景
			this.graphics.clear();
			this.graphics.beginFill(0, 0.3);
			this.graphics.drawRect(0, 0, _WIDTH, _HEIGHT);
			
			// 下载量
			var memory:Number = BlResourceManager.instance().loaderManager.loadedMemory;
			memory = memory / 1000;
			loadMemory_tf.text = memory.toString() + " k";
			// 资源数
			res_tf.text = BlResourceManager.instance().loadedResCount[BlResourceManager.TYPE_IMAGE].toString()
				+ " " + BlResourceManager.instance().loadedResCount[BlResourceManager.TYPE_MESH].toString();
			// 摄像机名字
			cameraName_tf.text = BlCameraManager.instance().currentCamera.name;
			// 摄像机位置
			var v:Vector3D;
			v = BlCameraManager.instance().currentCamera.camera.scenePosition;
			cameraPos_tf.text = "("+v.x.toFixed(1)+", "+v.y.toFixed(1)+", "+v.z.toFixed(1)+")";
			// 摄像机旋转
			v = BlCameraManager.instance().currentCamera.camera.eulers;
			cameraRot_tf.text = "("+v.x.toFixed(1)+", "+v.y.toFixed(1)+", "+v.z.toFixed(1)+")";
			// 鼠标位置
			if(BlSceneManager.instance().currentScene)
			{
				var mousePos : Vector3D = BlSceneManager.instance().currentScene.getTerrainPosByScreenPoint(
					BlInputManager.mouseX(), 
					BlInputManager.mouseY());
				if(mousePos)
				{
					terrainPos_tf.text = "("+mousePos.x.toFixed(1)+", "+mousePos.y.toFixed(1)+", "+mousePos.z.toFixed(1)+")";
					BlSceneManager.instance().currentScene.getTerrainHeight(mousePos.x, mousePos.z);		// 强制更新高度图
				}
				else
					terrainPos_tf.text = "-";
			}
			// vb
			vb_ib_tex_tf.text = Context3DProxy.vbCount + " " + Context3DProxy.ibCount + " " + Context3DProxy.texCount + " " + Context3DProxy.programCount;
			// 3d对象数
			object_tf.text = ObjectContainer3D.Object3DNumber.toString() + " " + Entity.EntityNumber.toString() + " " + Mesh.MeshNumber.toString();
			// 材质数
			mat_tf.text = MaterialBase.AllMaterialCount.toString() + " " + BitmapTextureCache.instance().textureCount.toString();
			// avatar数
			avatar_tf.text = blAvatarStore.allocateAvatarMeshCount.toString();
			// 特效数
			effect_tf.text = BlEffectManager.allEffectCount.toString() + " " + BlEffectManager.instance().getBusyCount();
			
		}
		
		private function _onEnterFrame(ev : Event) : void
		{
			
		}
		
		private function _onDiagramMouseDown(ev : MouseEvent) : void
		{
			_drag_dx = this.mouseX;
			_drag_dy = this.mouseY;
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, _onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, _onMouseUpOrLeave);
			stage.addEventListener(Event.MOUSE_LEAVE, _onMouseUpOrLeave);
		}
		
		private function _onMouseMove(ev : MouseEvent) : void
		{
			_dragging = true;
			this.x = stage.mouseX - _drag_dx;
			this.y = stage.mouseY - _drag_dy;
		}
		
		private function _onMouseUpOrLeave(ev : Event) : void
		{
			_endDrag();
		}
		
		private function _endDrag() : void
		{
			if (this.x < -_WIDTH)
				this.x = -(_WIDTH-20);
			else if (this.x > stage.stageWidth)
				this.x = stage.stageWidth - 20;
			
			if (this.y < 0)
				this.y = 0;
			else if (this.y > stage.stageHeight)
				this.y = stage.stageHeight - 15;
			
			// Round x/y position to make sure it's on
			// whole pixels to avoid weird anti-aliasing
			this.x = Math.round(this.x);
			this.y = Math.round(this.y);
			
			
			_dragging = false; 
			stage.removeEventListener(Event.MOUSE_LEAVE, _onMouseUpOrLeave);
			stage.removeEventListener(MouseEvent.MOUSE_UP, _onMouseUpOrLeave);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, _onMouseMove);
		}
		
		public function stop(b:Boolean):void
		{
			if(b)
			{
				_timer.stop();
				removeEventListener(TimerEvent.TIMER, _onTimer);
				removeEventListener(Event.ENTER_FRAME, _onEnterFrame);
			}
			else
			{
				_timer.start();
				addEventListener(TimerEvent.TIMER, _onTimer);
				addEventListener(Event.ENTER_FRAME, _onEnterFrame);
			}
		}
	}
}