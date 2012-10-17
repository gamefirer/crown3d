/**
 *	面片解析器 
 */
package blade3d.effect.parser
{
	import away3d.entities.SpriteQuad;
	import away3d.materials.TextureMaterial;
	import away3d.materials.utils.DefaultMaterialManager;
	import away3d.textures.BitmapTextureCache;
	
	import blade3d.effect.BlEffect;
	import blade3d.resource.BlResourceManager;
	import blade3d.utils.BlStringUtils;

	public class BlEffectQuadParser extends BlEffectBaseParser
	{
		static public function parseQuad(xml:XML, newEffect:BlEffect, path:String="") : void
		{
			var startTime : int = int(xml.@starttime.toString());
			var endTime : int = int(xml.@endtime.toString());
			
			var width : int = int(xml.@width.toString());
			var height : int = int(xml.@height.toString());
			
			var orient : int = int(xml.@orient.toString());
			
			var quad : SpriteQuad = 
				new SpriteQuad(DefaultMaterialManager.getDefaultMaterial(), width, height, orient);
			
			quad.billBoard = (xml.@billboard.toString() == "true");
			quad.rotz = Number(xml.@rot.toString());
			quad.zUp = (xml.@zUp.toString() != "false");
			
			// 基础属性
			parseCommonProperty(xml, quad);
			// 基础动画
			parseMeshAnimator(xml, quad);
			
			newEffect.addSpriteQuad(quad, startTime, endTime);
			
			// 面片的贴图
			var textureFileName : String = BlResourceManager.findValidPath(xml.@texture.toString() + BlStringUtils.texExtName, path);
			quad.material = new TextureMaterial(BitmapTextureCache.instance().getTexture( BlResourceManager.instance().findImageResource(textureFileName).bmpData ) );
			
			parseBlendMode(xml, quad.material);
		}
	}
}