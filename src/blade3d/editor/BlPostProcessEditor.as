/**
 *	后期特效编辑 
 */
package blade3d.editor
{
	import blade3d.editor.poster.BlPosterBlurPanel;
	import blade3d.editor.poster.BlPosterSaturationPanel;
	import blade3d.postprocess.BlBlurPoster;
	import blade3d.postprocess.BlPostProcessManager;
	import blade3d.postprocess.BlPoster;
	import blade3d.postprocess.BlSaturationPoster;
	import blade3d.ui.editor.slRttShower;
	import blade3d.ui.slUIManager;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import org.aswing.ASColor;
	import org.aswing.BorderLayout;
	import org.aswing.JButton;
	import org.aswing.JCheckBox;
	import org.aswing.JComboBox;
	import org.aswing.JFrame;
	import org.aswing.JList;
	import org.aswing.JPanel;
	import org.aswing.SoftBoxLayout;
	import org.aswing.VectorListModel;
	import org.aswing.border.LineBorder;
	import org.aswing.colorchooser.VerticalLayout;
	
	public class BlPostProcessEditor extends JFrame
	{
		private var _panel : JPanel;
		private var _upPanel : JPanel;
		private var _centerPanel : JPanel;
		private var _downPanel : JPanel;
		private var _posterPanel : JPanel;
		
		private var _blurPanel : BlPosterBlurPanel;
		private var _saturationPanel : BlPosterSaturationPanel;
		
		private var _addComboBox : JComboBox;
		private var _addBtn : JButton;
		private var _delBtn : JButton;
		
		private var _postList : JList;
		private var _postListModel : VectorListModel;
		
		
		
		public function BlPostProcessEditor(owner:*=null, title:String="", modal:Boolean=false)
		{
			super(owner, title, modal);
			
			setSizeWH(300, 600);
			var parent:Sprite = Sprite(owner);
			setLocationXY( parent.width - (300+30), 0 );
			
			initPanel();
			
			show();
			
			initUpPanel();
			
			initDownPanel();
			
		}
		
		private function initPanel():void
		{
			_panel = new JPanel(new BorderLayout(2,2));
			setContentPane(_panel);
			_panel.setBorder(new LineBorder(null, ASColor.GREEN));		// _panel 绿边
			
			_upPanel = new JPanel(new VerticalLayout);
			_upPanel.setBorder(new LineBorder(null, ASColor.BLUE));
			_centerPanel = new JPanel(new SoftBoxLayout(SoftBoxLayout.Y_AXIS));
			_centerPanel.setBorder(new LineBorder(null, ASColor.BLUE));
			_downPanel = new JPanel(new SoftBoxLayout(SoftBoxLayout.Y_AXIS));
			_downPanel.setBorder(new LineBorder(null, ASColor.BLUE));
			
			_panel.append(_upPanel, BorderLayout.NORTH);
			_panel.append(_centerPanel, BorderLayout.CENTER);
			_panel.append(_downPanel, BorderLayout.SOUTH);
		}
		
		private function initUpPanel():void
		{
			// 是否显示渲染图
			var rttShowBtn : JCheckBox = new JCheckBox("显示渲染图");
			rttShowBtn.addActionListener(
				function(evt:Event):void
				{
					slUIManager.instance().frame.rttShower.showRtt(rttShowBtn.isSelected());
				}
			);
			_upPanel.append(rttShowBtn);
			// 渲染图切换
			var arr:Array = new Array();
			arr.push("深度图");
			arr.push("色彩图");
			arr.push("阴影图");
			arr.push("贴图灯");
			var switchRttListMod : VectorListModel = new VectorListModel(arr);
			
			var switchRttCbb0 : JComboBox = new JComboBox(switchRttListMod);
			switchRttCbb0.setPreferredWidth(100);
			switchRttCbb0.addActionListener(
				function(evt:Event):void
				{
					slUIManager.instance().frame.rttShower.setRtt(0, switchRttCbb0.getSelectedIndex());
				}
				);
			_upPanel.append(switchRttCbb0);
			
			var switchRttCbb1 : JComboBox = new JComboBox(switchRttListMod);
			switchRttCbb1.setPreferredWidth(100);
			switchRttCbb1.addActionListener(
				function(evt:Event):void
				{
					slUIManager.instance().frame.rttShower.setRtt(1, switchRttCbb1.getSelectedIndex());
				}
			);
			_upPanel.append(switchRttCbb1);
			
			var switchRttCbb2 : JComboBox = new JComboBox(switchRttListMod);
			switchRttCbb2.setPreferredWidth(100);
			switchRttCbb2.addActionListener(
				function(evt:Event):void
				{
					slUIManager.instance().frame.rttShower.setRtt(2, switchRttCbb2.getSelectedIndex());
				}
			);
			_upPanel.append(switchRttCbb2);
			
			var switchRttCbb3 : JComboBox = new JComboBox(switchRttListMod);
			switchRttCbb3.setPreferredWidth(100);
			switchRttCbb3.addActionListener(
				function(evt:Event):void
				{
					slUIManager.instance().frame.rttShower.setRtt(3, switchRttCbb3.getSelectedIndex());
				}
			);
			_upPanel.append(switchRttCbb3);
		}
		
		private function initDownPanel():void
		{
			var hPanel : JPanel;
			_centerPanel.append(hPanel = new JPanel);
			
			var arr:Array = new Array;
			arr.push("模糊");
			arr.push("色调");
			_addComboBox = new JComboBox(new VectorListModel(arr));
			_addComboBox.setPreferredWidth(150);
			_addComboBox.setSelectedIndex(0);
			hPanel.append(_addComboBox);
			
			_centerPanel.append(hPanel = new JPanel);
			
			_addBtn = new JButton("添加");
			_addBtn.addActionListener(onAddPoster);
			hPanel.append(_addBtn);
			
			_delBtn = new JButton("删除");
			_delBtn.addActionListener(onRemovePoster);
			hPanel.append(_delBtn);
			
			
			_postListModel = new VectorListModel();
			_postList = new JList(_postListModel);
			_postList.setBorder(new LineBorder(null, ASColor.BLACK));
			_postList.addSelectionListener(onSelectPostList);
			_centerPanel.append(_postList);
			
			_centerPanel.append(_posterPanel = new JPanel);
		}
		
		private function onAddPoster(evt:Event):void
		{
			var addIndex : uint = _addComboBox.getSelectedIndex();
			var posterCode : uint = 0;
			switch(addIndex)
			{
				case 0:		// 模糊
					posterCode = BlPoster.POSTER_BLUR;
					break;
				case 1:		// 色调
					posterCode = BlPoster.POSTER_SATURATION;
					break;
			}
			
			BlPostProcessManager.instance().addPoster(posterCode);
			
			updatePosterList();
		}
		
		private function onRemovePoster(evt:Event):void
		{
			var posterName : String = _postList.getSelectedValue();
			var posterCode : uint;
			switch(posterName)
			{
				case "模糊":
					posterCode = BlPoster.POSTER_BLUR;
					break;
				case "色调":
					posterCode = BlPoster.POSTER_SATURATION;
					break;
			}
			
			BlPostProcessManager.instance().removePoster(posterCode);
			
			updatePosterList();
		}
		
		private function updatePosterList():void
		{
			_postListModel.clear();
			
			var posterMap : Dictionary = BlPostProcessManager.instance().posterMap;
			for each(var poster : BlPoster in posterMap)
			{
				if(!poster)
					continue;
				
				_postListModel.append(new ListObj(poster));
				
			}
			
			_postList.updateUI();
		}
		
		private function onSelectPostList(evt:Event):void
		{
			_posterPanel.removeAll();
			
			var obj:ListObj =  _postList.getSelectedValue();
			if(!obj)
				return;
			
			var poster : BlPoster = obj.poster;

			switch(poster.type)
			{
				case BlPoster.POSTER_BLUR:
					_blurPanel ||= new BlPosterBlurPanel;
					_blurPanel.poster = BlBlurPoster(poster);
					_posterPanel.append(_blurPanel);
					break;
				case BlPoster.POSTER_SATURATION:
					_saturationPanel ||= new BlPosterSaturationPanel;
					_saturationPanel.poster = BlSaturationPoster(poster);
					_posterPanel.append(_saturationPanel);
					break;
			}
			
		}
	}
}


import blade3d.postprocess.BlPoster;

class ListObj
{
	public var poster : BlPoster;
	
	public function ListObj(poster:BlPoster):void
	{
		this.poster = poster;
	}
	
	public function toString():String
	{
		switch(poster.type)
		{
			case BlPoster.POSTER_BLUR:
				return "模糊";
			case BlPoster.POSTER_SATURATION:
				return "色调";
		}
		return ""; 
	}
}
