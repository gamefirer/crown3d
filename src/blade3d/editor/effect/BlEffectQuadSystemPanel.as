/**
 *	面片系统界面 
 */
package blade3d.editor.effect
{
	import blade3d.editor.BlEditorManager;
	import blade3d.editor.BlResourceEditor;
	import blade3d.resource.BlImageResource;
	import blade3d.resource.BlResource;
	import blade3d.resource.BlResourceManager;
	import blade3d.utils.BlStringUtils;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	
	import org.aswing.AssetPane;
	import org.aswing.JButton;
	import org.aswing.JCheckBox;
	import org.aswing.JComboBox;
	import org.aswing.JLabel;
	import org.aswing.JPanel;
	import org.aswing.JStepper;
	import org.aswing.LayoutManager;
	import org.aswing.VectorListModel;
	import org.aswing.colorchooser.VerticalLayout;
	
	public class BlEffectQuadSystemPanel extends JPanel
	{
		private var _quadXML : XML;
		
		private var _wide : JStepper;
		private var _height : JStepper;
		private var _rot : JStepper;
		private var _zUp : JCheckBox;
		private var _billBoard : JCheckBox;
		
		private var _orient : JComboBox;
		
		// 贴图
		private var _texSelectBtn: JButton;
		private var _texUrl : JLabel;
		private var _texPreview : AssetPane;		// 贴图预览
		
		public function set srcData(quadXML:XML):void
		{
			_quadXML = quadXML;
			updateUIByData();
		}
		
		public function BlEffectQuadSystemPanel()
		{
			super(new VerticalLayout);
			initUI();
		}
		
		private function initUI():void
		{
			var hPanel : JPanel;
			
			append(hPanel = new JPanel);
			hPanel.append(new JLabel("宽"));
			hPanel.append(_wide = new JStepper);
			_wide.addActionListener(updateData);
			
			
			append(hPanel = new JPanel);
			hPanel.append(new JLabel("高"));
			hPanel.append(_height = new JStepper);
			_height.addActionListener(updateData);
			
			append(hPanel = new JPanel);
			hPanel.append(new JLabel("初始角度"));
			hPanel.append(_rot = new JStepper);
			_rot.addActionListener(updateData);
			
			append(_zUp = new JCheckBox("遮挡"));
			_zUp.addActionListener(updateData);
			
			append(_billBoard = new JCheckBox("billboard"));
			_billBoard.addActionListener(updateData);
			
			var arr:Array = new Array;
			arr.push("面向X轴");
			arr.push("面向Y轴");
			arr.push("面向Z轴");
			_orient = new JComboBox(new VectorListModel(arr));
			_orient.setPreferredWidth(100);
			_orient.addActionListener(updateData);
			append(_orient);
			
			// 选择贴图
			_texSelectBtn = new JButton("贴图");
			_texSelectBtn.addActionListener(onSelectTex);
			append(_texSelectBtn);
			
			_texUrl = new JLabel("");
			append(_texUrl);
			
			// 贴图预览
			append(_texPreview = new AssetPane);
			_texPreview.scaleX = 1;
			_texPreview.scaleY = 1;
		}
		
		private function updateData(evt:Event):void
		{
			_quadXML.@width = _wide.getValue();
			_quadXML.@height = _height.getValue();
			_quadXML.@rot = Number(_rot.getValue() * Math.PI / 180).toFixed(2);
			_quadXML.@zUp = _zUp.isSelected() ? "true" : "false";
			_quadXML.@billboard = _billBoard.isSelected() ? "true" : "false";
			_quadXML.@orient = _orient.getSelectedIndex();
		}
		
		private function updateUIByData():void
		{
			_wide.setValue( int(_quadXML.@width.toString()) );
			_height.setValue( int(_quadXML.@height.toString()) );
			_rot.setValue( Number(_quadXML.@rot.toString()) * 180 / Math.PI );
			_zUp.setSelected( _quadXML.@zUp.toString() != "false" );
			_billBoard.setSelected(_quadXML.@billboard.toString() == "true");
			
			var orient : int = int(_quadXML.@orient.toString());
			_orient.setSelectedIndex(orient);
			
			// 贴图
			var texFileName : String = BlResourceManager.findValidPath(_quadXML.@texture.toString() + BlStringUtils.texExtName, "effect/");
			_texUrl.setText(texFileName);
			var texRes : BlImageResource = BlResourceManager.instance().findImageResource(texFileName);
			if(texRes.isLoaded)
				_texPreview.setAsset(new Bitmap(texRes.bmpData));		// 能打开此界面，此资源一定已经加载
		}
		
		private function onSelectTex(evt:Event):void
		{
			BlEditorManager.instance()._resourceEditor.setSelectFunction(onSelectTexEnd, "选择条带的贴图", BlResourceEditor.FILTER_TEXTURE);
			BlEditorManager.instance().showResourceEditor(true);
		}
		
		private function onSelectTexEnd(res:BlResource):void
		{
			if(!_quadXML) return;
			
			if(res.resType != BlResourceManager.TYPE_IMAGE)
				return;
			
			BlImageResource(res).asycLoad(onLoadTex);
		}
		
		private function onLoadTex(res:BlResource):void
		{
			if(!_quadXML) return;
			
			_texPreview.setAsset(new Bitmap(BlImageResource(res).bmpData));
			
			_texUrl.setText(res.url);
			_quadXML.@texture = BlStringUtils.extractFileNameNoExt(BlStringUtils.extractFileName(res.url));
		}
	}
}