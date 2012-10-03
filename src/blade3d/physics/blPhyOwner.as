/**
 *	物理对象拥有者的接口 
 */
package blade3d.physics
{
	import org.rje.glaze.engine.dynamics.RigidBody;
		
	public interface blPhyOwner
	{
		
		function ownerType() : int;
		function onStartCollision(collider : RigidBody, collidee : RigidBody) : void;
		function onCollision(collider : RigidBody, collidee : RigidBody) : void;
		function onEndCollision(collider : RigidBody, collidee : RigidBody) : void;
		
		function get angle() : Number;
		function setTargetDirection(x:Number, y:Number):void;
		function onMoveEnd():void;
	}
}