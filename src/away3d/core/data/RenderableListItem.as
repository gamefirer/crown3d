package away3d.core.data
{

	import away3d.core.base.IRenderable;

	public final class RenderableListItem
	{
		public var next:RenderableListItem;
		public var renderable : IRenderable;

		// for faster access while sorting
		public var materialId : int;			// 材质排序
		public var renderOrderId : int;		// z排序
		public var zIndex : Number;
		public var renderPriority : int;		// 渲染优先级
	}
}
