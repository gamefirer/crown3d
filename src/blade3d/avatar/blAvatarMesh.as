/**
 *	支持Avatar效果换装的Mesh 
 */
package blade3d.avatar
{
	import away3d.animators.SkeletonAnimator;
	import away3d.animators.data.SkeletonPose;
	import away3d.arcane;
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Geometry;
	import away3d.core.base.SkinnedSubGeometry;
	import away3d.core.base.SubMesh;
	import away3d.core.managers.Context3DProxy;
	import away3d.entities.BoneTag;
	import away3d.entities.Mesh;
	import away3d.library.assets.AssetType;
	import away3d.materials.MaterialBase;
	import away3d.materials.TextureMaterial;
	import away3d.textures.BitmapTextureCache;
	
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;

	use namespace arcane;

	public class blAvatarMesh extends Mesh
	{
		protected var _avatarStore : blAvatarStore;		// 属于哪个AvatarStore,对应哪一套Avatar
		protected var subMeshUnion : Vector.<SubMesh> = new Vector.<SubMesh>(1, true);		// 仅一个SubMesh,组合而成
		protected var unitedSubMesh : SubMesh;
		protected var unitedSubGeom : SkinnedSubGeometry = new SkinnedSubGeometry(4);
		public var _assemblingCode : Vector.<Boolean>;		// 组装序号
		private var _curAssemblingCode :Vector.<Boolean>;	// 当前的组装序号
		
		protected var _boneTagMap : Dictionary;					// 该角色的骨骼绑定点列表
		
		// 贴图相关
		private var _curTextureBmp : BitmapData;
		private var _materialDirty : Boolean = true;
		
		protected var _updateBoundingBoxCount : int = 0;
		// 组装用变量
		private var indexDataOffset : uint = 0;
		
		public function blAvatarMesh(parentStore : blAvatarStore, material : MaterialBase = null, geometry : Geometry = null) : void 
		{
			super(geometry, material);
			
			avatarStore = parentStore;
			
			initMesh();
			visible = false;
		}
		
		public function set avatarStore(store : blAvatarStore) : void
		{
			_avatarStore = store;
			if(_avatarStore)
			{
				_assemblingCode = new Vector.<Boolean>(_avatarStore.getSubGeoCount(), true);
				_curAssemblingCode = new Vector.<Boolean>(_avatarStore.getSubGeoCount(), true);
				for (var i:int = 0; i < _avatarStore.getSubGeoCount(); i ++)
				{
					_curAssemblingCode[i] = false;
				}
			}
		}
			
		public override function get assetType() : String
		{
			return AssetType.AVATARMESH;
		}
		
		public function get avatarStore() : blAvatarStore {return _avatarStore;}
		
		public function getBoneTag(tagName : String) : BoneTag
		{
			if( _boneTagMap.hasOwnProperty(tagName) )
				return _boneTagMap[tagName];
			return null;
		}
		// 通过贴图的名字，获得部位类型
		public static function getTexturePartType(texName : String) : String
		{
			var list:Array = texName.split("/");
			return list[1];
		}
		// 通过模型的名字，获得部位类型
		public static function getModelPartType(modName : String) : String
		{
			return modName.substring(0, modName.indexOf("_"));
		}
		
		// 角色贴图变为初始贴图(裸体)
		public function resetTexture() : void
		{
			clearSubTexture();
			updateMaterial();
		}
		// 添加换装贴图
		public function addCloth(texName : String , point:Point = null) : void
		{
			if(addSubTexture(texName,point))
				updateMaterial();
		}
		
		public function addSubTexture(texName : String , point:Point = null) : Boolean
		{
			var subTex : BitmapData = _avatarStore.getSubTexture(texName);
			if(subTex)
			{
				// 如当前的texture使用是目前的bitmapdata，则必须clone一个新的bitmapdata,否则texture的数据不会更新
				if(!_materialDirty)
				{
					var oldTextureBmp : BitmapData = _curTextureBmp;
					_curTextureBmp = _curTextureBmp.clone();
					oldTextureBmp.dispose();
				}
				
				var copyPoint : Point 
				if(point)
				{
					copyPoint = point;
				}
				else
				{
					var partName:String = texName.split("/")[1];
//					copyPoint = _equipManager.getDefine().getDefine(partName);
				}
				_curTextureBmp.copyPixels(subTex, subTex.rect, copyPoint, subTex, null, true);
				_materialDirty = true;
				return true;
			}
			else
				return false;
		}
		
		public function clearSubTexture() : void
		{
			if(_curTextureBmp)
				_curTextureBmp.dispose();
			_curTextureBmp = _avatarStore.getTexture().clone();
			_materialDirty = true;
		}
		
		public function updateMaterial() : void
		{
			if(_materialDirty)
			{
				if(material)
				{
					TextureMaterial(material).texture = BitmapTextureCache.instance().getTexture(_curTextureBmp);
					TextureMaterial(material).updateMaterial(Context3DProxy.stage3DProxy._context3D);
				}
				else
				{
					material = new TextureMaterial(BitmapTextureCache.instance().getTexture(_curTextureBmp), true, true);
				}
				
				// 更新UI界面
//				if(blUIManager.getInstance().UIPlay() && blUIManager.getInstance().UIPlay()._editorLayer)
//				{
//					blUIManager.getInstance().UIPlay()._editorLayer.updateAvatarTexture(_curTextureBmp);
//				}
				_materialDirty = false;
			}
		}
		
		public function initMesh() : void 
		{
			unitedSubMesh = new SubMesh(unitedSubGeom, this);		// 创建组合的mesh
			subMeshUnion[0] = unitedSubMesh;

			unitedSubGeom.updateVertexData(new Vector.<Number>());
			unitedSubGeom.updateUVData(new Vector.<Number>());
			unitedSubGeom.updateIndexData(new Vector.<uint>());
			unitedSubGeom.updateJointIndexData(new Vector.<Number>());
			unitedSubGeom.updateJointWeightsData(new Vector.<Number>());
		}
		// 添加换装部件(会替换同部位的部件)
		public function addSubModel(subGeoName : String) : void
		{
			var subGeoNames : Vector.<String> = _avatarStore.getSubGeoNames();
			var index : int = subGeoNames.indexOf(subGeoName);
			if(index < 0)
				return;
			
			// 去掉已有的同部位的部件
			var typeName:String = getModelPartType(subGeoName);
			
			for(var ai:int=0; ai<_assemblingCode.length; ai++)
			{
				if( _assemblingCode[ai] )
				{
					var name : String = subGeoNames[ai];
					var type : String = getModelPartType(name);
					if(type == typeName)
						_assemblingCode[ai] = false;
				}
			}
			
			// 标记该部件
			_assemblingCode[index] = true;
		}
		
		// 用初始mesh组装(名字后面为0的为默认部件)
		public function unionZero() : void
		{
			var subGeoNames : Vector.<String> = _avatarStore.getSubGeoNames();
			var ni:int = 0;
			for(ni=0; ni<subGeoNames.length; ni++)
			{
				var subGeoName : String = subGeoNames[ni];
				
				if( subGeoName.charAt(subGeoName.length-1) == "0" )
					_assemblingCode[ni] = true;
				else
					_assemblingCode[ni] = false;
			}
		}
		
		public function unionAll() : void
		{
			var subGeoNames : Vector.<String> = _avatarStore.getSubGeoNames();
			var ni:int = 0;
			for(ni=0; ni<subGeoNames.length; ni++)
			{
				_assemblingCode[ni] = true;
			}
		}
		
		public function excludeModelByTypes(types:Vector.<String>) : void
		{
			var subGeoNames : Vector.<String> = _avatarStore.getSubGeoNames();
			var ni : int = 0;
			var count : int = subGeoNames.length;
			var subModelType : String;
			for(ni=0; ni<count; ni++)
			{
				subModelType = getModelPartType(subGeoNames[ni])
				if(types.indexOf(subModelType) >= 0){
					//需要排除
					_assemblingCode[ni] = false;
				}
			}
			
			
		}
		
		// 组装SubMesh
		public function assembleMesh() : void 
		{
			if(_assemblingCode.length==0)
			{
				visible = false;
				return;
			}
			
			// 检查组装序号是否和当前组装序号相同
			var isSame : Boolean = true;
			for(var ai:int=0; ai<_assemblingCode.length; ai++)
			{
				if( _assemblingCode[ai] != _curAssemblingCode[ai] )
				{
					isSame = false;
					break;
				}
			}
			
			if(isSame)
				return;
			
			// 重新组装模型
			indexDataOffset = 0;			
			if(_avatarStore)
			{
				cleanMesh();
			
				var isNonePart : Boolean = true;
				var subGeoMap : Dictionary = _avatarStore.getSubGeoMap();
				var subGeoNames : Vector.<String> = _avatarStore.getSubGeoNames();
				var ni:int = 0;
				for(ni=0; ni<subGeoNames.length; ni++)
				{
					if(_assemblingCode[ni])
					{
						pushSubGeo( SkinnedSubGeometry(subGeoMap[subGeoNames[ni]].clone()) );
						isNonePart = false;
						//Debug.bltrace("clone = " + subGeoNames[ni]);
					}
					//Debug.bltrace(ni+"="+subGeoNames[ni]);
					_curAssemblingCode[ni] = _assemblingCode[ni];
				}
				
				if(isNonePart)
					visible = false;
				else
					visible = true;
			}
		}
		
		private function cleanMesh() : void 
		{
			unitedSubGeom.vertexData.length = 0;
			unitedSubGeom.UVData.length = 0;
			unitedSubGeom.indexData.length = 0;
			unitedSubGeom.jointIndexData.length = 0;
			unitedSubGeom.jointWeightsData.length = 0;
			
			unitedSubGeom.disposeGpuBuffer();
		}
		
//		public function randomAssembleCode() : void
//		{
////			0 human_male_clothes03=761
////			1 shoubi2=84
////			2 wuqi1=66
////			3 jianjia1=54
////			4 jianjia2=54
////			5 pidai=13
////			6 xigai1=48
////			7 xiabai=9
////			8 xiabai2=30
////			9 toukui=66
//			for(var ci:int=0; ci<_assemblingCode.length; ci++)
//			{
//				_assemblingCode[ci] = false;
//				
//				if(ci == 0)
//					_assemblingCode[ci] = true;
//				if(ci == 1)
//					_assemblingCode[ci] = true;
//				if(ci == 2)
//					_assemblingCode[ci] = Math.random() > 0.5 ? true : false;
//				if(ci == 3)
//					_assemblingCode[ci] = Math.random() > 0.5 ? true : false;
//				if(ci == 4)
//					_assemblingCode[ci] = Math.random() > 0.5 ? true : false;
//				if(ci == 5)
//					_assemblingCode[ci] = Math.random() > 0.5 ? true : false;
//				if(ci == 6)
//					_assemblingCode[ci] = Math.random() > 0.5 ? true : false;
//				if(ci == 7)
//					_assemblingCode[ci] = Math.random() > 0.5 ? true : false;
//				if(ci == 8)
//					_assemblingCode[ci] = Math.random() > 0.5 ? true : false;
//				if(ci == 9)
//					_assemblingCode[ci] = Math.random() > 0.5 ? true : false;
//				
//			}
//		}
		
		protected function pushSubGeo(subGeo : SkinnedSubGeometry) : void {
			
			var len : int = subGeo.indexData.length;
			for(var i : int = 0; i < len; i++){
				subGeo.indexData[i] += indexDataOffset;
				//Debug.bltrace( subGeo.indexData[i] );
			}
			
			unitedSubGeom.updateVertexData(unitedSubGeom.vertexData.concat(subGeo.vertexData));
			unitedSubGeom.updateUVData(unitedSubGeom.UVData.concat(subGeo.UVData));
			unitedSubGeom.updateIndexData(unitedSubGeom.indexData.concat(subGeo.indexData));
			unitedSubGeom.updateJointIndexData(unitedSubGeom.jointIndexData.concat(subGeo.jointIndexData));
			unitedSubGeom.updateJointWeightsData(unitedSubGeom.jointWeightsData.concat(subGeo.jointWeightsData));
			
			indexDataOffset += subGeo.vertexData.length/3;
			
		}
		
		public function setBoneTagMaps(boneTagMap : Dictionary) : void
		{
			_boneTagMap = boneTagMap;
		}
		
		override protected function updateBounds() : void
		{
			_boundsInvalid = true;
			if( _updateBoundingBoxCount++ % 30 != 0 || !animator)	// 每30帧更新一次boundingbox
				return;
			
			var minX : Number = 1;
			var minY : Number = 1;
			var minZ : Number = 1;
			var maxX : Number = -1;
			var maxY : Number = -1;
			var maxZ : Number = -1;
			
			if(animator)
			{
				var skeletonPose : SkeletonPose = SkeletonAnimator(animator).globalPose;
				for(var ji:int = 0; ji<skeletonPose.jointPoses.length; ji++)
				{
					var jPos : Vector3D = skeletonPose.jointPoses[ji].translation;
					if(minX > jPos.x) minX = jPos.x;
					if(minY > jPos.y) minY = jPos.y;
					if(minZ > jPos.z) minZ = jPos.z;
					if(maxX < jPos.x) maxX = jPos.x;
					if(maxY < jPos.y) maxY = jPos.y;
					if(maxZ < jPos.z) maxZ = jPos.z;
				}
				_bounds.fromExtremes(minX, minY, minZ, maxX, maxY, maxZ);
			}
			else
			{
				_bounds.fromExtremes(-10, -10, -10, 10, 10, 10);
			}
			
		}
		
		// 获取渲染SubMesh(组装起来的SubMesh)
		public override function get subMeshes() : Vector.<SubMesh> 
		{
			return subMeshUnion;
		}
		
		// 回收该avatarmesh
		public function recycle() : void
		{
			_avatarStore.recycle(this);
		}
		
		override public function dispose() : void	// avatarmesh默认只是做回收
		{
			recycle();
		}
		
		public function realDispose():void
		{
			_avatarStore = null;
			unitedSubGeom.dispose();
			if(_curTextureBmp)
				_curTextureBmp.dispose();
			
			for each(var tag:BoneTag in _boneTagMap)
			{
				tag.dispose();
			}
			
			super.dispose();
		}
		
	}
	
}
