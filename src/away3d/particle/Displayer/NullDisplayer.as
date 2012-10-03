/**
 *	空显示器 
 */
package away3d.particle.Displayer
{
	import away3d.core.managers.Stage3DProxy;
	import away3d.core.traverse.PartitionTraverser;
	import away3d.materials.MaterialBase;
	import away3d.particle.ParticleSystem;
	
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	
	public class NullDisplayer implements ParticleDisplayerBase
	{
		public function NullDisplayer()
		{
		}
		
		public function setParticleSystem(value:ParticleSystem):void
		{
		}
		
		public function render(traverser:PartitionTraverser):void
		{
		}
		
		public function Stop(immediately:Boolean):void
		{
		}
		
		public function get material():MaterialBase
		{
			return null;
		}
		
		public function set material(value:MaterialBase):void
		{
		}
		
		public function getVertexBuffer(stage3DProxy:Stage3DProxy):VertexBuffer3D
		{
			return null;
		}
		
		public function getVertexColorBuffer(stage3DProxy:Stage3DProxy):VertexBuffer3D
		{
			return null;
		}
		
		public function getUVBuffer(stage3DProxy:Stage3DProxy):VertexBuffer3D
		{
			return null;
		}
		
		public function getIndexBuffer(stage3DProxy:Stage3DProxy):IndexBuffer3D
		{
			return null;
		}
		
		public function dispose() : void
		{
			
		}
	}
}