package blade3d.scene
{
	import away3d.core.math.Quaternion;
	import away3d.core.partition.Partition3D;
	import away3d.core.partition.QuadTree;
	import away3d.debug.Debug;
	
	import blade3d.resource.BlResource;
	import blade3d.resource.BlResourceConfig;
	import blade3d.resource.BlResourceManager;
	import blade3d.resource.BlStringResource;
	import blade3d.scene.loadvo.CollideVO;
	import blade3d.scene.loadvo.LightVO;
	import blade3d.scene.loadvo.MeshVO;
	import blade3d.scene.loadvo.TerrainCollideVO;
	import blade3d.utils.BlStringUtils;
	
	import flash.geom.Vector3D;
	
	import org.aswing.AbstractButton;
	import org.poly2tri.Point;

	public class BlSceneParser
	{
		private var _scene : BlScene;
		private var _callback : Function;
		private var _pathName : String;				// 场景文件目录
		public var texturePathName : String = "";			// 贴图库目录
		public var terrainTexturePathName : String = "";	// 地表贴图库目录
		
		private var _xml : XML;
		
		// 加载数据
		public var meshList : Vector.<MeshVO> = new Vector.<MeshVO>;		// 静态模型
		public var terrainCollide : TerrainCollideVO;		// 地形碰撞
		public var collide : CollideVO;					// 阻挡碰撞
		public var lightList : Vector.<LightVO> = new Vector.<LightVO>;	// 投影灯
		
		public function get xml() : XML {return _xml;}
		
		public function BlSceneParser(scene:BlScene)
		{
			_scene = scene;
		}
		
		public function parse(callback:Function):void
		{
			_callback = callback;
			
			// 读入map.xml
			_pathName = BlResourceConfig.scene_dir + _scene.name + "/";
			var mapRes : BlStringResource = BlResourceManager.instance().findStringResource(_pathName + "map.xml");
			if(mapRes)
				mapRes.asycLoad(onSceneStringReady);
			
		}
		
		private function onSceneStringReady(mapRes : BlResource) : void
		{
			var xmlStr : String = BlStringResource(mapRes).str;
			
			if(!xmlStr)
			{
				Debug.trace("load scene "+_scene.name + " xml failed");
				_callback.call();
				return;
			}
			
			try
			{
				_xml = new XML(xmlStr);
			}
			catch(e:Error)
			{
				Debug.trace("scene xml error")
				_callback.call();		// 加载失败
				return;
			}
			if(_xml)
			{
				parseSceneXml();	
			}
			
			_callback();
		}
		
		private function parseSceneXml() : void
		{
			var top_xml : XML;
			var meshList : XMLList;
			var terrainList : XMLList;
			var wallList : XMLList;
			var holeList : XMLList;
			var lightList : XMLList;
			
			meshList = _xml.mesh;
			terrainList = _xml.terrain;
			wallList = _xml.wall;
			holeList = _xml.hole;
			lightList = _xml.light;
			
			var parentPath : String = _pathName.substr(0, _pathName.lastIndexOf("/"));
			parentPath = parentPath.substr(0, parentPath.lastIndexOf("/"));
			
			// 读取贴图库目录
			var texturePathXML : XML = _xml.texturepath[0];
			if(texturePathXML)
			{
				var pathAttr : String =  texturePathXML.@path.toString();
				if(pathAttr.length == 0)
				{
					texturePathName = _pathName;
				}
				else
				{	// 有贴图库目录
					texturePathName = parentPath + "/" + pathAttr + "/";
				}
			}
			else
				texturePathName = _pathName;
			
			// 读取地表贴图库目录
			var terrainTexturePathXML : XML = _xml.terraintexturepath[0];
			if(terrainTexturePathXML)
			{
				var pathAttr2 : String = terrainTexturePathXML.@path.toString();
				terrainTexturePathName = parentPath + "/" + pathAttr2 + "/";
			}
			else
				terrainTexturePathName = _pathName;
			
			// 场景范围的载入
			var sceneboundXML : XML = _xml.scenebound[0];
			parseSceneBound(sceneboundXML);
			// 场景模型的载入
			for each(top_xml in meshList) 
			{
				parseSceneMesh(top_xml);				
			}
			// 地形的载入
			for each(top_xml in terrainList)
			{
				parseSceneTerrain(top_xml);				
			}
			// 物理系统
			collide = new CollideVO;
			// 墙体的载入
			for each(top_xml in wallList)
			{
				parseSceneWall(top_xml);
			}
			// 洞的载入
			for each(top_xml in holeList)
			{
				parseSceneHole(top_xml);
			}
			// 世界范围导入
			var worldXML : XML = _xml.world[0];
			parseSceneWorld(worldXML);
			// 场景灯的载入
			for each(top_xml in lightList)
			{
				parseSceneLight(top_xml);
			}
			
		}
		
		// 解析场景范围
		private  function parseSceneBound(xml : XML) : void
		{
			var minX : Number = 0;
			var minZ : Number = 0;
			var maxX : Number = 0;
			var maxZ : Number = 0;
			
			if(!xml)
			{	// 无场景范围设置
				Debug.log("no scene bound");
				return;
			}
			else
			{
				minX = Number(xml.@minX.toString());
				minZ = Number(xml.@minY.toString());
				maxX = Number(xml.@maxX.toString());
				maxZ = Number(xml.@maxY.toString());
			}
			
			var max : Number = 0;
			max = Math.max(Math.abs(maxX-minX), max);
			max = Math.max(Math.abs(maxZ-minZ), max);
			
			var centerX : Number = Math.abs(maxX-minX)/2+minX;
			var centerZ : Number = Math.abs(maxZ-minZ)/2+minZ;
			
			var partition3d : Partition3D;		// 创建的划分方式
			if(max < 7500)
				partition3d = new QuadTree(3, 7500, centerX, centerZ);
			else if(max < 15000)
				partition3d = new QuadTree(4, 15000, centerX, centerZ);
			else if(max < 30000)
				partition3d = new QuadTree(5, 30000, centerX, centerZ);
			else
				partition3d = new QuadTree(6, 60000, centerX, centerZ);
			
			_scene.partition = partition3d;
			
			
		}
		
		private function parseSceneLight(xml : XML) : void 
		{
			// 读取场景灯的属性
			if( xml.hasOwnProperty('@name')
				&& xml.hasOwnProperty('@size')
				&& xml.hasOwnProperty('@tex')
				&& xml.hasOwnProperty('@x')
				&& xml.hasOwnProperty('@z')
				&& xml.hasOwnProperty('@rot')
				&& xml.hasOwnProperty('@r')
				&& xml.hasOwnProperty('@g')
				&& xml.hasOwnProperty('@b')
			)
			{
				var lightVO : LightVO = new LightVO;
				lightVO.lightName = xml.@name.toString();					// 名字
				lightVO.lightPosx = Number(xml.@x.toString());				// 位置
				lightVO.lightPosz = Number(xml.@z.toString());
				lightVO.lightSize = Number(xml.@size.toString());			// 大小
				lightVO.lightRot = Number(xml.@rot.toString());				// 旋转
				lightVO.lightR = Number(xml.@r.toString()) / 255;			// 颜色
				lightVO.lightG = Number(xml.@g.toString()) / 255;
				lightVO.lightB = Number(xml.@b.toString()) / 255;
				lightVO.lightIntensity = Number(xml.@bright.toString());	// 光照强度
				var texName : String = xml.@tex.toString();
				lightVO.texName = texturePathName + texName;
				
				lightList.push(lightVO);
			}
		}
		
		private function parseSceneWorld(xml : XML) : void
		{
			var svrMapMinX:int = 10000;
			var svrMapMaxY:int = -10000;
			if(xml)
			{
				var top_xml : XML;
				var worldPointXmlList : XMLList = xml.point;
				for each(top_xml in worldPointXmlList)
				{
					if(top_xml.hasOwnProperty('@x')
						&& top_xml.hasOwnProperty('@z') 	)
					{
						var worldPointX : Number = Number(top_xml.@x.toString());
						var worldPointY : Number = Number(top_xml.@z.toString());
						collide.worldPoints.push(new Point(worldPointX, worldPointY));
						
						if(worldPointX < svrMapMinX) svrMapMinX = worldPointX;
						if(worldPointY > svrMapMaxY) svrMapMaxY = worldPointY;
					}
				}
				
				// 计算服务端物体地图的左上角坐标(此算法需和服务端一致)
				var cellLength : int = 500;
				svrMapMinX = Math.floor((Math.floor(svrMapMinX) - cellLength) / cellLength) * cellLength;
				svrMapMaxY = -(Math.floor((Math.floor(svrMapMaxY) + cellLength) / cellLength)+1) * cellLength;
			}
		}
		
		private function parseSceneWall(xml : XML) : void 
		{
			// 读取墙体
			var wallPointXmlList : XMLList = xml.point;
			var wallPoints : Vector.<Point> = new Vector.<Point>;
			for each(var wallPoint_xml : XML in wallPointXmlList)
			{
				if(wallPoint_xml.hasOwnProperty('@x')
					&& wallPoint_xml.hasOwnProperty('@z')
				)
				{
					var wallPointX : Number = Number(wallPoint_xml.@x.toString());
					var wallPointY : Number = Number(wallPoint_xml.@z.toString());
					wallPoints.push(new Point(wallPointX, wallPointY));
				}
			}
			if(wallPoints.length >= 3)
				collide.wallPointsList.push(wallPoints);
		}

		private function parseSceneHole(xml : XML) : void
		{
			// 读取洞
			var holePointXmlList : XMLList = xml.point;
			var holePoints : Vector.<Point> = new Vector.<Point>;
			for each(var holePoint_xml : XML in holePointXmlList)
			{
				if(holePoint_xml.hasOwnProperty('@x')
					&& holePoint_xml.hasOwnProperty('@z')
				)
				{
					var holePointX : Number = Number(holePoint_xml.@x.toString());
					var holePointY : Number = Number(holePoint_xml.@z.toString());
					holePoints.push(new Point(holePointX, holePointY));
				}
			}
			if(holePoints.length >= 3)
				collide.holePointsList.push(holePoints);
		}
		
		private function parseSceneTerrain(xml : XML) : void
		{
			if( xml.hasOwnProperty('@name') == false )
				return;
			
			terrainCollide = new TerrainCollideVO;
			var terrainMeshName : String = xml.@name.toString();
			terrainCollide.path = _pathName + terrainMeshName + ".3ds";
		}
		
		private function parseSceneMesh(xml : XML) : void
		{
			// 读取mesh的属性
			if( xml.hasOwnProperty('@name') == false )
				return;
			
			var meshVO : MeshVO = new MeshVO;
			
			var meshName : String = xml.@name.toString();
			var meshFileName : String = _pathName + meshName + ".3ds";
			
			meshVO.path = meshFileName;
			
			meshVO.hasVertexColor = (xml.@vertexColor.toString() == "true");
			
			var xmlPos :XML = xml.pos[0];
			var meshPos : Vector3D = new Vector3D;
			meshPos.x = Number(xmlPos.@x.toString());
			meshPos.y = Number(xmlPos.@y.toString());
			meshPos.z = Number(xmlPos.@z.toString());
			meshVO.pos = meshPos;
			
			var xmlRot : XML = xml.rot[0];
			var quat : Quaternion = new Quaternion( Number(xmlRot.@rx.toString()),
				Number(xmlRot.@ry.toString()),
				Number(xmlRot.@rz.toString()),
				Number(xmlRot.@rw.toString()) );
			meshVO.rot = quat;
			
			var xmlScale : XML = xml.scale[0];
			if(xmlScale)
			{
				var scale : Number = Number(xmlScale.@s.toString());
				meshVO.scale = new Vector3D(scale, scale, scale);
			}
			else
				meshVO.scale = new Vector3D(1, 1, 1);
			// 材质
			var xmlMat : XML = xml.mat[0];
			
			var matStr : String = xmlMat.@blend.toString();
			meshVO.isBlend = (matStr == "true");
				
			matStr = xmlMat.@twoSide.toString();
			meshVO.IsTwoSide = (matStr == "true");
			
			meshVO.zBias = Number(xmlMat.@layer.toString());
			
			var isShadow : String = xmlMat.@shadow.toString();
			meshVO.isCastShadow = (isShadow == "true");
			
			var isLight : String = xmlMat.@light.toString();
			meshVO.isRecvTexLight = !(isLight == "false");
			
			var zWriteStr : String =  xmlMat.@zwrite.toString();
			var zTestStr : String = xmlMat.@ztest.toString();
			if( zWriteStr && zTestStr )
			{
				meshVO.writeZ = (zWriteStr == "true");
				meshVO.testZ = (zTestStr == "true");
			}
			
			// 是否为地表纹理
			var xmlTerrainTex : XML = xml.terraintex[0];
			if(xmlTerrainTex)
			{
				meshVO.isTerrainTexture = true;
				meshVO.uvScale = Number(xmlTerrainTex.@uvscale.toString());
				
				meshVO.mixTextureName =terrainTexturePathName + xmlTerrainTex.@tex.toString() + BlStringUtils.texExtName;
				
				meshVO.terrainTextureName1 =terrainTexturePathName + xmlTerrainTex.@tex1.toString() + BlStringUtils.texExtName;
				meshVO.terrainTextureName2 =terrainTexturePathName + xmlTerrainTex.@tex2.toString() + BlStringUtils.texExtName;
				meshVO.terrainTextureName3 =terrainTexturePathName + xmlTerrainTex.@tex3.toString() + BlStringUtils.texExtName;
				meshVO.terrainTextureName4 =terrainTexturePathName + xmlTerrainTex.@tex4.toString() + BlStringUtils.texExtName;
			}
			
			meshList.push(meshVO);
		}
		
		
	}
}
