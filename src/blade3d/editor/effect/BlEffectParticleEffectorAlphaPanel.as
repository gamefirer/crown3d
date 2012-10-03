/**
 *	透明度效果器面板 
 */
package blade3d.editor.effect
{
	import away3d.materials.passes.GpuParticlePass;
	
	import flash.events.Event;
	
	import org.aswing.ASColor;
	import org.aswing.JAdjuster;
	import org.aswing.JButton;
	import org.aswing.JLabel;
	import org.aswing.JList;
	import org.aswing.JPanel;
	import org.aswing.LayoutManager;
	import org.aswing.VectorListModel;
	import org.aswing.border.LineBorder;
	import org.aswing.colorchooser.VerticalLayout;
	
	public class BlEffectParticleEffectorAlphaPanel extends JPanel
	{
		private var _alphaEffectorXML : XML;
				
		private var _frameList : JList;
		private var _frameListModel : VectorListModel;
		private var _selectFrameXML : XML;

		private var _add : JButton;
		private var _del : JButton;
		
		private var _lifePercent : JAdjuster;
		private var _alpha : JAdjuster;
		
		public function set srcData(alphaXML:XML):void
		{
			_alphaEffectorXML = alphaXML;
			updateUIByData();
		}
		
		public function BlEffectParticleEffectorAlphaPanel()
		{
			super(new VerticalLayout());
			
			// 帧列表
			_frameListModel = new VectorListModel;
			_frameList = new JList(_frameListModel);
			_frameList.setBorder(new LineBorder(null, ASColor.BLACK));
			_frameList.setPreferredWidth(120);
			_frameList.addSelectionListener(onSelectFrame);
			append(_frameList);
			
			var hp:JPanel = new JPanel;
			append(hp);
			
			_add = new JButton("添加帧");
			_add.addActionListener(onAddFrame);
			hp.append(_add);
			_del = new JButton("删除帧");
			_del.addActionListener(onDelFrame);
			hp.append(_del);
			
			// 生命期
			append(hp = new JPanel);
			hp.append(new JLabel("生命期"));
			_lifePercent = new JAdjuster;
			_lifePercent.setMinimum(0);
			_lifePercent.setMaximum(100);
			_lifePercent.addActionListener(updateData);
			hp.append(_lifePercent);
			
			// alpha
			append(hp = new JPanel);
			hp.append(new JLabel("透明度"));
			_alpha = new JAdjuster;
			_alpha.setMinimum(0);
			_alpha.setMaximum(255);
			_alpha.addActionListener(updateData);
			hp.append(_alpha);
			
		}
		
		private function onAddFrame(evt:Event):void
		{
			if( _frameListModel.size() >= GpuParticlePass.gpuEffectorKeyFrameMax )
				return;
			
			var selObj : frameObj = _frameList.getSelectedValue();
			_alphaEffectorXML.insertChildAfter((selObj ? selObj.xml : null), <keyframe a="0.0" lifepercent="0.0"/>);
			
			updateUIByData();
			
		}
		
		private function onDelFrame(evt:Event):void
		{
			var selIndex : int = _frameList.getSelectedIndex();
			if(selIndex == -1) selIndex = 0;
			
			var akeyFrameList:XMLList = _alphaEffectorXML.keyframe;
			if(akeyFrameList.length() <= selIndex)
				return;
			delete akeyFrameList[selIndex];
			updateUIByData();
		}
		
		private function onSelectFrame(evt:Event):void
		{
			var selectObj : frameObj = _frameList.getSelectedValue();
			if(!selectObj) 
			{
				_selectFrameXML = null;
				_lifePercent.setValue(0);
				_alpha.setValue(0);
				return;
			}
			
			_selectFrameXML = selectObj.xml;
			
			
			_lifePercent.setValue( Number(_selectFrameXML.@lifepercent.toString()) * 100 );
			_alpha.setValue( int(_selectFrameXML.@a.toString()) );
		}
		
		private function updateData(evt:Event):void
		{
			if(!_selectFrameXML) return;
			
			_selectFrameXML.@lifepercent = Number(_lifePercent.getValue())/100;
			_selectFrameXML.@a = _alpha.getValue();
		}
		
		private function updateUIByData():void
		{
			_frameListModel.clear();
			
			var akeyFrameList:XMLList = _alphaEffectorXML.keyframe;
			
			var i:int = 1;
			var akey:XML;
			for each(akey in akeyFrameList)
			{
				_frameListModel.append(new frameObj(akey, "frame"+i));
				i++;
			}
		}
	}
}

class frameObj
{
	public var xml : XML;
	public var name : String;
	
	public function frameObj(frameXml:XML, name:String):void
	{
		this.name = name;
		this.xml = frameXml;
	}
	
	public function toString():String
	{
		return name; 
	}
}