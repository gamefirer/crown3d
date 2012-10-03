/**
 *	粒子编辑器 
 */
package blade3d.editor.effect
{
	import away3d.debug.Debug;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import org.aswing.ASColor;
	import org.aswing.BorderLayout;
	import org.aswing.JFrame;
	import org.aswing.JList;
	import org.aswing.JPanel;
	import org.aswing.JScrollPane;
	import org.aswing.SoftBoxLayout;
	import org.aswing.VectorListModel;
	import org.aswing.border.LineBorder;
	
	public class BlEffectParticleEditor extends JFrame
	{
		
		private var _particleXML : XML;
		
		// panel
		private var  _panel : JPanel;
		
		private var _upPanel : JPanel;
		private var _downPanel : JPanel;
		
		private var _upLeftPanel : JPanel;
		private var _upRightPanel : JPanel;
		
		// action panel
		private var _systemPanel : BlEffectParticleSystemPanel;			// 系统面板
		private var _emitterPanel : BlEffectParticleEmitterPanel;			// 发射器面板
		private var _samplerPanel : BlEffectParticleSamplerPanel;			// 采样器面板
		private var _effectorPanel : BlEffectParticleEffectorPanel;		// 效果器面板
		private var _animationPanel : BlEffectAnimationPanel;				// 动画面板
		
		// ui
		private var _actionList : JList;
		private var _actionListMod : VectorListModel;
		
		
		
		public function BlEffectParticleEditor(owner:*=null, title:String="", modal:Boolean=false)
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
			
			_upPanel = new JPanel(new SoftBoxLayout(SoftBoxLayout.X_AXIS));
			_upPanel.setPreferredHeight(500);
			_downPanel = new JPanel(new SoftBoxLayout(SoftBoxLayout.X_AXIS));
			_downPanel.setBorder(new LineBorder(null, ASColor.BLUE, 1));
			
			_panel.append(_upPanel, BorderLayout.NORTH);
			_panel.append(_downPanel, BorderLayout.SOUTH);
			
			_upLeftPanel = new JPanel(new SoftBoxLayout(SoftBoxLayout.Y_AXIS));
			_upLeftPanel.setPreferredWidth(150);
			_upLeftPanel.setBorder(new LineBorder(null, ASColor.PINK, 1));
			_upRightPanel = new JPanel(new SoftBoxLayout(SoftBoxLayout.X_AXIS));
			
			_upPanel.append(_upLeftPanel, BorderLayout.WEST);
			_upPanel.append(_upRightPanel, BorderLayout.EAST);
			
			// 影响器列表
			
			var arr:Array = new Array();
			_actionListMod = new VectorListModel(arr);
			_actionList = new JList(_actionListMod);
			_actionList.addSelectionListener(onActionSelected);
			_upLeftPanel.append(_actionList);
			
			show();
		}
		
		public function get srcData():XML
		{
			return _particleXML;
		}
		
		public function set srcData(particleXML:XML):void
		{
			_particleXML = particleXML;
			
			_actionListMod.clear();
			_actionListMod.append("系统属性");
			_actionListMod.append("发射器");
			_actionListMod.append("采样器");
			_actionListMod.append("效果器");
			_actionListMod.append("动画器");
			
			_actionList.updateUI();
		}
		
		private function onActionSelected(evt:Event):void
		{
			_upRightPanel.removeAll();
			
			var actionName:String = _actionList.getSelectedValue();
			if(!actionName) return;
			
			switch(actionName)
			{
				case "系统属性":
				{
					_systemPanel ||= new BlEffectParticleSystemPanel();
					_upRightPanel.append(_systemPanel, BorderLayout.EAST);
					_systemPanel.srcData = _particleXML;
					break;
				}
				case "发射器":
				{
					_emitterPanel ||= new BlEffectParticleEmitterPanel();
					_upRightPanel.append(_emitterPanel, BorderLayout.EAST);
					if(_particleXML.rect_emitter[0])
						_emitterPanel.srcData = _particleXML.rect_emitter[0];
					else if(_particleXML.circle_emitter[0])
						_emitterPanel.srcData = _particleXML.circle_emitter[0];
					else if(_particleXML.sphere_emitter[0])
						_emitterPanel.srcData = _particleXML.sphere_emitter[0];
					break;
				}
				case "采样器":
				{
//					_samplerPanel ||= new BlEffectParticleSamplerPanel();
//					_upRightPanel.append(_samplerPanel, BorderLayout.CENTER);
//					_samplerPanel.srcData = _srcXML.samplerData;
					break;
				}
				case "效果器":
				{
					_effectorPanel ||= new BlEffectParticleEffectorPanel();
					_upRightPanel.append(_effectorPanel, BorderLayout.EAST);
					_effectorPanel.srcData = _particleXML;
					break;
				}
				case "动画器":
				{
					_animationPanel ||= new BlEffectAnimationPanel();
					_upRightPanel.append(_animationPanel, BorderLayout.EAST);
					_animationPanel.srcData = _particleXML;
					break;
				}
				default:
				{
					Debug.assert(false, "error onActionSelected");
					break;
				}
			}
			
			_upRightPanel.updateUI();
			
		}
		
	}
}