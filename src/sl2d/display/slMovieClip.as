package sl2d.display
{
	public class slMovieClip extends slSprite
	{
		protected var _animation:slAnimation = new slAnimation(null);
		protected var _currentFrame:int;
		protected var _skipFrame:Boolean = false;
		protected var _playNextFrame:Boolean = true;
		public function slMovieClip()
		{
		}
		override protected function updateAnim():void{
			_currentFrame = _animation.update(_playNextFrame, _skipFrame);
		}
		override protected function bindFrame():void{
			gotoFrame(_currentFrame);
		}
	}
}