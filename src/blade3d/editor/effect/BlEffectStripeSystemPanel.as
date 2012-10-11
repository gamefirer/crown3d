/**
 *	条带系统界面 
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
	import org.aswing.SoftBoxLayout;
	import org.aswing.VectorListModel;
	import org.aswing.colorchooser.VerticalLayout;
	
	public class BlEffectStripeSystemPanel extends JPanel
	{
		private var _stripeXML : XML;
		
		// 拖拽器类型
		private var _draggerType : JComboBox;
		
		private var _max : JStepper;
		private var _billBoard : JCheckBox;
		private var _timeduv : JCheckBox;
		private var _parallel : JCheckBox;
		private var _wide : JStepper;
		private var _dragTime : JStepper;
		private var _wideDir : JComboBox;
		
		// 贴图
		private var _texSelectBtn: JButton;
		private var _texUrl : JLabel;
		private var _texPreview : AssetPane;		// 贴图预览
		
		
		
		public function set srcData(stripeXML:XML):void
		{
			_stripeXML = stripeXML;
			updateUIByData();
		}
		
		public function BlEffectStripeSystemPanel()
		{
			super(new VerticalLayout);
			initUI();
		}
		
		private function initUI():void
		{
			var arr:Array;
			
			var hPanel : JPanel;
			
			// 拖拽器类型
			arr = new Array;
			arr.push("拖尾");
			arr.push("带状");
			_draggerType = new JComboBox(new VectorListModel(arr));
			_draggerType.setPreferredWidth(100);
			append(_draggerType);
			_draggerType.addActionListener(onDragger);
			
			append(hPanel = new JPanel);
			hPanel.append(new JLabel("最大面数")); 
			hPanel.append(_max = new JStepper);
			_max.addActionListener(updateData);
			
			_billBoard = new JCheckBox("billboard");
			append(_billBoard);
			_billBoard.addActionListener(updateData);
			
			_timeduv = new JCheckBox("UV随时间变化");
			append(_timeduv);
			_timeduv.addActionListener(updateData);
			
			_parallel = new JCheckBox("拉伸平行");
			append(_parallel);
			_parallel.addActionListener(updateData);
			
			append(hPanel = new JPanel);
			hPanel.append(new JLabel("宽度")); 
			hPanel.append(_wide = new JStepper);
			_wide.addActionListener(updateData);
			
			append(hPanel = new JPanel);
			hPanel.append(new JLabel("拖拽时间"));
			hPanel.append(_dragTime = new JStepper);
			_dragTime.addActionListener(updateData);
			
			append(hPanel = new JPanel);
			hPanel.append(new JLabel("条带宽度方向"));
			arr = new Array;
			arr.push("X方向");
			arr.push("Y方向");
			arr.push("Z方向");
			_wideDir = new JComboBox(new VectorListModel(arr));
			_wideDir.setPreferredWidth(100);
			hPanel.append(_wideDir);
			_wideDir.addActionListener(updateData);
			
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
		
		private function onDragger(evt:Event):void
		{
			delete _stripeXML.dragger;
			delete _stripeXML.lighting;
			
			var draggerXML : XML;
			if(_draggerType.getSelectedIndex() == 0)
			{
				draggerXML = <dragger b="255" r="255" a="255" g="255"/>;
			}
			else if(_draggerType.getSelectedIndex() == 1)
			{
				draggerXML = <lighting b="255" r="255" a="255" g="255" shakeamp="1" shaketime="500" lifeTime="0"/>;
			}
			
			_stripeXML.appendChild(draggerXML);
		}
		
		private function updateData(evt:Event):void
		{
			_stripeXML.@max = _max.getValue();
			
			_stripeXML.@billboard = _billBoard.isSelected() ? "true" : "false";
			_stripeXML.@timeduv = _timeduv.isSelected() ? "true" : "false";
			_stripeXML.@parallel = _parallel.isSelected() ? "true" : "false";
			_stripeXML.@wide = _wide.getValue();
			_stripeXML.@dragtime = _dragTime.getValue();
			
			_stripeXML.@widedir = _wideDir.getSelectedIndex();
			
		}
		
		private function updateUIByData():void
		{
			_max.setValue( int(_stripeXML.@max.toString()) ); 
			_billBoard.setSelected( _stripeXML.@billboard.toString() == "true" );
			_timeduv.setSelected( _stripeXML.@timeduv.toString() == "true" );
			_parallel.setSelected( _stripeXML.@parallel.toString() == "true" );
			_wide.setValue( int(_stripeXML.@wide.toString()) );
			_dragTime.setValue( int(_stripeXML.@dragtime.toString()) );
			
			_wideDir.setSelectedIndex( int(_stripeXML.@widedir.toString()) );
			
			// 贴图
			var texFileName : String = BlResourceManager.findValidPath(_stripeXML.@texture.toString() + BlStringUtils.texExtName, "effect/");
			_texUrl.setText(texFileName);
			var texRes : BlImageResource = BlResourceManager.instance().findImageResource(texFileName);
			if(texRes.isLoaded)
				_texPreview.setAsset(new Bitmap(texRes.bmpData));		// 能打开此界面，此资源一定已经加载
			// 拖拽器类型
			if(_stripeXML.dragger[0])
			{	// 拖尾
				_draggerType.setSelectedIndex(0);
			}
			else if(_stripeXML.lighting[0])
			{	// 带状
				_draggerType.setSelectedIndex(1);
			}
		}
		
		private function onSelectTex(evt:Event):void
		{
			BlEditorManager.instance()._resourceEditor.setSelectFunction(onSelectTexEnd, "选择条带的贴图", BlResourceEditor.FILTER_TEXTURE);
			BlEditorManager.instance().showResourceEditor(true);
		}
		
		private function onSelectTexEnd(res:BlResource):void
		{
			if(!_stripeXML) return;
			
			if(res.resType != BlResourceManager.TYPE_IMAGE)
				return;
			
			BlImageResource(res).asycLoad(onLoadTex);
		}
		
		private function onLoadTex(res:BlResource):void
		{
			if(!_stripeXML) return;
			
			_texPreview.setAsset(new Bitmap(BlImageResource(res).bmpData));
			
			_texUrl.setText(res.url);
			_stripeXML.@texture = BlStringUtils.extractFileNameNoExt(BlStringUtils.extractFileName(res.url));
		}
		
	}
}