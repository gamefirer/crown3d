package away3d.materials.methods
{
	public class MethodVO
	{
		public var vertexConstantsOffset : int;
		public var vertexData : Vector.<Number>;
		public var fragmentData : Vector.<Number>;

		// public register indices
		public var texturesIndex : int;
		public var secondaryTexturesIndex : int;	// sometimes needed for composites
		public var thirdlyTexturesIndex : int;
		public var fourthTexturesIndex : int;
		public var fifthTexturesIndex : int;
		public var vertexConstantsIndex : int;
		public var secondaryVertexConstantsIndex : int;	// sometimes needed for composites
		public var fragmentConstantsIndex : int;
		public var secondaryFragmentConstantsIndex : int;	// sometimes needed for composites

		public var useMipmapping : Boolean;
		public var useSmoothTextures : Boolean;
		public var repeatTextures : Boolean;

		// internal stuff for the material to know before assembling code
		public var needsColor : Boolean;		// 需要顶点色
		public var needsProjection : Boolean;
		public var needsView : Boolean;
		public var needsNormals : Boolean;
		public var needsTangents : Boolean;
		public var needsUV : Boolean;
		public var needsSecondaryUV : Boolean;
		public var needsGlobalPos : Boolean;

		public var numLights : int;

		public function reset() : void
		{
			vertexConstantsOffset = 0;
			texturesIndex = -1;
			vertexConstantsIndex = -1;
			fragmentConstantsIndex = -1;

			useMipmapping = true;
			useSmoothTextures = true;
			repeatTextures = false;

			needsColor = false;					// 是否需要 顶点色
			needsProjection = false;			// 是否需要 投影矩阵
			needsView = false;					// 是否需要 View矩阵
			needsNormals = false;				// 是否需要 normal
			needsTangents = false;				// 是否需要 tangent
			needsUV = false;					// 是否需要 UV
			needsSecondaryUV = false;			// 是否需要 第二UV
			needsGlobalPos = false;				// 是否需要全集 pos

			numLights = 0;
		}
	}
}
