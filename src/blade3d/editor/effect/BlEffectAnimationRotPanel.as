/**
 *	旋转动画面板 
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
	
	public class BlEffectAnimationRotPanel extends JPanel
	{
		private var _rotXML : XML;
		
		private var _frameList : JList;
		private var _frameListModel : VectorListModel;
		private var _selectFrameXML : XML;
		
		private var _add : JButton;
		private var _del : JButton;
		
		private var durtime : JStepper;
		private var rotx : JStepper;
		private var roty : JStepper;
		private var rotz : JStepper;
		
		public function set srcData(rotXML:XML):void
		{
			_rotXML = rotXML;
			
			updateUIByData();
		}
		
		public function BlEffectAnimationRotPanel()
		{
			super(new VerticalLayout);
			
			setBorder(new LineBorder(null, ASColor.GREEN, 1));
			
			append(new JLabel("旋转动画"));
			
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
			rotx = new JStepper;
			rotx.addActionListener(updateData);
			hp.append(rotx);
			// Y
			roty = new JStepper;
			roty.addActionListener(updateData);
			hp.append(roty);
			// Z
			rotz = new JStepper;
			rotz.addActionListener(updateData);
			hp.append(rotz);
			
		}
		
		private function onAddFrame(evt:Event):void
		{
			var selObj : frameObj = _frameList.getSelectedValue();
			_rotXML.insertChildAfter((selObj ? selObj.xml : null), <frame durtime="1000" x="0" y="0" z="0"/>);
			
			updateUIByData();
			
		}
		
		private function onDelFrame(evt:Event):void
		{
			var selIndex : int = _frameList.getSelectedIndex();
			if(selIndex == -1) selIndex = 0;
			
			var akeyFrameList:XMLList = _rotXML.frame;
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
				rotx.setValue(0);
				roty.setValue(0);
				rotz.setValue(0);
				return;
			}
			
			_selectFrameXML = selectObj.xml;
			
			
			durtime.setValue( int(_selectFrameXML.@durtime.toString()) );
			rotx.setValue( Number(_selectFrameXML.@x.toString()) * 180 / Math.PI );
			roty.setValue( Number(_selectFrameXML.@y.toString()) * 180 / Math.PI );
			rotz.setValue( Number(_selectFrameXML.@z.toString()) * 180 / Math.PI );
		}
		
		private function updateData(evt:Event):void
		{
			if(!_selectFrameXML) return;
			
			_selectFrameXML.@durtime = int(durtime.getValue());
			_selectFrameXML.@x = Number(rotx.getValue() / 180 * Math.PI).toFixed(2);
			_selectFrameXML.@y = Number(roty.getValue() / 180 * Math.PI).toFixed(2);
			_selectFrameXML.@z = Number(rotz.getValue() / 180 * Math.PI).toFixed(2);
		}
		
		private function updateUIByData():void
		{
			_frameListModel.clear();
			
			if(_rotXML)
			{
				var akeyFrameList:XMLList = _rotXML.frame;
				
				var i:int = 1;
				var akey:XML;
				for each(akey in akeyFrameList)
				{
					_frameListModel.append(new frameObj(akey, "frame"+i));
					i++;
				}
			}
			
			durtime.setValue(0);
			rotx.setValue(0);
			roty.setValue(0);
			rotz.setValue(0);
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