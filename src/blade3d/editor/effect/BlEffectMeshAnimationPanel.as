/**
 *	模型动画面板 
 */
package blade3d.editor.effect
{
	import flash.events.Event;
	
	import org.aswing.ASColor;
	import org.aswing.BorderLayout;
	import org.aswing.JList;
	import org.aswing.JPanel;
	import org.aswing.JScrollPane;
	import org.aswing.LayoutManager;
	import org.aswing.SoftBoxLayout;
	import org.aswing.VectorListModel;
	import org.aswing.border.LineBorder;
	import org.aswing.colorchooser.VerticalLayout;
	
	public class BlEffectMeshAnimationPanel extends JPanel
	{
		private var _objectXML : XML;
		
		private var _leftPanel : JPanel;
		private var _rightPanel : JPanel;
		private var _actionList : JList;
		
		// 面板
		private var _colorPanel : BlEffectMeshAnimationColorPanel;
		private var _uvPanel : BlEffectMeshAnimationUVPanel;
		
		public function set srcData(objectXML:XML):void
		{
			_objectXML = objectXML;
			updateUIByData();
		}
		
		public function BlEffectMeshAnimationPanel()
		{
			super(new SoftBoxLayout(SoftBoxLayout.X_AXIS));
			initUI();
		}
		
		private function initUI():void
		{
			_leftPanel = new JPanel(new SoftBoxLayout(SoftBoxLayout.Y_AXIS));
			_leftPanel.setPreferredHeight(500);
			_leftPanel.setBorder(new LineBorder(null, ASColor.RED, 1));
			
			_rightPanel = new JPanel(new SoftBoxLayout(SoftBoxLayout.Y_AXIS));
			_rightPanel.setBorder(new LineBorder(null, ASColor.BLUE, 1));
			
			append(_leftPanel, BorderLayout.WEST);
			append(_rightPanel, BorderLayout.CENTER);
			
			// left
			var arr:Array = new Array;
			arr.push("颜色动画");
			arr.push("UV动画");
			var actionListMod : VectorListModel = new VectorListModel(arr);
			_actionList = new JList(actionListMod);
			_actionList.setPreferredWidth(150);
			_actionList.addSelectionListener(onAnimationSelected);
			_leftPanel.append(_actionList);
			
			// 颜色动画
			_colorPanel = new BlEffectMeshAnimationColorPanel;
			// UV动画
			_uvPanel = new BlEffectMeshAnimationUVPanel;
		}
		
		private function onAnimationSelected(evt:Event):void
		{
			_rightPanel.removeAll();
			
			var actionName:String = _actionList.getSelectedValue();
			if(!actionName) return;
			
			switch(actionName)
			{
				case "颜色动画":
				{
					_rightPanel.append(_colorPanel);
					break;
				}
				case "UV动画":
				{
					_rightPanel.append(_uvPanel);
					break;
				}
			}
		}
		
		private function updateUIByData():void
		{
			var color_xml : XML = _objectXML.color[0];
			if(!color_xml)
			{
				color_xml = <color/>;
				_objectXML.appendChild(color_xml);
			}
			
			var uv_xml : XML = _objectXML.uv[0];
			if(!uv_xml)
			{
				uv_xml = <uv/>;
				_objectXML.appendChild(uv_xml);
			}
			
			_colorPanel.srcData = color_xml;
			_uvPanel.srcData = uv_xml;
		}
	}
}