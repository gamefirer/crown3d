/**
 *	力场效果器 
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
	
	public class BlEffectParticleEffectorForcePanel extends JPanel
	{
		private var _forceEffectorXML : XML;
		
		private var _dirX : JStepper;
		private var _dirY : JStepper;
		private var _dirZ : JStepper;
		
		private var _force : JStepper;
		
		public function set srcData(attractXML:XML):void
		{
			_forceEffectorXML = attractXML;
			updateUIByData();
		}
		
		public function BlEffectParticleEffectorForcePanel()
		{
			super(new VerticalLayout());
			
			var hPanel : JPanel;
			
			append(new JLabel("力场方向"));
			append(hPanel = new JPanel);
			hPanel.append(_dirX = new JStepper);
			hPanel.append(_dirY = new JStepper);
			hPanel.append(_dirZ = new JStepper);
			
			_dirX.addActionListener(updateData);
			_dirY.addActionListener(updateData);
			_dirZ.addActionListener(updateData);
			
			append(new JLabel("力场大小"));
			append(_force = new JStepper);
			_force.addActionListener(updateData);
		}
		
		private function updateData(evt:Event):void
		{
			if(!_forceEffectorXML) return;
			
			_forceEffectorXML.@dir = _dirX.getValue() + " "+ _dirY.getValue() + " " + _dirZ.getValue();
			_forceEffectorXML.@f = _force.getValue();
		}
		
		private function updateUIByData():void
		{
			var dir:Vector3D = BlEffectBaseParser.parseVector3D(_forceEffectorXML.@dir.toString());
			_dirX.setValue(dir.x);
			_dirY.setValue(dir.y);
			_dirZ.setValue(dir.z);
			
			_force.setValue( int(_forceEffectorXML.@f.toString()) );
			
		}
	}
}