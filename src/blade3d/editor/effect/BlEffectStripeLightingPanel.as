/**
 *	条带生成器 
 */
package blade3d.editor.effect
{
	import flash.events.Event;
	
	import org.aswing.JAdjuster;
	import org.aswing.JLabel;
	import org.aswing.JPanel;
	import org.aswing.JStepper;
	import org.aswing.LayoutManager;
	import org.aswing.colorchooser.VerticalLayout;
	
	public class BlEffectStripeLightingPanel extends JPanel
	{
		private var _lightingXML : XML;
		
		private var _shakeAmp : JStepper;
		private var _shakeTime : JStepper;
		private var _lifeTime : JStepper;
		
		private var _A : JAdjuster;
		private var _R : JAdjuster;
		private var _G : JAdjuster;
		private var _B : JAdjuster;
		
		
		public function set srcData(draggerXML:XML):void
		{
			_lightingXML = draggerXML;
			updateUIByData();
		}
		
		public function BlEffectStripeLightingPanel()
		{
			super(new VerticalLayout);
			
			append(new JLabel("震动幅度"));
			append(_shakeAmp = new JStepper);
			_shakeAmp.addActionListener(updateData);
			
			append(new JLabel("_shakeTime"));
			append(_shakeTime = new JStepper);
			_shakeTime.addActionListener(updateData);
			
			append(new JLabel("_lifeTime"));
			append(_lifeTime = new JStepper);
			_lifeTime.addActionListener(updateData);
			
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
			_lightingXML.@shakeamp = _shakeAmp.getValue();
			_lightingXML.@shaketime = _shakeTime.getValue();
			_lightingXML.@lifeTime = _lifeTime.getValue();
			
			_lightingXML.@a = _A.getValue();
			_lightingXML.@r = _R.getValue();
			_lightingXML.@g = _G.getValue();
			_lightingXML.@b = _B.getValue();
		}
		
		private function updateUIByData():void
		{
			_shakeAmp.setValue( int(_lightingXML.@shakeamp.toString()) );
			_shakeTime.setValue( int(_lightingXML.@shaketime.toString()) );
			_lifeTime.setValue( int(_lightingXML.@lifeTime.toString()) );
			
			_A.setValue( int(_lightingXML.@a.toString()) );
			_R.setValue( int(_lightingXML.@r.toString()) );
			_G.setValue( int(_lightingXML.@g.toString()) );
			_B.setValue( int(_lightingXML.@b.toString()) );
		}
	}
}