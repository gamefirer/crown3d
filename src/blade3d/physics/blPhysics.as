/**
 *	物理世界 
 */
package blade3d.physics 
{
	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.primitives.WireframeLines;
	
	import blade3d.profiler.Profiler;
	import blade3d.scene.BlScene;
	import blade3d.scene.BlSceneManager;
	
	import flash.display.Graphics;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	
	import org.rje.glaze.engine.collision.shapes.*;
	import org.rje.glaze.engine.dynamics.*;
	import org.rje.glaze.engine.dynamics.constraints.*;
	import org.rje.glaze.engine.math.*;
	import org.rje.glaze.engine.space.*;
	
	public class blPhysics 
	{
		public static var showPhysics : Boolean = false;
		
		private static var instance : blPhysics;
		
		private var _scene : BlScene;
		
		public var staticColour:uint = 0xE8EC95;// 0xD8D9BD;// 0xC8CAA4;
		
//		public var space : SortAndSweepSpace;
		public var space : SpacialHashSpace;
		
		public var holeBody : RigidBody;		// hole碰撞的rigidbody
		
		private static var fps : int = 30;
		private static var pps : int = 30;		// 每秒20个物理的tick
		
		private var frameCount : int = 0;
		
		private var _physicsNode : ObjectContainer3D;
		private var _bodyMeshs : Vector.<WireframeLines> = new Vector.<WireframeLines>;		//	显示碰撞用
		
		public function blPhysics(scene : BlScene) : void 
		{
			_scene =scene;
			initSpace();
		}
		
		public function initSpace() : void 
		{
//			space = new SortAndSweepSpace(fps, pps, null);
			
			// hash空间
			// 参数4：桶大小  参数5：hash格大小
			// hash格的大小影响物理碰撞计算量，通过narrowPhase数衡量
			space = new SpacialHashSpace(fps, pps, null, 257, 1000);		
			space.damping = 1;
			space.iterations = Space.BLADE3D_ITERATIONS;			// 碰撞处理的迭代次数
			
			// 墙
			space.defaultStaticBody.layers = blPhyActor.Collision_MASK_WALL;
			
			// 洞
			holeBody = new RigidBody(RigidBody.STATIC_BODY);
			holeBody.layers = blPhyActor.Collision_MASK_HOLE;
			space.addRigidBody(holeBody);
			
			// 显示物理体的node
			_physicsNode = new ObjectContainer3D;
			_physicsNode.name = "phy_node";
			_scene.addEditor(_physicsNode);
		}
		
		public function addBlockSegment(segment : Segment) : void 
		{
			var shape : GeometricShape = space.defaultStaticBody.addShape(segment);
			shape.fillColour = staticColour;
		}
		// 添加墙体碰撞
		public function addBlockPolygon(verts : Array, pos : Vector2D) : void 
		{
			var pos : Vector2D
			var shape : GeometricShape = space.defaultStaticBody.addShape(new Polygon(verts, pos, new Material(0.0, 0, 1)));
			shape.fillColour = staticColour;
		}
		// 添加洞碰撞
		public function addHolePlygon(verts : Array, pos : Vector2D) : void
		{
			var pos : Vector2D
			var shape : GeometricShape = holeBody.addShape(new Polygon(verts, pos, new Material(0.0, 0, 1)));
			shape.fillColour = staticColour;
		}
		
		public function syncSpace() : void 
		{
			space.syncBroadphase();		// 静态碰撞物体整理
		}
		
		public function addActor(actor : blPhyActor) : void 
		{
			space.addRigidBody(actor);
		}

		public function removeActor(actor : blPhyActor) : void 
		{
			space.removeRigidBody(actor);
		}
		
		public function addObject(object : blPhyObject) : void
		{
			space.addRigidBody(object);
		}
		
		public function removeObject(object : blPhyObject) : void
		{
			space.removeRigidBody(object);
		}
		
		public static function randomRange(min:Number, max:Number):Number 
		{
			return Math.round(Math.random() * (max - min + 1)) + min;
		}
		
		public static function deg2rad(deg:Number):Number 
		{
			return deg * Math.PI / 180;
		}
		
		public function render() : void 
		{
			//Step the engine n times.  The higher n, the more accurate things get.
			Profiler.start("blPhysics.render");
			space.step();
			
			// 显示物体碰撞体
			if(showPhysics)
			{
				_physicsNode.visible = true;
				renderSpace();
			}
			else
				_physicsNode.visible = false
			
			Profiler.end("blPhysics.render");
		}
		
		private function renderSpace() : void
		{
			while(_bodyMeshs.length < space.activeBodiesCount)
			{
				AddBodyMesh();
			}
			
			var body : RigidBody = space.activeBodies;
			var mi : int = 0;
			while (body) 
			{
				_bodyMeshs[mi].visible = true;
				_bodyMeshs[mi].x = body.p.x;
				_bodyMeshs[mi].z = body.p.y;
				_bodyMeshs[mi].y = BlSceneManager.instance().currentScene.getTerrainHeight(body.p.x, body.p.y)+10;
				body = body.next;
				mi++;
			}
			
			for(;mi<_bodyMeshs.length;mi++)
				_bodyMeshs[mi].visible = false;
		}
		
		private function AddBodyMesh() : void
		{
			var points : Vector.<Vector3D> = new Vector.<Vector3D>;
			var p : Vector3D;
			var radius : Number = 50;
			for(var i:int=0;i<16;i++)
			{
				p = new Vector3D;
				p.x = Math.cos( Number(i)/16 * Math.PI * 2 + Math.PI / 16 ) * radius;
				p.y = 0;
				p.z = Math.sin( Number(i)/16 * Math.PI * 2 + Math.PI / 16 ) * radius;
				points.push(p);
				p = new Vector3D;
				p.x = Math.cos( Number(i+1)/16 * Math.PI * 2 + Math.PI / 16 ) * radius;
				p.y = 0;
				p.z = Math.sin( Number(i+1)/16 * Math.PI * 2 + Math.PI / 16 ) * radius;
				points.push(p);
			}
			// x正方向
			p = new Vector3D;
			p.x = 0;
			p.y = 0;
			p.z = 0;
			points.push(p);
			p = new Vector3D;
			p.x = radius;
			p.y = 0;
			p.z = 0;
			points.push(p);
			
			// z正方向
			p = new Vector3D;
			p.x = 0;
			p.y = 0;
			p.z = 0;
			points.push(p);
			p = new Vector3D;
			p.x = 0;
			p.y = 0;
			p.z = radius/2;
			points.push(p);
				
			var bodyMesh : WireframeLines = new WireframeLines(points, 0xfff00);
			_physicsNode.addChild( bodyMesh );
				
			_bodyMeshs.push(bodyMesh);
		}
		
		public function dispose() :void
		{
			
		}
	}
}
