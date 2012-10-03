/**
 *	颜色效果器面板 
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
	
	public class BlEffectParticleEffectorColorPanel extends JPanel
	{
		private var _colorEffectorXML : XML;
		
		private var _frameList : JList;
		private var _frameListModel : VectorListModel;
		private var _selectFrameXML : XML;
		
		private var _add : JButton;
		private var _del : JButton;
		
		private var _lifePercent : JAdjuster;
		private var _R : JAdjuster;
		private var _G : JAdjuster;
		private var _B : JAdjuster;
		
		public function set srcData(sizeXML:XML):void
		{
			_colorEffectorXML = sizeXML;
			updateUIByData();
		}
		
		
		public function BlEffectParticleEffectorColorPanel()
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
			
			// R
			append(hp = new JPanel);
			hp.append(new JLabel("红"));
			_R = new JAdjuster;
			_R.setMinimum(0);
			_R.setMaximum(255);
			_R.addActionListener(updateData);
			hp.append(_R);
			
			// G
			append(hp = new JPanel);
			hp.append(new JLabel("绿"));
			_G = new JAdjuster;
			_G.setMinimum(0);
			_G.setMaximum(255);
			_G.addActionListener(updateData);
			hp.append(_G);
			
			// B
			append(hp = new JPanel);
			hp.append(new JLabel("蓝"));
			_B = new JAdjuster;
			_B.setMinimum(0);
			_B.setMaximum(255);
			_B.addActionListener(updateData);
			hp.append(_B);
		}
		
		private function onAddFrame(evt:Event):void
		{
			if( _frameListModel.size() >= GpuParticlePass.gpuEffectorKeyFrameMax )
				return;
			
			var selObj : frameObj = _frameList.getSelectedValue();
			_colorEffectorXML.insertChildAfter((selObj ? selObj.xml : null), <keyframe r="255" g="255" b="255" lifepercent="0.0"/>);
			
			updateUIByData();
			
		}
		
		private function onDelFrame(evt:Event):void
		{
			var selIndex : int = _frameList.getSelectedIndex();
			if(selIndex == -1) selIndex = 0;
			
			var akeyFrameList:XMLList = _colorEffectorXML.keyframe;
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
				_R.setValue(0);
				_G.setValue(0);
				_B.setValue(0);
				return;
			}
			
			_selectFrameXML = selectObj.xml;
			
			
			_lifePercent.setValue( Number(_selectFrameXML.@lifepercent.toString()) * 100 );
			_R.setValue( int(_selectFrameXML.@r.toString()) );
			_G.setValue( int(_selectFrameXML.@g.toString()) );
			_B.setValue( int(_selectFrameXML.@b.toString()) );
		}
		
		private function updateData(evt:Event):void
		{
			if(!_selectFrameXML) return;
			
			_selectFrameXML.@lifepercent = Number(_lifePercent.getValue())/100;
			_selectFrameXML.@r = _R.getValue();
			_selectFrameXML.@g = _G.getValue();
			_selectFrameXML.@b = _B.getValue();
		}
		
		private function updateUIByData():void
		{
			_frameListModel.clear();
			
			var akeyFrameList:XMLList = _colorEffectorXML.keyframe;
			
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