/**
 *	特效对象池(游戏中会有大量的特效对象频繁出现和消失,因此以池方式管理) 
 */
package blade3d.effect
{
	import away3d.debug.Debug;
	
	import blade3d.effect.BlEffect;
	import blade3d.effect.BlEffectLoader;
	import blade3d.effect.BlEffectManager;
	import blade3d.resource.BlResource;
	
	public class BlEffectStore
	{
		private var _freeEffect : Vector.<BlEffect> = new Vector.<BlEffect>;			// 闲置的特效
		private var _busyEffect : Vector.<BlEffect> = new Vector.<BlEffect>;			// 正在使用的特效
		private var _name : String;
		
		private var _effectLoader : BlEffectLoader;		// 用来创建特效的加载器
		
		public function BlEffectStore(effectName : String, effRes : BlResource)
		{
			_name = effectName;
			_effectLoader = new BlEffectLoader(this, effRes);		
		}
		
		public function get name() : String {return _name;}
		public function get loader() : BlEffectLoader {return _effectLoader;}
		public function get busyCount() : int {return _busyEffect.length;}
		public function get freeCount() : int {return _freeEffect.length;}
		
		// 从池中取一个特效对象出来
		public function CreateEffect() : BlEffect
		{
			var retEffect : BlEffect = CreateEffectNoRecycle();
			
			_busyEffect.push(retEffect);			

			return retEffect;
		}
		
		private function CreateEffectNoRecycle() : BlEffect
		{
			if(_freeEffect.length == 0)
				increasePool(_effectLoader.cacheNumber);
			
			var retEffect : BlEffect;
			
			retEffect = _freeEffect.pop();
			
			retEffect.reset();
			return retEffect;
		}
		
		// 加大缓存池
		private function increasePool(count:uint) : void
		{
			var newEffect : BlEffect;
			for(var i:int=0; i<count; i++)
			{
				newEffect = AllocateOneEffect();
				_freeEffect.push(newEffect);
			}
		}		
		// 重新创建一个特效对象
		private function AllocateOneEffect() : BlEffect
		{
			BlEffectManager.allEffectCount++;
			
			var newEffect:BlEffect = _effectLoader.createEffect();
			return 	newEffect;
		}
		
		private function FreeOneEffect(eff : BlEffect) : void
		{
			BlEffectManager.allEffectCount--;
			
			eff.detachParent();
			eff.dispose();
		}
		
		public function clearPool() : void
		{
			var i:int = 0;
			for(i=0; i<_freeEffect.length; i++)
			{
				FreeOneEffect(_freeEffect[i]);
			}
			
			for(i=0; i<_busyEffect.length; i++)
			{
				FreeOneEffect(_busyEffect[i]);
			}
			
			_freeEffect.length = 0;
			_busyEffect.length = 0;
		}
		
		public function cacheOne(cacheEffect : BlEffect) : void
		{
			if(!cacheEffect)
				throw new Error("cache null effect");
			BlEffectManager.allEffectCount++;
			_freeEffect.push(cacheEffect);
		}
		
		public function addCache(cacheNumber : uint) : void
		{
			var addCount : int = cacheNumber - _freeEffect.length;
			for(var i:int=0; i<addCount; i++)
			{
				_freeEffect.push(AllocateOneEffect());
			}
		}
		
		public function freeCache(cacheNumber : uint) : void
		{
			for(var i:int=0; i<cacheNumber; i++)
			{
				if(_freeEffect.length <= 1)
					break;
				
				var releaseEff : BlEffect = _freeEffect.pop();
				if(releaseEff)
				{
					FreeOneEffect(releaseEff);
				}
			}
		}
		
		public function recycle(deadEffect : BlEffect) : void
		{
			deadEffect.detachParent();
			
			var index:int = _busyEffect.indexOf(deadEffect);
			if(index < 0)
				Debug.trace("recycle effect error");
			else
			{
				_busyEffect.splice(index, 1);
				_freeEffect.push(deadEffect);
			}
		}
		
		
		
	}
}