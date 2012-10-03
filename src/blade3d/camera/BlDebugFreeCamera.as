/**
 *	调试用摄像机 
 */
package blade3d.camera
{
	import away3d.cameras.Camera3D;
	import away3d.containers.View3D;
	import away3d.controllers.FirstPersonController;
	import away3d.debug.Debug;
	
	import blade3d.io.BlInputManager;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;

	public class BlDebugFreeCamera extends BlCameraControllerBase
	{
		private var _camera : Camera3D;
		private var _view : View3D;
		
		private var _mouseDown:Boolean = false;
		private var _lastMouseX:Number;
		private var _lastMouseY:Number;
		
		private var _yaw:Number = 0;		// y轴旋转
		private var _pitch:Number = 30;		// x轴旋转
		private var _roll:Number = 0;		// z轴旋转
		
		private var _camController:FirstPersonController;
		
		
		public function BlDebugFreeCamera(view:View3D, name:String)
		{
			super();
			
			_camera = new Camera3D();
			_camera.name = name;
			_camera.lens.near = 100;
			_camera.lens.far = 10000;
			_camera.y = 100;
			_camera.z = -200;
			_camera.eulers = new Vector3D(_pitch, _yaw, _roll);
			
			_view = view;
			
		}
		
		override public function get camera() : Camera3D {return _camera;}
		
		override public function onActive():void
		{
			
		}
		
		override public function onDeactive():void
		{
			_mouseDown = false;
		}
		
		override public function update(time:uint, deltaTime:uint):void	
		{
			// 旋转
			if(_mouseDown)
			{
				var deltaX : Number = _view.stage.mouseX - _lastMouseX;
				var deltaY : Number = _view.stage.mouseY - _lastMouseY;
				_lastMouseX = _view.stage.mouseX;
				_lastMouseY = _view.stage.mouseY;
				
//				Debug.trace("deltaX="+deltaX+" "+"deltaY="+deltaY);
				_yaw += deltaX * rotSpeed;
				_pitch += deltaY * rotSpeed;
				
				_camera.eulers = new Vector3D(_pitch, _yaw, _roll);
			}
			
			if(BlInputManager.keyIsDown(Keyboard.Q))
			{
				_yaw -= deltaTime * rotSpeed;
				_camera.eulers = new Vector3D(_pitch, _yaw, _roll);
			}
			else if(BlInputManager.keyIsDown(Keyboard.E))
			{
				_yaw += deltaTime * rotSpeed;
				_camera.eulers = new Vector3D(_pitch, _yaw, _roll);
			}
			// 位移
			updateCamera();
		}
		
		private function updateCamera():void
		{
			var moveLeft : Boolean = BlInputManager.keyIsDown(Keyboard.A);
			var moveRight : Boolean = BlInputManager.keyIsDown(Keyboard.D);
			var moveUp : Boolean = BlInputManager.keyIsDown(Keyboard.R);
			var moveDown : Boolean = BlInputManager.keyIsDown(Keyboard.F);
			var moveForward : Boolean = BlInputManager.keyIsDown(Keyboard.W);
			var moveBackward : Boolean = BlInputManager.keyIsDown(Keyboard.S);
			
				
			if(moveForward || moveBackward)
			{
				var forwardDir : Vector3D = _camera.forwardVector;
				forwardDir.scaleBy(moveSpeed);
				if(moveForward)
					_camera.position = _camera.position.add(forwardDir);
				else
					_camera.position = _camera.position.subtract(forwardDir);
			}
			if(moveLeft || moveRight)
			{
				var rightDir : Vector3D = _camera.rightVector;
				rightDir.scaleBy(moveSpeed);
				if(moveRight)
					_camera.position = _camera.position.add(rightDir);
				else
					_camera.position = _camera.position.subtract(rightDir);
			}
			if(moveUp || moveDown)
			{
				var upDir : Vector3D = _camera.upVector;
				upDir.scaleBy(moveSpeed);
//				var upDir : Vector3D = Vector3D.Y_AXIS;
//				upDir.normalize();
//				upDir.scaleBy(moveSpeed);
				if(moveUp)
					_camera.position = _camera.position.add(upDir);
				else
					_camera.position = _camera.position.subtract(upDir);
			}
		}
		
		override public function onMouseDown(event:MouseEvent):Boolean
		{
			_lastMouseX = _view.stage.mouseX;
			_lastMouseY = _view.stage.mouseY;
			_mouseDown = true;
			return false;
		}
		
		override public function onMouseUp(event:MouseEvent):Boolean
		{
			_mouseDown = false;
			return true;
		}
		
	}
}