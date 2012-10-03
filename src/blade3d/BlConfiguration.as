package blade3d
{
	import away3d.debug.Debug;
	
	import blade3d.profiler.Profiler;
	
	import sl2d.slWorld;

	public class BlConfiguration
	{
		/**
		 *	编辑模式:
		 * 
		 *  编辑器界面
		 * 	碰撞显示模型，和地形碰撞显示模型
		 * 	编辑辅助物体
		 * 	投影灯会随camera自适应
		 * 	粒子发射器的发射器模型
		 */		
		static public var editorMode : Boolean = true; 
		
		static public function debug():void
		{
			Debug.context3DErrorCheck = true;
			Debug.active = true;
			Debug.assertEnable = true;
			Debug.warningsAsErrors = true;
			
			Profiler.isProfiler = true;
		}
		
		static public function release():void
		{
			Debug.context3DErrorCheck = false;
			Debug.active = false;
			Debug.assertEnable = true;
			Debug.warningsAsErrors = false;
			
			Profiler.isProfiler = true;
		}
		
		static public function final():void
		{
			Debug.context3DErrorCheck = false;
			Debug.active = false;
			Debug.assertEnable = false;
			Debug.warningsAsErrors = false;
			
			Profiler.isProfiler = false;
		}
	}
}