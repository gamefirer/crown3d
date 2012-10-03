package sl2d.display
{
	import sl2d.texture.slTexture;

	public class slImage extends slBounds
	{
		public function slImage(texture:slTexture, frame:int = 0)
		{
			textureRef = texture;
			gotoFrame(frame);
		}
	}
}