/**
 *	对象基础属性面板 
 */
package blade3d.editor.scene
{
	import away3d.containers.ObjectContainer3D;
	import away3d.events.Object3DEvent;
	
	import flash.events.Event;
	
	import org.aswing.JAdjuster;
	import org.aswing.JLabel;
	import org.aswing.JPanel;
	import org.aswing.JStepper;
	import org.aswing.JTextField;
	import org.aswing.LayoutManager;
	import org.aswing.colorchooser.VerticalLayout;
	
	public class BlSceneObjectPanel extends JPanel
	{
		private var _obj:ObjectContainer3D;
		
		private var _name : JTextField;
		// 位置
		private var posX : JStepper;
		private var posY : JStepper;
		private var posZ : JStepper;
		// 旋转
		private var rotX : JAdjuster;
		private var rotY : JAdjuster;
		private var rotZ : JAdjuster;
		// 缩放
		private var sclX : JStepper;
		private var sclY : JStepper;
		private var sclZ : JStepper;
		
		public function BlSceneObjectPanel()
		{
			super(new VerticalLayout());
			
			append(new JLabel("名字:"));
			append(_name = new JTextField(""));
			_name.setPreferredWidth(200);
			_name.addActionListener(onChange);
			
			append(new JLabel("位置:"));
			var posPanel : JPanel = new JPanel;
			append(posPanel);
			posPanel.append(posX = new JStepper);
			posPanel.append(posY = new JStepper);
			posPanel.append(posZ = new JStepper);
			
			posX.addActionListener(onChange);
			posY.addActionListener(onChange);
			posZ.addActionListener(onChange);
			
			append(new JLabel("旋转:"));
			var rotPanel : JPanel = new JPanel;
			append(rotPanel);
			rotPanel.append(rotX = new JAdjuster);
			rotPanel.append(rotY = new JAdjuster);
			rotPanel.append(rotZ = new JAdjuster);
			
			rotX.setMaximum(360);
			rotY.setMaximum(360);
			rotZ.setMaximum(360);
			
			rotX.addActionListener(onChange);
			rotY.addActionListener(onChange);
			rotZ.addActionListener(onChange);
			
			append(new JLabel("缩放:"));
			var sclPanel : JPanel = new JPanel;
			append(sclPanel);
			sclPanel.append(sclX = new JStepper);
			sclPanel.append(sclY = new JStepper);
			sclPanel.append(sclZ = new JStepper);
			
			sclX.addActionListener(onChange);
			sclY.addActionListener(onChange);
			sclZ.addActionListener(onChange);
		}
		
		private function onChange(evt:Event):void
		{
			if(!_obj) return;
			
			_obj.name = _name.getText();
			
			_obj.x = posX.getValue();
			_obj.y = posY.getValue();
			_obj.z = posZ.getValue();
			
			_obj.rotationX = rotX.getValue();
			_obj.rotationY = rotY.getValue();
			_obj.rotationZ = rotZ.getValue();
			
			_obj.scaleX = Number(sclX.getValue())/100;
			_obj.scaleY = Number(sclY.getValue())/100;
			_obj.scaleZ = Number(sclZ.getValue())/100;
		}
		
		public function setObj(obj:ObjectContainer3D):void
		{
			_obj = obj;
			_obj.addEventListener(Object3DEvent.POSITION_CHANGED, function(evt:Event):void
				{
				updatePanel();
				}
				, false, 0, true);
			
			updatePanel();
		}
		
		private function updatePanel():void
		{
			_name.setText(_obj.name);
			
			posX.setValue(_obj.x);
			posY.setValue(_obj.y);
			posZ.setValue(_obj.z);
			
			rotX.setValue(_obj.rotationX % 360);
			rotY.setValue(_obj.rotationY % 360);
			rotZ.setValue(_obj.rotationZ % 360);
			
			sclX.setValue(_obj.scaleX * 100);
			sclY.setValue(_obj.scaleY * 100);
			sclZ.setValue(_obj.scaleZ * 100);
		}
		
	}
}

