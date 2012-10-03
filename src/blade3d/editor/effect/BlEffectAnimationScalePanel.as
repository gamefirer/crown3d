/**
 *	缩放动画面板 
 */
package blade3d.editor.effect
{
	import flash.events.Event;
	
	import org.aswing.ASColor;
	import org.aswing.JButton;
	import org.aswing.JLabel;
	import org.aswing.JList;
	import org.aswing.JPanel;
	import org.aswing.JStepper;
	import org.aswing.LayoutManager;
	import org.aswing.VectorListModel;
	import org.aswing.border.LineBorder;
	import org.aswing.colorchooser.VerticalLayout;
	
	public class BlEffectAnimationScalePanel extends JPanel
	{
		private var _scaleXML : XML;
		
		private var _frameList : JList;
		private var _frameListModel : VectorListModel;
		private var _selectFrameXML : XML;
		
		private var _add : JButton;
		private var _del : JButton;
		
		private var durtime : JStepper;
		private var sclx : JStepper;
		private var scly : JStepper;
		private var sclz : JStepper;
		
		public function set srcData(scaleXML:XML):void
		{
			_scaleXML = scaleXML;
			
			updateUIByData();
		}
		
		public function BlEffectAnimationScalePanel()
		{
			super(new VerticalLayout);
			
			setBorder(new LineBorder(null, ASColor.BLUE, 1));
			
			append(new JLabel("缩放动画"));
			
			_frameListModel = new VectorListModel();
			_frameList = new JList(_frameListModel);
			_frameList.setPreferredWidth(150);
			_frameList.addSelectionListener(onSelectFrame);
			_frameList.setBorder(new LineBorder(null, ASColor.BLACK, 2));
			append(_frameList);
			
			var hp:JPanel = new JPanel;
			append(hp);
			
			_add = new JButton("添加帧");
			_add.addActionListener(onAddFrame);
			hp.append(_add);
			_del = new JButton("删除帧");
			_del.addActionListener(onDelFrame);
			hp.append(_del);
			
			append(new JLabel("持续时间"));
			durtime = new JStepper;
			durtime.addActionListener(updateData);
			append(durtime);
			
			append(new JLabel("位置"));
			
			append(hp = new JPanel);
			// X
			sclx = new JStepper;
			sclx.addActionListener(updateData);
			hp.append(sclx);
			// Y
			scly = new JStepper;
			scly.addActionListener(updateData);
			hp.append(scly);
			// Z
			sclz = new JStepper;
			sclz.addActionListener(updateData);
			hp.append(sclz);
		}
		
		private function onAddFrame(evt:Event):void
		{
			var selObj : frameObj = _frameList.getSelectedValue();
			_scaleXML.insertChildAfter((selObj ? selObj.xml : null), <frame durtime="1000" x="1" y="1" z="1"/>);
			
			updateUIByData();
			
		}
		
		private function onDelFrame(evt:Event):void
		{
			var selIndex : int = _frameList.getSelectedIndex();
			if(selIndex == -1) selIndex = 0;
			
			var akeyFrameList:XMLList = _scaleXML.frame;
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
				durtime.setValue(0);
				sclx.setValue(100);
				scly.setValue(100);
				sclz.setValue(100);
				return;
			}
			
			_selectFrameXML = selectObj.xml;
			
			
			durtime.setValue( int(_selectFrameXML.@durtime.toString()) );
			sclx.setValue( int(_selectFrameXML.@x.toString()) * 100);
			scly.setValue( int(_selectFrameXML.@y.toString()) * 100);
			sclz.setValue( int(_selectFrameXML.@z.toString()) * 100);
		}
		
		private function updateData(evt:Event):void
		{
			if(!_selectFrameXML) return;
			
			_selectFrameXML.@durtime = int(durtime.getValue());
			_selectFrameXML.@x = Number(sclx.getValue())/100;
			_selectFrameXML.@y = Number(scly.getValue())/100;
			_selectFrameXML.@z = Number(sclz.getValue())/100;
		}
		
		private function updateUIByData():void
		{
			_frameListModel.clear();
			
			if(_scaleXML)
			{
				var akeyFrameList:XMLList = _scaleXML.frame;
				
				var i:int = 1;
				var akey:XML;
				for each(akey in akeyFrameList)
				{
					_frameListModel.append(new frameObj(akey, "frame"+i));
					i++;
				}
			}
			
			durtime.setValue(0);
			sclx.setValue(100);
			scly.setValue(100);
			sclz.setValue(100);
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