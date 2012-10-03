package sl2d.display
{
	import flash.display.BitmapData;
	
	import sl2d.texture.slTexture;

	public class slShape extends slImage
	{
		//一个颜色色块。
		public function slShape()
		{
			var texture:slTexture = getShapeTexture();
			super(texture);
		}
		
		public static const ShapeTextureName:String = "slShape.texture.shapeTexture";
		private function getShapeTexture():slTexture{
			var texture:slTexture = textureFactory.getBmpTexture(ShapeTextureName);
			if(texture == null){
				var bmd:BitmapData = new BitmapData(4, 4, true, 0xFFFFFFFF);
				texture = textureFactory.createBmpTexture(ShapeTextureName, bmd);
			}
			return texture;
		}
		
	}
}