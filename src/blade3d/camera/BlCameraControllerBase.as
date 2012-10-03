/**
 *	摄像机控制器,基类 
 */
package blade3d.camera
{
	import away3d.cameras.Camera3D;
	import away3d.errors.AbstractMethodError;
	
	import blade3d.BlEngine;
	import blade3d.io.BlInputManager;
	
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;

	public class BlCameraControllerBase
	{
		
		public var moveSpeed:Number = 20;
		public var rotSpeed:Number = 0.2;
		
		public function BlCameraControllerBase()
		{
		}
		
		public function get camera() : Camera3D {return null;}
		
		public function get name() : String {return camera.name;}
		
		public function onActive():void
		{
			throw new AbstractMethodError();
		}
		
		public function onDeactive():void
		{
			throw new AbstractMethodError();	
		}
		
		public function onMouseDown(event:MouseEvent):Boolean {return true;}
		
		public function onMouseUp(event:MouseEvent):Boolean {return true}
		
		public function onMouseWheel(event:MouseEvent):Boolean {return true;}
		
		public function update(time:uint, deltaTime:uint):void	{}
		
		public function getMouseRay() : Vector3D
		{
			var mx : Number = BlInputManager.mouseX();
			var my : Number = BlInputManager.mouseY();
			
			var x : Number = (mx * 2 - BlEngine.getStageWidth()) / BlEngine.getStageWidth();
			var y : Number = (my * 2 - BlEngine.getStageHeight()) / BlEngine.getStageHeight();
			return camera.getRay(x, y);
		}
		
		public function getCameraRay() : Vector3D
		{
			return camera.getRay(0, 0);
		}
	}
}