/**
 *	特效编辑器 
 */
package blade3d.editor
{
	import away3d.containers.ObjectContainer3D;
	import away3d.debug.Debug;
	
	import blade3d.editor.effect.BlEffectBasePanel;
	import blade3d.editor.effect.BlEffectParticleEditor;
	import blade3d.effect.BlEffect;
	import blade3d.effect.BlEffectManager;
	import blade3d.effect.BlEffectStore;
	import blade3d.resource.BlResourceManager;
	import blade3d.resource.BlStringResource;
	import blade3d.scene.BlSceneEvent;
	import blade3d.scene.BlSceneManager;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.aswing.ASColor;
	import org.aswing.BorderLayout;
	import org.aswing.Component;
	import org.aswing.JButton;
	import org.aswing.JCheckBox;
	import org.aswing.JComboBox;
	import org.aswing.JFrame;
	import org.aswing.JLabel;
	import org.aswing.JList;
	import org.aswing.JPanel;
	import org.aswing.JScrollBar;
	import org.aswing.JScrollPane;
	import org.aswing.JSplitPane;
	import org.aswing.JStepper;
	import org.aswing.JTextField;
	import org.aswing.SoftBoxLayout;
	import org.aswing.VectorListModel;
	import org.aswing.border.LineBorder;
	import org.aswing.colorchooser.VerticalLayout;
	
	public class BlEffectEditor extends JFrame
	{
		private var _effectNode : ObjectContainer3D;
		
		private var _panel : JPanel;
		
		private var _leftPanel : JPanel;
		private var _rightPanel : JPanel;
		
		private var _leftUpPanel : JPanel;
		private var _leftCenterPanel : JPanel;
		private var _leftDownPanel : JPanel;
		
		private var _rightUpPanel : JPanel;
		private var _rightCenterPanel : JPanel;
		private var _rightDownPanel : JPanel;
		
		// 特效元素编辑界面
		private var _particleEditor : BlEffectParticleEditor;
		
		// 特效列表
		private var _searchTxt : JTextField;
		private var _effectList : JList;
		private var _listTimer : Timer;
		// 特效元素列表
		private var _elementList : JList;
		private var _elementListMod : VectorListModel;
		
		private var _effectAutoClear : JCheckBox;
		private var _effectAdd : JButton;
		private var _effectSave : JButton;
		private var _effectPlay : JButton;
		
		// 特效参数
		private var _addElementCbx : JComboBox;			// 可添加特性元素
		private var _addElementBtn : JButton;				// 添加元素
		private var _delElementBtn : JButton;				// 删除元素
		private var _copyElementBtn : JButton;				// 复制元素
		
		private var _effectCache : JStepper;			// 缓存数
		private var _effectLifeTime : JStepper;		// 特效持续时间
		private var _baseAttribePanel : BlEffectBasePanel;		// 基础属性面板
		
		
		// 特效对象
		private var _currentStore : BlEffectStore;
		
		public function BlEffectEditor(owner:*=null, title:String="", modal:Boolean=false)
		{
			super(owner, title, modal);
			
			setSizeWH(470, 600);
			var parent:Sprite = Sprite(owner);
			setLocationXY( parent.width - (470+50), 0 );
			
			
			_listTimer = new Timer(500);
			
			show();
			
			initPanel();
			initUI();
			
			_effectNode = new ObjectContainer3D;
			_effectNode.name = "BlEffectEditor";
			_effectNode.y = 100;
			
			BlSceneManager.instance().currentScene.addEditor(_effectNode);
			BlSceneManager.instance().addEventListener(BlSceneEvent.SCENE_LEAVE, onSceneLeave);
			BlSceneManager.instance().addEventListener(BlSceneEvent.SCENE_ENTER, onSceneChange);
		}
		
		private function onSceneLeave(evt:Event):void
		{
			_effectNode.detachParent();
		}
		
		private function onSceneChange(event:Event):void
		{
			BlSceneManager.instance().currentScene.addEditor(_effectNode);
		}
		
		private function initPanel():void
		{
			_panel = new JPanel(new BorderLayout(1, 1));
			setContentPane(_panel);
			_panel.setBorder(new LineBorder(null, ASColor.BLUE));
			
			var split:JSplitPane = new JSplitPane(JSplitPane.HORIZONTAL_SPLIT);
			_panel.append(split, BorderLayout.CENTER);
			
			_leftPanel = new JPanel(new BorderLayout(1, 1));
			_rightPanel = new JPanel(new BorderLayout(1, 1));
			
			split.setTopComponent(_leftPanel);
			split.setBottomComponent(_rightPanel);
			split.setDividerLocation(-40);
			
			_leftUpPanel = new JPanel(new SoftBoxLayout(SoftBoxLayout.Y_AXIS));
			_leftCenterPanel = new JPanel(new SoftBoxLayout(SoftBoxLayout.Y_AXIS));
			_leftDownPanel = new JPanel(new VerticalLayout);
			
			
			_rightUpPanel = new JPanel();
			_rightCenterPanel = new JPanel(new SoftBoxLayout(SoftBoxLayout.Y_AXIS));
			_rightDownPanel = new JPanel(new VerticalLayout());
			
			_leftPanel.append(_leftUpPanel, BorderLayout.NORTH);
			_leftPanel.append(_leftCenterPanel, BorderLayout.CENTER);
			_leftPanel.append(_leftDownPanel, BorderLayout.SOUTH);
			
			_rightPanel.append(_rightUpPanel, BorderLayout.NORTH);
			_rightPanel.append(_rightCenterPanel, BorderLayout.CENTER);
			_rightPanel.append(_rightDownPanel, BorderLayout.SOUTH);
		}
		
		private function initUI():void
		{
			// left panel
			initLeftUI();
			
			// right panel
			initRightUI();
			
		}
		
		private function initLeftUI():void
		{
			// 上
			var p:JPanel;
			// 创建特效列表
			_leftUpPanel.append(p = new JPanel);
			p.append(new JLabel("特效列表:"));
			
			_leftUpPanel.append(p = new JPanel);
			p.append(new JLabel("搜索:"));
			_searchTxt = new JTextField;
			_searchTxt.setPreferredWidth(120);
			p.append(_searchTxt);
			_searchTxt.addActionListener(
				function(evt:Event):void
				{
					updateEffectList();
				}
			);
			
			// 中
			_leftCenterPanel.append(createEffectList());
			
			// 下
			_effectAutoClear = new JCheckBox("自动更新");
			_effectAutoClear.setSelected(true);
			_leftDownPanel.append(_effectAutoClear);
			
			_leftDownPanel.append(p = new JPanel);
			// 保存
			_effectSave = new JButton("保存");
			_effectSave.addActionListener(onSave);
			p.append(_effectSave);
			
			// 播放特效按钮
			_effectPlay = new JButton("播放");
			_effectPlay.addActionListener(onPlay);
			p.append(_effectPlay);
		}
		
		private function initRightUI():void
		{
			// 可添加特性元素
			_rightUpPanel.append(createAddElementList());
			
			_rightUpPanel.append(_addElementBtn = new JButton("添加"));
			_addElementBtn.addActionListener(onAddElement);
			_rightUpPanel.append(_delElementBtn = new JButton("删除"));
			_delElementBtn.addActionListener(onDelElement);
			_rightUpPanel.append(_copyElementBtn = new JButton("复制"));
			_copyElementBtn.addActionListener(onCopyElement);
			
			
			// 创建特效元素列表
			_rightCenterPanel.append(createEffectElementList());
			
			var p:JPanel = new JPanel;
			_rightCenterPanel.append(p);
			
			p.append(new JLabel("缓存数"));
			_effectCache = new JStepper();
			_effectCache.addActionListener(ChangeEffectTime);
			p.append(_effectCache);
			
			_rightCenterPanel.append(p = new JPanel);
			p.append(new JLabel("持续时间"));
			_effectLifeTime = new JStepper(5);
			_effectLifeTime.addActionListener(ChangeEffectTime);
			_effectLifeTime.setMaximum(99999999);
			_effectLifeTime.setValue(0);
			p.append(_effectLifeTime);
			
			_baseAttribePanel = new BlEffectBasePanel;
			_rightCenterPanel.append(_baseAttribePanel);
		}
		
		private function createAddElementList():Component
		{
			var arr:Array = new Array();
			
			arr.push("粒子");
			
			var listData:VectorListModel = new VectorListModel(arr);
			_addElementCbx = new JComboBox(listData);
			_addElementCbx.setPreferredWidth(100);
			_addElementCbx.setSelectedIndex(0);
			return _addElementCbx;
		}
		
		private function createEffectList():Component
		{
			_effectList = new JList();
			_effectList.addSelectionListener(onEffectListSelected);
			_effectList.setPreferredHeight(300);
			
			updateEffectList();
			
			var scroll : JScrollPane = new JScrollPane(_effectList);
			scroll.setBorder(new LineBorder(null, ASColor.LIGHT_GRAY, 1));
			return scroll;
		}
		
		private function updateEffectList():void
		{
			var arr:Array = new Array();
			var searchStr : String = _searchTxt.getText();
			for(var key:String in BlEffectManager.instance().effectResources)
			{
				if(searchStr.length > 0 && key.indexOf(searchStr) < 0)		// 搜索过滤
					continue;
				arr.push(key);
			}
			
			var listData:VectorListModel = new VectorListModel(arr);
			_effectList.setModel(listData);
		}
		
		private function createEffectElementList():Component
		{
			var arr:Array = new Array();
			_elementListMod = new VectorListModel(arr);
			_elementList = new JList(_elementListMod);
			_elementList.setPreferredHeight(100);
			_elementList.setBorder(new LineBorder(null, ASColor.LIGHT_GRAY, 1));
			_elementList.addSelectionListener(onEffectElementSelected);
			return new JScrollPane(_elementList);
		}
		// 选择特效
		private function onEffectListSelected(evt:Event):void
		{
			_currentStore = null;
			
			var effectName:String = _effectList.getSelectedValue();
			if(!effectName) return;
			var effectStore:BlEffectStore = BlEffectManager.instance().getEffectStore(effectName);
			if(!effectStore) return;
			_currentStore = effectStore;
			
			// 更新特效元素表
			updateEffect();
			
			hideElementEditor();
			
		}
		// 选择特效元素
		private function onEffectElementSelected(evt:Event):void
		{
			if(!_currentStore || !_currentStore.loader.srcXML) return;
			
			hideElementEditor();
			
			var effObj:EffectListObject = _elementList.getSelectedValue();
			if(!effObj) return;
			
			updateBaseAttribe(effObj.eleXML);		// 基础属性
			
			if(effObj.eleXML.name() == "particle")
			{	// 编辑粒子
				_particleEditor ||= new BlEffectParticleEditor(this, "粒子编辑器", false);
				_particleEditor.srcData = effObj.eleXML;
				_particleEditor.visible = true;
			}
		}
		// 隐藏元素编辑面板
		private function hideElementEditor():void
		{
			if(_particleEditor) 
				_particleEditor.visible = false;
		}
		
		private function onSave(evt:Event):void
		{
			// 保存当前特效
			var effectName:String = _effectList.getSelectedValue();
			if(!effectName)
				return;
			
			var store:BlEffectStore = BlEffectManager.instance().getEffectStore(effectName);
			if(!store)
				return;
			
			store.loader.saveSrcData();
		}
		
		private function onPlay(evt:Event):void
		{
			// 创建特效
			var effectName:String = _effectList.getSelectedValue();
			if(!effectName)
				return;
			
			// 清空特效池
			if(_effectAutoClear.isSelected())
				BlEffectManager.instance().getEffectStore(effectName).clearPool();
			
			// 创建特效对象
			var effect : BlEffect = BlEffectManager.instance().createEffect(effectName);
			if(!effect)
			{
				Debug.trace("effect "+effectName+" not exist");
				return;
			}
			
			_effectNode.addChild(effect);
			
			// 为特效对象添加辅助对象
			BlSceneManager.instance().currentScene.addHelperFor(effect);
		}
		
		private function onTimeUpdateEffectElement(evt:Event):void
		{
			updateEffect();
		}
		
		private function updateEffect():void
		{
			_elementListMod.clear();
			
			var effXML:XML = _currentStore.loader.srcXML;
			
			if(!effXML)
			{
				_listTimer.addEventListener(TimerEvent.TIMER, onTimeUpdateEffectElement);
				_listTimer.start();
				return;
			}
			
			_listTimer.removeEventListener(TimerEvent.TIMER, onTimeUpdateEffectElement);
			_listTimer.stop();
			
			// 特效属性
			
			
			// 特效元素
			var children : XMLList = effXML.children();
			for each(var child : XML in children)
			{
				
				var name:String = child.name();
				if(name == "property")
				{
					// 特效属性
					UpdateEffectTime(child);
					
					
					// 更新基础属性
					updateBaseAttribe(child);
					continue;
				}
				
				_elementListMod.append(new EffectListObject(child));
			}
			
			_elementList.updateUI();
		}
		
		private function updateBaseAttribe(effData:XML):void
		{
			_baseAttribePanel.srcData = effData;
		}
		
		private function UpdateEffectTime(effProperyXML:XML):void
		{
			_effectCache.setValue( int(effProperyXML.@cache.toString()) );
			_effectLifeTime.setValue( int(effProperyXML.@lifetime.toString()) );
		}
		
		private function ChangeEffectTime(evt:Event):void
		{
			if(!_currentStore || !_currentStore.loader.srcXML)
				return;
			
			var effXML:XML = _currentStore.loader.srcXML;
			var propertyXML:XML = effXML.property[0];
			
			propertyXML.@cache = Math.max(_effectCache.getValue(), 1);
			propertyXML.@lifetime = Math.max(_effectLifeTime.getValue(), 0);
		}
		
		private function onAddElement(evt:Event):void
		{
			if(!_currentStore)
				return;
			
			var addEleName : String = _addElementCbx.getSelectedItem();
			if(!addEleName) return;
			
//			switch(addEleName)
//			{
//				case "粒子":
//					_currentStore.loader.srcData.addParticleData();
//					break;
//				
//			}
//			
//			updateEffectElement(_currentStore.loader.srcData);
		}
		
		private function onDelElement(evt:Event):void
		{
			if(!_currentStore)
				return;
			
			var delEleName : String = _elementList.getSelectedValue();
			if(!delEleName) return;
			
//			if(_currentStore.loader.srcData.delData(delEleName))
//				updateEffectElement(_currentStore.loader.srcData);
		}
		
		private function onCopyElement(evt:Event):void
		{
			if(!_currentStore)
				return;
			
			var copyEleName : String = _elementList.getSelectedValue();
			if(!copyEleName) return;
			
//			if(_currentStore.loader.srcData.copyData(copyEleName))
//				updateEffectElement(_currentStore.loader.srcData);
		}
	}
}

class EffectListObject
{
	public var eleXML : XML;
	public function EffectListObject(eleXML:XML):void
	{
		this.eleXML = eleXML;
	}
	
	public function toString():String
	{
		return eleXML.@label; 
	}
}