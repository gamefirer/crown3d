package away3d.core.partition
{
	import away3d.arcane;

	use namespace arcane;

	public class QuadTree extends Partition3D
	{
		public function QuadTree(maxDepth : int, size : Number, centerX : Number = 0, centerZ : Number = 0, height : Number = 1000)
		{
			super(new QuadTreeNode(maxDepth, size, height, centerX, centerZ));
		}
	}
}