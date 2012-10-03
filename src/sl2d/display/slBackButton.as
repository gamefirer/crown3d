package sl2d.display
{
	public class slBackButton extends slButton
	{
		private var _buttonWidth:int;
		private var _buttonHeight:int;
		public function slBackButton(Width:int, Height:int, Click:Function = null, Over:Function = null, Out:Function = null)
		{
			super(Click, Over, Out);
			_buttonWidth = Width;
			_buttonHeight = Height;
			setSize(Width, Height);
		}
		public function resetButtonSize(Width:int, Height:int):void{
			_buttonWidth = Width;
			_buttonHeight = Height;
			setSize(_buttonWidth, _buttonHeight);
		}
		override protected function get hotWidth():int{
			return _buttonWidth;
		}
		override protected function get hotHeight():int{
			return _buttonHeight;
		}
		override public function collectRenderer():void{
			//啥也不做。
		}
	}
}