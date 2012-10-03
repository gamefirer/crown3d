package blade3d.scene
{
	import away3d.containers.ObjectContainer3D;
	
	import flash.events.Event;
	
	public class BlSceneEvent extends Event
	{
		public static const SCENE_LEAVE:String = "scene_leave";					// 离开场景
		public static const SCENE_ENTER:String = "scene_enter";					// 进入场景
		public static const SCENE_LOAD_START:String = "scene_start_load";		// 开始加载场景
		public static const SCENE_LOAD_END:String = "scene_end_load";			// 场景加载完毕
		public static const SCENE_DISPOSE:String = "scene_dispose";				// 场景销毁
		public static const SCENE_ADD_OBJECT:String = "scene_add";									// 场景加载物体
		
		public var scene : BlScene;
		public var addObject : ObjectContainer3D;
		
		public function BlSceneEvent(type:String, scene:BlScene, addObject:ObjectContainer3D=null)
		{
			super(type, false, false);
			this.scene = scene;
			this.addObject = addObject;
		}
	}
}