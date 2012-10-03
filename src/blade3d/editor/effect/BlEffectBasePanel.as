/**
 *	基础属性
 */
package blade3d.editor.effect
{
	import blade3d.effect.parser.BlEffectBaseParser;
	
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	import org.aswing.ASColor;
	import org.aswing.JButton;
	import org.aswing.JLabel;
	import org.aswing.JPanel;
	import org.aswing.JStepper;
	import org.aswing.JTextField;
	import org.aswing.LayoutManager;
	import org.aswing.border.LineBorder;
	import org.aswing.colorchooser.VerticalLayout;
	
	public class BlEffectBasePanel extends JPanel
	{
		
		// panel
		private var _posPanel : JPanel;
		private var _rotPanel : JPanel;
		private var _scalePanel : JPanel;
		
		private var _nameTxt : JTextField;
				
		private var _posx : JStepper;
		private var _posy : JStepper;
		private var _posz : JStepper;
		
		private var _rotx : JStepper;
		private var _roty : JStepper;
		private var _rotz : JStepper;
		
		private var _sclx : JStepper;
		private var _scly : JStepper;
		private var _sclz : JStepper;
		
		private var _propertyXML : XML;
		
		public function BlEffectBasePanel()
		{
			super(new VerticalLayout());
			setBorder(new LineBorder(null, ASColor.ORANGE));
			
			_posPanel = new JPanel();
			_rotPanel = new JPanel();
			_scalePanel = new JPanel();
			
			// 名字
			append(new JLabel("名字:"));
			_nameTxt = new JTextField();
			_nameTxt.setPreferredWidth(100);
			_nameTxt.addActionListener(changeValue);
			append(_nameTxt);
			
			var nameOkBtn : JButton = new JButton("确定");
			nameOkBtn.addActionListener(changeValue);
			append(nameOkBtn);
			
			// 位置
			var posLabel : JLabel = new JLabel("位置:");
			append(posLabel);
			append(_posPanel);
			
			_posPanel.append(_posx = new JStepper(4));
			_posPanel.append(_posy = new JStepper(4));
			_posPanel.append(_posz = new JStepper(4));

			_posx.addActionListener(changeValue);
			_posy.addActionListener(changeValue);
			_posz.addActionListener(changeValue);
			
			_posx.setMaximum(99999999);
			_posx.setMinimum(-99999999);
			_posy.setMaximum(99999999);
			_posy.setMinimum(-99999999);
			_posz.setMaximum(99999999);
			_posz.setMinimum(-99999999);
			
			// 旋转
			var rotLabel : JLabel = new JLabel("旋转:");
			append(rotLabel);
			append(_rotPanel);
			
			_rotPanel.append(_rotx = new JStepper(4));
			_rotPanel.append(_roty = new JStepper(4));
			_rotPanel.append(_rotz = new JStepper(4));
			
			_rotx.addActionListener(changeValue);
			_roty.addActionListener(changeValue);
			_rotz.addActionListener(changeValue);
			
			_rotx.setMaximum(99999999);
			_rotx.setMinimum(-99999999);
			_roty.setMaximum(99999999);
			_roty.setMinimum(-99999999);
			_rotz.setMaximum(99999999);
			_rotz.setMinimum(-99999999);
			
			// 缩放
			var scaleLabel : JLabel = new JLabel("缩放:");
			append(scaleLabel);
			append(_scalePanel);
			
			_scalePanel.append(_sclx = new JStepper(4));
			_scalePanel.append(_scly = new JStepper(4));
			_scalePanel.append(_sclz = new JStepper(4));
			
			_sclx.addActionListener(changeValue);
			_scly.addActionListener(changeValue);
			_sclz.addActionListener(changeValue);
			
			_sclx.setMaximum(99999999);
			_sclx.setMinimum(-99999999);
			_scly.setMaximum(99999999);
			_scly.setMinimum(-99999999);
			_sclz.setMaximum(99999999);
			_sclz.setMinimum(-99999999);
			
			_sclx.setEnabled(false);
			_scly.setEnabled(false);
			_sclz.setEnabled(false);
			
		}
		
		public function set srcData(propertyXML:XML):void
		{
			_propertyXML = propertyXML;
			if(!_propertyXML) return;
			
			// 位移
			var pos : Vector3D = new Vector3D(0, 0, 0);
			if(_propertyXML.@pos)
				pos = BlEffectBaseParser.parseVector3D(_propertyXML.@pos.toString());
			_posx.setValue(pos.x);
			_posy.setValue(pos.y);
			_posz.setValue(pos.z);
			
			// 旋转
			var rot : Vector3D = new Vector3D(0, 0, 0);
			if(_propertyXML.@rot)
				rot = BlEffectBaseParser.parseVector3D(_propertyXML.@rot.toString());
			_rotx.setValue(rot.x);
			_roty.setValue(rot.y);
			_rotz.setValue(rot.z);
			
			// 缩放
			var scl : Vector3D = new Vector3D(1, 1, 1);
			if(_propertyXML.@scl.toString().length)
				scl = BlEffectBaseParser.parseVector3D(_propertyXML.@scl.toString());
			
			_sclx.setValue(scl.x*100);
			_scly.setValue(scl.y*100);
			_sclz.setValue(scl.z*100);
						
			_nameTxt.setText(_propertyXML.@label);
		}
		
		private function changeValue(evt:Event):void
		{
			if(!_propertyXML) return;
			
			_propertyXML.@pos = _posx.getValue()+" "+_posy.getValue()+" "+_posz.getValue();
			_propertyXML.@rot = _rotx.getValue()+" "+_roty.getValue()+" "+_rotz.getValue();
			_propertyXML.@scl = (_sclx.getValue()/100)+" "+(_scly.getValue()/100)+" "+(_sclz.getValue()/100);
			_propertyXML.@label = _nameTxt.getText();
		}
	}
}