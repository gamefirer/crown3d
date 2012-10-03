/**
 *	log界面 
 */
package blade3d.editor
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import org.aswing.ASColor;
	import org.aswing.BorderLayout;
	import org.aswing.JButton;
	import org.aswing.JFrame;
	import org.aswing.JPanel;
	import org.aswing.JScrollPane;
	import org.aswing.JTextArea;
	import org.aswing.border.LineBorder;
	
	public class BlLogEditor extends JFrame
	{
		private var _panel : JPanel;
		private var _logText : JTextArea;
		
		public function BlLogEditor(owner:*=null, title:String="", modal:Boolean=false)
		{
			super(owner, title, modal);
			
			setSizeWH(450, 300);
			var parent:Sprite = Sprite(owner);
			setLocationXY( parent.width - (450+50), parent.height - (300+50) );
			
			_panel = new JPanel(new BorderLayout(1, 1));
			setContentPane(_panel);
			_panel.setBorder(new LineBorder(null, ASColor.BLACK));
			
			var upPanel : JPanel = new JPanel();
			var downPanel : JPanel = new JPanel(new BorderLayout(0, 0));
			_panel.append(upPanel, BorderLayout.NORTH);
			_panel.append(downPanel, BorderLayout.CENTER);
			
			var clearBtn : JButton = new JButton("清除");
			upPanel.append(clearBtn);
			clearBtn.addActionListener(
				function(evt:Event):void
				{
					clear();
				}
				);
			
			_logText = new JTextArea();
			_logText.setEditable(false);
			downPanel.append(new JScrollPane(_logText), BorderLayout.CENTER);
		}
		
		public function clear():void
		{
			_logText.setText("");
		}
		
		public function log(str:Object):void
		{
			_logText.appendText(str.toString());
			_logText.appendText("\n");
			_logText.scrollToBottomLeft();
		}
	}
}