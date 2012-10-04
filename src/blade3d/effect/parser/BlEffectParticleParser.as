package blade3d.effect.parser
{
	import away3d.debug.Debug;
	import away3d.materials.GpuParticleMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.materials.utils.DefaultMaterialManager;
	import away3d.particle.Effector.AlphaEffector;
	import away3d.particle.Effector.AttractEffector;
	import away3d.particle.Effector.ColorEffector;
	import away3d.particle.Effector.ForceEffector;
	import away3d.particle.Effector.SizeEffector;
	import away3d.particle.Effector.TerrainEffector;
	import away3d.particle.Effector.UVEffector;
	import away3d.particle.Emitter.CylinderParticleEmitter;
	import away3d.particle.Emitter.ParticleEmitterBase;
	import away3d.particle.Emitter.RectangleParticleEmitter;
	import away3d.particle.Emitter.SphereParticleEmitter;
	import away3d.particle.ParticleSystem;
	
	import blade3d.effect.BlEffect;
	import blade3d.resource.BlModelResource;
	import blade3d.resource.BlResourceManager;
	import blade3d.utils.BlStringUtils;

	public class BlEffectParticleParser extends BlEffectBaseParser
	{
		// 解析粒子系统
		static public function parseParticle(xml:XML, newEffect:BlEffect, path:String="") : void
		{
			var startTime : int = int(xml.@starttime.toString());
			var endTime : int = int(xml.@endtime.toString());
			
			// 粒子发射器
			var emitter : ParticleEmitterBase = parseParticleEmitter(xml);
			if(emitter == null)
				return;
			
			// 粒子参数
			var particleMax : int = int(xml.@max.toString());
			var meshName : String = xml.@mesh.toString();
			
			var particleSystem : ParticleSystem;
			if(meshName.length == 0)
			{	
				if(ParticleSystem.useGpuParticle)
				{
					particleSystem = new ParticleSystem(
						new GpuParticleMaterial(DefaultMaterialManager.getDefaultBitmapData()), 
						emitter,
						particleMax);
				}
				else
				{
					particleSystem = new ParticleSystem(
						DefaultMaterialManager.getDefaultMaterial(), 
						emitter,
						particleMax);
				}
			}
			else
			{
				var meshUrl:String = BlResourceManager.findValidPath(meshName + BlStringUtils.modelExtName, path);
				var modelRes:BlModelResource = BlResourceManager.instance().findModelResource(meshUrl);
				
				particleSystem = new ParticleSystem(
					new GpuParticleMaterial(DefaultMaterialManager.getDefaultBitmapData()), 
					emitter,
					particleMax,
					null,
					modelRes.geo);
				
			}
			
			particleSystem.isWolrdParticle = (xml.@global.toString() == "true");
			particleSystem.isBillBoard = (xml.@billboard.toString() != "false");
			particleSystem.particleOrient = int(xml.@orient.toString());
			
			// 基础属性
			parseCommonProperty(xml, particleSystem);
			// 基础动画
			parseObject3DAnimator(xml, particleSystem);
			
//			_particles.push(particleSystem);
			
			newEffect.addParticle(particleSystem, startTime, endTime);
			
			if(meshName.length != 0)
			{	// 粒子的mesh
//				incResourceLoad();
//				var meshFileName : String = _path + "/" + meshName + ".3ds";
//				blAssetsLoader.getMeshFromURL(meshFileName, _particles.length, onParticleMesh);
			}
			else
			{
				// 粒子的贴图
				var textureFileName : String = BlResourceManager.findValidPath(xml.@texture.toString() + BlStringUtils.texExtName, path);
				particleSystem.material = new GpuParticleMaterial(BlResourceManager.instance().findImageResource(textureFileName).bmpData);
			}
			
			// 粒子影响器(必须放最后，在effector中会嵌套粒子系统)
			parseParticleEffector(xml, particleSystem, newEffect);
		}
		// 解析粒子发射器
		static private function parseParticleEmitter(xml:XML) : ParticleEmitterBase
		{
			var emitter : ParticleEmitterBase;
			
			var emitterXML : XML;
			// 矩形发射器
			emitterXML = xml.rect_emitter[0];
			if(emitterXML)
			{
				var rectEmitter : RectangleParticleEmitter = new RectangleParticleEmitter;
				parseRectangleParticleEmitter(emitterXML, rectEmitter);
				emitter = rectEmitter;
				return emitter;
			}
			// 圆柱发射器
			emitterXML = xml.circle_emitter[0];
			if(emitterXML)
			{
				var circleEmitter : CylinderParticleEmitter = new CylinderParticleEmitter;
				parseCylinderParticleEmitter(emitterXML, circleEmitter);
				emitter = circleEmitter;
				return emitter;
			}
			// 球形发射器
			emitterXML = xml.sphere_emitter[0];
			if(emitterXML)
			{
				var sphereEmitter : SphereParticleEmitter = new SphereParticleEmitter;
				parseSphereParticleEmitter(emitterXML, sphereEmitter);
				emitter = sphereEmitter;
				return emitter;
			}
			
			return emitter;
		}
		// 球形发射器
		static private function parseSphereParticleEmitter(emitterXML:XML, sphereEmitter:SphereParticleEmitter) : void
		{
			sphereEmitter.radiusBig = Number(emitterXML.@radiusbig.toString());
			sphereEmitter.radiusSmall = Number(emitterXML.@radiussmall.toString());
			parseRectangleParticleEmitter(emitterXML, sphereEmitter);
		}
		
		// 圆柱发射器
		static private function parseCylinderParticleEmitter(emitterXML:XML, cylinderEmitter:CylinderParticleEmitter) : void
		{
			cylinderEmitter.radiusBig = Number(emitterXML.@radiusbig.toString());
			cylinderEmitter.radiusSmall = Number(emitterXML.@radiussmall.toString());
			cylinderEmitter.height = Number(emitterXML.@height.toString());
			parseRectangleParticleEmitter(emitterXML, cylinderEmitter);
		}
		
		// 矩形发射器
		static private function parseRectangleParticleEmitter(emitterXML:XML, rectEmitter : RectangleParticleEmitter) : void
		{
			rectEmitter.emitRate = int(emitterXML.@emitrate.toString());
			rectEmitter.lifeTime = int(emitterXML.@lifetime.toString());
			rectEmitter.lifeTimeRange = int(emitterXML.@lifetimerange.toString());
			
			var A:uint = uint(emitterXML.@a.toString());
			var R:uint = uint(emitterXML.@r.toString());
			var G:uint = uint(emitterXML.@g.toString());
			var B:uint = uint(emitterXML.@b.toString());
			
			var AR:uint = uint(emitterXML.@arange.toString());
			var RR:uint = uint(emitterXML.@rrange.toString());
			var GR:uint = uint(emitterXML.@grange.toString());
			var BR:uint = uint(emitterXML.@brange.toString());
			
			rectEmitter.color = ((R&0xff)<<16) + ((G&0xff)<<8) + (B&0xff);
			rectEmitter.colorRange = ((RR & 0xff)<<16) + ((GR & 0xff)<<8) + (BR & 0xff);
			rectEmitter.alpha = Number(A&0xff)/0xff;
			rectEmitter.alphaRange = Number(AR & 0xff) / 0xff;
			
			rectEmitter.sizeX = Number(emitterXML.@sizeX.toString());
			rectEmitter.sizeY = Number(emitterXML.@sizeY.toString());
			rectEmitter.sizeRange = Number(emitterXML.@sizerange.toString());
			
			rectEmitter.directionFrom = parseVector3D(emitterXML.@directionfrom.toString());
			rectEmitter.directionFrom.normalize();
			rectEmitter.directionTo = parseVector3D(emitterXML.@directionto.toString());
			rectEmitter.directionTo.normalize();
			
			var rectX:Number = Number(emitterXML.@rectx.toString());
			var rectY:Number = Number(emitterXML.@recty.toString());
			var rectZ:Number = Number(emitterXML.@rectz.toString());
			rectEmitter.EmitterRectFrom.setTo(-rectX,-rectY,-rectZ);
			rectEmitter.EmitterRectTo.setTo(rectX,rectY,rectZ);
			
			rectEmitter.vel = int(emitterXML.@vel.toString());
			rectEmitter.velRange = int(emitterXML.@velrange.toString());
			
			rectEmitter.rot = Number(emitterXML.@rot.toString()) / 180 * Math.PI;
			rectEmitter.rotRange = Number(emitterXML.@rotrange.toString()) / 180 * Math.PI;
			
			rectEmitter.rotVel = Number(emitterXML.@rotvel.toString()) / 180 * Math.PI;
			rectEmitter.rotVelRange = Number(emitterXML.@rotvelrange.toString()) / 180 * Math.PI;
			
			rectEmitter.emitPeriod = int(emitterXML.@emitperiod.toString());
			rectEmitter.emitTime = int(emitterXML.@emittime.toString());
			
			if( int(emitterXML.@showemit.toString()) )
				rectEmitter.showEmitter();
			
		}
		
		static private function parseParticleEffector(xml:XML, particleSystem : ParticleSystem, newEffect:BlEffect) : void
		{
			var effectorXML : XML;
			// 粒子大小影响器
			effectorXML = xml.size_effector[0];
			if(effectorXML)
			{
				var sizeEffector : SizeEffector = new SizeEffector;
				var sizekey : XML;
				var sizekeyFrameList : XMLList = effectorXML.keyframe;
				for each(sizekey in sizekeyFrameList)
				{
					var sizelifepercent : Number = Number(sizekey.@lifepercent.toString());
					var sx : Number = Number(sizekey.@sizeX.toString());
					var sy : Number = Number(sizekey.@sizeY.toString());
					sizeEffector.addKeyFrame(sizelifepercent, sx,sy);
				}
				particleSystem.addEffector(sizeEffector);
			}
			// 粒子颜色影响器
			effectorXML = xml.color_effector[0];
			if(effectorXML)
			{
				var colorEffector : ColorEffector = new ColorEffector;
				
				var key : XML;
				var keyFrameList : XMLList = effectorXML.keyframe;
				for each(key in keyFrameList)
				{
					var lifepercent : Number = Number(key.@lifepercent.toString());
					var r : Number = Number(key.@r.toString());
					var g : Number = Number(key.@g.toString());
					var b : Number = Number(key.@b.toString());
					
					colorEffector.addKeyFrame(lifepercent, r, g, b);
				}
				
				particleSystem.addEffector(colorEffector);
			}
			// 粒子alpha影响器
			effectorXML = xml.alpha_effector[0];
			if(effectorXML)
			{
				var alphaEffector : AlphaEffector = new AlphaEffector;
				
				var akey:XML;
				var akeyFrameList:XMLList = effectorXML.keyframe;
				for each(akey in akeyFrameList)
				{
					var alphalifepercent : Number = Number(akey.@lifepercent.toString());
					var alpha : Number = Number(akey.@a.toString());
					alphaEffector.addKeyFrame(alphalifepercent, alpha);
				}
				
				//				alphaEffector.deltaAlpha = Number(effectorXML.@a.toString());
				particleSystem.addEffector(alphaEffector);
			}
			// 粒子UV影响器
			effectorXML = xml.uv_effector[0];
			if(effectorXML)
			{
				var uvEffector : UVEffector = new UVEffector;
				/*	uvEffector.deltaU = Number(effectorXML.@u.toString());
				uvEffector.deltaV = Number(effectorXML.@v.toString());*/
				
				var uvkey:XML;
				var uvkeyFrameList:XMLList = effectorXML.keyframe;
				for each(uvkey in uvkeyFrameList)
				{
					var uv_lifepercent:Number = Number(uvkey.@lifepercent.toString());
					var u:Number = Number(uvkey.@u.toString());
					var v:Number = Number(uvkey.@v.toString());
					uvEffector.addKeyFrame(uv_lifepercent,u,v);
				}
				uvEffector.smoothU = effectorXML.@smoothU.toString() == "true";
				uvEffector.smoothV = effectorXML.@smoothV.toString() == "true";
				uvEffector.scaleU = Number(effectorXML.@su.toString());
				if(uvEffector.scaleU == 0)	uvEffector.scaleU = 1;
				uvEffector.scaleV = Number(effectorXML.@sv.toString());
				if(uvEffector.scaleV == 0)	uvEffector.scaleV = 1;
				particleSystem.addEffector(uvEffector);
			}
			// 粒子吸引器
			effectorXML = xml.attract_effector[0];
			if(effectorXML)
			{
				var attractEffector : AttractEffector = new AttractEffector;
				attractEffector.attractPoint = parseVector3D(effectorXML.@p.toString());
				attractEffector.force = Number(effectorXML.@f.toString());
				particleSystem.addEffector(attractEffector);
			}
			// 粒子力场控制器
			effectorXML = xml.force_effector[0];
			if(effectorXML)
			{
				var forceEffector : ForceEffector = new ForceEffector;
				forceEffector.forceDir = parseVector3D(effectorXML.@dir.toString());
				forceEffector.force = Number(effectorXML.@f.toString());
				particleSystem.addEffector(forceEffector);
			}
			
		}
	}
}