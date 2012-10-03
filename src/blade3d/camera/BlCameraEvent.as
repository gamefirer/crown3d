/**
 *	摄像机事件 
 */
package blade3d.camera
{
	import flash.events.Event;
	
	public class BlCameraEvent extends Event
	{
		public static const CAMERA_CHANGE:String = "camera_change";					// 改变当前摄像机
		
		public var cam : BlCameraControllerBase;
		
		public function BlCameraEvent(type:String, cam : BlCameraControllerBase)
		{
			super(type, false, false);
			this.cam = cam;
		}
	}
}