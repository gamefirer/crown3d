/**
 *	粒子系统的显示器 
 */
package away3d.particle.Displayer
{
	import away3d.core.managers.Stage3DProxy;
	import away3d.core.traverse.PartitionTraverser;
	import away3d.materials.MaterialBase;
	import away3d.particle.ParticleSystem;
	
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;

	public interface ParticleDisplayerBase
	{
		function setParticleSystem(value : ParticleSystem) : void;
		
		function render(traverser : PartitionTraverser) : void;
		function Stop(immediately : Boolean) : void;
		
		function get material() : MaterialBase;
		function set material(value : MaterialBase) : void
			
		function getVertexBuffer(stage3DProxy : Stage3DProxy) : VertexBuffer3D;
		function getVertexColorBuffer(stage3DProxy : Stage3DProxy) : VertexBuffer3D;
		function getUVBuffer(stage3DProxy : Stage3DProxy) : VertexBuffer3D;
		function getIndexBuffer(stage3DProxy : Stage3DProxy) : IndexBuffer3D;
		
		function get indexData() : Vector.<uint>;
	
		function dispose() : void;
	}
}