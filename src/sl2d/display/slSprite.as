package sl2d.display
{

	public class slSprite extends slBounds
	{
		public function slSprite()
		{
		}
		protected function preUpdate():void{
			
		}
		protected function updatePos():void{
			
		}
		protected function updateAnim():void{
			
		}
		protected function bindFrame():void{
			
		}
		protected function afterUpdate():void{
			
		}
		override public function update():void{
			preUpdate();
			updatePos();
			updateAnim();
			bindFrame();
			setOffset();
			afterUpdate();
		}
		
		
	}
}