/**
 *	特效管理器 
 */
package blade3d.effect
{
	import away3d.debug.Debug;
	
	import blade3d.BlManager;
	import blade3d.resource.BlResource;
	
	import flash.utils.Dictionary;
	
	public class BlEffectManager extends BlManager
	{
		static private var _instance : BlEffectManager;
		static public var allEffectCount : uint = 0;		// 所有特效对象数 
		
		private var _effectStoreMap : Dictionary = new Dictionary;
		private var _busyEffects : Vector.<BlEffect> = new Vector.<BlEffect>;
		
		public var effectResources : Dictionary = new Dictionary;
		
		public function getBusyCount() : int {return _busyEffects.length;}
		
		public function BlEffectManager()
		{
			if(_instance)
				Debug.error("BlEffectManager error");
		}
		
		static public function instance() : BlEffectManager
		{
			if(!_instance)
				_instance = new BlEffectManager();
			return _instance;
		}
		
		public function init(callBack:Function):Boolean
		{
			callBack(this);
			return true;
		}
		
		public function recordEffectResource(effRes : BlResource):void
		{
			effectResources[effRes.url] = effRes;
		}
		
		public function getEffectStore(effectName : String) : BlEffectStore
		{
			if( _effectStoreMap[effectName] == null )
			{
				if(effectResources[effectName])
				{
					_effectStoreMap[effectName] = new BlEffectStore(effectName, effectResources[effectName]);
				}
				else
				{
					Debug.assert(false, "effect "+effectName+" not exist");
					return null;
				}
			}
			
			return _effectStoreMap[effectName];
		}
		
		public function createEffect(effectName : String, play : Boolean = true) : BlEffect
		{
			getEffectStore(effectName);
			
			var newEffect : BlEffect = _effectStoreMap[effectName].CreateEffect();
					
			_busyEffects.push(newEffect);
			
			if(play)
			{
				newEffect.play();
			}
			
			return newEffect;
		}
		
		public function update(time:uint, deltaTime:uint):void
		{
//			_currentCamera.update(time, deltaTime);
			// 特效的处理
			var effect : BlEffect;
			for(var ei:int=0; ei<_busyEffects.length; ei++)
			{
				effect = _busyEffects[ei];
				if(effect.isDead || effect.isDispose)
				{	// 特效结束的处理
					if(!effect.isDispose)
						effect.recycle();
					_busyEffects.splice(ei, 1);					
					ei--;
				}
				else
					effect.updateEff(time, deltaTime);
			}
			
		}
		
	}
}