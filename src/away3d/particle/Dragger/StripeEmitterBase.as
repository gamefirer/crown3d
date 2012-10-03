/**
 *	条带发射器基类 
 */
package away3d.particle.Dragger
{
	import away3d.core.traverse.PartitionTraverser;
	import away3d.errors.AbstractMethodError;
	import away3d.particle.StripeSystem;

	public class StripeEmitterBase
	{
		protected var _stripeSystem : StripeSystem;
		
		protected var _stripeNum : int = 1;		// 条带数
		protected var _IndexOrders : Vector.<Vector.<int>>;			// 条带中粒子的index顺序
		protected var _stripeParticleNum : Vector.<int>;				// 条带中的粒子数
		
		// 条带基本参数
		public var width : int = 10;		// 条带宽度
		public var dragTime : int = 100;	// 拖尾时间(毫秒)
		
		public function StripeEmitterBase(stripeSystem : StripeSystem)
		{
			this.stripeSystem = stripeSystem;
		}
		
		public function Clear() : void
		{
			for(var i:int=0; i<	_IndexOrders.length; i++)
			{
				for(var j:int=0; j<	_IndexOrders[i].length; j++)
				{
					_IndexOrders[i][j] = -1;
				}
				_stripeParticleNum[i] = 0;
			}
		}
		
		public function set stripeSystem(value : StripeSystem) : void
		{
			if(_stripeSystem)
			{	// 脱离当前发射器
				_stripeSystem.dragger = null;
			}
			_stripeSystem = value;
			this.stripeNum = _stripeNum;		// 重建条带index order
		}
		
		public function get stripeSystem() : StripeSystem
		{
			return _stripeSystem;
		}
		// 设置条带数
		public function set stripeNum(value : int) : void
		{
			_stripeNum = value;
			if(!_stripeSystem)
				return;
			
			_IndexOrders = new Vector.<Vector.<int>>(_stripeNum, true);
			_stripeParticleNum = new Vector.<int>(_stripeNum, true);
			for(var i:int=0; i<_stripeNum; i++)
			{
				var particleNumberInStripe : int = _stripeSystem.maxParticleNumber/_stripeNum;
				_IndexOrders[i] = new Vector.<int>(particleNumberInStripe, true);
				for(var j:int=0; j<particleNumberInStripe; j++)
					_IndexOrders[i][j] = -1;
				_stripeParticleNum[i] = 0;
			}			
		}
		
		public function get stripeNum() : int
		{
			return _stripeNum;
		}
		
		public function getIndexOrder(index:int) : Vector.<int>
		{
			return _IndexOrders[index]; 
		}
		
		public function getStripeParticleNum(index:int) : int
		{
			return _stripeParticleNum[index];
		}
		
		public function setStripeParticleNum(index:int, value:int) : void
		{
			_stripeParticleNum[index] = value;
		}
		
		public function Update(deltaTime : int, traverser : PartitionTraverser) : void
		{
			throw new AbstractMethodError();
		}
	}
}