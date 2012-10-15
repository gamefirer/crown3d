/**
 *	拖尾生成器 
 */
package blade3d.editor.effect
{
	import flash.events.Event;
	
	import org.aswing.JAdjuster;
	import org.aswing.JLabel;
	import org.aswing.JPanel;
	import org.aswing.LayoutManager;
	import org.aswing.colorchooser.VerticalLayout;
	
	public class BlEffectStripeDraggerPanel extends JPanel
	{
		private var _draggerXML : XML;
		
		private var _A : JAdjuster;
		private var _R : JAdjuster;
		private var _G : JAdjuster;
		private var _B : JAdjuster;
		
		public function set srcData(draggerXML:XML):void
		{
			_draggerXML = draggerXML;
			updateUIByData();
		}
		
		public function BlEffectStripeDraggerPanel()
		{
			super(new VerticalLayout);
			
			append(new JLabel("透明度"));
			append(_A = new JAdjuster);
			_A.setMinimum(0);
			_A.setMaximum(255);
			_A.addActionListener(updateData);
			
			append(new JLabel("红"));
			append(_R = new JAdjuster);
			_R.setMinimum(0);
			_R.setMaximum(255);
			_R.addActionListener(updateData);
			
			append(new JLabel("绿"));
			append(_G = new JAdjuster);
			_G.setMinimum(0);
			_G.setMaximum(255);
			_G.addActionListener(updateData);
			
			append(new JLabel("蓝"));
			append(_B = new JAdjuster);
			_B.setMinimum(0);
			_B.setMaximum(255);
			_B.addActionListener(updateData);
			
		}
		
		private function updateData(evt:Event):void
		{
			_draggerXML.@a = _A.getValue();
			_draggerXML.@r = _R.getValue();
			_draggerXML.@g = _G.getValue();
			_draggerXML.@b = _B.getValue();
		}
		
		private function updateUIByData():void
		{
			_A.setValue( int(_draggerXML.@a.toString()) );
			_R.setValue( int(_draggerXML.@r.toString()) );
			_G.setValue( int(_draggerXML.@g.toString()) );
			_B.setValue( int(_draggerXML.@b.toString()) );
		}
	}
}