/**
 *	物理实体 
 */
package blade3d.physics
{
	import org.rje.glaze.engine.collision.shapes.Circle;
	import org.rje.glaze.engine.dynamics.Material;
	import org.rje.glaze.engine.dynamics.RigidBody;
	import org.rje.glaze.engine.math.Vector2D;
	
	public class blPhyObject extends RigidBody
	{
		private var material : Material = new Material(0.0, 0.0, 1);
		
		private var _speed : Number = 0;		// 移动速度
		private var _moveDir: Vector2D = new Vector2D;		// 移动方向
		private var _shape : Circle;			// 碰撞shape
		
		public var collisionCallBack : Object = null;		// 碰撞的回调
		
		public function blPhyObject(owner : blPhyOwner, radius : Number)
		{
			super();
			this._owner = owner;
			
			this.isBlockable = false;			// 不会受物理阻挡
			
			_shape = new Circle(radius, Vector2D.zeroVect, material);
			addShape(_shape);
			
			collisionProcessingMask = 7;
		}
		
		public function addToSpace() : void
		{
//			blWorld.getInstance().physics.addObject(this);
		}
		
		public function removeFromSpace() : void
		{
//			blWorld.getInstance().physics.removeObject(this);
		}
		
		public function setPosition(x:Number, y:Number) : void
		{
			p.x = x;
			p.y = y;
		}
		
		public function moveTo(x:Number, y:Number) : void
		{
			x = x - p.x;
			y = y - p.y;
			_moveDir.x = x;
			_moveDir.y = y;
			_moveDir = _moveDir.normalize();
			
			v.copy(_moveDir);
			v.copy(v.mult(_speed));
		}
		
		public function set speed(value:Number) : void
		{
			_speed = value;
			
			v.copy(_moveDir);
			v.copy(v.mult(_speed));
		}
		
		public function get speed() : Number {return _speed;}
		
	}
}