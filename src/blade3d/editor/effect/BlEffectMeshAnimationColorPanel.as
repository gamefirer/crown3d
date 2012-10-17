/**
 *	模型颜色动画 
 */
package blade3d.editor.effect
{
	import flash.events.Event;
	
	import org.aswing.ASColor;
	import org.aswing.JAdjuster;
	import org.aswing.JButton;
	import org.aswing.JLabel;
	import org.aswing.JList;
	import org.aswing.JPanel;
	import org.aswing.JStepper;
	import org.aswing.LayoutManager;
	import org.aswing.VectorListModel;
	import org.aswing.border.LineBorder;
	import org.aswing.colorchooser.VerticalLayout;
	
	public class BlEffectMeshAnimationColorPanel extends JPanel
	{
		private var _colorXML : XML;
		
		private var _frameList : JList;
		private var _frameListModel : VectorListModel;
		private var _selectFrameXML : XML;
		
		private var _add : JButton;
		private var _del : JButton;
		
		private var durtime : JStepper;
		private var a : JAdjuster;
		private var r : JAdjuster;
		private var g : JAdjuster;
		private var b : JAdjuster;
		
		public function set srcData(colorXML:XML):void
		{
			_colorXML = colorXML;
			
			updateUIByData();
		}
		
		public function BlEffectMeshAnimationColorPanel()
		{
			super(new VerticalLayout);
			
			setBorder(new LineBorder(null, ASColor.GREEN, 1));
			
			append(new JLabel("颜色动画"));
			
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
			
			// alpha
			append(hp = new JPanel);
			hp.append(new JLabel("透明度"));
			a = new JAdjuster;
			a.setMinimum(0);
			a.setMaximum(255);
			a.addActionListener(updateData);
			hp.append(a);
			// r
			append(hp = new JPanel);
			hp.append(new JLabel("红"));
			r = new JAdjuster;
			r.setMinimum(0);
			r.setMaximum(255);
			r.addActionListener(updateData);
			hp.append(r);
			// g
			append(hp = new JPanel);
			hp.append(new JLabel("绿"));
			g = new JAdjuster;
			g.setMinimum(0);
			g.setMaximum(255);
			g.addActionListener(updateData);
			hp.append(g);
			// b
			append(hp = new JPanel);
			hp.append(new JLabel("蓝"));
			b = new JAdjuster;
			b.setMinimum(0);
			b.setMaximum(255);
			b.addActionListener(updateData);
			hp.append(b);
		}
		
		private function onAddFrame(evt:Event):void
		{
			var selObj : frameObj = _frameList.getSelectedValue();
			_colorXML.insertChildAfter((selObj ? selObj.xml : null), <frame durtime="1000" a="255" r="255" g="255" b="255"/>);
			
			updateUIByData();
			
		}
		
		private function onDelFrame(evt:Event):void
		{
			var selIndex : int = _frameList.getSelectedIndex();
			if(selIndex == -1) selIndex = 0;
			
			var akeyFrameList:XMLList = _colorXML.frame;
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
				a.setValue(0);
				r.setValue(0);
				g.setValue(0);
				b.setValue(0);
				return;
			}
			
			_selectFrameXML = selectObj.xml;
			
			durtime.setValue( int(_selectFrameXML.@durtime.toString()) );
			a.setValue( int(_selectFrameXML.@a.toString()) );
			r.setValue( int(_selectFrameXML.@r.toString()) );
			g.setValue( int(_selectFrameXML.@g.toString()) );
			b.setValue( int(_selectFrameXML.@b.toString()) );
		}
		
		private function updateData(evt:Event):void
		{
			if(!_selectFrameXML) return;
			
			_selectFrameXML.@durtime = int(durtime.getValue());
			_selectFrameXML.@a = a.getValue();
			_selectFrameXML.@r = r.getValue();
			_selectFrameXML.@g = g.getValue();
			_selectFrameXML.@b = b.getValue();
		}
		
		private function updateUIByData():void
		{
			_frameListModel.clear();
			
			if(_colorXML)
			{
				var akeyFrameList:XMLList = _colorXML.frame;
				
				var i:int = 1;
				var akey:XML;
				for each(akey in akeyFrameList)
				{
					_frameListModel.append(new frameObj(akey, "frame"+i));
					i++;
				}
			}
			
			durtime.setValue(0);
			a.setValue(0);
			r.setValue(0);
			g.setValue(0);
			b.setValue(0);
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