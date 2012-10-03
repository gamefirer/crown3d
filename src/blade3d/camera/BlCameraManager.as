package blade3d.camera
{
	import away3d.containers.View3D;
	import away3d.debug.Debug;
	
	import blade3d.BlManager;
	import blade3d.io.BlInputManager;
	
	import com.greensock.TweenLite;
	
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;

	public class BlCameraManager extends BlManager
	{
		static public var CAMERA_NAME_THIRD : String = "third";
		
		static private var _instance : BlCameraManager;
		
		private var _debugFreeCamera : BlCameraControllerBase;
		
		private var _currentCamera : BlCameraControllerBase;
		
		private var _cameras : Vector.<BlCameraControllerBase> = new Vector.<BlCameraControllerBase>;
		
		private var _view : View3D;
		
		public function BlCameraManager()
		{
			if(_instance)
				Debug.error("BlCameraManager error");
		}
		
		static public function instance() : BlCameraManager
		{
			if(!_instance)
				_instance = new BlCameraManager();
			return _instance;
		}
		
		public function get currentCamera() : BlCameraControllerBase {return _currentCamera;}
		public function get cameras() : Vector.<BlCameraControllerBase> {return _cameras;}
		
		public function init(view:View3D, callBack:Function):Boolean
		{
			_view = view;
			
			BlInputManager.addMouseDownHandler(onMouseDown);
			BlInputManager.addMouseUpHandler(onMouseUp);
			BlInputManager.addMouseWheelHandler(onMouseWheel);
			
			// 释放原摄像机
			_view.camera.dispose();
			
			var camera : BlCameraControllerBase;
			// 创建调试用摄像机
			camera = new BlDebugFreeCamera(_view, "free1");
			_cameras.push(camera);
			
			// 创建第3人称摄像机
			camera = new BlThirdPersonCamera(_view, CAMERA_NAME_THIRD);
			_cameras.push(camera);
			
			switchCamera(0, false);
			
			callBack(this);
			return true;
		}
		
		public function addFreeCamera(name:String):void
		{
			var camera : BlCameraControllerBase;
			camera = new BlDebugFreeCamera(_view, name);
			_cameras.push(camera);
		}
		
		private function onMouseDown(event:MouseEvent):Boolean
		{
			if(_currentCamera) return _currentCamera.onMouseDown(event);
			return true;
		}
		
		private function onMouseUp(event:MouseEvent):Boolean
		{
			if(_currentCamera) return _currentCamera.onMouseUp(event);
			return true;
		}
		
		private function onMouseWheel(event:MouseEvent):Boolean
		{
			if(_currentCamera) return _currentCamera.onMouseWheel(event);
			return true;
		}
		
		public function update(time:uint, deltaTime:uint):void
		{
			_currentCamera.update(time, deltaTime);
		}
		
		public function switchCameraByName(camName:String):void
		{
			var i:int = 0;
			for(; i<_cameras.length; i++)
			{
				if(_cameras[i].name == camName)
					break;
			}
			
			if(i<_cameras.length)
				switchCamera(i);
		}
		
		private var _isTweening : Boolean = false;
		
		private function switchCamera(cameraIndex:int, tween:Boolean = true):void
		{
			if(_cameras[cameraIndex] == _currentCamera)
				return;
			
			var newCamera : BlCameraControllerBase = _cameras[cameraIndex];
			var oldCamera : BlCameraControllerBase = _currentCamera;
			
			if(_currentCamera)
				_currentCamera.onDeactive();
			
			_currentCamera = _cameras[cameraIndex];
			
			_currentCamera.onActive();
			
			_view.camera = _currentCamera.camera;
			
			dispatchEvent(new BlCameraEvent(BlCameraEvent.CAMERA_CHANGE, _currentCamera));
			
			if(tween && oldCamera)
			{
				var fromPosX : Number = oldCamera.camera.x;
				var fromPosY : Number = oldCamera.camera.y;
				var fromPosZ : Number = oldCamera.camera.z;
				var fromRotX : Number = oldCamera.camera.rotationX;
				var fromRotY : Number = oldCamera.camera.rotationY;
				var fromRotZ : Number = oldCamera.camera.rotationZ;
				
				var toPosX : Number = newCamera.camera.x;
				var toPosY : Number = newCamera.camera.y;
				var toPosZ : Number = newCamera.camera.z;
				var toRotX : Number = newCamera.camera.rotationX;
				var toRotY : Number = newCamera.camera.rotationY;
				var toRotZ : Number = newCamera.camera.rotationZ;
				
				TweenLite.from(_currentCamera.camera, 0.2, {x:fromPosX, y:fromPosY, z:fromPosZ, rotationX:fromRotX, rotationY:fromRotY, rotationZ:fromRotZ});
				TweenLite.to(_currentCamera.camera, 0.2, {x:toPosX, y:toPosY, z:toPosZ, rotationX:toRotX, rotationY:toRotY, rotationZ:toRotZ});
			}
		}
		
	}
}