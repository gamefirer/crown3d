/**
 *	基础动画面板 
 */
package blade3d.editor.effect
{
	import org.aswing.ASColor;
	import org.aswing.JLabel;
	import org.aswing.JList;
	import org.aswing.JPanel;
	import org.aswing.JScrollPane;
	import org.aswing.LayoutManager;
	import org.aswing.SoftBoxLayout;
	import org.aswing.border.LineBorder;
	import org.aswing.colorchooser.VerticalLayout;
	
	public class BlEffectAnimationPanel extends JPanel
	{
		private var _objectXML : XML;
		
		// 面板
		private var _pathPanel : BlEffectAnimationPathPanel;
		private var _rotPanel : BlEffectAnimationRotPanel;
		private var _scalePanel : BlEffectAnimationScalePanel;
		
		// 选择动画
		private var rotAniList : JList;
		
		
		public function BlEffectAnimationPanel()
		{
			super(new SoftBoxLayout(SoftBoxLayout.X_AXIS));
			initUI();
		}
		
		public function set srcData(objectXML:XML):void
		{
			_objectXML = objectXML;
			updateUIByData();
		}
		
		private function initUI():void
		{
			var mainPanel : JPanel = new JPanel(new VerticalLayout);
			var scroll : JScrollPane = new JScrollPane(mainPanel);
			scroll.setPreferredWidth(300);
			append(scroll);
			
			// 位移动画
			_pathPanel = new BlEffectAnimationPathPanel;
			mainPanel.append(_pathPanel);
			// 旋转动画
			_rotPanel = new BlEffectAnimationRotPanel;
			mainPanel.append(_rotPanel);
			// 缩放动画
			_scalePanel = new BlEffectAnimationScalePanel;
			mainPanel.append(_scalePanel);
			
		}
		
		private function updateUIByData():void
		{
			var path_xml : XML = _objectXML.path[0];
			if(!path_xml)
			{
				path_xml = <path/>;
				_objectXML.appendChild(path_xml);
			}
			var rotate_xml : XML = _objectXML.rotate[0];
			if(!rotate_xml)
			{
				rotate_xml = <rotate/>;
				_objectXML.appendChild(rotate_xml);
			}
			var scale_xml : XML = _objectXML.scale[0];
			if(!scale_xml)
			{
				scale_xml = <scale/>;
				_objectXML.appendChild(scale_xml);
			}
			
			_pathPanel.srcData = path_xml;
			_rotPanel.srcData = rotate_xml;
			_scalePanel.srcData = scale_xml;
		}
	}
}