/**
 *	粒子系统属性 
 */
package blade3d.editor.effect
{
	import blade3d.editor.BlEditorManager;
	import blade3d.editor.BlResourceEditor;
	import blade3d.effect.parser.BlEffectBaseParser;
	import blade3d.resource.BlImageResource;
	import blade3d.resource.BlModelResource;
	import blade3d.resource.BlResource;
	import blade3d.resource.BlResourceManager;
	import blade3d.utils.BlStringUtils;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	
	import org.aswing.ASColor;
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
	import org.aswing.border.LineBorder;
	import org.aswing.colorchooser.VerticalLayout;
	
	public class BlEffectParticleSystemPanel extends JPanel
	{
		private var _psXML : XML;
		
		// 最大粒子数
		private var _particleMax : JStepper;
		// 双面渲染
		private var _twoSide : JCheckBox;
		// 全局空间
		private var _global : JCheckBox;
		// billboard
		private var _billboard : JCheckBox;
		// 朝向
		private var _orient : JComboBox;
		// 模型
		private var _meshSelectBtn : JButton;
		private var _meshNoSelectBtn : JButton;
		private var _meshUrl : JLabel;
		// 贴图
		private var _texSelectBtn: JButton;
		private var _texUrl : JLabel;
		private var _texPreview : AssetPane;		// 贴图预览
		
		
		public function BlEffectParticleSystemPanel()
		{
			super(new SoftBoxLayout(SoftBoxLayout.X_AXIS));
			initUI();
		}
		
		public function set srcData(psXML:XML):void
		{
			_psXML = psXML;
			updateUIByData();
		}
		
		private function initUI():void
		{
			setBorder(new LineBorder(null, ASColor.GREEN, 1));
			
			var vPanel : JPanel = new JPanel(new VerticalLayout);
			append(vPanel);
			
			var hPanel : JPanel;
			
			// 最大粒子数
			vPanel.append(new JLabel("最大粒子数"));
			_particleMax = new JStepper;
			vPanel.append(_particleMax);
			_particleMax.addActionListener(updateData);
			
			// 双面渲染
			_twoSide = new JCheckBox("双面渲染");
			vPanel.append(_twoSide);
			_twoSide.addActionListener(updateData);
			
			// 全局空间
			_global = new JCheckBox("全局空间");
			vPanel.append(_global);
			_global.addActionListener(updateData);
			
			// billboard
			_billboard = new JCheckBox("billboard");;
			vPanel.append(_billboard);
			_billboard.addActionListener(updateData);
			
			// 朝向
			vPanel.append(new JLabel("粒子朝向"));
			var arr:Array = new Array;
			arr.push("X轴方向");
			arr.push("Y轴方向");
			arr.push("Z轴方向");
			arr.push("Y轴BillBoard");
			arr.push("速度方向");
			_orient = new JComboBox(new VectorListModel(arr));
			_orient.setPreferredWidth(100);
			vPanel.append(_orient);
			_orient.addActionListener(updateData);
			
			// 模型
			vPanel.append(new JLabel("粒子模型"));
			vPanel.append(hPanel = new JPanel);
			
			hPanel.append(_meshSelectBtn = new JButton("选择模型"));
			_meshSelectBtn.addActionListener(onSelectMesh);
			
			hPanel.append(_meshNoSelectBtn = new JButton("无模型"));
			_meshNoSelectBtn.addActionListener(
				function(evt:Event):void
				{
					_meshUrl.setText("");
					_psXML.@mesh = "";
				}
			);
			
			vPanel.append(_meshUrl = new JLabel(""));
			
			// 选择贴图
			_texSelectBtn = new JButton("贴图");
			_texSelectBtn.addActionListener(onSelectTex);
			vPanel.append(_texSelectBtn);
			
			_texUrl = new JLabel("");
			vPanel.append(_texUrl);
			
			// 贴图预览
			vPanel.append(_texPreview = new AssetPane);
			_texPreview.scaleX = 1;
			_texPreview.scaleY = 1;
		}
		
		private function onSelectMesh(evt:Event):void
		{
			BlEditorManager.instance()._resourceEditor.setSelectFunction(onSelectMeshEnd, "选择粒子的模型", BlResourceEditor.FILTER_MESH);
			BlEditorManager.instance().showResourceEditor(true);
		}
		
		private function onSelectMeshEnd(res:BlResource):void
		{
			if(!_psXML) return;
			
			if(res.resType != BlResourceManager.TYPE_MESH)
				return;
			
			BlModelResource(res).asycLoad(onLoadMesh);
		}
		
		private function onLoadMesh(res:BlResource):void
		{
			if(!_psXML) return;
			
			// 顶点数检查
			if(BlModelResource(res).geo.subGeometries.length == 0) return;
			
			var allVertexCount : uint = BlModelResource(res).geo.subGeometries[0].numVertices * _particleMax.getValue();
			if(allVertexCount >= 0xffff)
			{
				_meshUrl.setText("顶点数太多");
				return;
			}
			
			_meshUrl.setText(res.url);
			_psXML.@mesh = BlStringUtils.extractFileNameNoExt(res.url);
		}
		
		private function onSelectTex(evt:Event):void
		{
			BlEditorManager.instance()._resourceEditor.setSelectFunction(onSelectTexEnd, "选择粒子的贴图", BlResourceEditor.FILTER_TEXTURE);
			BlEditorManager.instance().showResourceEditor(true);
		}
		
		private function onSelectTexEnd(res:BlResource):void
		{
			if(!_psXML) return;
			
			if(res.resType != BlResourceManager.TYPE_IMAGE)
				return;
			
			BlImageResource(res).asycLoad(onLoadTex);
		}
		
		private function onLoadTex(res:BlResource):void
		{
			if(!_psXML) return;
			_texPreview.setAsset(new Bitmap(BlImageResource(res).bmpData));
			
			_texUrl.setText(res.url);
			_psXML.@texture = BlStringUtils.extractFileNameNoExt(BlStringUtils.extractFileName(res.url));
		}
		
		private function updateData(evt:Event):void
		{
			_psXML.@max = _particleMax.getValue();
			
			_psXML.@twoside = _twoSide.isSelected() ? 1 : 0;
			
			_psXML.@global = _global.isSelected() ? "true" : "false";
			
			_psXML.@billboard = _billboard.isSelected() ? "true" : "false";
			
			_psXML.@orient = _orient.getSelectedIndex();
			
		}
		
		private function updateUIByData():void
		{
			_twoSide.setSelected( int(_psXML.@twoside.toString()) == 1 );
			_particleMax.setValue( int(_psXML.@max.toString()) );
			_global.setSelected( (_psXML.@global.toString() == "true") );
			_billboard.setSelected( _psXML.@billboard.toString() != "false" );
			
			_orient.setSelectedIndex( int(_psXML.@orient.toString()) );
			
			var meshFileName : String = _psXML.@mesh;
			_meshUrl.setText(meshFileName);
			
			var texFileName : String = BlResourceManager.findValidPath(_psXML.@texture.toString() + BlStringUtils.texExtName, "effect/");
			_texUrl.setText(texFileName);
			var texRes : BlImageResource = BlResourceManager.instance().findImageResource(texFileName);
			if(texRes.isLoaded)
				_texPreview.setAsset(new Bitmap(texRes.bmpData));		// 能打开此界面，此资源一定已经加载
		}
		
		
	
	}
}