/**
 *	预览模型显示框 
 */
package blade3d.profiler
{
	import blade3d.viewer.BlViewer;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	
	public class ViewStats extends Sprite
	{
		private const _WIDTH : Number = 200;
		private const _HEIGHT : Number = 200;
		private var _dia_bmp : BitmapData;
		private var _diagram : Sprite;
		
//		private var _viewSimple : BlViewer;
		
		public function ViewStats()
		{
			super();
			
			x = 200;
			
			init();
		}
		
		private function init() : void
		{
			_dia_bmp = new BitmapData(_WIDTH, _HEIGHT, true, 0x22333333);
			_diagram = new Sprite;
			_diagram.graphics.beginBitmapFill(_dia_bmp);
			_diagram.graphics.drawRect(0, 0, _dia_bmp.width, _dia_bmp.height);
			_diagram.graphics.endFill();
			_diagram.y = 0;
			addChild(_diagram);
			
//			_viewSimple = new BlViewer;
//			_viewSimple.y = 20;
//			_viewSimple.width = _WIDTH;
//			_viewSimple.height = _HEIGHT - _viewSimple.y;
//			addChild(_viewSimple);
//			
//			_viewSimple.backgroundColor = 0xff0000;
		}
		
		public function render() : void
		{
//			_viewSimple.render();
		}
	}
}