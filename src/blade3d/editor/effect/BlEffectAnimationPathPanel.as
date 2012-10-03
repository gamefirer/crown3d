/**
 *	位移动画面板 
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
	
	public class BlEffectAnimationPathPanel extends JPanel
	{
		private var _pathXML : XML;
		
		private var _frameList : JList;
		private var _frameListModel : VectorListModel;
		private var _selectFrameXML : XML;
		
		private var _add : JButton;
		private var _del : JButton;
		
		private var durtime : JStepper;
		private var posx : JStepper;
		private var posy : JStepper;
		private var posz : JStepper;
		
		public function set srcData(pathXML:XML):void
		{
			_pathXML = pathXML;
			
			updateUIByData();
		}
		
		public function BlEffectAnimationPathPanel()
		{
			super(new VerticalLayout);
			
			setBorder(new LineBorder(null, ASColor.RED, 1));
			
			append(new JLabel("路径动画"));
			
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
			posx = new JStepper;
			posx.addActionListener(updateData);
			hp.append(posx);
			// Y
			posy = new JStepper;
			posy.addActionListener(updateData);
			hp.append(posy);
			// Z
			posz = new JStepper;
			posz.addActionListener(updateData);
			hp.append(posz);
		}
		
		private function onAddFrame(evt:Event):void
		{
			var selObj : frameObj = _frameList.getSelectedValue();
			_pathXML.insertChildAfter((selObj ? selObj.xml : null), <frame durtime="1000" x="0" y="0" z="0"/>);
			
			updateUIByData();
			
		}
		
		private function onDelFrame(evt:Event):void
		{
			var selIndex : int = _frameList.getSelectedIndex();
			if(selIndex == -1) selIndex = 0;
			
			var akeyFrameList:XMLList = _pathXML.frame;
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
				posx.setValue(0);
				posy.setValue(0);
				posz.setValue(0);
				return;
			}
			
			_selectFrameXML = selectObj.xml;
			
			
			durtime.setValue( int(_selectFrameXML.@durtime.toString()) );
			posx.setValue( int(_selectFrameXML.@x.toString()) );
			posy.setValue( int(_selectFrameXML.@y.toString()) );
			posz.setValue( int(_selectFrameXML.@z.toString()) );
		}
		
		private function updateData(evt:Event):void
		{
			if(!_selectFrameXML) return;
			
			_selectFrameXML.@durtime = int(durtime.getValue());
			_selectFrameXML.@x = posx.getValue();
			_selectFrameXML.@y = posy.getValue();
			_selectFrameXML.@z = posz.getValue();
		}
		
		private function updateUIByData():void
		{
			_frameListModel.clear();
			
			if(_pathXML)
			{
				var akeyFrameList:XMLList = _pathXML.frame;
				
				var i:int = 1;
				var akey:XML;
				for each(akey in akeyFrameList)
				{
					_frameListModel.append(new frameObj(akey, "frame"+i));
					i++;
				}
			}
			
			durtime.setValue(0);
			posx.setValue(0);
			posy.setValue(0);
			posz.setValue(0);
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