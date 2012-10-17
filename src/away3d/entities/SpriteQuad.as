/**
 *	面片特效用对象 
 */
package away3d.entities
{
	import away3d.arcane;
	import away3d.bounds.BoundingSphere;
	import away3d.bounds.BoundingVolumeBase;
	import away3d.cameras.Camera3D;
	import away3d.core.base.Geometry;
	import away3d.core.base.IRenderable;
	import away3d.core.base.SubGeometry;
	import away3d.core.base.SubMesh;
	import away3d.core.managers.Stage3DProxy;
	import away3d.core.partition.EntityNode;
	import away3d.core.partition.RenderableNode;
	import away3d.core.traverse.PartitionTraverser;
	import away3d.materials.DefaultMaterialBase;
	import away3d.materials.MaterialBase;
	
	import flash.display.BlendMode;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;

	use namespace arcane;
	
	public class SpriteQuad extends Mesh
	{
		private var _subGeometry : SubGeometry;		// 矩形mesh
		
		private var _width : Number;
		private var _height : Number;
		public var rotz : Number = 0;		// 旋转 弧度
		public var rotZVel : Number = 0;	// 旋转速度
		private var _zUp : Boolean = true;
		
		private var _vertexData : Vector.<Number>;
		private var _invalidVertexData : Boolean = true;
		
		private var _billBoard : Boolean = true;
		private var _orient : uint = 2;
		
		/**
		 *	 orient: 朝向 0面向x轴 1面向y轴 2面向z轴 
		 */		
		public function SpriteQuad(material : MaterialBase, width : Number, height : Number, orient : int)
		{
			_width = width;
			_height = height;
			
			// 创建矩形mesh
			if (!_subGeometry) 
			{
				_subGeometry = new SubGeometry();
				_vertexData = new Vector.<Number>(12, true);
				
				_orient = orient;
				updateVertexData(_orient);
				
				_subGeometry.updateUVData(Vector.<Number>([.0, .0, 1.0, .0, 1.0, 1.0, .0, 1.0]));
				_subGeometry.updateIndexData(Vector.<uint>([0, 1, 2, 0, 2, 3]));
				_subGeometry.updateVertexTangentData(Vector.<Number>([1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0]));
				_subGeometry.updateVertexNormalData(Vector.<Number>([.0, .0, -1.0, .0, .0, -1.0, .0, .0, -1.0, .0, .0, -1.0]));
			}
			
			var oneGeometry : Geometry = new Geometry;
			oneGeometry.addSubGeometry(_subGeometry);
			super(oneGeometry, material);
			
			renderLayer = Entity.Effect_Layer;			// 面片在特效层渲染
		}
		
		public function get billBoard() : Boolean {return _billBoard;}
		
		public function set billBoard(val:Boolean) : void
		{
			_billBoard = val;
			if(_billBoard)
			{
				if(_orient != 2)
					updateVertexData(2);
			}
			else
			{
				updateVertexData(_orient);
			}
		}
		
		public function get width() : Number { return _width; }
		
		public function set width(value : Number) : void
		{
			if (_width == value) return;
			_width = value;
			_invalidVertexData = true;
		}
		
		public function get height() : Number { return _height; }
		
		public function set height(value : Number) : void
		{
			if (_height == value) return;
			_height = value;
			_invalidVertexData = true;
		}
		
		private function updateVertexData(orient : int) : void
		{
			if(_invalidVertexData)
			{
				if(orient == 0)			// 面向x轴
				{
					_vertexData[0] = 0;
					_vertexData[1] = -0.5 * _width;
					_vertexData[2] = 0.5 * _height;
					
					_vertexData[3] = 0;
					_vertexData[4] = 0.5 * _width;
					_vertexData[5] = 0.5 * _height;
					
					_vertexData[6] = 0;
					_vertexData[7] = 0.5 * _width;
					_vertexData[8] = -0.5 * _height;
					
					_vertexData[9] = 0;
					_vertexData[10] = -0.5 * _width;
					_vertexData[11] = -0.5 * _height;
					
					
				}
				else if(orient == 1)	// 面向y轴
				{
					_vertexData[0] = -0.5 * _width;
					_vertexData[1] = 0;
					_vertexData[2] = 0.5 * _height;
					
					_vertexData[3] = 0.5 * _width;
					_vertexData[4] = 0;
					_vertexData[5] = 0.5 * _height;
					
					_vertexData[6] = 0.5 * _width;
					_vertexData[7] = 0;
					_vertexData[8] = -0.5 * _height;
					
					_vertexData[9] = -0.5 * _width;
					_vertexData[10] = 0;
					_vertexData[11] = -0.5 * _height;
				}
				else		// 面向z轴
				{
					_vertexData[0] = -0.5 * _width;
					_vertexData[1] = 0.5 * _height;
					_vertexData[2] = 0;
					
					_vertexData[3] = 0.5 * _width;
					_vertexData[4] = 0.5 * _height;
					_vertexData[5] = 0;
					
					_vertexData[6] = 0.5 * _width;
					_vertexData[7] = -0.5 * _height;
					_vertexData[8] = 0;
					
					_vertexData[9] = -0.5 * _width;
					_vertexData[10] = -0.5 * _height;
					_vertexData[11] = 0;
				}
				
				_subGeometry.updateVertexData(_vertexData);
				
				_invalidVertexData = false;
			}
		}
		
		override public function pushModelViewProjection(camera : Camera3D) : void
		{
			if(billBoard)
			{
				var comps : Vector.<Vector3D>;
				var rot : Vector3D;
				if (++_mvpIndex == _stackLen) {
					_mvpTransformStack[_mvpIndex] = new Matrix3D();
					++_stackLen;
				}
				
				var mvp : Matrix3D = _mvpTransformStack[_mvpIndex];
				mvp.copyFrom(sceneTransform);
				mvp.append(camera.inverseSceneTransform);
				comps = mvp.decompose();
				rot = comps[1];
				rot.x = rot.y = rot.z = 0;		// 消去旋转
				rot.z = rotz / 180 * Math.PI;
				mvp.recompose(comps);
				mvp.append(camera.lens.matrix);
				mvp.copyColumnTo(3, _pos);
				_zIndices[_mvpIndex] = -_pos.z;
			}
			else
			{
				super.pushModelViewProjection(camera);
			}
		}
		// 面片的旋转
		override public function get rotationZ() : Number
		{
			if(billBoard)
				return rotz;
			else
				return super.rotationZ;
		}
		
		override public function set rotationZ(val:Number):void
		{
			if(billBoard)
				rotz = val;
			else
				super.rotationZ = val;
		}
		
		public function set zUp(value : Boolean) : void
		{
			_zUp = value;
			if(_zUp)
				DefaultMaterialBase(this.material).zBias = 30;
			else
				DefaultMaterialBase(this.material).zBias = 0;
		}
		
		public override function set material(value : MaterialBase) : void
		{
			super.material = value;
			if(!value)
				return;
					
			// 设置material属性
			this.material.blendMode = BlendMode.ADD;		// 透明贴图
			this.material.bothSides = true;				// 双面渲染
			this.material.depthWrite = false;				// 不写z
			if(_zUp)
				DefaultMaterialBase(this.material).zBias = 30;		// 面片在上面
			DefaultMaterialBase(this.material).normalMethod.normalMap = null;		// 无normal map
			DefaultMaterialBase(this.material).specularMethod = null;
			if(!DefaultMaterialBase(this.material).colorTransform)
				DefaultMaterialBase(this.material).colorTransform = new ColorTransform;
			
		}
		
		override public function dispose() : void
		{
			super.dispose();
		}
		
	}
}