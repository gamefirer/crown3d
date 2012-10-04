/**
 *	资源管理界面 
 */
package blade3d.editor
{
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.core.base.Geometry;
	import away3d.debug.Debug;
	import away3d.entities.Mesh;
	import away3d.lights.DirectionalLight;
	import away3d.materials.MaterialBase;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.CelDiffuseMethod;
	import away3d.materials.methods.CelSpecularMethod;
	import away3d.materials.methods.OutlineMethod;
	import away3d.textures.BitmapTexture;
	import away3d.textures.BitmapTextureCache;
	
	import blade3d.BlEngine;
	import blade3d.resource.BlImageResource;
	import blade3d.resource.BlModelResource;
	import blade3d.resource.BlResource;
	import blade3d.resource.BlResourceEvent;
	import blade3d.resource.BlResourceManager;
	import blade3d.scene.BlSceneEvent;
	import blade3d.scene.BlSceneManager;
	import blade3d.ui.slUIFrame;
	import blade3d.viewer.BlViewer;
	import blade3d.viewer.BlViewerManager;
	
	import editor.EffectViewer;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import org.aswing.ASColor;
	import org.aswing.AsWingConstants;
	import org.aswing.BorderLayout;
	import org.aswing.Box;
	import org.aswing.ButtonGroup;
	import org.aswing.EmptyLayout;
	import org.aswing.FlowLayout;
	import org.aswing.Insets;
	import org.aswing.JButton;
	import org.aswing.JCheckBox;
	import org.aswing.JFrame;
	import org.aswing.JLabel;
	import org.aswing.JPanel;
	import org.aswing.JRadioButton;
	import org.aswing.JScrollPane;
	import org.aswing.JSlider;
	import org.aswing.JTextArea;
	import org.aswing.JTree;
	import org.aswing.SoftBox;
	import org.aswing.SoftBoxLayout;
	import org.aswing.SolidBackground;
	import org.aswing.UIManager;
	import org.aswing.ViewportLayout;
	import org.aswing.border.EmptyBorder;
	import org.aswing.border.LineBorder;
	import org.aswing.border.TitledBorder;
	import org.aswing.colorchooser.VerticalLayout;
	import org.aswing.event.TreeSelectionEvent;
	import org.aswing.geom.IntRectangle;
	import org.aswing.tree.DefaultMutableTreeNode;
	import org.aswing.tree.DefaultTreeModel;
	import org.aswing.tree.TreePath;
	
	public class BlResourceEditor extends JFrame
	{
		static public var FILTER_OTHER : int = 0x01;
		static public var FILTER_MESH : int = 0x02;
		static public var FILTER_TEXTURE : int = 0x04;
		
		private var _mesh : Mesh;		// 显示模型
		private var _image:Bitmap;		// 显示图片 
		
		private var _selectRes : BlResource;
		
		private var _panel : JPanel;
		
		private var _leftPanel1 : JPanel;
		private var _rightPanel1 : JPanel;
		
		private var _upPanel2 : JPanel;
		private var _centerPanel2 : JPanel;
		private var _downPanel2 : JPanel;

		
		private var _isImageChk : JCheckBox;			// 是否显示图片
		private var _isMeshChk : JCheckBox;			// 是否显示模型
		
		private var _showAllRB : JRadioButton;			// 显示全部
		private var _showMeshRB : JRadioButton;		// 显示模型
		private var _showTexRB : JRadioButton;			// 显示贴图
		private var _showFilter : uint = 0xff;				// 1 其他 2 模型 4 贴图
		
		// 预览摄像机调整
		private var _cameraZoom : JSlider;
		private var _cameraRot : JSlider;
		private var _cameraHeight : JSlider;
		
		// 资源树
		private var _resTreeCtrl : JTree;
		private var _resTreeModel : DefaultTreeModel;
		private var _rootTreeNode : DefaultMutableTreeNode;
		
		private var _selectOkBtn : JButton;
		private var _selectDescribe : JLabel;
		private var _selectCallback : Function;
		
		private var frameWide:int = 450;
		
		// 材质描述
		private var _materialDesc : JTextArea;
		
		// 3D视图
		public  var modelViewer : BlViewer;
		
		
		private var _unLoadColor : ASColor = ASColor.LIGHT_GRAY;
		private var _loadColor : ASColor = ASColor.DARK_GRAY;
		
		public function BlResourceEditor(owner:*=null, title:String="", modal:Boolean=false)
		{
			super(owner, title, modal);
			
			setSizeWH(frameWide, 500);
			var parent:Sprite = Sprite(owner);
			setLocationXY( parent.width - (frameWide+30), 0 );
			
			// 显示图片控件
			_image = new Bitmap();
			_image.x = 0;
			_image.y = 100;			
			BlEditorManager.instance().rootSprite().addChild(_image);
			
			// 创建3D视图
			modelViewer = BlViewerManager.instance().createViewer(512, 512);
			modelViewer.backgroundColor = 0x111111;
			modelViewer.visible = false;
			
			initPanel();
						
			show();
			
			// 左边 up panel
			_isImageChk = new JCheckBox("预览图片");
			_isImageChk.setSelected(true);
			_isImageChk.addActionListener(
				function(evt:Event):void
				{
					_image.visible = _isImageChk.isSelected();
				}
			);
			_image.visible = _isImageChk.isSelected();
			_upPanel2.append(_isImageChk);
			
			_isMeshChk = new JCheckBox("预览模型");
			_isMeshChk.setSelected(true);
			_isMeshChk.addActionListener(
				function(evt:Event):void
				{
					modelViewer.visible = _isMeshChk.isSelected();
				}
			);
			modelViewer.visible = _isMeshChk.isSelected();
			_upPanel2.append(_isMeshChk);
			
			var hPanel : JPanel;
			_upPanel2.append(hPanel = new JPanel);
			
			var borders:SoftBox = SoftBox.createVerticalBox(2);
			borders.setBorder(new TitledBorder(null, "资源显示", TitledBorder.BOTTOM));
			borders.append(_showAllRB = new JRadioButton("全部"));
			borders.append(_showMeshRB = new JRadioButton("模型"));
			borders.append(_showTexRB = new JRadioButton("贴图"));
			hPanel.append(borders);
			
			var group:ButtonGroup = new ButtonGroup();
			group.append(_showAllRB);
			group.append(_showMeshRB);
			group.append(_showTexRB);
			
			_showAllRB.setSelected(true);
			_showMeshRB.setSelected(false);
			_showTexRB.setSelected(false);
			
			_showAllRB.addActionListener( onSwitchShowType );
			_showMeshRB.addActionListener( onSwitchShowType );
			_showTexRB.addActionListener( onSwitchShowType );
			
			// 预览Camera
			var vPanel : JPanel;
			hPanel.append(vPanel = new JPanel(new VerticalLayout));
			_cameraZoom = new JSlider(AsWingConstants.HORIZONTAL, 50, 1000, 200);
			_cameraZoom.setPreferredWidth(100);
			_cameraZoom.addStateListener(updateModelViewerCamera);
			vPanel.append(_cameraZoom);
			
			_cameraRot = new JSlider(AsWingConstants.HORIZONTAL, 0, 360, 0);
			_cameraRot.setPreferredWidth(100);
			_cameraRot.addStateListener(updateModelViewerCamera);
			vPanel.append(_cameraRot);
			
			_cameraHeight = new JSlider(AsWingConstants.HORIZONTAL, -90, 90, 45);
			_cameraHeight.setPreferredWidth(100);
			_cameraHeight.addStateListener(updateModelViewerCamera);
			vPanel.append(_cameraHeight);
			
			
			// 左边center panel
			onResourceList();
			
			// 左边 down panel
			_selectOkBtn = new JButton("选择确认");
			_selectOkBtn.setEnabled(false);
			_selectOkBtn.addActionListener(
				function(evt:Event):void
				{
					if(_selectCallback != null && _selectRes != null)
					{
						_selectCallback(_selectRes);
						_selectCallback = null;
						_selectOkBtn.setEnabled(false);
						_selectDescribe.setText("");
						BlEditorManager.instance().showResourceEditor(false);
					}
				}
				);
			_downPanel2.append(_selectOkBtn);
			
			_downPanel2.append(_selectDescribe = new JLabel(""));
			
			// 右边
			_materialDesc = new JTextArea("", 5);
			_materialDesc.setEditable(false);
			_rightPanel1.append(new JScrollPane(_materialDesc));
			
			BlResourceManager.instance().addEventListener(BlResourceEvent.RESOURCE_COMPLETE, onResourceLoaded);
			
			updateModelViewerCamera(null);
		}
		
		private function updateModelViewerCamera(evt:Event):void
		{
			var radius : Number = _cameraZoom.getValue();
			var theta : Number = _cameraRot.getValue() / 180 * Math.PI;
			var rho : Number = _cameraHeight.getValue() / 180 * Math.PI;
			
			var x:Number = radius * Math.cos(rho) * Math.sin(theta);
			var y:Number = radius * Math.sin(rho);
			var z:Number = radius * Math.cos(rho) * Math.cos(theta);
			
			modelViewer.camera.position = new Vector3D(x, y, z);
			modelViewer.camera.lookAt(new Vector3D(0, 50, 0), new Vector3D(0, 1, 0));
		}
		
		private function initPanel():void
		{
			// 创建panel
			_panel = new JPanel(new BorderLayout(1,1));
			setContentPane(_panel);
			_panel.setBorder(new LineBorder(null, ASColor.GREEN));		// _panel 绿边
			
			// 左右
			_leftPanel1 = new JPanel(new BorderLayout(1, 1));
			_rightPanel1 = new JPanel(new BorderLayout(1, 1));
			_rightPanel1.setBorder(new LineBorder(null, ASColor.RED));
			_panel.append(_leftPanel1, BorderLayout.WEST);
			_panel.append(_rightPanel1, BorderLayout.CENTER);
			
			_leftPanel1.setPreferredWidth(200);
			
			// 左边上中下
			_upPanel2 = new JPanel();
			_upPanel2.setBorder(new LineBorder(null, ASColor.BLUE));
			_centerPanel2 = new JPanel(new BorderLayout);
			_centerPanel2.setBorder(new LineBorder(null, ASColor.BLUE));
			_downPanel2 = new JPanel();
			_downPanel2.setBorder(new LineBorder(null, ASColor.BLUE));
			
			_leftPanel1.append(_upPanel2, BorderLayout.NORTH);
			_leftPanel1.append(_centerPanel2, BorderLayout.CENTER);
			_leftPanel1.append(_downPanel2, BorderLayout.SOUTH);
		}
		
		private function onSwitchShowType(evt:Event):void
		{
			if(_showAllRB.isSelected())
				_showFilter = 0xff;
			else if(_showMeshRB.isSelected())
				_showFilter = FILTER_MESH;
			else if(_showTexRB.isSelected())
				_showFilter = FILTER_TEXTURE;
			
			UpdateTree();
		}
		
		// 资源列表加载完毕，创建资源界面
		private function onResourceList():void
		{
			_resTreeCtrl = new JTree();
			var scrollPane : JScrollPane = new JScrollPane(_resTreeCtrl);
			_centerPanel2.append(scrollPane);
						
			_rootTreeNode = new DefaultMutableTreeNode("root");
			_resTreeModel = new DefaultTreeModel(_rootTreeNode);
			_resTreeCtrl.setModel(_resTreeModel);
			
			UpdateTree();
			
			_resTreeCtrl.addSelectionListener(onTreeSelectChange);
		}
		
		private function UpdateTree():void
		{
			// clear
			_rootTreeNode.removeAllChildren();
			
			var resMap : Dictionary = BlResourceManager.instance().ResourceMap;
			for each(var res:BlResource in resMap)
			{
				var isShow : Boolean = false;
				if(res.resType == BlResourceManager.TYPE_MESH && (_showFilter & 0x2))
					isShow = true;
				else if(res.resType == BlResourceManager.TYPE_IMAGE && (_showFilter & 0x4))
					isShow = true;
				else if(_showFilter & 0x1)
					isShow = true;
				if(!isShow)
					continue;
				
				var currentNode:DefaultMutableTreeNode = _rootTreeNode;
				// 添加树路径
				var pathArray:Array = res.url.split("/");
				var x:int = 0;
				for(var i:int=0; i<pathArray.length-1; i++)
				{
					// 检查是否存在该节点
					var newChild : DefaultMutableTreeNode = null;
					for(var ni:int = 0; ni < currentNode.getChildCount(); ni++)
					{
						var name:String = DefaultMutableTreeNode(currentNode.getChildAt(ni)).getUserObject();
						if(name == pathArray[i])
							newChild = DefaultMutableTreeNode(currentNode.getChildAt(ni));
					}
					
					if(newChild)
					{
						currentNode = newChild;
					}
					else
					{
						newChild = new DefaultMutableTreeNode(pathArray[i]);
						newChild.color = _loadColor;
						currentNode.append(newChild);
						currentNode = newChild;
					}
										
				}
				
				// 添加树节点
				var leafNode:DefaultMutableTreeNode = new DefaultMutableTreeNode(pathArray[pathArray.length-1]);
				if(res.isLoaded)
					leafNode.color = _loadColor;
				else
					leafNode.color = _unLoadColor;
				currentNode.append(leafNode);
				
			}
			
			_resTreeCtrl.updateUI();
		}
		
		private function onResourceLoaded(evt: BlResourceEvent):void
		{
			// 资源加载完毕，改变界面颜色
			var pathArray:Array = evt.res.url.split("/");
			
			var childNode : DefaultMutableTreeNode = _rootTreeNode;
			for(var i:int = 0; i<pathArray.length; i++)
			{
				if(!childNode)
					break;
				childNode = childNode.findChildByUserObject(pathArray[i]);			
			}
			
			if(childNode)
				childNode.color = _loadColor;
			
		}
		
		private var refreshTimer : Timer = new Timer(500);
		private function onTreeSelectChange(evt : TreeSelectionEvent):void
		{
			var urlString : String = pathToUrl(evt.getPath());
			
			var res:BlResource = BlResourceManager.instance().findResource(urlString);
			if(res)
				res.load();
			else
				return;
			
			if(res.isLoaded)
			{
				refreshTimer.stop();
				refreshTimer.removeEventListener(TimerEvent.TIMER, onFreshTimer);
				showRes(res);
			}
			else
			{
				refreshTimer.addEventListener(TimerEvent.TIMER, onFreshTimer);
				refreshTimer.start();
			}
			_selectRes = res;
		}
		
		private function onFreshTimer(evt:TimerEvent):void
		{
			showRes(_selectRes);
			
			refreshTimer.stop();
			refreshTimer.removeEventListener(TimerEvent.TIMER, onFreshTimer);
		}
		
		private function showRes(res:BlResource):void
		{
			if(res is BlImageResource && res.isLoaded)
			{
				showImage( BlImageResource(res).bmpData );
			}
			else if(res is BlModelResource && res.isLoaded)
			{
				showModel( BlModelResource(res) );
			}
		}
		
		private function showImage(bmpData:BitmapData):void
		{
			_image.bitmapData = bmpData;
			
			if(_mesh)
			{
				for(var i:int=0; i<_mesh.subMeshes.length; i++)
					_mesh.subMeshes[i].material = null;
				_mesh.material = createMaterial(_image.bitmapData);
			}
		}
		
		private function showModel(res : BlModelResource):void
		{
			if(_mesh)
			{
				modelViewer.setRenderNode(null);
				_mesh.dispose();
				_mesh = null;
			}
			
			if(!_isMeshChk.isSelected())
			{
				modelViewer.visible = false;
				return;
			}
			
			modelViewer.visible = true;
			_mesh = new Mesh(res.geo);
			
			for(var i:int=0; i<res.tex_urls.length; i++)
			{
				var image : BlImageResource = BlResourceManager.instance().findImageResource( res.tex_urls[i] );
				if(image)
					_mesh.subMeshes[i].material = createMaterial(image.bmpData);
			}
			
			modelViewer.setRenderNode(_mesh);
		}
		
		private function createMaterial(bmp:BitmapData):MaterialBase
		{
			var resultMat : TextureMaterial;
			
			resultMat = new TextureMaterial(BitmapTextureCache.instance().getTexture(bmp));
//			resultMat.diffuseMethod = new CelDiffuseMethod();
//			resultMat.specularMethod = new CelSpecularMethod();
			resultMat.ambientMethod.ambientColor = 0x909090;
			
//			resultMat.addMethod(new OutlineMethod());
		
			resultMat.lightPicker = BlSceneManager.instance().lightPicker;
			
			// 材质描述
			var materialDesc : String = "";
			materialDesc += resultMat.ambientMethod;
			materialDesc += "\n";
			materialDesc += resultMat.diffuseMethod;
			materialDesc += "\n";
			materialDesc += resultMat.specularMethod;
			materialDesc += "\n";
			materialDesc += resultMat.normalMethod;
			materialDesc += "\n";
			
			
			
			
			_materialDesc.setText(materialDesc);
			
			return resultMat;
		}
		
		private function pathToUrl(treePath : TreePath) : String
		{
			var path : Array = treePath.getPath();
			var urlString : String = "";
			for(var i:int = 1; i<path.length; i++)		// no root
			{
				urlString += path[i];
				if(i != path.length-1)
					urlString += "/";
			}
			return urlString;
		}
		
		public function setSelectFunction(callback:Function, describe:String, filter:uint):void
		{
			_selectCallback = callback;
			_selectOkBtn.setEnabled(_selectCallback != null);
			_selectDescribe.setText(describe);
			
			if(filter == FILTER_MESH)
			{
				_showMeshRB.setSelected(true);
			}
			else if(filter == FILTER_TEXTURE)
			{
				_image.visible = true;
				_showTexRB.setSelected(true);
				_isImageChk.setSelected(true);
			}
			else
			{
				_showAllRB.setSelected(true);
			}
			onSwitchShowType(null);
		}
		
		override public function set visible(value:Boolean):void
		{
			super.visible = value;
			
			if(value)
			{
				modelViewer.visible = _isMeshChk.isSelected();
				_image.visible = _isImageChk.isSelected();
			}
			else
			{
				modelViewer.visible = false;
				_image.visible = false;
			}
		}
		
	}
}