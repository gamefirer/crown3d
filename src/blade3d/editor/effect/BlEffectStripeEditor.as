/**
 *	条带编辑器 
 */
package blade3d.editor.effect
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import org.aswing.ASColor;
	import org.aswing.BorderLayout;
	import org.aswing.JFrame;
	import org.aswing.JList;
	import org.aswing.JPanel;
	import org.aswing.SoftBoxLayout;
	import org.aswing.VectorListModel;
	import org.aswing.border.LineBorder;
	
	public class BlEffectStripeEditor extends JFrame
	{
		
		private var _stripeXML : XML;
		
		// panel
		private var  _panel : JPanel;
		
		private var _leftPanel : JPanel;
		private var _rightPanel : JPanel;
		
		private var _systemPanel : BlEffectStripeSystemPanel;				// 系统面板
		private var _animationPanel : BlEffectAnimationPanel;				// 动画面板
		private var _effectorPanel : BlEffectParticleEffectorPanel;		// 效果器面板
		
		private var _draggerPanel : BlEffectStripeDraggerPanel;			// 拖尾生成器
		private var _lightingPanel : BlEffectStripeLightingPanel;				// 带状生成器
		
		private var _actionList : JList;
		
		public function BlEffectStripeEditor(owner:*=null, title:String="", modal:Boolean=false)
		{
			super(owner, title, modal);
			initUI();
		}
		
		private function initUI():void
		{
			// pos和size
			setSizeWH(550, 550);
			var parent:Sprite = Sprite(owner);
			setLocationXY( 30, 0 );
			
			// panel
			_panel = new JPanel(new BorderLayout(0,0));
			setContentPane(_panel);
			
			_leftPanel = new JPanel(new SoftBoxLayout(SoftBoxLayout.Y_AXIS));
			_leftPanel.setPreferredHeight(500);
			_leftPanel.setBorder(new LineBorder(null, ASColor.RED, 1));
				
			_rightPanel = new JPanel(new SoftBoxLayout(SoftBoxLayout.Y_AXIS));
			_rightPanel.setBorder(new LineBorder(null, ASColor.BLUE, 1));
			
			_panel.append(_leftPanel, BorderLayout.WEST);
			_panel.append(_rightPanel, BorderLayout.CENTER);
			
			show();
			
			// 系统编辑列表
			var arr:Array = new Array();
			arr.push("系统属性");
			arr.push("生成器");
			arr.push("效果器");
			arr.push("动画器");
			var actionListMod : VectorListModel = new VectorListModel(arr);
			_actionList = new JList(actionListMod);
			_actionList.setPreferredWidth(150);
			_actionList.addSelectionListener(onActionSelected);
			_leftPanel.append(_actionList);
		}
		
		public function set srcData(stripeXML:XML):void
		{
			_stripeXML = stripeXML;
		}
		
		private function onActionSelected(evt:Event):void
		{
			_rightPanel.removeAll();
			
			var actionName:String = _actionList.getSelectedValue();
			if(!actionName) return;
			
			switch(actionName)
			{
				case "系统属性":
				{
					_systemPanel ||= new BlEffectStripeSystemPanel();
					_rightPanel.append(_systemPanel);
					_systemPanel.srcData = _stripeXML;
					break;
				}
				case "动画器":
				{
					_animationPanel ||= new BlEffectAnimationPanel();
					_rightPanel.append(_animationPanel, BorderLayout.EAST);
					_animationPanel.srcData = _stripeXML;
					break;
				}
				case "效果器":
				{
					_effectorPanel ||= new BlEffectParticleEffectorPanel();
					_rightPanel.append(_effectorPanel, BorderLayout.EAST);
					_effectorPanel.srcData = _stripeXML;
					break;
				}
				case "生成器":
				{
					if(_stripeXML.dragger[0])
					{
						_draggerPanel ||= new BlEffectStripeDraggerPanel;
						_rightPanel.append(_draggerPanel, BorderLayout.EAST);
						_draggerPanel.srcData = _stripeXML.dragger[0];
					}
					else if(_stripeXML.lighting[0])
					{
						_lightingPanel ||= new BlEffectStripeLightingPanel;
						_rightPanel.append(_lightingPanel, BorderLayout.EAST);
						_lightingPanel.srcData = _stripeXML.lighting[0];
					}
					
					break;
				}
			
			}
			
		}
	}
}