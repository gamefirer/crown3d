/**
 *	矩形发射器面板 
 */
package blade3d.editor.effect
{
	import flash.events.Event;
	
	import org.aswing.JLabel;
	import org.aswing.JPanel;
	import org.aswing.JStepper;
	import org.aswing.LayoutManager;
	import org.aswing.colorchooser.VerticalLayout;
	
	public class BlEffectParticleRectEmitterPanel extends JPanel
	{
		private var _emitXML : XML;
		
		private var stepper_X : JStepper;
		private var stepper_Y : JStepper;
		private var stepper_Z : JStepper;
		
		public function BlEffectParticleRectEmitterPanel()
		{
			super(new VerticalLayout);
			
			append(new JLabel("X宽度"));
			stepper_X = new JStepper(5);
			stepper_X.setMaximum(99999999);
			stepper_X.addActionListener(onData);
			append(stepper_X);
			
			append(new JLabel("Y宽度"));
			stepper_Y = new JStepper(5);
			stepper_Y.setMaximum(99999999);
			stepper_Y.addActionListener(onData);
			append(stepper_Y);
			
			append(new JLabel("Z宽度"));
			stepper_Z = new JStepper(5);
			stepper_Z.setMaximum(99999999);
			stepper_Z.addActionListener(onData);
			append(stepper_Z);
			
		}
		
		private function onData(evt:Event):void
		{
			if(!_emitXML) return;
			_emitXML.@rectx = stepper_X.getValue();
			_emitXML.@recty = stepper_Y.getValue();
			_emitXML.@rectz = stepper_Z.getValue();
		}
		
		public function set srcData(emitXML:XML):void
		{
			_emitXML = emitXML;
			
			stepper_X.setValue( int(_emitXML.@rectx.toString()) );
			stepper_Y.setValue( int(_emitXML.@recty.toString()) );
			stepper_Z.setValue( int(_emitXML.@rectz.toString()) );
		}
		
		
	}
}