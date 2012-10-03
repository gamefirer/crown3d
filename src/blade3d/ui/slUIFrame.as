/**
 *	3D ui 的根节点 
 */
package blade3d.ui
{
	import blade3d.ui.editor.slRttShower;
	
	import sl2d.display.slWindow;
	
	public class slUIFrame extends slWindow
	{
		public var rttShower : slRttShower;
		
		public function slUIFrame()
		{
			super();
			
			// 创建界面
			initUI();
		}
		
		private function initUI():void
		{
			rttShower = new slRttShower;
			addChild(rttShower);
		}
		
		
	}
}