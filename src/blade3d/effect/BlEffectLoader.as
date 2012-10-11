/**
 *	特效对象加载器 
 */
package blade3d.effect
{
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.SubGeometry;
	import away3d.debug.Debug;
	import away3d.materials.utils.DefaultMaterialManager;
	import away3d.primitives.PlaneGeometry;
	import away3d.primitives.SphereGeometry;
	
	import blade3d.effect.parser.BlEffectBaseParser;
	import blade3d.effect.parser.BlEffectParticleParser;
	import blade3d.effect.parser.BlEffectStripeParser;
	import blade3d.resource.BlImageResource;
	import blade3d.resource.BlResource;
	import blade3d.resource.BlResourceManager;
	import blade3d.resource.BlStringResource;
	import blade3d.utils.BlStringUtils;
	
	import flash.display.BlendMode;
	import flash.geom.Vector3D;

	public class BlEffectLoader
	{
		public var cacheNumber : uint = 1;
		
		private var _store:BlEffectStore;
		private var _name:String;
		private var _effRes:BlResource;			// 特效资源数据
		private var _effPath:String;				// 特效资源所在目录
		
		private var _unLoadedEffects : Vector.<BlEffect> = new Vector.<BlEffect>;
		private var _newEffect : BlEffect;
		
		private var _srcXML : XML;		// 特效源数据
		
		public function BlEffectLoader(store : BlEffectStore, effRes : BlResource)
		{
			_store = store;
			_name = _store.name;
			_effRes = effRes;
			
			_effPath = BlStringUtils.extractPath(_effRes.url);
			
			// 加载源数据
			loadEffData();
		}
		
		public function get srcXML() : XML {return _srcXML;}
		
		public function createEffect():BlEffect
		{
			var newEffect : BlEffect = new BlEffect;
			newEffect.name = _name;
			newEffect.store = _store;
			
			_unLoadedEffects.push(newEffect);
			
			// 加载特效数据资源
			if(!_srcXML)
				loadEffData();
			else
				loadEffect();
						
			return newEffect;
		}
		
		public function saveSrcData():void
		{
			// srcData -> res
			var outputXML:XML = new XML(_srcXML);
				
			if(_effRes.resType == BlResourceManager.TYPE_STRING)
			{
				BlStringResource(_effRes).str = outputXML;
			}
			else
				Debug.assert(false);
			
			// save res
			BlResourceManager.instance().saveResource(_effRes);
		}
		
		private function loadEffData():void
		{
			if(!_srcXML)
			{
				_effRes.asycLoad(onEffData);
			}
		}
		
		private function onEffData(res:BlResource):void
		{
			var xmlStr : String = BlStringResource(res).str;
			
			// 资源数据 -> 源数据
			try
			{
				_srcXML = new XML(xmlStr);
			}
			catch(e:Error)
			{
				Debug.trace(res.url + " xml error")
				return;
			}
		
			// 加载特效所需资源
			prepareEffResource();
		}
		
		private var _prepareCount : int = 0;
		private function prepareEffResource():void
		{
			_prepareCount++;
			var res:BlResource;
			var resUrl:String;
			var top_xml : XML;
			// 粒子所需资源
			var particleList : XMLList;
			particleList = _srcXML.particle;
			for each(top_xml in particleList)
			{
				// 粒子的贴图
				resUrl = top_xml.@texture;
				if(resUrl.length>0)
				{
					resUrl += BlStringUtils.texExtName;
					resUrl = BlResourceManager.findValidPath(resUrl, _effPath);
					res = BlResourceManager.instance().findResource(resUrl);
					_prepareCount++;
					res.asycLoad(onPrepareEffResource);
				}
				// 粒子的模型
				resUrl = top_xml.@mesh;
				if(resUrl.length>0)
				{
					resUrl += BlStringUtils.modelExtName;
					resUrl = BlResourceManager.findValidPath(resUrl, _effPath);
					res = BlResourceManager.instance().findResource(resUrl);
					_prepareCount++;
					res.asycLoad(onPrepareEffResource);
				}
			}
			// 条带所需资源
			var stripeList : XMLList;
			stripeList = _srcXML.stripe;
			for each(top_xml in stripeList)
			{
				// 条带的贴图
				resUrl = top_xml.@texture;
				if(resUrl.length>0)
				{
					resUrl += BlStringUtils.texExtName;
					resUrl = BlResourceManager.findValidPath(resUrl, _effPath);
					res = BlResourceManager.instance().findResource(resUrl);
					_prepareCount++;
					res.asycLoad(onPrepareEffResource);
				}
			}
			
			onPrepareEffResource(null);
		}
		
		private function onPrepareEffResource(res:BlResource):void
		{
			_prepareCount--;
			if(_prepareCount == 0)
			{	// 特效所需资源加载完毕
				// 创建未加载的特效对象
				loadEffect();
			}
		}
		
		
		private function loadEffect():void
		{
			while(_unLoadedEffects.length>0)
			{
				var newEffect : BlEffect = _unLoadedEffects.shift();
				
				var property_xml : XML;
				
				var top_xml : XML;
				var particleList : XMLList;
				var stripeList : XMLList;
				var quadList : XMLList;
				var lightList : XMLList;
				var morphList : XMLList;
				var i:int;
				
				// 特效自身属性
				property_xml = _srcXML.property[0];
				if(property_xml)
				{
					parseProperty(property_xml, newEffect);
				}
				
				// 创建粒子
				particleList = _srcXML.particle;
				for each(top_xml in particleList)
				{
					BlEffectParticleParser.parseParticle(top_xml, newEffect, _effPath);
				}
				// 创建条带
				stripeList = _srcXML.stripe;
				for each(top_xml in stripeList)
				{
					BlEffectStripeParser.parseStripe(top_xml, newEffect, _effPath);
				}
				
				newEffect.onCreate();		// 创建完毕
			}
		}
		
		// 解析特效系统的基础属性
		private function parseProperty(xml:XML, newEffect:BlEffect) : void
		{
			newEffect.lifeTime = int(xml.@lifetime.toString());
			cacheNumber = Math.max(1, int(xml.@cache.toString()));
		}
		
	
	}
}