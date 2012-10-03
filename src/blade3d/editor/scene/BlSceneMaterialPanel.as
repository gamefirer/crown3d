/**
 *	材质面板 
 */
package blade3d.editor.scene
{
	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.materials.TextureMaterial;
	import away3d.textures.BitmapTexture;
	import away3d.textures.BitmapTextureCache;
	
	import blade3d.editor.BlEditorManager;
	import blade3d.editor.BlResourceEditor;
	import blade3d.resource.BlImageResource;
	import blade3d.resource.BlResource;
	import blade3d.resource.BlResourceManager;
	
	import flash.display.Bitmap;
	import flash.display.BlendMode;
	import flash.display3D.Context3DCompareMode;
	import flash.events.Event;
	
	import org.aswing.ASColor;
	import org.aswing.AssetPane;
	import org.aswing.JAdjuster;
	import org.aswing.JButton;
	import org.aswing.JCheckBox;
	import org.aswing.JColorChooser;
	import org.aswing.JComboBox;
	import org.aswing.JFrame;
	import org.aswing.JLabel;
	import org.aswing.JPanel;
	import org.aswing.JScrollPane;
	import org.aswing.JStepper;
	import org.aswing.LayoutManager;
	import org.aswing.VectorListModel;
	import org.aswing.colorchooser.VerticalLayout;
	
	public class BlSceneMaterialPanel extends JPanel
	{
		private var _obj:Mesh;
		private var _tex:TextureMaterial;
		
		private var _texPreview : AssetPane;		// 贴图预览
		private var _texSelectBtn: JButton;
		
		private var _renderLayer : JComboBox;		// 渲染层级
		private var _blendMode : JComboBox;		// 混合模式
		private var _bothSides : JCheckBox;		// 双面显示
		private var _mipmap : JCheckBox;			// mipmap
		private var _smooth : JCheckBox;			// 平滑采样
		private var _repeat : JCheckBox;			// 贴图重复
		private var _depthWrite : JCheckBox;		// 写Z
		private var _castShadow : JCheckBox;		// 产生阴影
		private var _depthCompareMode : JComboBox;	// 深度测试模式
		
		private var _renderPriority : JStepper;		// 渲染优先级
		private var _zbais : JStepper;					// zbais
		
		private var _alpha : JAdjuster;				// alpha
		private var _alphaBlending : JCheckBox;		// 是否透明
		private var _alphaThreshold : JStepper;		// alpha裁剪
		private var _gloss : JStepper;					// 高光度
		private var _ambient : JStepper;				// 环境反射
		private var _specular : JStepper;				// 镜面反射
		private var _ambientColor : JButton;			// 环境反射色
		private var _ambientColorTxt : JLabel;
		private var _specularColor : JButton;			// 镜面反射色
		private var _specularColorTxt : JLabel;
		
		private var _chooseColorIndex : int;
		private var _chooserDialog:JFrame;			// 颜色选择框
		
		public function BlSceneMaterialPanel()
		{
			super(new VerticalLayout());
			
			// 颜色选择
			_chooserDialog = JColorChooser.createDialog(new JColorChooser(), this, "选择颜色", 
				true, __colorSelected);
			
			// 渲染层级
			var arr : Array = new Array;
			arr.push("场景层");
			arr.push("地表贴花层");
			arr.push("角色渲染层");
			arr.push("特效渲染层");
			arr.push("贴图灯渲染层");
			arr.push("投影层");
			
			_renderLayer = new JComboBox(new VectorListModel(arr));
			_renderLayer.setPreferredWidth(100);
			_renderLayer.addActionListener(onUIChange);
			append(_renderLayer);
			
			// 混合模式
			arr.length = 0;
			arr.push("normal");
			arr.push("alpha");
			arr.push("add");
			_blendMode = new JComboBox(new VectorListModel(arr));
			_blendMode.setPreferredWidth(100);
			_blendMode.addActionListener(onUIChange);
			append(_blendMode);
			
			var hPanel : JPanel = new JPanel;
			append(hPanel);
			// 双面显示
			hPanel.append(_bothSides = new JCheckBox("双面渲染"));
			_bothSides.addActionListener(
				function(evt:Event):void
				{
					if(!_tex) return;
					_tex.bothSides = _bothSides.isSelected();
				}
				);
			// mipmap
			hPanel.append(_mipmap = new JCheckBox("mipmap"));
			_mipmap.addActionListener(
				function(evt:Event):void
				{
					if(!_tex) return;
					_tex.mipmap = _mipmap.isSelected();
				}
			);
			// smooth
			hPanel.append(_smooth = new JCheckBox("平滑"));
			_smooth.addActionListener(
				function(evt:Event):void
				{
					if(!_tex) return;
					_tex.smooth = _smooth.isSelected();
				}
			);
			// repeat
			hPanel.append(_repeat = new JCheckBox("重复"));
			_repeat.addActionListener(
				function(evt:Event):void
				{
					if(!_tex) return;
					_tex.repeat = _repeat.isSelected();
				}
			);
			
			var hPanel2 : JPanel = new JPanel;
			append(hPanel2);
			
			// 渲染优先级
			hPanel2.append(new JLabel("渲染优先级"));	
			
			hPanel2.append(_renderPriority = new JStepper());
			_renderPriority.addActionListener(
				function(evt:Event):void
				{
					if(!_tex) return;
					_tex.renderPriority = _renderPriority.getValue();
				}
			);
			
			var hPanel3 : JPanel = new JPanel;
			append(hPanel3);
			
			// 写z值
			hPanel3.append(_depthWrite = new JCheckBox("写Z"));
			_depthWrite.addActionListener(
				function(evt:Event):void
				{
					if(!_tex) return;
					_tex.depthWrite = _depthWrite.isSelected();
				}
			);
			// 产生阴影
			hPanel3.append(_castShadow = new JCheckBox("阴影"));
			_castShadow.addActionListener(
				function(evt:Event):void
				{
					if(!_tex) return;
					_obj.castsShadows = _castShadow.isSelected();
				}
			);
			
			var hPanel4 : JPanel = new JPanel;
			append(hPanel4);
			
			// zbais
			hPanel4.append(new JLabel("深度偏移"));
			hPanel4.append(_zbais = new JStepper());
			_zbais.addActionListener(
				function(evt:Event):void
				{
					if(!_tex) return;
					_tex.zBias = _zbais.getValue();
				}
				);
			
			append(new JLabel("深度检测模式"));
			
			arr.length = 0;
			arr.push(Context3DCompareMode.ALWAYS);
			arr.push(Context3DCompareMode.EQUAL);
			arr.push(Context3DCompareMode.GREATER);
			arr.push(Context3DCompareMode.GREATER_EQUAL);
			arr.push(Context3DCompareMode.LESS);
			arr.push(Context3DCompareMode.LESS_EQUAL);
			arr.push(Context3DCompareMode.NEVER);
			arr.push(Context3DCompareMode.NOT_EQUAL);
			_depthCompareMode = new JComboBox(new VectorListModel(arr));
			_depthCompareMode.setPreferredWidth(100);
			_depthCompareMode.addActionListener(onUIChange);
			append(_depthCompareMode);
			
			var hPanel_10 : JPanel = new JPanel;
			append(hPanel_10);
			
			hPanel_10.append(new JLabel("透明度"));
			hPanel_10.append(_alpha = new JAdjuster());
			_alpha.addActionListener(
				function(evt:Event):void
				{
					if(!_tex) return;
					_tex.alpha = Number(_alpha.getValue()) / 100;
				}
			);
			
			append(_alphaBlending = new JCheckBox("半透明"));
			_alphaBlending.addActionListener(
				function(evt:Event):void
				{
					if(!_tex) return;
					_tex.alphaBlending = _alphaBlending.isSelected();
				}
			);
		
			var hPanel_11 : JPanel = new JPanel;
			append(hPanel_11);
			
			hPanel_11.append(new JLabel("alpha裁剪"));
			hPanel_11.append(_alphaThreshold = new JStepper());
			_alphaThreshold.addActionListener(
				function(evt:Event):void
				{
					if(!_tex) return;
					_tex.alphaThreshold = Number(_alphaThreshold.getValue())/255;
				}
			);
			
			var hPanel_12 : JPanel = new JPanel;
			append(hPanel_12);
			
			hPanel_12.append(new JLabel("高光度"));
			hPanel_12.append(_gloss = new JStepper);
			_gloss.addActionListener(
				function(evt:Event):void
				{
					if(!_tex) return;
					_tex.gloss = _gloss.getValue();
				}
			);
			
			
			var hPanel_13 : JPanel = new JPanel;
			append(hPanel_13);
			
			hPanel_13.append(new JLabel("环境反射度"));
			hPanel_13.append(_ambient = new JStepper);
			_ambient.addActionListener(
				function(evt:Event):void
				{
					if(!_tex) return;
					_tex.ambient = Number(_ambient.getValue())/100;
				}
			);
			
			var hPanel_14 : JPanel = new JPanel;
			append(hPanel_14);
			
			hPanel_14.append(new JLabel("镜面反射度"));
			hPanel_14.append(_specular = new JStepper);
			_specular.addActionListener(
				function(evt:Event):void
				{
					if(!_tex) return;
					_tex.specular = Number(_specular.getValue())/100;
				}
			);
			
			append(_ambientColor = new JButton("环境反射色"));
			_ambientColor.addActionListener(
				function(evt:Event):void
				{
					if(!_tex) return;
					_chooseColorIndex = 0;
					_chooserDialog.show();
				}
			);
			append(_ambientColorTxt = new JLabel(""));
			
			append(_specularColor= new JButton("镜面反射色"));
			_specularColor.addActionListener(
				function(evt:Event):void
				{
					if(!_tex) return;
					_chooseColorIndex = 1;
					_chooserDialog.show();
				}
			);
			append(_specularColorTxt = new JLabel(""));
			
			
			// 贴图
			append(_texSelectBtn = new JButton("贴图"));
			_texSelectBtn.addActionListener(onSelectTex);
			append(_texPreview = new AssetPane);
			_texPreview.scaleX = 0.25;
			_texPreview.scaleY = 0.25
		}
		
		private function __colorSelected(color:ASColor):void
		{
			if(!_tex) return;
			if(_chooseColorIndex == 0)
			{
				_tex.ambientColor = (color.getRed()<<16) + (color.getGreen()<<8) + color.getBlue();
			}
			else if(_chooseColorIndex == 1)
			{
				_tex.specularColor= (color.getRed()<<16) + (color.getGreen()<<8) + color.getBlue();
			}
			
			onUIChange(null);
		}
		
		public function setObj(obj:Mesh):void
		{
			_obj = obj;
			_tex = TextureMaterial(_obj.material);
			updatePanel();
		}
		
		private function onUIChange(evt:Event):void
		{
			if(!_obj) return;
			var i : int;
			
			// 混合模式
			i = _blendMode.getSelectedIndex();
			switch(i)
			{
				case 0:
					_tex.blendMode = BlendMode.NORMAL;
					break;
				case 1:
					_tex.blendMode = BlendMode.ALPHA;
					break;
				case 2:
					_tex.blendMode = BlendMode.ADD;
					break;
			}
			
			// 渲染层
			i = Math.pow(2, _renderLayer.getSelectedIndex());
			_obj.renderLayer = i;
			
			// 深度检测
			i = _depthCompareMode.getSelectedIndex();
			switch(i)
			{
				case 0:
					_tex.depthCompareMode = Context3DCompareMode.ALWAYS;
					break;
				case 1:
					_tex.depthCompareMode = Context3DCompareMode.EQUAL;
					break;
				case 2:
					_tex.depthCompareMode = Context3DCompareMode.GREATER;
					break;
				case 3:
					_tex.depthCompareMode = Context3DCompareMode.GREATER_EQUAL;
					break;
				case 4:
					_tex.depthCompareMode = Context3DCompareMode.LESS;
					break;
				case 5:
					_tex.depthCompareMode = Context3DCompareMode.LESS_EQUAL;
					break;
				case 6:
					_tex.depthCompareMode = Context3DCompareMode.NEVER;
					break;
				case 7:
					_tex.depthCompareMode = Context3DCompareMode.NOT_EQUAL;
					break;
				
			}
			
			_ambientColorTxt.setText(_tex.ambientColor.toString(16));
			if(_tex.specularMethod)
				_specularColorTxt.setText(_tex.specularColor.toString(16));
		}
		
		private function updatePanel():void
		{
			if(_tex.texture)
				_texPreview.setAsset(new Bitmap( BitmapTexture(_tex.texture).bitmapData ));
			
			_renderLayer.setSelectedIndex(_obj.renderLayer / 2);
			
			_bothSides.setSelected(_tex.bothSides);
			_mipmap.setSelected(_tex.mipmap);
			_smooth.setSelected(_tex.smooth);
			_repeat.setSelected(_tex.repeat);
			_depthWrite.setSelected(_tex.depthWrite);
			_castShadow.setSelected(_obj.castsShadows);
			_renderPriority.setValue(_tex.renderPriority);
			_zbais.setValue(_tex.zBias);
			_alpha.setValue(_tex.alpha * 100);
			_alphaBlending.setSelected(_tex.alphaBlending);
			_alphaThreshold.setValue(_tex.alphaThreshold * 255);
			_gloss.setValue(_tex.gloss);
			_ambient.setValue(_tex.ambient* 100);
			_specular.setValue(_tex.specular * 100);
			_ambientColorTxt.setText(_tex.ambientColor.toString(16));
			if(_tex.specularMethod)
				_specularColorTxt.setText(_tex.specularColor.toString(16));
			
			// 混合模式
			switch(_tex.blendMode)
			{
				case  BlendMode.NORMAL:
					_blendMode.setSelectedIndex(0);
					break;
				case BlendMode.ALPHA:
					_blendMode.setSelectedIndex(1);
					break;
				case BlendMode.ADD:
					_blendMode.setSelectedIndex(2);
					break;
			}
			
			// 深度测试模式
			switch(_tex.depthCompareMode)
			{
				case Context3DCompareMode.ALWAYS:
					_depthCompareMode.setSelectedIndex(0);
					break;
				case Context3DCompareMode.EQUAL:
					_depthCompareMode.setSelectedIndex(1);
					break;
				case Context3DCompareMode.GREATER:
					_depthCompareMode.setSelectedIndex(2);
					break;
				case Context3DCompareMode.GREATER_EQUAL:
					_depthCompareMode.setSelectedIndex(3);
					break;
				case Context3DCompareMode.LESS:
					_depthCompareMode.setSelectedIndex(4);
					break;
				case Context3DCompareMode.LESS_EQUAL:
					_depthCompareMode.setSelectedIndex(5);
					break;
				case Context3DCompareMode.NEVER:
					_depthCompareMode.setSelectedIndex(6);
					break;
				case Context3DCompareMode.NOT_EQUAL:
					_depthCompareMode.setSelectedIndex(7);
					break;
			}
		}
		
		private function onSelectTex(evt:Event):void
		{
			BlEditorManager.instance()._resourceEditor.setSelectFunction(onSelectTexEnd, "选择贴图灯的贴图", BlResourceEditor.FILTER_TEXTURE);
			BlEditorManager.instance().showResourceEditor(true);
		}
		
		private function onSelectTexEnd(res:BlResource):void
		{
			if(!_obj) return;
			if(res.resType != BlResourceManager.TYPE_IMAGE)
				return;
			
			BlImageResource(res).asycLoad(onLoadTex);
		}
		
		private function onLoadTex(res:BlResource):void
		{
			if(!_obj) return;
			_texPreview.setAsset(new Bitmap(BlImageResource(res).bmpData));
			_tex = new TextureMaterial(BitmapTextureCache.instance().getTexture( BlImageResource(res).bmpData ));
			_obj.material = _tex
			_obj.material.bitmapDataUrl = res.url;
			
			updatePanel();
		}
	}
}