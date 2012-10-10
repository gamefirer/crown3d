/**
 *	效果器面板 
 */
package blade3d.editor.effect
{
	import flash.events.Event;
	
	import org.aswing.ASColor;
	import org.aswing.JButton;
	import org.aswing.JComboBox;
	import org.aswing.JList;
	import org.aswing.JPanel;
	import org.aswing.LayoutManager;
	import org.aswing.SoftBoxLayout;
	import org.aswing.VectorListModel;
	import org.aswing.border.LineBorder;
	import org.aswing.colorchooser.VerticalLayout;
	
	public class BlEffectParticleEffectorPanel extends JPanel
	{
		private var _particleXML : XML;
		
		private var _leftPanel : JPanel;
		private var _rightPanel : JPanel;

		// 效果器XML
		private var _sizeEffectorXML : XML;			// 大小效果器
		private var _colorEffectorXML : XML;			// 颜色效果器
		private var _alphaEffectorXML : XML;			// 透明度效果器
		private var _uvEffectorXML : XML;				// uv效果器
		private var _attractEffectorXML : XML;			// 吸引效果器
		private var _forceEffectorXML : XML;			// 力场效果器
		private var _velAttractEffectorXML : XML;		// 速度吸引器
		
		// 面板
		private var _sizePanel : BlEffectParticleEffectorSizePanel;		// 大小效果器面板
		private var _alphaPanel : BlEffectParticleEffectorAlphaPanel;		// 透明度效果器面板
		private var _colorPanel : BlEffectParticleEffectorColorPanel;		// 颜色效果器面板
		private var _attractPanel : BlEffectParticleEffectorAttractPanel;	// 吸引效果器面板
		private var _forcePanel : BlEffectParticleEffectorForcePanel;		// 力场效果器面板
		private var _velAttractPanel : BlEffectParticleEffectorVelAttractPanel;	// 速度吸引器面板
		private var _uvPanel : BlEffectParticleEffectorUVPanel;			// UV效果器面板
		
		// 效果器列表
		private var _effectList : JList;
		private var _effectListModel : VectorListModel;
		
		// 添加栏
		private var _addEffectList : JComboBox;
		private var _addBtn : JButton;
		private var _delBtn : JButton;
		
		public function BlEffectParticleEffectorPanel()
		{
			super(new SoftBoxLayout(SoftBoxLayout.X_AXIS));
			initUI();
		}
		
		public function set srcData(partilceXML:XML):void
		{
			_particleXML = partilceXML;
			updateUIByData();
		}
		
		private function initUI():void
		{
			append(_leftPanel = new JPanel(new VerticalLayout));
			append(_rightPanel = new JPanel(new VerticalLayout));
			
			// 效果器列表
			_effectListModel = new VectorListModel;
			_effectList = new JList(_effectListModel);
			_effectList.setBorder(new LineBorder(null, ASColor.BLACK));
			_effectList.setPreferredWidth(150);
			_effectList.addSelectionListener(onSelectEffector);
			_leftPanel.append(_effectList);
			
			// 添加栏
			var hp:JPanel;
			_leftPanel.append(hp = new JPanel);
			
			_addBtn = new JButton("添加");
			_addBtn.addActionListener(onAddEffector);
			hp.append(_addBtn);
			
			var arr:Array = new Array;
			arr.push("大小效果器");
			arr.push("颜色效果器");
			arr.push("透明效果器");
			arr.push("UV效果器");
			arr.push("吸引效果器");
			arr.push("力场效果器");
			arr.push("速度吸引器");
			_addEffectList = new JComboBox(new VectorListModel(arr));
			_addEffectList.setPreferredWidth(100);
			_addEffectList.setSelectedIndex(0);
			hp.append(_addEffectList);
			
			_leftPanel.append(hp = new JPanel);
			_delBtn = new JButton("删除");
			_delBtn.addActionListener(onDelEffector);
			hp.append(_delBtn);
			
		}
		
		private function onAddEffector(evt:Event):void
		{
			switch( _addEffectList.getSelectedIndex() )
			{
				case 0:
				{
					if(_particleXML.size_effector[0] == null)
						_particleXML.appendChild(<size_effector/>);
					break;
				}
				case 1:
				{
					if(_particleXML.color_effector[0] == null)
						_particleXML.appendChild(<color_effector/>);
					break;
				}
				case 2:
				{
					if(_particleXML.alpha_effector[0] == null)
						_particleXML.appendChild(<alpha_effector/>);
					break;
				}
				case 3:
				{
					if(_particleXML.uv_effector[0] == null)
						_particleXML.appendChild(<uv_effector/>);
					break;
				}
				case 4:
				{
					if(_particleXML.attract_effector[0] == null)
						_particleXML.appendChild(<attract_effector/>);
					break;
				}
				case 5:
				{
					if(_particleXML.force_effector[0] == null)
						_particleXML.appendChild(<force_effector/>);
					break;
				}
				case 6:
				{
					if(_particleXML.velattract_effector[0] == null)
						_particleXML.appendChild(<velattract_effector/>);
					break;
				}
				
			}
			
			updateUIByData();
		}
		
		private function onDelEffector(evt:Event):void
		{
			var selectObj : effectListObject = _effectList.getSelectedValue();
			if(!selectObj) return;
			
			var effectorXML : XML = selectObj.xml;
			if(effectorXML.name() == "size_effector")
				delete _particleXML.size_effector;
			else if(effectorXML.name() == "color_effector")
				delete _particleXML.color_effector;
			else if(effectorXML.name() == "alpha_effector")
				delete _particleXML.alpha_effector;
			else if(effectorXML.name() == "uv_effector")
				delete _particleXML.uv_effector;
			else if(effectorXML.name() == "attract_effector")
				delete _particleXML.attract_effector;
			else if(effectorXML.name() == "force_effector")
				delete _particleXML.force_effector;
			else if(effectorXML.name() == "velattract_effector")
				delete _particleXML.velattract_effector;
			
			updateUIByData();
		}
		
		private function onSelectEffector(evt:Event):void
		{
			_rightPanel.removeAll();
			
			var selectObj : effectListObject = _effectList.getSelectedValue();
			if(!selectObj) return;
			
			var effectorXML : XML = selectObj.xml;
			if(effectorXML.name() == "size_effector")
			{
				_sizePanel ||= new BlEffectParticleEffectorSizePanel;
				_sizePanel.srcData = effectorXML;
				_rightPanel.append(_sizePanel);
			}
			else if(effectorXML.name() == "alpha_effector")
			{
				_alphaPanel ||= new BlEffectParticleEffectorAlphaPanel;
				_alphaPanel.srcData = effectorXML;
				_rightPanel.append(_alphaPanel);
			}
			else if(effectorXML.name() == "color_effector")
			{
				_colorPanel ||= new BlEffectParticleEffectorColorPanel;
				_colorPanel.srcData = effectorXML;
				_rightPanel.append(_colorPanel);
			}
			else if(effectorXML.name() == "uv_effector")
			{
				_uvPanel ||= new BlEffectParticleEffectorUVPanel;
				_uvPanel.srcData = effectorXML;
				_rightPanel.append(_uvPanel);
			}
			else if(effectorXML.name() == "attract_effector")
			{
				_attractPanel ||= new BlEffectParticleEffectorAttractPanel;
				_attractPanel.srcData = effectorXML;
				_rightPanel.append(_attractPanel);
			}
			else if(effectorXML.name() == "force_effector")
			{
				_forcePanel ||= new BlEffectParticleEffectorForcePanel;
				_forcePanel.srcData = effectorXML;
				_rightPanel.append(_forcePanel);
			}
			else if(effectorXML.name() == "velattract_effector")
			{
				_velAttractPanel ||= new BlEffectParticleEffectorVelAttractPanel;
				_velAttractPanel.srcData = effectorXML;
				_rightPanel.append(_velAttractPanel);
			}
			
		}
		
		private function updateUIByData():void
		{
			_effectListModel.clear();
			
			var effectorXML : XML;
			// 粒子大小效果器
			_sizeEffectorXML = _particleXML.size_effector[0];
			if(_sizeEffectorXML)
			{
				_effectListModel.append(new effectListObject(_sizeEffectorXML, "大小效果器"));
			}
			
			// 粒子颜色效果器
			_colorEffectorXML = _particleXML.color_effector[0];
			if(_colorEffectorXML)
			{
				_effectListModel.append(new effectListObject(_colorEffectorXML, "颜色效果器"));
			}
			
			// 透明度效果器
			_alphaEffectorXML = _particleXML.alpha_effector[0];
			if(_alphaEffectorXML)
			{
				_effectListModel.append(new effectListObject(_alphaEffectorXML, "透明效果器"));
			}
			
			// 粒子UV效果器
			_uvEffectorXML = _particleXML.uv_effector[0];
			if(_uvEffectorXML)
			{
				_effectListModel.append(new effectListObject(_uvEffectorXML, "UV效果器"));
			}
			
			// 粒子吸引器
			_attractEffectorXML = _particleXML.attract_effector[0];
			if(_attractEffectorXML)
			{
				_effectListModel.append(new effectListObject(_attractEffectorXML, "吸引效果器"));
			}
			// 粒子力场控制器
			_forceEffectorXML = _particleXML.force_effector[0];
			if(_forceEffectorXML)
			{
				_effectListModel.append(new effectListObject(_forceEffectorXML, "力场效果器"));
			}
			// 速度吸引器
			_velAttractEffectorXML = _particleXML.velattract_effector[0];
			if(_velAttractEffectorXML)
			{
				_effectListModel.append(new effectListObject(_velAttractEffectorXML, "速度吸引器"));
			}
			
		}
	}
}

class effectListObject
{
	public var xml:XML;
	public var type:String;
	
	public function effectListObject(xml:XML, type:String):void
	{
		this.xml = xml;
		this.type = type;
	}
	
	public function toString():String
	{
		return type; 
	}
}