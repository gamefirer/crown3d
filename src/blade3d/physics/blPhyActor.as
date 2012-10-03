/**
 *	生物的物理对象(只负责碰撞检测和匀速移动) 
 */
package blade3d.physics
{
	
	import away3d.debug.Debug;
	
	import org.rje.glaze.engine.collision.shapes.Circle;
	import org.rje.glaze.engine.dynamics.Material;
	import org.rje.glaze.engine.dynamics.RigidBody;
	import org.rje.glaze.engine.math.Vector2D;
	
	// 物理对象
	public class blPhyActor extends RigidBody 
	{
		// collsion mask
		public static const Collision_MASK_HOLE		: uint = 0x0001;		// 洞的碰撞layer
		public static const Collision_MASK_WALL		: uint = 0x0002;		// 墙的碰撞
		
		public static const Collision_MASK_CREATURE	: uint = 0x0013;		// 角色(墙和洞都碰撞)
		
		private static var material : Material = new Material(0.0, 0.0, 1);		// 所有的material都用这一个
		
		private var _shape : Circle;			// 碰撞shape

		private const _lastp : Vector2D = new Vector2D;	// 上一帧位置
		
		private var _radius : Number = 50;
		private var _speed : Number = 50;			// 实际运动速度
		private var _moveSpeed : Number = _speed;	// 速度值
		private var _pushSpeed : Number = _speed;
		
		public var _forNetSlow : Boolean = true;		// 网络生物移动减速(使在网络波动下运动更平滑)
		
		public function blPhyActor(player : blPhyOwner, radius : Number, isBlockable : Boolean = false) : void 
		{
			super();
			this.isBlockable = isBlockable;

			this._owner = player;
			this.layers = Collision_MASK_CREATURE;
			
			collisionProcessingMask = 7;
			
			
			this._radius = radius;
			_shape = new Circle(_radius, Vector2D.zeroVect, material);
			addShape(_shape);
		}
		// 是否受到阻挡
		public function set blockable(val : Boolean) : void 
		{
			isBlockable = val;
		}
		
		public function get blockable() : Boolean
		{
			return isBlockable;
		}
		// 是否阻挡其他对象
		public function set block(val : Boolean) : void
		{
			if(val)
				this.layers = Collision_MASK_CREATURE;
			else
				this.layers = 0;
		}
		
		public function get block() : Boolean
		{
			return (this.layers != 0);
		}
		
		public function set radius(val : Number) : void
		{
			if(_radius == val)
				return;
			
			_radius = val;
			if(_shape)
			{
				removeShape(_shape);
			}
			_shape = new Circle(_radius, Vector2D.zeroVect, material);
			addShape(_shape);		
		}
		
		public function get radius() : Number { return _radius; }
		
		public function set speed(val:Number) : void 
		{
			_moveSpeed = val;
			updateSpeed(_moveSpeed);
					
		}
		public function get speed() : Number { return _moveSpeed; }
		
		private function updateSpeed(val:Number) : void
		{
			if(_forNetSlow)
				_speed = val * 0.90;
			else
				_speed = val;
			this.v.copy(this.v.normalize());
			this.v.copy(this.v.mult(_speed));
//			Debug.bltrace("speed="+_speed);
		}
		
		public function jumpTo( x : Number, y : Number) : void 
		{
			p.x = x;	
			p.y = y;
			
			dest.x = x;
			dest.y = y;
		}
		
		
		private var _pushTime : int = 0;
		
		public function pushTo(x : Number, y : Number, changeFace:Boolean, pushSpeed : Number) : void
		{
			var dis : Number = p.distance(new Vector2D(x, y));
			
			_pushSpeed = pushSpeed;
			_pushTime = dis * 1000 / _pushSpeed;
			
			if(_pushTime>0)
			{
				updateSpeed(_pushSpeed);				
			}
			
			moveTo(x, y, changeFace);
		}
		
		public var dest : Vector2D = new Vector2D();
		public var moveDistanceInThisFrame : Number = 0;
		private var _moveDistance : Number = 0;
		private var _destDistance : Number = 0;
		private var _isMove : Boolean = false;
		
		public function moveTo(x : Number, y : Number, changeFace:Boolean) : void {
			if(!owner)
				return;
			if(isSleeping)
				wake(10);
			dest.x = x;
			dest.y = y;
			
			var nextV : Vector2D = dest.minus(p).normalize().mult(_speed);
			if( nextV.equalsZero() )
			{
				nextV.x = _speed * Math.cos( owner.angle );
				nextV.y = _speed * Math.sin( owner.angle );
			}
			v.copy(nextV);
			
			if(changeFace)
				owner.setTargetDirection(nextV.x, nextV.y);

			_lastp.copy(p);
			
			_moveDistance = 0;
			_destDistance = dest.distance(p);
			
			if(!_isMove)
			{
				_isMove = true;
				onMoveStart();
			}
		}
		
		private function onMoveStart() : void {
			
		}
		
		private function onMoveEnd() : void {
			if(!owner)
				return;
			owner.onMoveEnd();
		}
		
		public function stop() : void {
			v.copy(Vector2D.zeroVect);
			dest.copy(p);
			_moveDistance = 0;
			_destDistance = 0;
			
		}
		
		public override function onStep(DT : int) : void {
//			if(player == blSceneManager.getInstance().MyPlayer)
//				Debug.bltrace("p="+p.x.toFixed(2)+" "+p.y.toFixed(2)+" v="+v.x.toFixed(2)+" "+v.y.toFixed(2));			
			// 计算行走距离
			moveDistanceInThisFrame = p.distance(_lastp);
			_moveDistance += moveDistanceInThisFrame;
			_lastp.copy(p);
			
			if( _moveDistance > _destDistance + 10 )
			{
				if(_isMove)
				{
					_isMove = false;
					onMoveEnd();
				}
			}
			
			if(_pushTime > 0)		// 被动移动处理
			{
				_pushTime -= DT;
				if(_pushTime <= 0)
				{
					updateSpeed(_moveSpeed);
					stop();					
				}
			}
			
		}
		
	}
}

