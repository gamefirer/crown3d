/**
 *	第3人称摄像机 
 */
package blade3d.camera
{
	import away3d.cameras.Camera3D;
	import away3d.containers.View3D;
	import away3d.controllers.HoverController;
	import away3d.debug.Debug;
	
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class BlThirdPersonCamera extends BlCameraControllerBase
	{
		private var _camera : Camera3D;
		private var _view : View3D;
		
		private var _move:Boolean = false;
		private var _lastPanAngle:Number;
		private var _lastTiltAngle:Number;
		private var _lastMouseX:Number;
		private var _lastMouseY:Number;
		
		private var _camController:HoverController;
		
		public function BlThirdPersonCamera(view:View3D, name:String)
		{
			super();
			
			_camera = new Camera3D();
			_camera.name = name;
			_camera.lens.near = 100;
			_camera.lens.far = 10000;
			
			_camController = new HoverController(_camera, null, 45, 20, 200, 10);
			
			_view = view;
			
		}
		
		override public function get camera() : Camera3D {return _camera;}
		
		override public function onActive():void
		{
//			_view.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
//			_view.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
//			_view.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			
			_camController.update();
		}
		
		override public function onDeactive():void
		{
			_move = false;
//			_view.stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
//			
//			_view.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
//			_view.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
//			_view.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		}
		
		override public function update(time:uint, deltaTime:uint):void	
		{
			if(_move)
			{
				_camController.panAngle = rotSpeed*(_view.stage.mouseX - _lastMouseX) + _lastPanAngle;
				_camController.tiltAngle = rotSpeed*(_view.stage.mouseY - _lastMouseY) + _lastTiltAngle;
			}
		}
		
		override public function onMouseWheel(event:MouseEvent):Boolean
		{
			var camDis : Number = _camController.distance;
			camDis -= event.delta * moveSpeed;
			if(camDis < 10)
				camDis = 10;
			_camController.distance = camDis;
			return true;
		}
		
		override public function onMouseDown(event:MouseEvent):Boolean
		{
			_lastPanAngle = _camController.panAngle;
			_lastTiltAngle = _camController.tiltAngle;
			_lastMouseX = _view.stage.mouseX;
			_lastMouseY = _view.stage.mouseY;
			_move = true;
			return false;
		}
		
		override public function onMouseUp(event:MouseEvent):Boolean
		{
			_move = false;
			return true;
		}
		
		
	}
}