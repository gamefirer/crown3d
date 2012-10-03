package sl2d.display
{
	import flash.display.Stage;
	
	import sl2d.slGlobal;

	public class slButtonGroup extends slGroup
	{
		private static var _Stage:Stage;
		
		public function slButtonGroup() : void {
			
		}
		
		//鼠标。。
		public static function setButtonStage(stage:Stage):void
		{
			_Stage = stage;
		}
		
		public static function checkInteractive():slButton
		{
			slButtonHelper._InteractiveGetted = false;
			doCheckItem(slGlobal.View);
			return slButtonHelper.check();
		}
		public static function forceLostTarget():void{
			slButtonHelper.setCurrentFocus(null);
			slButtonHelper.check();
		}
		
		private static function doCheckItem(group:slObject):void{
			var node:slGroup = group as slGroup;
			if(node == null) return;
			var groupItem:slButtonGroup;
			var current:slObject;
			var children:Array = node.children;
			var count:int = node.numChildren - 1;
			while(count > -1){
				if(slButtonHelper._InteractiveGetted) break;
				current = children[count];
				count --;
				groupItem = current as slButtonGroup;
				if(groupItem == null){
					doCheckItem(current);
				}else{
					groupItem.checkMouseInteractive();
				}
			}
			
		}
		public static function onMouseDown():void{
			slButtonHelper.onStageDown();
		}
		
		private function checkMouseInteractive():void{
			var button:slButton;
			var interactive:Boolean;
			var current:slButton;
			var obj:slObject;
			var count:int = _numChildren - 1;
			while(count > -1){
				if(slButtonHelper._InteractiveGetted) break;
				obj = children[count];
				count --;
				if(obj.visible == false)
					continue;
				button = obj as slButton;
				if(button == null)
					continue;
				interactive = button.checkInteractive(_Stage.mouseX, _Stage.mouseY);
				if(interactive){
					slButtonHelper.setCurrentFocus(button);
				}
			}
			
		}
		

	}
}
import sl2d.display.slButton;






class slButtonHelper
{
	private static var _Last:slButton;
	private static var _Just:slButton;
	private static var _Current:slButton;
	internal static var _InteractiveGetted:Boolean = false;
	
	public function slButtonHelper()
	{
		
	}
	public static function setCurrentFocus(just:slButton):void{
		_InteractiveGetted = true;
		_Just = just;
	}
	
		
	public static function check():slButton{
		//战斗场景没有焦点
//		if(!FightDB.SceneMouseEnable){
//			if(_Current){
//				_Current.onHandlerEvent(Out);
//				_Current = null;
//			}
//			return;
//		}
		_Current = _Just;
		if(_Just == null && _Last == null){
			
		}
		else if(_Just && _Last == null){
			_Just.handlerMouse(slButton.Button_Over);
		}
		else if(_Just && _Last && _Just == _Last){
			
		}
		else if(_Last && _Just == null){
			_Last.handlerMouse(slButton.Button_Out);
		}
		else if(_Just && _Last && _Last != _Just){
			_Last.handlerMouse(slButton.Button_Out);
			_Just.handlerMouse(slButton.Button_Over);
		}
		_Last = _Just;
		_Just = null;
		return _Last;
	}
		
	
	public static function onStageDown():void{
		if(_Last){
			_Last.handlerMouse(slButton.Button_Down);
		}
		
	}
	
	
	
	
	
	
	
	
	
}
