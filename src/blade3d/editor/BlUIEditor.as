/**
 *	3d ui的流量器 
 */
package blade3d.editor
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import org.aswing.ASColor;
	import org.aswing.BorderLayout;
	import org.aswing.JButton;
	import org.aswing.JCheckBox;
	import org.aswing.JFrame;
	import org.aswing.JPanel;
	import org.aswing.JScrollPane;
	import org.aswing.JTree;
	import org.aswing.SoftBoxLayout;
	import org.aswing.border.LineBorder;
	import org.aswing.tree.DefaultMutableTreeNode;
	import org.aswing.tree.DefaultTreeModel;
	
	import sl2d.display.slBounds;
	import sl2d.display.slGroup;
	import sl2d.display.slObject;
	import sl2d.slGlobal;
	import sl2d.slWorld;
	
	public class BlUIEditor extends JFrame
	{
		private var _panel : JPanel;
		private var _upPanel : JPanel;
		private var _centerPanel : JPanel;
		private var _downPanel : JPanel;
		
		// UI树
		private var _uiTree : JTree;
		private var _uiTreeModel : DefaultTreeModel;
		private var _rootTreeNode : DefaultMutableTreeNode;
		
		public function BlUIEditor(owner:*=null, title:String="", modal:Boolean=false)
		{
			super(owner, title, modal);
			
			setSizeWH(300, 450);
			var parent:Sprite = Sprite(owner);
			setLocationXY( parent.width - (300+50), 0 );
			
			_panel = new JPanel(new BorderLayout(1, 1));
			setContentPane(_panel);
			_panel.setBorder(new LineBorder(null, ASColor.ORANGE));
			
			show();
			
			initPanel();
			initUI();
		}
		
		private function initPanel():void
		{
			_upPanel = new JPanel(new SoftBoxLayout(SoftBoxLayout.Y_AXIS));
			_centerPanel = new JPanel(new SoftBoxLayout(SoftBoxLayout.Y_AXIS));
			_downPanel = new JPanel(new SoftBoxLayout(SoftBoxLayout.Y_AXIS));
			
			_panel.append(_upPanel, BorderLayout.NORTH);
			_panel.append(_centerPanel, BorderLayout.CENTER);
			_panel.append(_downPanel, BorderLayout.SOUTH);
		}
		
		private function initUI():void
		{
			var renderUIChk : JCheckBox = new JCheckBox("显示UI");
			_upPanel.append(renderUIChk);
			renderUIChk.setSelected(slWorld.RenderUI);
			renderUIChk.addActionListener(
				function(evt:Event):void
				{
					slWorld.RenderUI = renderUIChk.isSelected();
				}
			);
			
			var refreshBtn : JButton = new JButton("更新");
			_upPanel.append(refreshBtn);
			refreshBtn.addActionListener(
				function(evt:Event):void
				{
					refreshUITree();
				}
			);
		
			// ui tree
			_uiTree = new JTree();
//			_uiTree.addSelectionListener(onTreeNodeSelected);
			_centerPanel.append(new JScrollPane(_uiTree));
			
			_rootTreeNode = new DefaultMutableTreeNode("slUIFrame");
			_uiTreeModel = new DefaultTreeModel(_rootTreeNode);
			_uiTree.setModel(_uiTreeModel);
			
			refreshUITree();
		}
		
		private function refreshUITree():void
		{
			_rootTreeNode.removeAllChildren();
			
			recurUI(slGlobal.View, _rootTreeNode);
			
			_uiTree.updateUI();
		}
		
		private function recurUI(slObj:slBounds, treeNode:DefaultMutableTreeNode):void
		{
			if(slObj is slGroup)
			{
				var group : slGroup = slGroup(slObj);
				
				for each(var child:slBounds in group.children)
				{
					var newTreeNode : DefaultMutableTreeNode = new DefaultMutableTreeNode(child);
					treeNode.append(newTreeNode);
					
					if(!child.drawEnable)
						newTreeNode.color = ASColor.LIGHT_GRAY;
					
					recurUI(child, newTreeNode);
				}
			}
		}
	}
}