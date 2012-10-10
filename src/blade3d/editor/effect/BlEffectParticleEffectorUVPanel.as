/**
 *	UV效果器面板 
 */
package blade3d.editor.effect
{
	import away3d.materials.passes.GpuParticlePass;
	
	import flash.events.Event;
	
	import org.aswing.ASColor;
	import org.aswing.JAdjuster;
	import org.aswing.JButton;
	import org.aswing.JCheckBox;
	import org.aswing.JLabel;
	import org.aswing.JList;
	import org.aswing.JPanel;
	import org.aswing.JStepper;
	import org.aswing.LayoutManager;
	import org.aswing.VectorListModel;
	import org.aswing.border.LineBorder;
	import org.aswing.colorchooser.VerticalLayout;
	
	public class BlEffectParticleEffectorUVPanel extends JPanel
	{
		private var _uvEffectorXML : XML;
		
		private var _auto_x : JStepper;
		private var _auto_y : JStepper;
		private var _auto_btn : JButton;
		
//		private var _smooth : JCheckBox;
//		private var _repeat : JCheckBox;
		
		private var _scaleU : JStepper;
		private var _scaleV : JStepper;
		
		private var _frameList : JList;
		private var _frameListModel : VectorListModel;
		private var _selectFrameXML : XML;
		
		private var _add : JButton;
		private var _del : JButton;
		
		private var _lifePercent : JAdjuster;
		private var _U : JAdjuster;
		private var _V : JAdjuster;
		
		public function set srcData(sizeXML:XML):void
		{
			_uvEffectorXML = sizeXML;
			updateUIByData();
		}
		
		public function BlEffectParticleEffectorUVPanel()
		{
			super(new VerticalLayout());
			
			var hPanel : JPanel;
			
			append(new JLabel("自动生成"));
			append(hPanel = new JPanel);
			
			hPanel.append(_auto_x = new JStepper); 
			hPanel.append(_auto_y = new JStepper);
			
			_auto_x.setMinimum(1);
			_auto_x.setMaximum(6);
			_auto_y.setMinimum(1);
			_auto_y.setMaximum(6);
			
			append(_auto_btn = new JButton("自动生成"));
			_auto_btn.addActionListener(onAuto);
			
//			append(_smooth = new JCheckBox("平滑变化"));
//			append(_repeat = new JCheckBox("UV重复"));
			
			append(hPanel = new JPanel);
			hPanel.append(new JLabel("U缩放"));
			hPanel.append(_scaleU = new JStepper);
			_scaleU.addActionListener(updateData);
			
			append(hPanel = new JPanel);
			hPanel.append(new JLabel("V缩放"));
			hPanel.append(_scaleV = new JStepper);
			_scaleV.addActionListener(updateData);
			
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
			hp.append(new JLabel("U"));
			_U = new JAdjuster;
			_U.setMinimum(0);
			_U.setMaximum(100);
			_U.addActionListener(updateData);
			hp.append(_U);
			
			// G
			append(hp = new JPanel);
			hp.append(new JLabel("V"));
			_V = new JAdjuster;
			_V.setMinimum(0);
			_V.setMaximum(100);
			_V.addActionListener(updateData);
			hp.append(_V);
		}
		
		private function onAuto(evt:Event):void
		{
			var maxFrame : int = GpuParticlePass.gpuUVKeyFrameMax;
			var wide : int = _auto_x.getValue();
			var height : int = _auto_y.getValue();
			
			// 不能超过6帧
			if(height > maxFrame/wide)
				height = maxFrame/wide;
			
			var frameCount : int = wide*height;
			
			_uvEffectorXML.@su = (Number(1.0)/wide).toFixed(2);
			_uvEffectorXML.@sv = (Number(1.0)/height).toFixed(2);
			
			delete _uvEffectorXML.keyframe;
			
			for(var vi:int=0; vi<height; vi++)
			{
				for(var ui:int=0; ui<wide; ui++)
				{
					var kfXML : XML = <keyframe u="0" v="0" lifepercent="0"/>;
					kfXML.@lifepercent = (Number(vi*wide + ui) / frameCount).toFixed(2);
					kfXML.@u = (Number(ui)/wide).toFixed(2);
					kfXML.@v = (Number(vi)/height).toFixed(2);
					
					_uvEffectorXML.appendChild(kfXML);
				}
			}
			
			updateUIByData();	
		}
		
		private function onAddFrame(evt:Event):void
		{
			if( _frameListModel.size() >= GpuParticlePass.gpuUVKeyFrameMax )
				return;
			
			var selObj : frameObj = _frameList.getSelectedValue();
			_uvEffectorXML.insertChildAfter((selObj ? selObj.xml : null), <keyframe u="0" v="0" lifepercent="0.0"/>);
			
			updateUIByData();
			
		}
		
		private function onDelFrame(evt:Event):void
		{
			var selIndex : int = _frameList.getSelectedIndex();
			if(selIndex == -1) selIndex = 0;
			
			var akeyFrameList:XMLList = _uvEffectorXML.keyframe;
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
				_U.setValue(0);
				_V.setValue(0);
				return;
			}
			
			_selectFrameXML = selectObj.xml;
			
			
			_lifePercent.setValue( Number(_selectFrameXML.@lifepercent.toString()) * 100 );
			_U.setValue( Number(_selectFrameXML.@u.toString()) * 100 );
			_V.setValue( Number(_selectFrameXML.@v.toString()) * 100 );
		}
		
		private function updateData(evt:Event):void
		{
			if(!_uvEffectorXML) return;
			
			_uvEffectorXML.@su = (Number(_scaleU.getValue()) / 100).toFixed(2);
			_uvEffectorXML.@sv = (Number(_scaleV.getValue()) / 100).toFixed(2);
			
			if(!_selectFrameXML) return;
			
			_selectFrameXML.@lifepercent = Number(_lifePercent.getValue())/100;
			_selectFrameXML.@u = (Number(_U.getValue()) / 100).toFixed(2);
			_selectFrameXML.@v = (Number(_V.getValue()) / 100).toFixed(2);
		}
		
		private function updateUIByData():void
		{
			var scaleU:Number= Number(_uvEffectorXML.@su.toString());
			if(scaleU == 0)
				scaleU = 1;
			
			var scaleV:Number = Number(_uvEffectorXML.@sv.toString());
			if(scaleV == 0)
				scaleV = 1;
			
			_scaleU.setValue(scaleU * 100);
			_scaleV.setValue(scaleV * 100);
			
			_frameListModel.clear();
			
			var akeyFrameList:XMLList = _uvEffectorXML.keyframe;
			
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