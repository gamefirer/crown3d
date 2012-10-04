/**
 *	3D ui 的根节点 
 */
package blade3d.ui
{
	import away3d.debug.Debug;
	
	import blade3d.ui.editor.slModelShower;
	import blade3d.ui.editor.slRttShower;
	
	import sl2d.display.slWindow;
	
	public class slUIFrame extends slWindow
	{
		public var rttShower : slRttShower;		// 后期渲染显示器
		public var modelShower : slModelShower;	// 模型预览显示器
		
		static public var instance : slUIFrame;
		
		public function slUIFrame()
		{
			super();
			
			Debug.assert(!instance, "slUIFrame create twice");
			instance = this;
			
			// 创建界面
			initUI();
		}
		
		private function initUI():void
		{
			// 后期渲染显示其
			rttShower = new slRttShower;
			addChild(rttShower);
			
			modelShower = new slModelShower;
			addChild(modelShower);
		}
		
	}
}