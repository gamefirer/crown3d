package sl2d.display
{

	public class slButton extends slGroup
	{
		private var _mouseEnable:Boolean = true;
		private var _clickFun:Function;
		private var _overFun:Function;
		private var _outFun:Function;
		
		public static const Button_Down:String = "mouse.down";
		public static const Button_Over:String = "mouse.over";
		public static const Button_Out:String = "mouse.out";
		public function get mouseEnable():Boolean{
			return _mouseEnable;
		}
		
		public function set mouseEnable(b:Boolean):void{
			if(b == _mouseEnable) return;
			_mouseEnable = b;
		}
		
		public function slButton(click:Function = null, over:Function = null, out:Function = null)
		{
			super();
			_clickFun = click;
			_overFun = over;
			_outFun = out;
		}
		
		public function checkInteractive(mouseX:int, mouseY:int):Boolean{
//			Debug.bltrace(_globalY)
			if(_mouseEnable == false)
				return false;
			if(mouseX > _globalX 
				&& mouseX < (_globalX + hotWidth)
				&& mouseY > _globalY
					&& mouseY < (_globalY + hotHeight)
			){
				return true;
			}
			return false;
		
		}
		
		//获得热点区域的高度宽度
		protected function get hotWidth():int{
			return width;
		}
		protected function get hotHeight():int{
			return height;
		}
		
		//感应鼠标状态。
		protected function setOverState():void{
			
		}
		
		protected function setOutState():void{
			
		}

		protected function setDownState():void{
			
		}
		
		public function handlerMouse(type:String):void{
			if(_mouseEnable == false) return;
			
			switch(type){
				case Button_Down:
					setDownState();
					if(_clickFun != null){
						_clickFun();
					}
					break;
				case Button_Out:
					setOutState();
					if(_outFun != null){
						_outFun();
					}
					break;
				case Button_Over:
					setOverState();
					if(_overFun != null){
						_overFun();
					}
					break;
			
			}
		}
		
		

		
	}
}