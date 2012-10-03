package blade3d.editor.scene
{
	import away3d.lights.DirectionalLight;
	
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	import org.aswing.ASColor;
	import org.aswing.BorderLayout;
	import org.aswing.JButton;
	import org.aswing.JColorChooser;
	import org.aswing.JFrame;
	import org.aswing.JLabel;
	import org.aswing.JPanel;
	import org.aswing.JStepper;
	import org.aswing.LayoutManager;
	import org.aswing.colorchooser.VerticalLayout;
	
	public class BlSceneDirectionalLightPanel extends JPanel
	{
		private var _light : DirectionalLight;
		// 光照方向
		private var dirX : JStepper;
		private var dirY : JStepper;
		private var dirZ : JStepper;
		
		private var _chooserDialog:JFrame;			// 颜色选择框
		// 颜色
		private var _colorIndex : int = 0;
		
		// 光照强度
		private var diffuse : JStepper;
		private var specular : JStepper;
		
		public function BlSceneDirectionalLightPanel()
		{
			super(new VerticalLayout());
			
			append(new JLabel("光照方向:"));
			var dirPanel : JPanel = new JPanel;
			append(dirPanel);
			dirPanel.append(dirX = new JStepper);
			dirPanel.append(dirY = new JStepper);
			dirPanel.append(dirZ = new JStepper);
			
			dirX.addActionListener(onChange);
			dirY.addActionListener(onChange);
			dirZ.addActionListener(onChange);
			
			// 光照颜色
			_chooserDialog = JColorChooser.createDialog(new JColorChooser(), this, "选择颜色", 
				true, __colorSelected);
			
			var colorBtn : JButton = new JButton("光照颜色");
			append(colorBtn);
			colorBtn.addActionListener(
				function(evt:Event):void
				{
					_colorIndex = 0;
					_chooserDialog.show();
				}
				);
			
			var ambientColorBtn : JButton = new JButton("环境光颜色");
			append(ambientColorBtn);
			ambientColorBtn.addActionListener(
				function(evt:Event):void
				{
					_colorIndex = 1;
					_chooserDialog.show();
				}
			);
			
			append(new JLabel("漫反色射度:"));
			append(diffuse = new JStepper);
			append(new JLabel("镜面反射强度:"));
			append(specular = new JStepper);
			
			diffuse.addActionListener(onChange);
			specular.addActionListener(onChange);
			
		}
		
		private function __colorSelected(color:ASColor):void
		{
			if(!_light) return;
			if(_colorIndex == 0)
			{
				_light.color = (color.getRed() << 16) + (color.getGreen() << 8) + color.getBlue();
			}
			else if(_colorIndex == 1)
			{
				_light.ambientColor = (color.getRed() << 16) + (color.getGreen() << 8) + color.getBlue();
			}
		}
		
		private function onChange(evt:Event):void
		{
			if(!_light) return;
			
			var dir:Vector3D = new Vector3D(dirX.getValue(), dirY.getValue(), dirZ.getValue());
			_light.direction = dir;
			_light.diffuse = Number(diffuse.getValue()) / 100;
			_light.specular = Number(specular.getValue()) / 100;
		}
		
		public function setObj(light:DirectionalLight):void
		{
			_light = light;
			
			dirX.setValue(_light.direction.x);
			dirY.setValue(_light.direction.y);
			dirZ.setValue(_light.direction.z);
			
			diffuse.setValue(_light.diffuse * 100);
			specular.setValue(_light.specular * 100);
		}
	}
}