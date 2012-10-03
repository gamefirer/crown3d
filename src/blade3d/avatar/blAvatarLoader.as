/**
 *	Avatar文件(.bla)加载器 
 */
package blade3d.avatar
{
//	import away3d.animators.data.SkeletonKeyframeAnimationSequence;
	import away3d.debug.Debug;
	import away3d.entities.Mesh;
	import away3d.events.AssetEvent;
	import away3d.events.ParserEvent;
	import away3d.materials.utils.DefaultMaterialManager;
	
	import blade3d.resource.BlBinaryResource;
	import blade3d.resource.BlResource;
	import blade3d.resource.BlResourceConfig;
	import blade3d.resource.BlResourceManager;
	import blade3d.resource.BlStringResource;
	
	import flash.display.BitmapData;
	import flash.events.AsyncErrorEvent;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	public class blAvatarLoader
	{
		public static var _useAvatarParser2 : Boolean = true;		// 是否使用binary的Avatar文件格式
		
		private var _avatarStore : blAvatarStore;
		
		private var _avatar_dir : String;
		private var _avatarName : String;
		private var _targetMesh : Mesh;
		private var _callBack : Function;
		private var _meshLoadCount : int = 0;		// loading 计数
		private var _textureBmp : BitmapData;
		
		//改为静态成员。因为所有的职业和性别都可以共用该贴图了。
		private static var _clothTextureNames : Vector.<String> = new Vector.<String>;
		private static var _clothTextureMap : Dictionary = new Dictionary;			// 换装用贴图
		
		private var _avatarParser : AvatarParser;		
		private var _avatarMeshParser : Vector.<AvatarMeshParser> = new Vector.<AvatarMeshParser>;
		
		private var _avatarParser2 : AvatarParser2;
		private var _avatarMeshParser2 : Vector.<AvatarMeshParser2> = new Vector.<AvatarMeshParser2>;
		
		private var _extraBoneTagString : String;			// 外部骨骼绑定点文件
		private var _extraBoneTagBa : ByteArray;
		
		private var _extraSequncesStrings : Vector.<String> = new Vector.<String>;		// 外部动画文件
		private var _extraSequncesBa : Vector.<ByteArray> = new Vector.<ByteArray>;
		
		private var _extraMeshStrings : Vector.<String> = new Vector.<String>;			// 外部模型文件
		//拷贝所有的贴图数据
		public static function copyAllChothTexture() : Dictionary
		{
			var dic:Dictionary = new Dictionary();
			var key:String;
			for(key in _clothTextureMap){
				dic[key] = _clothTextureMap[key];
			}
			return dic;
		}
		
		public function blAvatarLoader(avatarStore:blAvatarStore)
		{
			_avatarStore = avatarStore;
			_avatarName = _avatarStore.name;
			_avatar_dir = BlResourceConfig.avatar_dir + _avatarName + "/";
			
		}
		
		public function get textureBmp() : BitmapData {return _textureBmp;}
		public function startParse(callBack : Function) : void 
		{
			this._callBack = callBack;
			
			loadAvatar();			
		}
		
		private function loadAvatar() : void 
		{
			// 加载贴图配置文件
			_meshLoadCount++;	// call onAvatarTextureConfig
			var texConfigUrl : String = _avatar_dir + "texture.txt";
			BlResourceManager.instance().findStringResource(texConfigUrl).asycLoad(onAvatarTextureConfig);
			
			// 加载外部骨骼描述文件
			_meshLoadCount++;	// call onAvatarBoneTagData
			var BoneTagUrl : String = _avatar_dir + "avatar" + BlResourceConfig.FILE_TYPE_AVATAR_TAG;
			if(_useAvatarParser2)
				BlResourceManager.instance().findBinaryResource(BoneTagUrl).asycLoad(onAvatarBoneTagData2);
			else
				BlResourceManager.instance().findStringResource(BoneTagUrl).asycLoad(onAvatarBoneTagData);
			
		}
		
		private function onAvatarBoneTagData2(res:BlResource) : void
		{
			_extraBoneTagBa = res.res;
			
			loadAvatarMeshConfig();
			
			onMeshLoaded(); // on call onAvatarBoneTagData2
		}
			
		private function onAvatarBoneTagData(res:BlResource) : void
		{
			_extraBoneTagString = res.res;
			
			loadAvatarMeshConfig();
			
			onMeshLoaded(); // on call onAvatarBoneTagData
		}
		
		private function loadAvatarMeshConfig() : void
		{
			// 加载外部模型描述文件
			_meshLoadCount++;	// call onAvatarMeshConfig
			var meshConfigUrl : String = _avatar_dir + "mesh.txt";
			BlResourceManager.instance().findStringResource(meshConfigUrl).asycLoad(onAvatarMeshConfig);
		}
		
		private function onAvatarMeshConfig(res:BlResource) : void
		{
			var meshConfig_str : String = res.res; 
			if(meshConfig_str)
			{
				// 加载外面描述的模型名
				var strArray : Array = meshConfig_str.split(/\s/);
				var filterStrArray : Array = strArray.filter(function(element:*, index:int, arr:Array):Boolean {
					return (element.length != 0 && element.charAt(0) != '#'); });
				
				var meshFileName : String;				
				for(var i:int=0; i<filterStrArray.length; i++)
				{
					meshFileName = filterStrArray[i];
					_extraMeshStrings.push(meshFileName);					
				}
			}
			
			// 加载外部动画描述文件
			_meshLoadCount++;	// call onAvatarAnimationConfig
			var aniConfigUrl : String = _avatar_dir + "animation.txt";
			BlResourceManager.instance().findStringResource(aniConfigUrl).asycLoad(onAvatarAnimationConfig);
			
			onMeshLoaded(); // on call onAvatarMeshConfig
		}
		
		private function loadAvatarData() : void
		{
			// 加载avatar文件
			_meshLoadCount++;	// call onAvatarDataReady2
			
			var avatarFileName : String = _avatar_dir + "avatar" + BlResourceConfig.FILE_TYPE_AVATAR;
			if(_useAvatarParser2)
				BlResourceManager.instance().findBinaryResource(avatarFileName).asycLoad(onAvatarDataReady2);
			else
				BlResourceManager.instance().findStringResource(avatarFileName).asycLoad(onAvatarDataReady);
		}
		
		private function onAvatarDataReady2(res:BlResource) : void
		{
			var avatar_ba : ByteArray = res.res;
			if(!avatar_ba)
				throw new Error("no avatar.bla");
			// 拼接上外部的动画文件
			for(var si:int=0; si<_extraSequncesBa.length; si++)
			{			
				avatar_ba.position = avatar_ba.length;
				avatar_ba.writeBytes(_extraSequncesBa[si]);				
			}
			// 拼接上外部骨骼绑定点文件
			if(_extraBoneTagBa)
			{
				avatar_ba.position = avatar_ba.length;
				avatar_ba.writeBytes(_extraBoneTagBa);
			}
			
			// 解析avatar数据
			_avatarParser2 = new AvatarParser2(_avatar_dir);
			_meshLoadCount++;	// call onAvatarDataParseReady2
			_avatarParser2.addEventListener(ParserEvent.PARSE_COMPLETE, onAvatarDataParseReady2);
			avatar_ba.position = 0;
			_avatarParser2.parseAsync(avatar_ba);			// 解析
			
			onMeshLoaded(); // on call onAvatarDataReady2
		}
		
		private function onAvatarDataParseReady2(evt : ParserEvent) : void 
		{
			if( !_avatarParser2 || evt.message != _avatarParser2.url )
				return;
			
			_avatarParser2.removeEventListener(ParserEvent.PARSE_COMPLETE, onAvatarDataParseReady2);
			// 解析贴图
			_meshLoadCount++;	// call onTextureLoaded
			var textureFullFileName :String = _avatar_dir + "avatar" + BlResourceConfig.FILE_TYPE_TEXTURE;
			BlResourceManager.instance().findImageResource(textureFullFileName).asycLoad(onTextureLoaded);
			// 解析mesh
			var mi:int;
			var meshName:String;
			// 合并外部模型名
			_avatarParser2._meshNames.length = 0;				// bla内模型名删除
			for(mi=0; mi<_extraMeshStrings.length; mi++)
			{
				if(_avatarParser2._meshNames.indexOf(_extraMeshStrings[mi]) == -1)
					_avatarParser2._meshNames.push(_extraMeshStrings[mi]);
			}
			// 加载模型
			_avatarMeshParser2.length = _avatarParser2._meshNames.length;
			for(mi=0; mi<_avatarParser2._meshNames.length; mi++)
			{
				meshName = _avatarParser2._meshNames[mi];
				meshName = _avatar_dir + meshName + BlResourceConfig.FILE_TYPE_AVATAR_MESH;
				
				_meshLoadCount++;	// call onAvatarMeshReady
				var res : BlBinaryResource = BlResourceManager.instance().findBinaryResource(meshName);
				res.userObject = mi;
				res.asycLoad(onAvatarMeshReady2);
			}
			
			onMeshLoaded();	// on call onAvatarDataParseReady2
		}
		
		private function onAvatarDataReady(res:BlResource) : void 
		{
			var avatar_str : String = res.res;
			// 拼接上外部的动画文件
			for(var si:int=0; si<_extraSequncesStrings.length; si++)
			{
				avatar_str = avatar_str.concat( _extraSequncesStrings[si] );
			}
			
			// 拼接上外部的骨骼绑定点文件
			if(_extraBoneTagString)
				avatar_str = avatar_str.concat(_extraBoneTagString);
			
			// 解析avatar文本
			_avatarParser = new AvatarParser(_avatar_dir);
			_meshLoadCount++;	// call onAvatarDataParseReady
			_avatarParser.addEventListener(ParserEvent.PARSE_COMPLETE, onAvatarDataParseReady);
			_avatarParser.parseAsync(avatar_str, 5);			// 解析
			
			onMeshLoaded(); // on call onAvatarDataReady
		}
		
		// avatar数据解析完成
		private function onAvatarDataParseReady(evt : ParserEvent) : void 
		{
			if( !_avatarParser || evt.message != _avatarParser.url )
				return;
			
			_avatarParser.removeEventListener(ParserEvent.PARSE_COMPLETE, onAvatarDataParseReady);
			// 解析贴图
			_meshLoadCount++;	// call onTextureLoaded
			var textureFullFileName :String = _avatar_dir + "avatar" + BlResourceConfig.FILE_TYPE_TEXTURE;
			BlResourceManager.instance().findImageResource(textureFullFileName).asycLoad(onTextureLoaded);
			// 解析mesh
			var mi:int;
			var meshName:String;
			// 合并外部模型名
			_avatarParser._meshNames.length = 0;				// bla内的模型名删除
			for(mi=0; mi<_extraMeshStrings.length; mi++)
			{
				if(_avatarParser._meshNames.indexOf(_extraMeshStrings[mi]) == -1)
					_avatarParser._meshNames.push(_extraMeshStrings[mi]);
			}
			// 加载模型
			_avatarMeshParser.length = _avatarParser._meshNames.length;
			for(mi=0; mi<_avatarParser._meshNames.length; mi++)
			{
				meshName = _avatarParser._meshNames[mi];
				meshName = _avatar_dir + meshName + BlResourceConfig.FILE_TYPE_AVATAR_MESH;
				
				_meshLoadCount++;	// call onAvatarMeshReady
				var res : BlStringResource = BlResourceManager.instance().findStringResource(meshName);
				res.userObject = mi;
				res.asycLoad(onAvatarMeshReady);
			}
			
			onMeshLoaded();	// on call onAvatarDataParseReady
		}
		
		private function onAvatarMeshReady2(res:BlResource) : void
		{
			var tag : int = res.userObject;
			var mesh_ba : ByteArray = res.res;
			var url:String = _avatar_dir + _avatarParser2._meshNames[tag] + BlResourceConfig.FILE_TYPE_AVATAR_MESH;
			if(mesh_ba)
			{
				_avatarMeshParser2[tag] = new AvatarMeshParser2(url);
				_meshLoadCount++;	// call onMeshDataParseReady2
				_avatarMeshParser2[tag].addEventListener(ParserEvent.PARSE_COMPLETE, onMeshDataParseReady2);
				_avatarMeshParser2[tag].parseAsync(mesh_ba);
			}
			else
				throw new Error("load "+url+" failed");
			
			onMeshLoaded(); 	// call onAvatarMeshReady2
		}
		
		private function onMeshDataParseReady2(evt : ParserEvent) : void 
		{
			// 解析mesh完毕
			var isThisParser:Boolean = false;
			for(var i:int=0; i<	_avatarMeshParser2.length; i++)
			{
				if( _avatarMeshParser2[i] && _avatarMeshParser2[i].url == evt.message )
				{
					isThisParser = true;
					_avatarMeshParser2[i].removeEventListener(ParserEvent.PARSE_COMPLETE, onMeshDataParseReady2);
					break;
				}
			}
			if(isThisParser)
				onMeshLoaded();		// on call onMeshDataParseReady
		}
		
		private function onAvatarMeshReady(res:BlResource) : void
		{
			var tag : int = res.userObject;
			var mesh_str : String = res.res;
			if(mesh_str)
			{
				var url:String = _avatar_dir + _avatarParser._meshNames[tag] + BlResourceConfig.FILE_TYPE_AVATAR_MESH;
				_avatarMeshParser[tag] = new AvatarMeshParser(url);
				_meshLoadCount++;	// call onMeshDataParseReady
				_avatarMeshParser[tag].addEventListener(ParserEvent.PARSE_COMPLETE, onMeshDataParseReady);
				_avatarMeshParser[tag].parseAsync(mesh_str, 5);
			}
			
			onMeshLoaded(); 	// call onAvatarMeshReady
		}
		
		private function onMeshDataParseReady(evt : ParserEvent) : void 
		{
			// 解析mesh完毕
			var isThisParser:Boolean = false;
			for(var i:int=0; i<	_avatarMeshParser.length; i++)
			{
				if( _avatarMeshParser[i] && _avatarMeshParser[i].url == evt.message )
				{
					isThisParser = true;
					_avatarMeshParser[i].removeEventListener(ParserEvent.PARSE_COMPLETE, onMeshDataParseReady);
					break;
				}
			}
			if(isThisParser)
				onMeshLoaded();		// on call onMeshDataParseReady
		}
		
		private function onTextureLoaded(res:BlResource) : void
		{	// 贴图加载完毕
			var bm : BitmapData = res.res;
			if(bm)
				_textureBmp = bm;
			else
				_textureBmp = DefaultMaterialManager.getDefaultBitmapData();
			onMeshLoaded();		// on call onTextureLoaded
		}
		
		private function onMeshLoaded() : void {
			_meshLoadCount--;
			if( _meshLoadCount == 0 )
			{	// 全部加载完成
				var newAvatarStore : blAvatarStore = generateAvatarStore();		// 生成一个AvatarStore
				_callBack();
				
				// 释放资源
				_avatarParser = null;				
				_avatarMeshParser.length = 0;
				_avatarParser2 = null;
				_avatarMeshParser2.length = 0;
			}			
		}
		
		private function generateAvatarStore() : blAvatarStore
		{
//			var newAvatarStore : blAvatarStore = new blAvatarStore(_avatarName);
			_avatarStore
			
			var pi:int;
			
			if(_useAvatarParser2)
			{
				// 添加subGeometry
				for(pi=0; pi<_avatarMeshParser2.length; pi++)
				{
					_avatarStore.addSubGeo(_avatarMeshParser2[pi].subGeometry, _avatarMeshParser2[pi].subGeometryName);
				}
				// 添加skeleton
				_avatarStore.addSkeleton( _avatarParser2.skeleton );
				// 添加sequence
				for(pi=0; pi<_avatarParser2._sequences.length; pi++)
				{
					_avatarStore.addSequence( _avatarParser2._sequences[pi] );
				}
				// 添加贴图
				_avatarStore.setTexture(_textureBmp);
				// 添加骨骼绑定点
				_avatarStore.addBoneTag( _avatarParser2._boneTagsName, _avatarParser2._boneTagParentIndex, _avatarParser2._boneTagMat );
			}
			else
			{
				// 添加subGeometry
				for(pi=0; pi<_avatarMeshParser.length; pi++)
				{
					if(_avatarMeshParser[pi])
						_avatarStore.addSubGeo(_avatarMeshParser[pi].subGeometry, _avatarMeshParser[pi].subGeometryName);
				}
				// 添加skeleton
				_avatarStore.addSkeleton( _avatarParser.skeleton );
				// 添加sequence
				for(pi=0; pi<_avatarParser._sequences.length; pi++)
				{
					_avatarStore.addSequence( _avatarParser._sequences[pi] );
				}
				// 添加贴图
				_avatarStore.setTexture(_textureBmp);
				// 添加骨骼绑定点
				_avatarStore.addBoneTag( _avatarParser._boneTagsName, _avatarParser._boneTagParentIndex, _avatarParser._boneTagMat );
				
			}
			
			// 添加换装贴图
			_avatarStore.setSubTextureMap(_clothTextureMap);
			// 子部件排序
			_avatarStore.sortSubGeo();
			
			return _avatarStore;
		}
		
		private function onAvatarTextureConfig(res:BlResource) : void 
		{
			var texConfig_str : String = res.res;
			if(texConfig_str)
			{	
				// 加载所有Effect特效文件
//				var strArray : Array = texConfig_str.split(/\s/);
//				var texfileName : String;
//				var list:Array;
//				for(var i:int=0; i<strArray.length; i++)
//				{
//					texfileName = strArray[i];
//					if(texfileName.length == 0)
//						continue;
//					if( texfileName.charAt(0) == '0')
//						continue;
//					
//					_clothTextureNames.push(texfileName);
//					list = _path.split("/");
//					list.length -= 2;
////					texfileName = _path + "/" + texfileName + blStrings.FILE_TYPE_TEXTURE;// ".blt";
//					texfileName = list.join("/") + "/equipment/equipment/" + texfileName + blStrings.FILE_TYPE_TEXTURE;// ".blt";
//					
//					_meshLoadCount++;	// call onClothTextureLoaded
//					blAssetsLoader.getTextureFromURL(texfileName, _clothTextureNames.length-1, onClothTextureLoaded);			
//					
//				}

			}
			
			onMeshLoaded();		// on call onAvatarTextureConfig
		}
		/*
		
		private function onClothTextureLoaded(tag : int, bm : BitmapData) : void
		{
			if(bm)
			{
				_clothTextureMap[_clothTextureNames[tag]] = bm;
			}
			
			onMeshLoaded();		// on call onClothTextureLoaded
		}
		*/
		private var _extraSequanceCount:int = 0;
		private function onAvatarAnimationConfig(res:BlResource) : void
		{
			var aniConfig_str : String = res.res;
			if(aniConfig_str)
			{
				// 加载所有动画
				var strArray : Array = aniConfig_str.split(/\s/);
				var filterStrArray : Array = strArray.filter(function(element:*, index:int, arr:Array):Boolean {
								return (element.length != 0 && element.charAt(0) != '#'); });
				
				var aniFileName : String;
				_extraSequanceCount += filterStrArray.length;
				for(var i:int=0; i<filterStrArray.length; i++)
				{
					aniFileName = filterStrArray[i];
					aniFileName = _avatar_dir + aniFileName + BlResourceConfig.FILE_TYPE_AVATAR_SEQ;
					
					_meshLoadCount++;	// call onAnimationLoaded
					if(_useAvatarParser2)
						BlResourceManager.instance().findBinaryResource(aniFileName).asycLoad(onAnimationLoaded2);
					else
						BlResourceManager.instance().findStringResource(aniFileName).asycLoad(onAnimationLoaded);
					
				}
			}
			else
			{	// 无外部动画文件
				loadAvatarData();
			}
			
			onMeshLoaded();		// on call onAvatarAnimationConfig
		}
		
		private function onAnimationLoaded2(res:BlResource) : void
		{
			var seqBa : ByteArray = res.res;
			if(seqBa)
			{
				_extraSequncesBa.push(seqBa);
			}
			
			_extraSequanceCount--;
			if(_extraSequanceCount == 0)
			{	// 外部动画文件加载完毕
				loadAvatarData();
			}
			
			onMeshLoaded();		// on call onAnimationLoaded
			
		}
		
		private function onAnimationLoaded(res:BlResource) : void
		{
			var seqString : String = res.res;
			if(seqString)
			{
				_extraSequncesStrings.push(seqString);
			}
			
			_extraSequanceCount--;
			if(_extraSequanceCount == 0)
			{	// 外部动画文件加载完毕
				loadAvatarData();
			}
			
			onMeshLoaded();		// on call onAnimationLoaded
		}
		
	}
}