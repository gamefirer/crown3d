/**
 *	后期特效编辑 
 */
package blade3d.editor
{
	import blade3d.ui.editor.slRttShower;
	import blade3d.ui.slUIManager;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import org.aswing.ASColor;
	import org.aswing.BorderLayout;
	import org.aswing.JCheckBox;
	import org.aswing.JComboBox;
	import org.aswing.JFrame;
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
		
		
		public function BlPostProcessEditor(owner:*=null, title:String="", modal:Boolean=false)
		{
			super(owner, title, modal);
			
			setSizeWH(300, 600);
			var parent:Sprite = Sprite(owner);
			setLocationXY( parent.width - (300+30), 0 );
			
			initPanel();
			
			show();
			
			initUpPanel();
			
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
	}
}


