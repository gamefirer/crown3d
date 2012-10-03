/**
 *	球形发射器面板 
 */
package blade3d.editor.effect
{
	import flash.events.Event;
	
	import org.aswing.JLabel;
	import org.aswing.JPanel;
	import org.aswing.JStepper;
	import org.aswing.LayoutManager;
	import org.aswing.colorchooser.VerticalLayout;
	
	public class BlEffectParticleSphereEmitterPanel extends JPanel
	{
		private var _emitXML : XML;
		
		private var _minR : JStepper;
		private var _maxR : JStepper;
		
		public function BlEffectParticleSphereEmitterPanel(layout:LayoutManager=null)
		{
			super(new VerticalLayout);
			
			append(new JLabel("内径"));
			_minR = new JStepper(5);
			_minR.addActionListener(onData);
			append(_minR);
			
			append(new JLabel("外径"));
			_maxR = new JStepper(5);
			_maxR.addActionListener(onData);
			append(_maxR);
			
		}
		
		private function onData(evt:Event):void
		{
			if(!_emitXML) return;
			
			_emitXML.@radiusbig = _maxR.getValue();
			_emitXML.@radiussmall = _minR.getValue();
		}
		
		public function set srcData(emitXML:XML):void
		{
			_emitXML = emitXML;
			
			_maxR.setValue( int(_emitXML.@radiusbig.toString()) );
			_minR.setValue( int(_emitXML.@radiussmall.toString()) );
		}
	}
}