package away3d.core.traverse
{
	import away3d.arcane;
	import away3d.containers.Scene3D;
	import away3d.core.base.IRenderable;
	import away3d.core.partition.NodeBase;
	import away3d.entities.Entity;
	import away3d.errors.AbstractMethodError;
	import away3d.lights.DirectionalLight;
	import away3d.lights.LightBase;
	import away3d.lights.LightProbe;
	import away3d.lights.PointLight;
	import away3d.particle.ParticleSystem;
	
	import flash.geom.Vector3D;

	use namespace arcane;

	/**
	 * IPartitionTraverser is a hierarchical visitor pattern that traverses through a Partition3D data structure.
	 *
	 * @see away3d.partition.Partition3D
	 */
	public class PartitionTraverser
	{
		/**
		 * The scene being traversed.
		 */
		public var scene : Scene3D;

		public var time : uint = 0;		// 当前时间
		public var deltaTime : uint = 0;		// deltatime
		
		arcane var _entryPoint : Vector3D;

		/**
		 *	收集器要收集的渲染层 
		 */		
		public function get layerMask() : uint {throw new AbstractMethodError();return 0xffff;}
		
		/**
		 * Called when the traversers enters a node. At minimum, it notifies the currently visited Partition3DNode whether or not further recursion is necessary.
		 * @param node The currently entered node.
		 * @return true if further recursion down children is necessary, false if not.
		 */
		public function enterNode(node : NodeBase) : Boolean { 
			// TODO: not used;
		 	node=node; 
		 	return true; 
		}

		/**
		 * Called when the traverser leaves a node. This method is still called when enterNode returned false.
		 * @param node The node being left by the traverser.
		 */
		public function leaveNode(node : NodeBase) : void {}

		/**
		 * Passes a skybox to be processed by the traverser.
		 */
		public function applySkyBox(renderable : IRenderable) : void
		{
			throw new AbstractMethodError();
		}

		/**
		 * Passes an IRenderable object to be processed by the traverser.
		 */
		public function applyRenderable(renderable : IRenderable) : void
		{
			throw new AbstractMethodError();
		}
		
		public function applyParticle(particleSystem : ParticleSystem) : void
		{
			throw new AbstractMethodError();
		}

		/**
		 * Passes a light to be processed by the traverser.
		 */
		public function applyUnknownLight(light : LightBase) : void
		{
			throw new AbstractMethodError();
		}

		public function applyDirectionalLight(light : DirectionalLight) : void
		{
			throw new AbstractMethodError();
		}

		public function applyPointLight(light : PointLight) : void
		{
			throw new AbstractMethodError();
		}

		public function applyLightProbe(light : LightProbe) : void
		{
			throw new AbstractMethodError();
		}

		/**
		 * Registers an entity for use.
		 */
		public function applyEntity(entity : Entity) : void
		{
			throw new AbstractMethodError();
		}

		/**
		 * The entry point for scene graph traversal, ie the point that will be used for traversing the graph
		 * position-dependently. For example: BSP visibility determination or collision detection.
		 * For the EntityCollector, this is the camera's scene position for example.
		 */
		public function get entryPoint() : Vector3D
		{
			return _entryPoint;
		}
	}
}