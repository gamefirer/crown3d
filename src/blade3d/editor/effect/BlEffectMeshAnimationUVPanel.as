/**
 *	模型UV动画 
 */
package blade3d.editor.effect
{
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
	
	public class BlEffectMeshAnimationUVPanel extends JPanel
	{
		private var _uvXML : XML;
		
		private var _auto_durtime : JStepper;
		private var _auto_x : JStepper;
		private var _auto_y : JStepper;
		private var _auto_btn : JButton;
		
		private var _smooth : JCheckBox;
		private var _repeat : JCheckBox;
		
		private var _frameList : JList;
		private var _frameListModel : VectorListModel;
		private var _selectFrameXML : XML;
		
		private var _add : JButton;
		private var _del : JButton;
		
		private var _durTime : JStepper;
		private var _U : JAdjuster;
		private var _V : JAdjuster;
		private var _SU : JAdjuster;
		private var _SV : JAdjuster;
		private var _R : JStepper;
		
		
		public function set srcData(uvXML:XML):void
		{
			_uvXML = uvXML;
			updateUIByData();
		}
		
		public function BlEffectMeshAnimationUVPanel()
		{
			super(new VerticalLayout);
			
			setBorder(new LineBorder(null, ASColor.GREEN, 1));
			
			var hp:JPanel;
			
			append(new JLabel("自动生成"));
			
			append(hp = new JPanel);
			hp.append(new JLabel("总时间"));
			hp.append(_auto_durtime = new JStepper);
			
			append(hp = new JPanel);
			hp.append(new JLabel("横向"));
			hp.append(_auto_x = new JStepper);
			_auto_x.setMinimum(1);
			_auto_x.setMaximum(8);
			
			append(hp = new JPanel);
			hp.append(new JLabel("纵向"));
			hp.append(_auto_y = new JStepper);
			_auto_y.setMinimum(1);
			_auto_y.setMaximum(8);
			
			append(_auto_btn = new JButton("自动生成"));
			_auto_btn.addActionListener(onAuto);
			
			append(new JLabel("动画属性"));
			
			append(_smooth = new JCheckBox("平滑"));
			_smooth.addActionListener(updateData);
			append(_repeat = new JCheckBox("重复"));
			_repeat.addActionListener(updateData);
			
			
			append(new JLabel("UV动画"));
			
			// 帧列表
			_frameListModel = new VectorListModel;
			_frameList = new JList(_frameListModel);
			_frameList.setBorder(new LineBorder(null, ASColor.BLACK));
			_frameList.setPreferredWidth(120);
			_frameList.addSelectionListener(onSelectFrame);
			append(_frameList);
			
			append(hp = new JPanel);
			
			_add = new JButton("添加帧");
			_add.addActionListener(onAddFrame);
			hp.append(_add);
			_del = new JButton("删除帧");
			_del.addActionListener(onDelFrame);
			hp.append(_del);
			
			
			// 持续时间
			append(hp = new JPanel);
			hp.append(new JLabel("持续时间"));
			_durTime = new JStepper;
			_durTime.addActionListener(updateData);
			hp.append(_durTime);
			
			// U
			append(hp = new JPanel);
			hp.append(new JLabel("U"));
			_U = new JAdjuster;
			_U.setMinimum(0);
			_U.setMaximum(100);
			_U.addActionListener(updateData);
			hp.append(_U);
			
			// V
			append(hp = new JPanel);
			hp.append(new JLabel("V"));
			_V = new JAdjuster;
			_V.setMinimum(0);
			_V.setMaximum(100);
			_V.addActionListener(updateData);
			hp.append(_V);
			
			// SU
			append(hp = new JPanel);
			hp.append(new JLabel("SU"));
			_SU = new JAdjuster;
			_SU.setMinimum(0);
			_SU.setMaximum(100);
			_SU.addActionListener(updateData);
			hp.append(_SU);
			
			// V
			append(hp = new JPanel);
			hp.append(new JLabel("SV"));
			_SV = new JAdjuster;
			_SV.setMinimum(0);
			_SV.setMaximum(100);
			_SV.addActionListener(updateData);
			hp.append(_SV);
			
			// R
			append(hp = new JPanel);
			hp.append(new JLabel("旋转"));
			_R = new JStepper;
			_durTime.addActionListener(updateData);
			hp.append(_R);
			
		}
		
		private function onAuto(evt:Event):void
		{
			var durtime : Number = _auto_durtime.getValue();
			var wide : int = _auto_x.getValue();
			var height : int = _auto_y.getValue();
			var intervalTime : Number = durtime / (wide * height);
			
			var frameCount : int = wide*height;
			
			delete _uvXML.frame;
			
			for(var vi:int=0; vi<height; vi++)
			{
				for(var ui:int=0; ui<wide; ui++)
				{
					var kfXML : XML = <frame durtime="0" u="0" v="0" su="0" sv="0" r="0"/>;
					kfXML.@durtime = intervalTime.toFixed(2);
					kfXML.@u = (Number(ui)/wide).toFixed(2);
					kfXML.@v = (Number(vi)/height).toFixed(2);
					kfXML.@su = (Number(1)/wide).toFixed(2);
					kfXML.@sv = (Number(1)/height).toFixed(2);
					kfXML.@r = 0;
					
					_uvXML.appendChild(kfXML);
				}
			}
			
			updateUIByData();	
		}
		
		private function onAddFrame(evt:Event):void
		{
			var selObj : frameObj = _frameList.getSelectedValue();
			_uvXML.insertChildAfter((selObj ? selObj.xml : null), <frame durtime="1000" v="0" u="0" su="0" sv="0" r="0"/>);
			
			updateUIByData();
			
		}
		
		private function onDelFrame(evt:Event):void
		{
			var selIndex : int = _frameList.getSelectedIndex();
			if(selIndex == -1) selIndex = 0;
			
			var akeyFrameList:XMLList = _uvXML.frame;
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
				_durTime.setValue(0);
				_U.setValue(0);
				_V.setValue(0);
				_SU.setValue(0);
				_SV.setValue(0);
				_R.setValue(0);
				return;
			}
			
			_selectFrameXML = selectObj.xml;
			
			_durTime.setValue( int(_selectFrameXML.@durtime.toString()) );
			_U.setValue( Number(_selectFrameXML.@u.toString()) * 100 );
			_V.setValue( Number(_selectFrameXML.@v.toString()) * 100 );
			_SU.setValue( Number(_selectFrameXML.@su.toString()) * 100 );
			_SV.setValue( Number(_selectFrameXML.@sv.toString()) * 100 );
			_R.setValue( Number(_selectFrameXML.@r.toString()) * 180 / Math.PI );
			
		}
		
		private function updateData(evt:Event):void
		{
			if(!_uvXML) return;
			
			_uvXML.@smooth = _smooth.isSelected() ? "true" : "false";
			_uvXML.@repeat = _repeat.isSelected() ? "true" : "false";
			
			if(!_selectFrameXML) return;
			
			_selectFrameXML.@durtime = _durTime.getValue();
			_selectFrameXML.@u = (Number(_U.getValue()) / 100).toFixed(2);
			_selectFrameXML.@v = (Number(_V.getValue()) / 100).toFixed(2);
			_selectFrameXML.@su = (Number(_SU.getValue()) / 100).toFixed(2);
			_selectFrameXML.@sv = (Number(_SV.getValue()) / 100).toFixed(2);
			_selectFrameXML.@r = (_R.getValue() * Math.PI / 180).toFixed(2);
		}
		
		private function updateUIByData():void
		{
			_smooth.setSelected( (_uvXML.@smooth.toString() == "true") );
			_repeat.setSelected( (_uvXML.@repeat.toString() == "true") );
			
			_frameListModel.clear();
			
			var akeyFrameList:XMLList = _uvXML.frame;
			
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