/**
 *	条带系统解析器 
 */
package blade3d.effect.parser
{
	import away3d.materials.TextureMaterial;
	import away3d.materials.utils.DefaultMaterialManager;
	import away3d.particle.Dragger.DragStripeEmitter;
	import away3d.particle.Dragger.LightingStripeEmitter;
	import away3d.particle.Dragger.StripeEmitterBase;
	import away3d.particle.StripeSystem;
	import away3d.textures.BitmapTextureCache;
	
	import blade3d.effect.BlEffect;
	import blade3d.resource.BlResourceManager;
	import blade3d.utils.BlStringUtils;
	
	import flash.geom.Vector3D;

	public class BlEffectStripeParser extends BlEffectParticleParser
	{
		static public function parseStripe(xml:XML, newEffect:BlEffect, path:String="") : void
		{
			var startTime : int = int(xml.@starttime.toString());
			var endTime : int = int(xml.@endtime.toString());
			var particleMax : int = int(xml.@max.toString());
			if(particleMax == 0) particleMax = 20;		// 默认20
			
			var emitter : StripeEmitterBase = parseStripeDragger(xml);
			if(!emitter)
				return;
			
			var stripeSystem : StripeSystem = 
				new StripeSystem(emitter, DefaultMaterialManager.getDefaultMaterial(), particleMax);
			
			stripeSystem.dragger.width = int(xml.@wide.toString());
			stripeSystem.dragger.dragTime = int(xml.@dragtime.toString());
			var stripeNum : int = int(xml.@stripenum.toString());
			if(stripeNum == 0) stripeNum = 1;
			stripeSystem.dragger.stripeNum = stripeNum;
			
			switch( int(xml.@widedir.toString()) )
			{
				case 0:
					stripeSystem.wideDir = new Vector3D(1,0,0);
					break;
				case 1:
					stripeSystem.wideDir = new Vector3D(0,1,0);
					break;
				default:
					stripeSystem.wideDir = new Vector3D(0,0,1);
					break;
			}
			
			stripeSystem.isBillBoard = (xml.@billboard.toString() == "true");
			stripeSystem.isTimedUV = (xml.@timeduv.toString() == "true");
			stripeSystem.wideParallel = (xml.@parallel.toString() == "true");
			
			// 粒子影响器			
			parseParticleEffector(xml, stripeSystem, newEffect);
			
			// 基础属性
			parseCommonProperty(xml, stripeSystem);
			
			// 基础动画
			parseObject3DAnimator(xml, stripeSystem);
			
//			_stripes.push(stripeSystem);
			
			newEffect.addStripe(stripeSystem, startTime, endTime);
			// 条带的贴图
			var textureFileName : String = BlResourceManager.findValidPath(xml.@texture.toString() + BlStringUtils.texExtName, path);
			stripeSystem.material = new TextureMaterial(BitmapTextureCache.instance().getTexture(BlResourceManager.instance().findImageResource(textureFileName).bmpData));
		}
		
		// 解析条带的生成器
		static private function parseStripeDragger(xml:XML) : StripeEmitterBase
		{
			var A:uint; var R:uint; var G:uint; var B:uint;
			
			var emitter : StripeEmitterBase;
			
			var emitterXML : XML;
			// 拖拽生成器
			emitterXML = xml.dragger[0];
			if(emitterXML)
			{
				var Dragger : DragStripeEmitter = new DragStripeEmitter;
				
				A = uint(emitterXML.@a.toString());
				R = uint(emitterXML.@r.toString());
				G = uint(emitterXML.@g.toString());
				B = uint(emitterXML.@b.toString());
				
				Dragger.color = ((R&0xff)<<16) + ((G&0xff)<<8) + (B&0xff);
				Dragger.alpha = Number(A&0xff)/0xff;
				
				emitter = Dragger;
				return emitter;
			}
			// 带状生成器
			emitterXML = xml.lighting[0];
			if(emitterXML)
			{
				var lighting : LightingStripeEmitter = new LightingStripeEmitter;
				
				lighting.shakeAmp = Number(emitterXML.@shakeamp.toString());
				lighting.shakeTime = int(emitterXML.@shaketime.toString());
				lighting.lifeTime = Number(emitterXML.@lifeTime.toString());
				A = uint(emitterXML.@a.toString());
				R = uint(emitterXML.@r.toString());
				G = uint(emitterXML.@g.toString());
				B = uint(emitterXML.@b.toString());
				
				lighting.color = ((R&0xff)<<16) + ((G&0xff)<<8) + (B&0xff);
				lighting.alpha = Number(A&0xff)/0xff;
				
				emitter = lighting;
				return emitter;
			}  
			// 粒子拖拽器
//			emitterXML = xml.particle_dragger[0];
//			if(emitterXML)
//			{
//				var psName : String = emitterXML.@particle.toString();
//				if(psName.length > 0 
//					&& _labels[psName] != null 
//					&& (_labels[psName] is ParticleSystem)
//				)
//				{
//					var particleDragger : ParticleStripeEmitter = new ParticleStripeEmitter;
//					
//					particleDragger.attachParticleSystem(_labels[psName]);
//					
//					A = uint(emitterXML.@a.toString());
//					R = uint(emitterXML.@r.toString());
//					G = uint(emitterXML.@g.toString());
//					B = uint(emitterXML.@b.toString());
//					
//					particleDragger.color = ((R&0xff)<<16) + ((G&0xff)<<8) + (B&0xff);
//					particleDragger.alpha = Number(A&0xff)/0xff;
//					
//					emitter = particleDragger;
//					return emitter;
//				}
//			}
			
			return emitter;
		}
	}
}