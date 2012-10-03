/**
 *	场景浏览界面 
 */
package blade3d.editor
{
	import away3d.arcane;
	import away3d.bounds.BoundingVolumeBase;
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.SubMesh;
	import away3d.core.pick.PickingColliderType;
	import away3d.core.render.DefaultRenderer;
	import away3d.debug.Debug;
	import away3d.debug.Trident;
	import away3d.entities.EditHelper;
	import away3d.entities.Entity;
	import away3d.entities.Mesh;
	import away3d.entities.SegmentSet;
	import away3d.entities.Sprite3D;
	import away3d.events.MouseEvent3D;
	import away3d.lights.DirectionalLight;
	import away3d.lights.LightBase;
	import away3d.materials.TextureMaterial;
	import away3d.materials.utils.DefaultMaterialManager;
	import away3d.primitives.WireframePlane;
	
	import blade3d.BlEngine;
	import blade3d.avatar.blAvatarMesh;
	import blade3d.editor.scene.BlSceneAnimationPanel;
	import blade3d.editor.scene.BlSceneDirectionalLightPanel;
	import blade3d.editor.scene.BlSceneDragger;
	import blade3d.editor.scene.BlSceneMaterialPanel;
	import blade3d.editor.scene.BlSceneMeshAnimationPanel;
	import blade3d.editor.scene.BlSceneObjectPanel;
	import blade3d.editor.scene.BlSceneTexLightPanel;
	import blade3d.effect.BlEffect;
	import blade3d.resource.BlResource;
	import blade3d.scene.BlScene;
	import blade3d.scene.BlSceneEvent;
	import blade3d.scene.BlSceneManager;
	import blade3d.scene.loadvo.LightVO;
	import blade3d.scene.loadvo.MeshVO;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	
	import org.aswing.ASColor;
	import org.aswing.AsWingUtils;
	import org.aswing.BorderLayout;
	import org.aswing.Component;
	import org.aswing.JAccordion;
	import org.aswing.JButton;
	import org.aswing.JCheckBox;
	import org.aswing.JColorChooser;
	import org.aswing.JComboBox;
	import org.aswing.JFrame;
	import org.aswing.JLabel;
	import org.aswing.JList;
	import org.aswing.JPanel;
	import org.aswing.JScrollPane;
	import org.aswing.JSplitPane;
	import org.aswing.JTextArea;
	import org.aswing.JTree;
	import org.aswing.SoftBoxLayout;
	import org.aswing.VectorListModel;
	import org.aswing.border.LineBorder;
	import org.aswing.colorchooser.VerticalLayout;
	import org.aswing.event.TreeSelectionEvent;
	import org.aswing.geom.IntPoint;
	import org.aswing.tree.DefaultMutableTreeNode;
	import org.aswing.tree.DefaultTreeModel;
	
	use namespace arcane;
	
	public class BlSceneEditor extends JFrame
	{
		private var _terrainImage:Bitmap;		// 显示图片 
		
		private var _sceneEditorNode : ObjectContainer3D;
		private var _axisNode : ObjectContainer3D;
		private var _dragger : BlSceneDragger;
		
		private var _panel : JPanel;
		
		private var _leftPanel : JPanel;
		private var _rightPanel : JPanel;
		
		private var _upPanel : JPanel;
		private var _centerPanel : JPanel;
		private var _downPanel : JPanel;
		
		private var _accordion : JAccordion;		// 属性折叠栏
		
		private var _btnPanel : JPanel;
		private var _btnPanel2 : JPanel;
		private var _addPanel : JPanel;
		private var _sceneTreePanel: JPanel;
		
		private var _axisCbb : JComboBox;			// 坐标显示框
		private var _chooserDialog:JFrame;			// 颜色选择框
		private var _colorIndex : int;
		private var _addObjectComboBox : JComboBox;		// 添加对象
		
		// 对象界面
		private var _objectBasePanel : BlSceneObjectPanel;
		private var _animationPanel : BlSceneAnimationPanel;
		private var _meshAnimationPanel : BlSceneMeshAnimationPanel;
		private var _meshAnimationPanelScroll : JScrollPane;
		private var _materialPanel : BlSceneMaterialPanel;
		private var _materialPanelScroll : JScrollPane;
		private var _directionalLightPanel : BlSceneDirectionalLightPanel;
		private var _texLightPanel : BlSceneTexLightPanel;
		
		
		// 场景树
		private var _sceneList : JList;
		private var _sceneTree : JTree;
		private var _sceneTreeModel : DefaultTreeModel;
		private var _rootTreeNode : DefaultMutableTreeNode;
		
		private var _isNodeVisibleChk : JCheckBox;			// node是否可见
		private var _isBoundingBox : JCheckBox;			// 显示包围盒
		private var _isPickChk : JCheckBox;				// 是否可以拾取
		
		
		private var _nodeDesc : JTextArea;
		
		private var _selectedObject : ObjectContainer3D;
		
				
		public function BlSceneEditor(owner:*=null, title:String="", modal:Boolean=false)
		{
			super(owner, title, modal);
			
			// 显示地形图片控件
			_terrainImage = new Bitmap();
			_terrainImage.x = 0;
			_terrainImage.y = 300;			
			BlEditorManager.instance().rootSprite().addChild(_terrainImage);
			
			initEditorObject();
			
			
			setSizeWH(500, 600);
			var parent:Sprite = Sprite(owner);
			setLocationXY( parent.width - (500+30), 0 );
			
			initPanel();
			
			show();
			
			initUpPanel();
			initCenterPanel();
			initDownPanel();
			
			
			
			updateTree(null);
			
			BlSceneManager.instance().addEventListener(BlSceneEvent.SCENE_LEAVE, onSceneLeave);
			BlSceneManager.instance().addEventListener(BlSceneEvent.SCENE_ENTER, onSceneEnter);
			BlSceneManager.instance().addEventListener(BlSceneEvent.SCENE_LOAD_END, onSceneLoadEnd);
		}
		
		private function onSceneLeave(evt:Event):void
	  	{
			selectedObject = null;
			_sceneEditorNode.detachParent();
			BlSceneManager.instance().removeEventListener(BlSceneEvent.SCENE_ADD_OBJECT, onSceneAddObject);
	  	}
		
		private function onSceneEnter(event:Event):void
		{
			BlSceneManager.instance().currentScene.addEditor(_sceneEditorNode);
			refreshTree();
		}
		
		private function onSceneLoadEnd(event:BlSceneEvent):void
		{
			refreshTree();
			BlSceneManager.instance().addEventListener(BlSceneEvent.SCENE_ADD_OBJECT, onSceneAddObject);
		}
		
		private function onSceneAddObject(event:BlSceneEvent):void
		{
			refreshTree();
			selectedObject = event.addObject
		}
		
		private function initEditorObject():void
		{
			// 场景编辑节点
			_sceneEditorNode = new ObjectContainer3D;
			_sceneEditorNode.name = "BlSceneEditor";
			BlSceneManager.instance().currentScene.addEditor(_sceneEditorNode);
			
			// 拖拽器
			_dragger = new BlSceneDragger;
			_dragger.node.visible = false;
			_sceneEditorNode.addChild(_dragger.node);
		}
		
		private function initPanel():void
		{
			_panel = new JPanel(new BorderLayout(0, 0));
			setContentPane(_panel);
			_panel.setBorder(new LineBorder(null, ASColor.GREEN));		// _panel 绿边
			
			var split:JSplitPane = new JSplitPane(JSplitPane.HORIZONTAL_SPLIT);
			_panel.append(split, BorderLayout.CENTER);
			
			_leftPanel = new JPanel(new BorderLayout(1, 1));
			_rightPanel = new JPanel(new BorderLayout(1, 1));
			split.setTopComponent(_leftPanel);
			split.setBottomComponent(_rightPanel);
			split.setDividerLocation(0);
			
			_upPanel = new JPanel(new SoftBoxLayout(SoftBoxLayout.Y_AXIS, 1));
			_upPanel.setBorder(new LineBorder(null, ASColor.BLUE));
			_centerPanel = new JPanel(new BorderLayout(1, 1));
			_centerPanel.setBorder(new LineBorder(null, ASColor.BLUE));
			_downPanel = new JPanel(new SoftBoxLayout(SoftBoxLayout.Y_AXIS, 1));
			_downPanel.setBorder(new LineBorder(null, ASColor.BLUE));
			
			_leftPanel.append(_upPanel, BorderLayout.NORTH);
			_leftPanel.append(_centerPanel, BorderLayout.CENTER);
			_leftPanel.append(_downPanel, BorderLayout.SOUTH);
			
			_accordion = new JAccordion();
			_rightPanel.append(_accordion);
		}
		
		private function initUpPanel():void
		{
			// up panel
			_upPanel.append(createAxisList());	// 坐标轴选择框
			
			_upPanel.append(new JLabel("场景列表"));
			
			_upPanel.append(createSceneList());		// 创建场景列表
			
			_btnPanel = new JPanel();
			_btnPanel2 = new JPanel();
			_addPanel = new JPanel();
			_upPanel.append(_btnPanel);
			_upPanel.append(_btnPanel2);
			_upPanel.append(_addPanel);
			
			// 按钮
			var loadBtn : JButton = new JButton("加载");				// 加载场景
			loadBtn.addActionListener(loadScene);
			_btnPanel.append(loadBtn);
			
			var saveBtn : JButton = new JButton("保存");
			saveBtn.addActionListener(saveScene);
			_btnPanel.append(saveBtn);
			
			var refreshBtn : JButton = new JButton("刷新");		// 更新场景树
			refreshBtn.addActionListener(updateTree);
			_btnPanel.append(refreshBtn);
			
			var _backgroundColorBtn : JButton = new JButton("背景色");
			_backgroundColorBtn.addActionListener(
				function(evt:Event):void
				{
					_colorIndex = 0;
					_chooserDialog.show();
				}
			);
			_btnPanel.append(_backgroundColorBtn);
			
			var _lightmapColorBtn : JButton = new JButton("贴图灯色");
			_lightmapColorBtn.addActionListener(
				function(evt:Event):void
				{
					_colorIndex = 1;
					_chooserDialog.show();
				}
			);
			_btnPanel.append(_lightmapColorBtn);
			
			_chooserDialog = JColorChooser.createDialog(new JColorChooser(), this, "Chooser a color to test", 
				true, __colorSelected);
			
			// 查看地形图
			var _terrainMapChk : JButton = new JButton("地形图");
			_terrainMapChk.addActionListener(
				function(evt:Event):void
				{
					var scene : BlScene = BlSceneManager.instance().currentScene;
					if(scene && scene.loader && scene.loader.terrainCollision)
					{
						_terrainImage.bitmapData = BlSceneManager.instance().currentScene.loader.terrainCollision.terrainBmp;
					}
				}
				);
			_btnPanel2.append(_terrainMapChk);
			
			
			// 添加对象
			var arr:Array = new Array();
			arr.push("模型");
			arr.push("贴图灯");
			arr.push("特效");
			
			var listData:VectorListModel = new VectorListModel(arr);
			_addObjectComboBox = new JComboBox(listData);
			_addObjectComboBox.setPreferredWidth(70);
			_addObjectComboBox.setSelectedIndex(1);
			_addPanel.append(_addObjectComboBox);
			
			var addBtn : JButton = new JButton("添加");
			addBtn.addActionListener(onAddObjectBtn);
			_addPanel.append(addBtn);
			
			var delBtn : JButton = new JButton("删除");
			_addPanel.append(delBtn);
			delBtn.addActionListener(
				function(evt:Event):void
				{
					if(selectedObject)
					{
						var delObject:ObjectContainer3D = selectedObject;
						selectedObject = null;
						delObject.dispose();
						refreshTree();
					}
				}
				);
		}
		
		private function initCenterPanel():void
		{
			//center it
			var location:IntPoint = AsWingUtils.getScreenCenterPosition();
			location.x -= _chooserDialog.getWidth()/2;
			location.y -= _chooserDialog.getHeight()/2;
			_chooserDialog.setLocation(location);
			
			// center panel
			_sceneTreePanel = new JPanel(new BorderLayout);
			_sceneTreePanel.setBorder(new LineBorder(null, ASColor.PINK));
			_centerPanel.append(_sceneTreePanel);
			
			// 场景树
			_sceneTree = new JTree();
			_sceneTree.addSelectionListener(onTreeNodeSelected);
			_sceneTreePanel.append(new JScrollPane(_sceneTree));
			
			_rootTreeNode = new DefaultMutableTreeNode("root");
			_sceneTreeModel = new DefaultTreeModel(_rootTreeNode);
			_sceneTree.setModel(_sceneTreeModel);
		}
		
		private function initDownPanel():void
		{
			// 场景配置
			var scenePanel : JPanel = new JPanel(new VerticalLayout);
			_downPanel.append(scenePanel);
			
			var hPanel : JPanel;
			scenePanel.append(hPanel = new JPanel);
			// 显示
			hPanel.append(_isNodeVisibleChk = new JCheckBox("显示"));
			_isNodeVisibleChk.addActionListener(
				function(evt:Event):void
				{
					if(selectedObject)
						selectedObject.visible = _isNodeVisibleChk.isSelected();
				}
			);
			
			// 包围盒
			hPanel.append(_isBoundingBox = new JCheckBox("包围盒"));
			_isBoundingBox.addActionListener(
				function(evt:Event):void
				{
					if(selectedObject && selectedObject is Entity)
						Entity(selectedObject).showBounds = _isBoundingBox.isSelected();
				}
			);
			
			// 显示辅助物体
			var helperVisible : JCheckBox;
			hPanel.append(helperVisible = new JCheckBox("辅助物体"));
			helperVisible.addActionListener(
				function(evt:Event):void
				{
					EditHelper.allVisible(helperVisible.isSelected());
				}
			);
			// 显示物理碰撞
			scenePanel.append(hPanel = new JPanel);
			
			var showPhysics : JCheckBox;
			hPanel.append(showPhysics = new JCheckBox("物理碰撞"));
			showPhysics.addActionListener(
				function(evt:Event):void
				{
					BlSceneManager.instance().currentScene.loader._navNode.visible = showPhysics.isSelected(); 
				}
				);
			// 显示地面碰撞
			var showTerrain : JCheckBox;
			hPanel.append(showTerrain = new JCheckBox("地面碰撞"));
			showTerrain.addActionListener(
				function(evt:Event):void
				{
					BlSceneManager.instance().currentScene.loader.terrainCollideMesh.visible = showTerrain.isSelected(); 
				}
			);
			
			
			// 是否可以拾取
			scenePanel.append(_isPickChk = new JCheckBox("拾取"));
			_isPickChk.addActionListener(
				function(evt:Event):void
				{
					refreshTree();
					selectedObject = null;
				}
			);
			
			// node描述
			_nodeDesc = new JTextArea("", 5);
			_nodeDesc.setEditable(false);
			_downPanel.append(new JScrollPane(_nodeDesc));
		}
		
		private function __colorSelected(color:ASColor):void
		{
			if(_colorIndex == 0)
			{
				BlEngine.mainView.renderer.backgroundR = Number(color.getRed())/0xff;
				BlEngine.mainView.renderer.backgroundG = Number(color.getGreen())/0xff;
				BlEngine.mainView.renderer.backgroundB = Number(color.getBlue())/0xff;
			}
			else if(_colorIndex == 1)
			{
				DefaultRenderer(BlEngine.mainView.renderer).lightMapRenderer.backgroundR = Number(color.getRed())/0xff;
				DefaultRenderer(BlEngine.mainView.renderer).lightMapRenderer.backgroundG = Number(color.getGreen())/0xff;
				DefaultRenderer(BlEngine.mainView.renderer).lightMapRenderer.backgroundB = Number(color.getBlue())/0xff;
			}
		}
		
		private function onAddObjectBtn(evt:Event):void
		{
			var newObject : ObjectContainer3D;
			var selIndex:int = _addObjectComboBox.getSelectedIndex();
			if(selIndex == 0)
			{	// 添加模型
				BlEditorManager.instance()._resourceEditor.setSelectFunction(onSelectMeshEnd, "选择要添加的模型", BlResourceEditor.FILTER_MESH);
				BlEditorManager.instance().showResourceEditor(true);
			}
			else if(selIndex == 1)
			{	// 添加贴图灯
				var lightVO : LightVO = new LightVO;
				BlSceneManager.instance().currentScene.loader.addTexLight(lightVO);
			}
		}
		
		private function onSelectMeshEnd(res:BlResource):void
		{
			var meshVO : MeshVO = new MeshVO;
			meshVO.path = res.url;
			
			BlSceneManager.instance().currentScene.loader.addMesh(meshVO);
		}
		
		private function createAxisList():Component
		{
			var arr:Array = new Array();
			arr.push("无");
			arr.push("坐标轴");
			arr.push("网格");
			
			var listData:VectorListModel = new VectorListModel(arr);
			
			_axisCbb = new JComboBox(listData);
			_axisCbb.setSelectedIndex(0);
			
			_axisCbb.addActionListener(
				function onAxisList(evt:Event):void
				{
					var axisName : String = _axisCbb.getSelectedItem();
					switchAxis(axisName);
				}
			);
			
			return _axisCbb;
		}
		
		public function switchAxis(name:String):void
		{
			if(_axisNode)
			{
				_axisNode.dispose();
				_axisNode = null;
			}
			
			switch(name)
			{
				case "坐标轴":
				{
					_axisNode = new Trident(100);
					_axisNode.name = "asix";
					break;
				}
				case "网格":
				{
					_axisNode = new WireframePlane(100, 100, 5, 5, 0x444444, 1, "xz");
					_axisNode.name = "wireframe";
					break;
				}
					
				default:
				{
					break;
				}
			}
			
			if(_axisNode)
				_sceneEditorNode.addChild(_axisNode);
			
		}
		
		private function createSceneList():Component
		{
			var arr:Array = new Array();
			
			var sceneNames : Vector.<String> = BlSceneManager.instance().sceneNames;
			for(var i:int=0; i<sceneNames.length; i++)
			{
				arr.push(sceneNames[i]);
			}
			
			var listData:VectorListModel = new VectorListModel(arr);
			_sceneList = new JList(listData);
			_sceneList.setBorder(new LineBorder(null, ASColor.RED, 1));
			
			_sceneList.setPreferredHeight(80);
			return new JScrollPane(_sceneList);
		}
		
		private function saveScene(e:Event):void
		{	// 保存场景
			BlSceneManager.instance().currentScene.saveScene();
		}
		
		private function loadScene(e:Event):void
		{
			// 显示场景
			var sceneName:String = _sceneList.getSelectedValue();
			BlSceneManager.instance().showScene(sceneName);
		}
		
		private function showName(e:Event):void
		{
			refreshTree();
		}
		
		// 更新场景树
		private function updateTree(e:Event):void
		{
			refreshTree();
		}
		
		private function refreshTree():void
		{	
			var scene : BlScene = BlSceneManager.instance().currentScene;
			
			_rootTreeNode.setUserObject(new TreeNodeObject(scene.rootNode));
			
			filterList.length = 0;
			recurScene(scene.rootNode, _rootTreeNode);
			// 删除editor_node节点
			for(var i:int=0; i<filterList.length; i++)
			{
				filterList[i].removeFromParent();
			}
			
			_sceneTree.updateUI();
		}
		
		static private var childList : Vector.<ObjectContainer3D> = new Vector.<ObjectContainer3D>;
		static private var usedList : Vector.<Boolean> = new Vector.<Boolean>;
		static private var filterList : Vector.<DefaultMutableTreeNode> = new Vector.<DefaultMutableTreeNode>;
		private function recurScene(sceneNode:ObjectContainer3D, treeNode:DefaultMutableTreeNode):void
		{
			// 刷新树算法
			var i:int;
			childList.length = 0;
			usedList.length = 0;
			// 当前node下所有子node
			for(i=0; i<sceneNode.numChildren; i++)
			{
				// 排除
				var oneChild : ObjectContainer3D = sceneNode.getChildAt(i);
				if(oneChild is Entity && Entity(oneChild).renderLayer == Entity.Editor_Layer)
				{
					if(oneChild is EditHelper)
						setMeshPickable(EditHelper(oneChild), _isPickChk.isSelected());		// 提供helper拾取功能
					continue;
				}
				
				childList.push(sceneNode.getChildAt(i));
				usedList.push(false);
			}
			
			// 排除treenode下已经不存在的treenode
			var iterTNode : DefaultMutableTreeNode = DefaultMutableTreeNode(treeNode.getFirstChild());
			var iterTNode2 : DefaultMutableTreeNode;
			while(iterTNode)
			{
				var uObj : TreeNodeObject = iterTNode.getUserObject();
				var exist:Boolean = false;
				for(i=0; i<childList.length; i++)
				{
					if(childList[i] == uObj.obj)
					{
						exist = true;
						usedList[i] = true;
						break;
					}
				}
				
				iterTNode2 = iterTNode;
				iterTNode = DefaultMutableTreeNode(treeNode.getChildAfter(iterTNode));
				if(!exist)
				{	// 删除该节点
					treeNode.remove(iterTNode2);
				}
			}
			
			// 加入新的节点
			for(i=0; i<usedList.length; i++)
			{
				if(usedList[i]) continue;
				var newTreeNode : DefaultMutableTreeNode = new DefaultMutableTreeNode(new TreeNodeObject(childList[i]));
				treeNode.append(newTreeNode);
			}
			
			// 更新所有子节点数据
			iterTNode = DefaultMutableTreeNode(treeNode.getFirstChild());
			while(iterTNode)
			{
				var obj : ObjectContainer3D = iterTNode.getUserObject().obj;
				if(obj is Mesh || obj is blAvatarMesh || obj is EditHelper)
				{
					// 被裁减，用灰色字体
					if(!Mesh(obj).isRendering)
						iterTNode.color = ASColor.LIGHT_GRAY;
					// 提供拾取能
					setMeshPickable(Mesh(obj), _isPickChk.isSelected());
					
					// 给所有mesh上一个ColorTransform,编辑用
					if(Mesh(obj).material is TextureMaterial 
						&& !TextureMaterial(Mesh(obj).material).colorTransform)
						TextureMaterial(Mesh(obj).material).colorTransform = new ColorTransform;
					// 也给所以submesh上一个ColorTransform
					for(i=0; i<Mesh(obj).subMeshes.length; i++)
					{
						var subMesh : SubMesh = Mesh(obj).subMeshes[i];
						if(subMesh.material is TextureMaterial &&  !TextureMaterial(subMesh.material).colorTransform)
							TextureMaterial(subMesh.material).colorTransform = new ColorTransform;
					}
				}
				// filter node				
				if(obj.name == "editor_node")
					filterList.push(iterTNode);
				
				recurScene(obj, iterTNode);
				
				iterTNode = DefaultMutableTreeNode(treeNode.getChildAfter(iterTNode));
			}
			
		}
		// 查看节点信息
		private function onTreeNodeSelected(evt : TreeSelectionEvent):void
		{
			var node:DefaultMutableTreeNode = DefaultMutableTreeNode(evt.getPath().getLastPathComponent());
			if(node)
			{
				var treeNode : TreeNodeObject = node.getUserObject();
				selectedObject = treeNode.obj;
			}
		}
		
		private function setMeshPickable(mesh:Mesh, enable:Boolean):void
		{
			if(enable)
			{
				mesh.mouseEnabled = true;
				mesh.shaderPickingDetails = true;
				mesh.pickingCollider = PickingColliderType.PB_FIRST_ENCOUNTERED; 
				mesh.addEventListener( MouseEvent3D.MOUSE_OVER, onMeshMouseOver, false, 0, true);		// 弱引用,场景删除后,不会影响
				mesh.addEventListener( MouseEvent3D.MOUSE_OUT, onMeshMouseOut, false, 0, true );
				mesh.addEventListener( MouseEvent3D.MOUSE_UP, onMeshMouseUp, false, 0, true );
			}
			else
			{
				mesh.mouseEnabled = false;
				mesh.shaderPickingDetails = false;
				mesh.pickingCollider = null;
				mesh.removeEventListener( MouseEvent3D.MOUSE_OVER, onMeshMouseOver );
				mesh.removeEventListener( MouseEvent3D.MOUSE_OUT, onMeshMouseOut );
				mesh.removeEventListener( MouseEvent3D.MOUSE_UP, onMeshMouseUp );
			}
		}
		
		private function get selectedObject() : ObjectContainer3D {return _selectedObject;}
		private function set selectedObject(obj:ObjectContainer3D):void
		{
			// 去高亮
			if(selectedObject is Mesh && Mesh(selectedObject).material is TextureMaterial)
			{
				noLightMesh(Mesh(selectedObject));
			}
			
			if(selectedObject is Entity)
				Entity(selectedObject).showBounds = false;
			
			_selectedObject = obj;
			onSelectedNode();
			
			//  去高亮
			if(selectedObject is Mesh && Mesh(selectedObject).material is TextureMaterial)
			{
				noLightMesh(Mesh(selectedObject));
			}
		}
		
		private function onSelectedNode():void
		{
//			_accordion.removeAll();
			
			// 更新拖拽器
			_dragger.setDraggerObject(selectedObject);
			
			if(!selectedObject) return;
			
			
			updateSelectObjectUI();
		}
		
		
		public function updateSelectObjectUI():void
		{
			// 更新按钮
			_isNodeVisibleChk.setSelected(selectedObject.visible);
			if(selectedObject is Entity)
				_isBoundingBox.setSelected(Entity(selectedObject).showBounds);
			
			// 显示信息
			_nodeDesc.getTextField().text = selectedObject +"\n" + selectedObject.name;
			
			// 更新基础界面
			_objectBasePanel ||= new BlSceneObjectPanel;
			if(_accordion.getIndex(_objectBasePanel) == -1)
				_accordion.appendTab(_objectBasePanel, "基础属性");
			_objectBasePanel.setObj(selectedObject);
			
			// 更新基础动画
			_animationPanel ||= new BlSceneAnimationPanel;
			if(_accordion.getIndex(_animationPanel) == -1)
				_accordion.appendTab(_animationPanel, "基础动画");
			_animationPanel.setObj(selectedObject);
			
			// 更新模型动画
			_meshAnimationPanel ||= new BlSceneMeshAnimationPanel;
			_meshAnimationPanelScroll ||= new JScrollPane(_meshAnimationPanel);
			if(selectedObject is Mesh 
				&& Mesh(selectedObject).material is TextureMaterial) 
			{
				
				if(_accordion.getIndex(_meshAnimationPanelScroll) == -1)
					_accordion.appendTab(_meshAnimationPanelScroll, "材质动画");
				_meshAnimationPanel.setObj(Mesh(selectedObject));
			}
			else
				_accordion.remove(_meshAnimationPanelScroll);
			
			// 更新材质界面
			_materialPanel ||= new BlSceneMaterialPanel;
			_materialPanelScroll ||= new JScrollPane(_materialPanel);
			if(selectedObject is Mesh 
				&& Mesh(selectedObject).material is TextureMaterial) 
			{
				if(_accordion.getIndex(_materialPanelScroll) == -1)
					_accordion.appendTab(_materialPanelScroll, "材质属性");
				_materialPanel.setObj(Mesh(selectedObject));
			}
			else
				_accordion.remove(_materialPanelScroll);
			
			// 更新特殊界面
			_directionalLightPanel ||= new BlSceneDirectionalLightPanel;
			if(selectedObject is DirectionalLight)
			{
				if(_accordion.getIndex(_directionalLightPanel) == -1)
					_accordion.appendTab(_directionalLightPanel, "方向灯属性");
				_directionalLightPanel.setObj(DirectionalLight(selectedObject));
			}
			else
				_accordion.remove(_directionalLightPanel);
			
			_texLightPanel ||= new BlSceneTexLightPanel;
			if(selectedObject is Sprite3D)
			{
				if(_accordion.getIndex(_texLightPanel) == -1)
					_accordion.appendTab(_texLightPanel, "贴图灯属性");
				_texLightPanel.setObj(Sprite3D(selectedObject));
			}
			else
				_accordion.remove(_texLightPanel);
			
		}
		
		private function onMeshMouseUp( event:MouseEvent3D ):void 
		{
//			Debug.log("onMeshMouseDown");
			var selectOne:ObjectContainer3D;
			if(event.object is EditHelper)
			{
				selectOne = EditHelper(event.object).editObject;
				noLightMesh(EditHelper(event.object));
			}
			else
				selectOne = event.object as Mesh;
			Debug.log("pick "+selectOne.name);
			
			selectedObject = selectOne;
			
			_isPickChk.setSelected(false);
			refreshTree();
		}
		
		private function onMeshMouseOver(event:MouseEvent3D):void
		{
//			Debug.log("onMeshMouseOver");
			var mesh:Mesh = event.object as Mesh;
			highLightMesh(mesh);
		}
		
		private function  onMeshMouseOut(event:MouseEvent3D):void
		{
			var mesh:Mesh = event.object as Mesh;
			noLightMesh(mesh);
//			Debug.log("onMeshMouseOut");
		}
		
		private function  onMeshMouseMove(event:MouseEvent3D):void
		{
//			Debug.log("onMeshMouseMove");
		}
		
		private function highLightMesh(mesh:Mesh):void
		{
			if(mesh.material is TextureMaterial)
			{
				TextureMaterial(mesh.material).colorTransform.redMultiplier = 2;
				TextureMaterial(mesh.material).colorTransform.greenMultiplier = 2;
				TextureMaterial(mesh.material).colorTransform.blueMultiplier = 0;
			}
			
			var i:int;
			for(i=0; i<mesh.subMeshes.length; i++)
			{
				var subMesh : SubMesh = mesh.subMeshes[i];
				if(subMesh.material)
				{
					TextureMaterial(subMesh.material).colorTransform.redMultiplier = 2;
					TextureMaterial(subMesh.material).colorTransform.greenMultiplier = 2;
					TextureMaterial(subMesh.material).colorTransform.blueMultiplier = 0;
				}
			}
		}
		
		private function noLightMesh(mesh:Mesh):void
		{
			if(mesh.material is TextureMaterial)
			{
				TextureMaterial(mesh.material).colorTransform.redMultiplier = 1;
				TextureMaterial(mesh.material).colorTransform.greenMultiplier = 1;
				TextureMaterial(mesh.material).colorTransform.blueMultiplier = 1;
			}
			
			var i:int;
			for(i=0; i<mesh.subMeshes.length; i++)
			{
				var subMesh : SubMesh = mesh.subMeshes[i];
				if(subMesh.material)
				{
					TextureMaterial(subMesh.material).colorTransform.redMultiplier = 1;
					TextureMaterial(subMesh.material).colorTransform.greenMultiplier = 1;
					TextureMaterial(subMesh.material).colorTransform.blueMultiplier = 1;
				}
			}
		}
		
		
	}
}
import away3d.containers.ObjectContainer3D;

class TreeNodeObject
{
	public var obj:ObjectContainer3D;
	
	public function TreeNodeObject(obj:ObjectContainer3D):void
	{
		this.obj = obj;
	}
	
	public function toString():String
	{
		return obj.name; 
	}
}