/**
 *	采样器编辑界面 
 */
package blade3d.editor.effect
{
	import away3d.debug.Debug;
	
	import blade3d.editor.BlEditorManager;
	import blade3d.editor.BlResourceEditor;
	import blade3d.resource.BlImageResource;
	import blade3d.resource.BlResource;
	import blade3d.resource.BlResourceManager;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	
	import org.aswing.ASColor;
	import org.aswing.AssetPane;
	import org.aswing.JButton;
	import org.aswing.JComboBox;
	import org.aswing.JLabel;
	import org.aswing.JPanel;
	import org.aswing.JTextField;
	import org.aswing.LayoutManager;
	import org.aswing.VectorListModel;
	import org.aswing.border.LineBorder;
	import org.aswing.colorchooser.VerticalLayout;
	
	public class BlEffectParticleSamplerPanel extends JPanel
	{
		// 采样器类型
		private var _samplerTypeComboBox : JComboBox;
		private var _samplerTypeModel : VectorListModel;
		
		// 贴图的url
		private var _texUrlTxt : JTextField;
		private var _texSelect : JButton;
		private var _texPreview : AssetPane;		// 图片预览
		
		public function BlEffectParticleSamplerPanel()
		{
			super(new VerticalLayout);
			
			_samplerTypeModel = new VectorListModel;
			_samplerTypeModel.append("面片发射器");
			_samplerTypeComboBox = new JComboBox(_samplerTypeModel);
			_samplerTypeComboBox.setPreferredWidth(100);
			append(_samplerTypeComboBox);
			
			append(new JLabel("贴图"));
			append(_texUrlTxt = new JTextField(""));
			_texUrlTxt.setPreferredWidth(200);
			_texUrlTxt.addActionListener(onUrlTxt);
			append(_texSelect = new JButton("选择"));
			_texSelect.addActionListener(onSelectTex);
			
			append(_texPreview = new AssetPane());
			_texPreview.setBorder(new LineBorder(null, ASColor.BLACK));
			
			
			
		}
		
		public function set srcData(data:XML):void
		{
//			_srcData = data;
			updateUIByData();
		}
		
		private function updateUIByData():void
		{
//			switch(_srcData.samplerType)
//			{
//				case ParticleSample.SAMPLER_TYPE_DEFAULT:
//				{
//					_samplerTypeComboBox.setSelectedIndex(0);
//					break;
//				}
//				default:
//				{
//					Debug.assert(false);
//					break;
//				}
//			}
//			
//			_texUrlTxt.setText(_srcData.texUrl);
			
			onUrlTxt(null);
		}
		
		private function onUrlTxt(evt:Event):void
		{
			var url : String = _texUrlTxt.getText();
			var imageRes : BlImageResource = BlResourceManager.instance().findImageResource(url);
			if(!imageRes) return;
			
//			_srcData.texUrl = url;
			
			if(imageRes.bmpData)
				_texPreview.setAsset(new Bitmap(imageRes.bmpData));
			else
				imageRes.load();
				
		}
		
		private var _selectDialog : BlResourceEditor;
		
		private function onSelectTex(evt:Event):void
		{
			BlEditorManager.instance()._resourceEditor.setSelectFunction(onSelectTexEnd, "选择粒子采集器贴图", 0x4);
			BlEditorManager.instance().showResourceEditor(true);
		}
		
		private function onSelectTexEnd(res:BlResource):void
		{
			_texUrlTxt.setText(res.url);
			onUrlTxt(null);
		}
	}
}