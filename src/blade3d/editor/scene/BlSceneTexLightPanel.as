/**
 *	贴图灯面板 
 */
package blade3d.editor.scene
{
	import away3d.entities.Sprite3D;
	import away3d.materials.SceneLightMaterial;
	
	import blade3d.editor.BlEditorManager;
	import blade3d.editor.BlResourceEditor;
	import blade3d.resource.BlImageResource;
	import blade3d.resource.BlResource;
	import blade3d.resource.BlResourceManager;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	import org.aswing.ASColor;
	import org.aswing.AssetPane;
	import org.aswing.JButton;
	import org.aswing.JColorChooser;
	import org.aswing.JFrame;
	import org.aswing.JLabel;
	import org.aswing.JPanel;
	import org.aswing.JStepper;
	import org.aswing.LayoutManager;
	import org.aswing.colorchooser.VerticalLayout;
	
	public class BlSceneTexLightPanel extends JPanel
	{
		private var _light : Sprite3D;
		
		private var _intensity : JStepper;
		private var _chooserDialog:JFrame;			// 颜色选择框
		private var _colorTxt : JLabel;
		private var _texPreview : AssetPane;		// 贴图预览
		private var _texSelectBtn: JButton;
		
		public function BlSceneTexLightPanel()
		{
			super(new VerticalLayout());
			
			append(new JLabel("光照强度:"));
			append(_intensity = new JStepper);
			_intensity.setMaximum(100);
			_intensity.setMinimum(0);
			_intensity.addActionListener(onChange);
			
			// 光照颜色
			_chooserDialog = JColorChooser.createDialog(new JColorChooser(), this, "选择颜色", 
				true, __colorSelected);
			
			var colorBtn:JButton = new JButton("光照颜色");
			colorBtn.addActionListener(
				function(evt:Event):void
				{
					_chooserDialog.show();
				}
				);
			append(colorBtn);
			
			append(_colorTxt = new JLabel(""));
			
			append(new JLabel("贴图:"));
			append(_texPreview = new AssetPane);
			append(_texSelectBtn = new JButton("选择贴图"));
			_texSelectBtn.addActionListener(onSelectTex);
		}
		
		private function onChange(evt:Event):void
		{
			if(!_light) return;

			_light.intensity = Number(_intensity.getValue())/100;
			
		}
		public function setObj(light:Sprite3D):void
		{
			_light = light;
			if(!_light) return;
			
			_intensity.setValue(_light.intensity * 100);
			
			_colorTxt.setText( int(_light.color.x * 0xff).toString(16)+","+int(_light.color.y * 0xff).toString(16)+","+int(_light.color.z * 0xff).toString(16) );
			
			if(_light.material is SceneLightMaterial)
			{
				_texPreview.setAsset(new Bitmap(SceneLightMaterial(_light.material).bitmapData));
			}
		}
		
		private function __colorSelected(color:ASColor):void
		{
			_light.color = new Vector3D( Number(color.getRed())/0xFF, Number(color.getGreen())/0xFF, Number(color.getBlue())/0xFF );
			
			_colorTxt.setText( color.getRed().toString(16)+","+color.getGreen().toString(16)+","+color.getBlue().toString(16) );
		}
		
		private function onSelectTex(evt:Event):void
		{
			BlEditorManager.instance()._resourceEditor.setSelectFunction(onSelectTexEnd, "选择模型的贴图", BlResourceEditor.FILTER_TEXTURE);
			BlEditorManager.instance().showResourceEditor(true);
		}
		
		private function onSelectTexEnd(res:BlResource):void
		{
			if(!_light) return;
			if(res.resType != BlResourceManager.TYPE_IMAGE)
				return;
			
			BlImageResource(res).asycLoad(onLoadTex);
		}
		
		private function onLoadTex(res:BlResource):void
		{
			if(!_light) return;
			_texPreview.setAsset(new Bitmap(BlImageResource(res).bmpData));
			_light.material = new SceneLightMaterial(BlImageResource(res).bmpData);
			_light.material.bitmapDataUrl = res.url;
		}
	}
}