/**
 *	速度吸引器 
 */
package blade3d.editor.effect
{
	import blade3d.effect.parser.BlEffectBaseParser;
	
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	import org.aswing.JLabel;
	import org.aswing.JPanel;
	import org.aswing.JStepper;
	import org.aswing.LayoutManager;
	import org.aswing.colorchooser.VerticalLayout;
	
	public class BlEffectParticleEffectorVelAttractPanel extends JPanel
	{
		private var _velAttractEffectorXML : XML;
		
		private var _x : JStepper;
		private var _y : JStepper;
		private var _z : JStepper;
		
		private var _force : JStepper;
		
		public function set srcData(vattractXML:XML):void
		{
			_velAttractEffectorXML = vattractXML;
			updateUIByData();
		}
		
		public function BlEffectParticleEffectorVelAttractPanel()
		{
			super(new VerticalLayout());
			
			var hPanel : JPanel;
			
			append(new JLabel("吸引器位置"));
			append(hPanel = new JPanel);
			hPanel.append(_x = new JStepper);
			hPanel.append(_y = new JStepper);
			hPanel.append(_z = new JStepper);
			
			_x.addActionListener(updateData);
			_y.addActionListener(updateData);
			_z.addActionListener(updateData);
			
			append(new JLabel("吸引力"));
			append(_force = new JStepper);
			_force.addActionListener(updateData);
		}
		
		private function updateData(evt:Event):void
		{
			if(!_velAttractEffectorXML) return;
			
			_velAttractEffectorXML.@p = _x.getValue() + " "+ _y.getValue() + " " + _z.getValue();
			_velAttractEffectorXML.@f = _force.getValue();
		}
		
		private function updateUIByData():void
		{
			var pos:Vector3D = BlEffectBaseParser.parseVector3D(_velAttractEffectorXML.@p.toString());
			_x.setValue(pos.x);
			_y.setValue(pos.y);
			_z.setValue(pos.z);
			
			_force.setValue( int(_velAttractEffectorXML.@f.toString()) );
		}
	}
}