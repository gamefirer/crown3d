/**
 *	场景加载器 
 */
package blade3d.scene
{
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.SubGeometry;
	import away3d.debug.Debug;
	import away3d.entities.Entity;
	import away3d.entities.Mesh;
	import away3d.entities.Sprite3D;
	import away3d.materials.SceneLightMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.materials.methods.FilteredShadowMapMethod;
	import away3d.materials.methods.NearShadowMapMethod;
	import away3d.materials.methods.SceneLightMapMethod;
	import away3d.materials.methods.TerrainDiffuseMethod2;
	import away3d.materials.utils.DefaultMaterialManager;
	import away3d.primitives.WireframeLines;
	import away3d.primitives.WireframeTriangles;
	import away3d.textures.BitmapTexture;
	import away3d.textures.BitmapTextureCache;
	
	import blade3d.BlConfiguration;
	import blade3d.loader.Bl3DSParser;
	import blade3d.resource.BlImageResource;
	import blade3d.resource.BlModelResource;
	import blade3d.resource.BlResource;
	import blade3d.resource.BlResourceManager;
	import blade3d.scene.loadvo.CollideVO;
	import blade3d.scene.loadvo.LightVO;
	import blade3d.scene.loadvo.MeshVO;
	import blade3d.scene.loadvo.TerrainCollideVO;
	import blade3d.scene.terrain.blTerrainMesh;
	import blade3d.utils.BlStringUtils;
	
	import flash.display.BlendMode;
	import flash.display3D.Context3DCompareMode;
	import flash.events.TimerEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import org.poly2tri.Edge;
	import org.poly2tri.Point;
	import org.poly2tri.Triangle;
	import org.poly2tri.VisiblePolygon;
	import org.poly2tri.utils.PathFind;
	import org.poly2tri.utils.SpatialMesh;
	import org.rje.glaze.engine.math.Vector2D;
	
	import pl.bmnet.gpcas.geometry.Poly;
	import pl.bmnet.gpcas.geometry.PolyDefault;

	public class BlSceneLoader
	{
		private var _scene : BlScene;
		private var _parser : BlSceneParser;
		
		private var _callback : Function;
		
		public var terrainCollideMesh : Mesh;				// 地面碰撞模型
		private var _terrainCollision : blTerrainMesh;		// 地形的碰撞对象
		
		// 阻挡碰撞
		private var _islands : Vector.<VisiblePolygon> = new Vector.<VisiblePolygon>;
		private var _blocks : Vector.<VisiblePolygon> = new Vector.<VisiblePolygon>;
		private var _holes : Vector.<VisiblePolygon> = new Vector.<VisiblePolygon>;
		private var _visiblePolygon : VisiblePolygon = new VisiblePolygon;
		// 物理范围相关
		private var _worldBoundPoints : Vector.<Point> = new Vector.<Point>;
		private var _worldPolygon : VisiblePolygon = new VisiblePolygon;

		public var _navNode : ObjectContainer3D;			// 导航网格的node, just for display
		private var _pathFinder : PathFind;				// 寻路器
		public var _pathSegmentMesh : WireframeLines;		// 显示用路径线段
		
		private var _meshNode : ObjectContainer3D;			// 静态模型
		private var _texLightNode : ObjectContainer3D;		// 贴图灯
		///////////////////////////////////////////////////////////////////////////////////////////
		// 加载相关
		private var _isStart : Boolean = false;				// 是否开始加载
		private var _loadTimer : Timer;
		private var _loadCount : int = 0;
		
		private var _meshVO : MeshVO;
		private var _terrrainCollideVO : TerrainCollideVO;
		private var _collideVO :CollideVO;
		private var _lightVO : LightVO;
		
		private var _meshLoading : Boolean = false;			// 加载mesh中
		private var _lightLoading : Boolean = false;			// 加载投影灯中
		private var _isTerrainCollisionLoaded : Boolean = true;	// 是否有地面碰撞
		
		public function get terrainCollision() : blTerrainMesh {return _terrainCollision;}
		
		public function BlSceneLoader(scene : BlScene, parser : BlSceneParser)
		{
			_parser = parser;
			_scene = scene;
			
			_meshNode = new ObjectContainer3D;
			_meshNode.name = "mesh_node";
			_scene.sceneNode.addChild(_meshNode);
			
			_texLightNode = new ObjectContainer3D;
			_texLightNode.name = "texlight_node";
			_scene.sceneNode.addChild(_texLightNode);
			
			// 导航网格node
			_navNode = new ObjectContainer3D;
			_navNode.name = "navNode";
			_navNode.y = 10.0;
			_scene.addEditor(_navNode);
			_navNode.visible = false;
		}
		
		public function load(callback : Function):void
		{
			_callback = callback;
			
			// 计算加载量
			_loadCount = _parser.meshList.length;				// 静态模型
			_loadCount += _parser.terrainCollide ? 1 : 0;		// 地面碰撞
			_loadCount += _parser.collide ? 1 : 0;				// 阻挡碰撞
			_loadCount += _parser.lightList.length;				// 投影灯
			
			_isTerrainCollisionLoaded = _parser.terrainCollide ? false : true;		// 地形碰撞是否已经加载
			
			// 开始加载
			_isStart = true;
			_loadTimer = new Timer(20, 0);
			_loadTimer.addEventListener(TimerEvent.TIMER, onLoadInterval);
			_loadTimer.start();
			
		}
		
		public function stopLoad():void
		{
			if(_loadCount != 0)
				Debug.log("scene: " + _scene.name + " load stop!");
			_loadTimer.stop();
			_isStart = false;
		}
		// 添加模型( externalLoad 外部调用，非xml加载)
		public function addMesh(meshVO:MeshVO, externalLoad:Boolean = true):Boolean
		{
			if(_meshLoading)
				return false;		// 正在加载其他模型 
			
			if(externalLoad)
			{
				_loadCount++;
				_isStart = true;
			}
			
			_meshVO = meshVO;
			_meshLoading = true;
			var meshRes : BlModelResource = BlResourceManager.instance().findModelResource(meshVO.path);
			meshRes.asycLoad(onMesh);
			
			return true;
		}
		
		// 添加贴图灯
		public function addTexLight(texLightVO:LightVO, externalLoad:Boolean = true):Boolean
		{
			if(_lightLoading)
				return false;			// 正在加载其他的灯
			
			if(externalLoad)
			{
				_loadCount++;
				_isStart = true;
			}
			
			_lightVO = texLightVO;
			_lightLoading = true;
			var lightTex : BlImageResource = BlResourceManager.instance().findImageResource(_lightVO.texName);
			if(lightTex)
				lightTex.asycLoad(onLightTex);
			else
				onLightTex(null);
			return true;
		}
		
		private function onLoadInterval(event : TimerEvent = null) : void
		{
			var ret:Boolean;
			// 加载静态模型
			if(_parser.meshList.length > 0 && !_meshLoading)
			{
				var meshVO : MeshVO = _parser.meshList.pop();
				ret = addMesh(meshVO, false);
				if(!ret)
					Debug.warning("addMesh failed");
			}
			// 加载地形碰撞
			else if(_parser.terrainCollide)
			{
				_terrrainCollideVO = _parser.terrainCollide;
				_parser.terrainCollide = null;
				
				var terrainCollideRes : BlModelResource = BlResourceManager.instance().findModelResource(_terrrainCollideVO.path);
				terrainCollideRes.asycLoad(onTerrainCollide);
			}
			// 加载阻挡碰撞(等待地形碰撞产生后再创建)
			else if(_parser.collide && _isTerrainCollisionLoaded)
			{
				_collideVO = _parser.collide;
				_parser.collide = null;
				
				// 创建导航网格
				processScenePhysics();
			}
			// 加载投影灯
			else if(_parser.lightList.length > 0 && !_lightLoading)
			{
				var lightVO : LightVO = _parser.lightList.pop();
				ret = addTexLight(lightVO, false);
				if(!ret)
					Debug.warning("addTexLight failed");
			}
		}
		
		private function onLightTex(res:BlResource):void
		{
			if(!_isStart) return;
			
			var lightSprite : Sprite3D = new Sprite3D(null, _lightVO.lightSize, _lightVO.lightSize, true);
			lightSprite.name = _lightVO.lightName;
			// 设置灯的位置
			lightSprite.x = _lightVO.lightPosx;
			lightSprite.y = 200;
			lightSprite.z = _lightVO.lightPosz;
			// 设置灯的旋转
			lightSprite.rot = _lightVO.lightRot / 180 * Math.PI;
			// 设置灯的颜色
			lightSprite.color = new Vector3D(_lightVO.lightR, _lightVO.lightG, _lightVO.lightB);
			// 光照强度 
			lightSprite.intensity = _lightVO.lightIntensity;
			// 投影灯贴图
			if(res)
			{
				lightSprite.material = new SceneLightMaterial( BlImageResource(res).bmpData );
				lightSprite.material.bitmapDataUrl = res.url;
			}
			else
			{
				lightSprite.material = new SceneLightMaterial( DefaultMaterialManager.getDefaultBitmapData() );
			}
			lightSprite.material.depthWrite = false;
			lightSprite.material.depthCompareMode = Context3DCompareMode.ALWAYS;
			lightSprite.material.blendMode = BlendMode.ADD;
			SceneLightMaterial(lightSprite.material).setLightColor(_lightVO.lightR, _lightVO.lightG, _lightVO.lightB);
			SceneLightMaterial(lightSprite.material).setLightIntensity(_lightVO.lightIntensity);
			
			_texLightNode.addChild(lightSprite);
			BlSceneManager.instance().dispatchEvent(new BlSceneEvent(BlSceneEvent.SCENE_ADD_OBJECT, _scene, lightSprite));
			// 给灯添加编辑辅助器
			_scene.addHelperFor(lightSprite);
			
			_lightLoading = false;
			tellLoadSomething(lightSprite.name);
		}
		
		// 创建导航网格
		private function processScenePhysics() : void
		{
			if(_collideVO.worldPoints.length == 0)
				return;
			
			// 消除worldPoints中重复的点
			var pi:int=1;
			while(pi < _collideVO.worldPoints.length)
			{
				if( _collideVO.worldPoints[pi-1].equals(_collideVO.worldPoints[pi]) )
					_collideVO.worldPoints.splice(pi, 1);
				else
					pi++;
			}
			
			_visiblePolygon.addPolyline(_collideVO.worldPoints); // 地图边框
			
			//加入阻挡
			var wallPolys : Vector.<PolyDefault> = new Vector.<PolyDefault>;		// 碰撞polys
			var holePolys : Vector.<PolyDefault> = new Vector.<PolyDefault>;	// 洞polys
			
			var li:int;
			var poly : PolyDefault;
			for(li=0; li<_collideVO.wallPointsList.length; li++)
			{
				poly = new PolyDefault();
				
				var wallPoints : Vector.<Point> = _collideVO.wallPointsList[li];
				for(var wi:int=0; wi<wallPoints.length; wi++)
				{
					poly.addPointXY(wallPoints[wi].x, wallPoints[wi].y);
				}
				
				if(poly.getArea() > 64)		// 排除面积太小的 
					wallPolys.push(poly);
			}
			
			var i:int;
			var polyUnion:PolyDefault = new PolyDefault();
			for(i=0; i<wallPolys.length; i++)
			{
				polyUnion = polyUnion.union(wallPolys[i]) as PolyDefault;
			}
			
			if(polyUnion)
				addPoly(polyUnion, _visiblePolygon, _islands, _blocks);
			
			// 加入洞
			for(li=0; li<_collideVO.holePointsList.length; li++)
			{
				poly = new PolyDefault();
				
				var holelPoints : Vector.<Point> = _collideVO.holePointsList[li];
				for(var hi:int=0; hi<holelPoints.length; hi++)
				{
					poly.addPointXY(holelPoints[hi].x, holelPoints[hi].y);
				}
				
				if(poly.getArea() > 64)		// 排除面积太小的 
					holePolys.push(poly);
			}
			
			var holePolyUnion : PolyDefault = new PolyDefault();
			for(i=0; i< holePolys.length; i++)
			{
				holePolyUnion = holePolyUnion.union(holePolys[i]) as PolyDefault;
			}
			
			if(holePolyUnion)
				addPoly(holePolyUnion, _visiblePolygon, _islands, _holes);
			
			// 创建为世界范围而生成的三角网格
			processWorldPoly();
			
			// 显示导航网格
			if(BlConfiguration.editorMode)
				showVisiblePolygon();
			
			// 设置物理空间
			setPhysicalTriangles();
			
			tellLoadSomething("physice");
		}
		
		private function addPoly(poly : Poly, vp : VisiblePolygon, islands : Vector.<VisiblePolygon>, blocks : Vector.<VisiblePolygon>) : void 
		{			
			var innerPolyCount : int = poly.getNumInnerPoly();
			var innerPoly : Poly;
			var i : int = 0;
			
			if( innerPolyCount == 0)
				return;
			else if (innerPolyCount>1)
			{
				for (i = 0; i<innerPolyCount; i++)
				{
					innerPoly = poly.getInnerPoly(i);
					if (!innerPoly.isHole()) 
						addPoly(innerPoly, vp, islands, blocks);				
				}
				for (i = 0; i<innerPolyCount; i++)
				{
					innerPoly = poly.getInnerPoly(i);
					if (innerPoly.isHole()) 
						addPoly(innerPoly, vp, islands, blocks);				
				}
			} 
			else
			{
				var pointsCount : int = poly.getNumPoints()
				var points : Vector.<Point> = new Vector.<Point>();
				
				if (poly.isHole())
				{
					if (pointsCount>2) for (i = 0; i<pointsCount;i++)
					{
						points.push(new Point(poly.getX(i), poly.getY(i)));
					}
					var island : VisiblePolygon = new VisiblePolygon();
					island.addPolyline(points);
					if(islands)
						islands.push(island);
				}
				else
				{
					if (pointsCount>2) for (i = 0; i<pointsCount;i++)
					{
						points.push(new Point(poly.getX(i), poly.getY(i)));
					}
					
					vp.addHole(points);
					
					var block : VisiblePolygon = new VisiblePolygon();
					block.addPolyline(points);
					if(blocks)
						blocks.push(block);
				} 
			}
		}
		
		private function processWorldPoly() : void
		{
			// 世界范围
			var worldMin : Point = new Point(+99999999, +99999999);
			var worldMax : Point = new Point(-99999999, -99999999);
			
			var li:int;
			for(li=0; li<_collideVO.worldPoints.length; li++)
			{
				if( worldMin.x > _collideVO.worldPoints[li].x) worldMin.x = _collideVO.worldPoints[li].x;
				if( worldMin.y > _collideVO.worldPoints[li].y) worldMin.y = _collideVO.worldPoints[li].y;
				if( worldMax.x < _collideVO.worldPoints[li].x) worldMax.x = _collideVO.worldPoints[li].x;
				if( worldMax.y < _collideVO.worldPoints[li].y) worldMax.y = _collideVO.worldPoints[li].y;
			}
			worldMin.x -= 500;
			worldMin.y -= 500;
			worldMax.x += 500;
			worldMax.y += 500;
			
			_worldBoundPoints.push(new Point(worldMin.x, worldMax.y));		// lt
			_worldBoundPoints.push(new Point(worldMax.x, worldMax.y));		// rt
			_worldBoundPoints.push(new Point(worldMax.x, worldMin.y));		// rb
			_worldBoundPoints.push(new Point(worldMin.x, worldMin.y));		// bl
			
			_worldPolygon.addPolyline( _worldBoundPoints );
			
			var polys : Vector.<PolyDefault> = new Vector.<PolyDefault>;		// 碰撞polys
			
			var poly : PolyDefault = new PolyDefault();
			
			
			for(var wi:int=0; wi<_collideVO.worldPoints.length; wi++)
			{
				poly.addPointXY(_collideVO.worldPoints[wi].x, _collideVO.worldPoints[wi].y);
			}
			
			if(poly.getArea() > 64)		// 排除面积太小的 
				polys.push(poly);
			
			var polyUnion:PolyDefault = new PolyDefault();
			for(var i:int=0; i<polys.length; i++)
			{
				polyUnion = polyUnion.union(polys[i]) as PolyDefault;
			}
			
			if(polyUnion)
				addPoly(polyUnion, _worldPolygon, null, null);
			
		}
		
		// 显示导航网格
		private function showVisiblePolygon() : void
		{
			var points : Vector.<Point> = new Vector.<Point>();
			
			var tmpPoint:Vector3D = new Vector3D;
			var triPoints : Vector.<Vector3D> = new Vector.<Vector3D>;
			var height : Number = 10;
			var i:int;
			var j:int;
			var tris : Vector.<Triangle>;
			var v0 : Vector2D, v1 : Vector2D, v2 : Vector2D;
			
			var len : int = _blocks.length;
			// 显示墙碰撞
			for(i = 0; i < len; i++) 
			{
				tris = _blocks[i].triangles;
				for(j = 0; j < tris.length; j++)
				{
					
					v0 = new Vector2D(tris[j].points[0].x, tris[j].points[0].y);
					v1 = new Vector2D(tris[j].points[1].x, tris[j].points[1].y);
					v2 = new Vector2D(tris[j].points[2].x, tris[j].points[2].y);
					
					tmpPoint.x = v0.x;
					tmpPoint.y = getTerrainHeight(v0.x, v0.y) + 5;
					tmpPoint.z = v0.y;
					triPoints.push(tmpPoint.clone());
					tmpPoint.x = v1.x;
					tmpPoint.y = getTerrainHeight(v1.x, v1.y)+5;
					tmpPoint.z = v1.y;
					triPoints.push(tmpPoint.clone());
					tmpPoint.x = v2.x;
					tmpPoint.y = getTerrainHeight(v2.x, v2.y)+5;
					tmpPoint.z = v2.y;
					triPoints.push(tmpPoint.clone());
				}
			}
			if(triPoints.length>0)
			{
				var wfWall : WireframeTriangles = new WireframeTriangles(triPoints, 0xff0000);
				wfWall.name = "phy_wall";
				_navNode.addChild(wfWall);
			}
			// 显示洞碰撞
			len = _holes.length;
			for(i = 0; i < len; i++) 
			{
				tris = _holes[i].triangles;
				for(j = 0; j < tris.length; j++)
				{
					
					v0 = new Vector2D(tris[j].points[0].x, tris[j].points[0].y);
					v1 = new Vector2D(tris[j].points[1].x, tris[j].points[1].y);
					v2 = new Vector2D(tris[j].points[2].x, tris[j].points[2].y);
					
					tmpPoint.x = v0.x;
					tmpPoint.y = getTerrainHeight(v0.x, v0.y) + 5;
					tmpPoint.z = v0.y;
					triPoints.push(tmpPoint.clone());
					tmpPoint.x = v1.x;
					tmpPoint.y = getTerrainHeight(v1.x, v1.y)+5;
					tmpPoint.z = v1.y;
					triPoints.push(tmpPoint.clone());
					tmpPoint.x = v2.x;
					tmpPoint.y = getTerrainHeight(v2.x, v2.y)+5;
					tmpPoint.z = v2.y;
					triPoints.push(tmpPoint.clone());
				}
			}
			if(triPoints.length>0)
			{
				var wfHole : WireframeTriangles = new WireframeTriangles(triPoints, 0xffff00);
				wfHole.name = "phy_hole";
				_navNode.addChild(wfHole);
			}
			// 显示导航网格
			triPoints.length = 0;
			tris = _visiblePolygon.triangles;
			for(j = 0; j < tris.length; j++)
			{
				v0 = new Vector2D(tris[j].points[0].x, tris[j].points[0].y);
				v1 = new Vector2D(tris[j].points[1].x, tris[j].points[1].y);
				v2 = new Vector2D(tris[j].points[2].x, tris[j].points[2].y);
				
				tmpPoint.x = v0.x;
				tmpPoint.y = getTerrainHeight(v0.x, v0.y);
				tmpPoint.z = v0.y;
				triPoints.push(tmpPoint.clone());
				tmpPoint.x = v1.x;
				tmpPoint.y = getTerrainHeight(v1.x, v1.y);
				tmpPoint.z = v1.y;
				triPoints.push(tmpPoint.clone());
				tmpPoint.x = v2.x;
				tmpPoint.y = getTerrainHeight(v2.x, v2.y);
				tmpPoint.z = v2.y;
				triPoints.push(tmpPoint.clone());
			}
			if(triPoints.length>0)
			{
				var wfNav : WireframeTriangles = new WireframeTriangles(triPoints, 0x00ff00);
				wfNav.name = "phy_nav";
				_navNode.addChild(wfNav);
			}
			
			// 显示导航网格边界
			triPoints.length = 0;
			var edges : Vector.<Edge> = _visiblePolygon.edge_list;
			for(i = 0; i < edges.length; i++)
			{
				tmpPoint.x = edges[i].p.x
				tmpPoint.y = getTerrainHeight(edges[i].p.x, edges[i].p.y) + 2;
				tmpPoint.z = edges[i].p.y;
				triPoints.push(tmpPoint.clone());
				tmpPoint.x = edges[i].q.x
				tmpPoint.y = getTerrainHeight(edges[i].q.x, edges[i].q.y) + 2;
				tmpPoint.z = edges[i].q.y;
				triPoints.push(tmpPoint.clone());
				
			}
			if(triPoints.length>0)
			{
				var wfNavBound : WireframeLines = new WireframeLines(triPoints, 0x0000ff);
				wfNavBound.name = "phy_navbound";
				_navNode.addChild(wfNavBound);
			}
			
			// 显示包围世界的三角网格
			triPoints.length = 0;
			tris = _worldPolygon.triangles;
			for(j = 0; j < tris.length; j++){
				
				v0 = new Vector2D(tris[j].points[0].x, tris[j].points[0].y);
				v1 = new Vector2D(tris[j].points[1].x, tris[j].points[1].y);
				v2 = new Vector2D(tris[j].points[2].x, tris[j].points[2].y);
				
				tmpPoint.x = v0.x;
				tmpPoint.y = getTerrainHeight(v0.x, v0.y);
				tmpPoint.z = v0.y;
				triPoints.push(tmpPoint.clone());
				tmpPoint.x = v1.x;
				tmpPoint.y = getTerrainHeight(v1.x, v1.y);
				tmpPoint.z = v1.y;
				triPoints.push(tmpPoint.clone());
				tmpPoint.x = v2.x;
				tmpPoint.y = getTerrainHeight(v2.x, v2.y);
				tmpPoint.z = v2.y;
				triPoints.push(tmpPoint.clone());
			}
			
			if(triPoints.length>0)
			{
				var wfWorld : WireframeTriangles = new WireframeTriangles(triPoints, 0x0000ff);
				wfWorld.name = "phy_world";
				_navNode.addChild(wfWorld);
			}
			
			// 显示寻路路径
			triPoints.length = 0;
			
			tmpPoint.x = 0
			tmpPoint.y =0
			tmpPoint.z = 0;
			triPoints.push(tmpPoint.clone());
			tmpPoint.x = 0
			tmpPoint.y = 0
			tmpPoint.z = 0;
			triPoints.push(tmpPoint.clone());
			
			_pathSegmentMesh = new WireframeLines(triPoints, 0xffffff);
			_pathSegmentMesh.name = "phy_path";
			_navNode.addChild(_pathSegmentMesh);
			
		}
		
		private function setPhysicalTriangles() : void 
		{
			if(!_scene.physics)
				return;
			
			var points : Vector.<Point> = new Vector.<Point>();
			
			var minX : int;
			var minY : int;
			var i : int;
			var j : int;
			var l : int;
			var v0 : Vector2D, v1 : Vector2D, v2 : Vector2D;
			
			var wallTris : Vector.<Triangle>;
			var wallTri : Array;
			
			// 加阻挡到物理空间中
			var len : int = _blocks.length;
			for(i = 0; i < len; i++) 
			{
				wallTris = _blocks[i].triangles;
				l = wallTris.length;
				
				for(j = 0; j < l; j++)
				{
					v0 = new Vector2D(int(wallTris[j].points[0].x), int(wallTris[j].points[0].y));
					v1 = new Vector2D(int(wallTris[j].points[1].x), int(wallTris[j].points[1].y));
					v2 = new Vector2D(int(wallTris[j].points[2].x), int(wallTris[j].points[2].y));
					
					var wallCenter : Vector2D = v0.plus(v1).plus(v2).div(3);
					wallCenter.x = int(wallCenter.x);
					wallCenter.y = int(wallCenter.y);
					
					v0.minusEquals(wallCenter);
					v1.minusEquals(wallCenter);
					v2.minusEquals(wallCenter);
					
					if(v0.x < minX) minX = v0.x;
					if(v0.y < minY) minY = v0.y;
					if(v1.x < minX) minX = v1.x;
					if(v1.y < minY) minY = v1.y;
					if(v2.x < minX) minX = v2.x;
					if(v2.y < minY) minY = v2.y;
					
					wallTri = new Array(3);
					wallTri[0] = v0;
					wallTri[1] = v1;
					wallTri[2] = v2;
					
					wallTri.reverse();
					
					_scene.physics.addBlockPolygon(wallTri, wallCenter);
				}
			}
			// 加洞到物理空间中
			len = _holes.length;
			for(i = 0; i < len; i++) 
			{
				var holeTris : Vector.<Triangle> = _holes[i].triangles;
				l = holeTris.length;
				
				for(j = 0; j < l; j++)
				{					
					v0 = new Vector2D(int(holeTris[j].points[0].x), int(holeTris[j].points[0].y));
					v1 = new Vector2D(int(holeTris[j].points[1].x), int(holeTris[j].points[1].y));
					v2 = new Vector2D(int(holeTris[j].points[2].x), int(holeTris[j].points[2].y));
					
					var holeCenter : Vector2D = v0.plus(v1).plus(v2).div(3);
					holeCenter.x = int(holeCenter.x);
					holeCenter.y = int(holeCenter.y);
					
					v0.minusEquals(holeCenter);
					v1.minusEquals(holeCenter);
					v2.minusEquals(holeCenter);
					
					if(v0.x < minX) minX = v0.x;
					if(v0.y < minY) minY = v0.y;
					if(v1.x < minX) minX = v1.x;
					if(v1.y < minY) minY = v1.y;
					if(v2.x < minX) minX = v2.x;
					if(v2.y < minY) minY = v2.y;
					
					var holeTri : Array = new Array(3);
					holeTri[0] = v0;
					holeTri[1] = v1;
					holeTri[2] = v2;
					
					holeTri.reverse();
					
					_scene.physics.addHolePlygon(holeTri, holeCenter);
				}
			}
			
			// 加世界范围的阻挡到物理空间中
			wallTris = _worldPolygon.triangles;
			l = wallTris.length;
			
			for(j = 0; j < l; j++)
			{
				wallTri = new Array(3);
				
				v0 = new Vector2D(int(wallTris[j].points[0].x), int(wallTris[j].points[0].y));
				v1 = new Vector2D(int(wallTris[j].points[1].x), int(wallTris[j].points[1].y));
				v2 = new Vector2D(int(wallTris[j].points[2].x), int(wallTris[j].points[2].y));
				
				wallCenter = v0.plus(v1).plus(v2).div(3);
				wallCenter.x = int(wallCenter.x);
				wallCenter.y = int(wallCenter.y);
				
				v0.minusEquals(wallCenter);
				v1.minusEquals(wallCenter);
				v2.minusEquals(wallCenter);
				
				if(v0.x < minX) minX = v0.x;
				if(v0.y < minY) minY = v0.y;
				if(v1.x < minX) minX = v1.x;
				if(v1.y < minY) minY = v1.y;
				if(v2.x < minX) minX = v2.x;
				if(v2.y < minY) minY = v2.y;
				
				wallTri[0] = v0;
				wallTri[1] = v1;
				wallTri[2] = v2;
				
				wallTri.reverse();
				
				_scene.physics.addBlockPolygon(wallTri, wallCenter);
			}
			
			_scene.physics.syncSpace();
			
			createPathFinder();		// 创建寻路器
		}
		
		private function createPathFinder() : void
		{
			var sm : SpatialMesh = SpatialMesh.fromTriangles(_visiblePolygon.triangles);
			_pathFinder = new PathFind(sm);
			
		}
		
		private function p2v(p : Point) : Vector2D 
		{
			return new Vector2D(p.x, p.y);
		}
		
		// 地面碰撞
		private function onTerrainCollide(res:BlResource):void
		{
			if(!_isStart) return;
			
			// 创建地面显示模型
			if(BlConfiguration.editorMode)
			{
				var tex : BitmapTexture = BitmapTextureCache.instance().getTexture(DefaultMaterialManager.getDefaultBitmapData());
				terrainCollideMesh = new Mesh(BlModelResource(res).geo, new TextureMaterial(tex, true, true));
				terrainCollideMesh.name = "terrain_collide";
				terrainCollideMesh.visible = false;
				_scene.addEditor(terrainCollideMesh);
			}
			
			// 创建地面碰撞对象
			var subGeometries : Vector.<SubGeometry> = BlModelResource(res).geo.subGeometries
			if(subGeometries.length < 1)
				return;
			
			var subGeo : SubGeometry = subGeometries[0];
			
			_terrainCollision = new blTerrainMesh(subGeo);
			
			_isTerrainCollisionLoaded = true;
			tellLoadSomething("terrain");
		}
		// 静态模型
		private function onMesh(res:BlResource):void
		{
			if(!_isStart) return;
			
			if(_meshVO.isTerrainTexture)
			{
				// 创建地表渲染方法
				var terrainMethod : TerrainDiffuseMethod2;
				terrainMethod = new TerrainDiffuseMethod2();
				// 加载地表渲染方法
				var terrainTexLoader : BlTerrainTextureLoader = new BlTerrainTextureLoader;
				terrainTexLoader.startLoad(terrainMethod, 
										_meshVO.mixTextureName,
										_meshVO.terrainTextureName1,
										_meshVO.terrainTextureName2,
										_meshVO.terrainTextureName3,
										_meshVO.terrainTextureName4,
										onTerrainTexture,
										res);
			}
			else
			{	// 加载贴图
				var tex_path : String = BlModelResource(res).tex_path;
				// 贴图目录
				if(tex_path)
				{
					tex_path =  BlResourceManager.findValidPath(tex_path, _parser.texturePathName);
				
					var texRes : BlImageResource = BlResourceManager.instance().findImageResource(tex_path);
					texRes.userObject = res;
					texRes.asycLoad(onMeshTexture);
				}
				else
				{	// 无贴图
					onMeshCreate(BlModelResource(res), null);
				}
			}
		}
		
		private function onTerrainTexture(tLoader : BlTerrainTextureLoader):void
		{
			if(!_isStart) return;
			
			// 创建Mesh
			var sceneMesh : Mesh = new Mesh(BlModelResource(tLoader.userObject).geo, new TextureMaterial(null, true, true));
			sceneMesh.name = BlResource(tLoader.userObject).url;
			tLoader.userObject = null;
			
			TextureMaterial(sceneMesh.material).diffuseMethod = tLoader.terrainMethod;
			TextureMaterial(sceneMesh.material).specularMethod = null;		// 去掉高光反射，因为暂存寄存器不够
			tLoader.terrainMethod.setUVScale(_meshVO.uvScale);
			
			processMesh(sceneMesh, _meshVO);
			
			if(_meshVO.hasVertexColor)
			{	// 加载顶点色文件
				var vcFileName : String = _meshVO.path.substr(0, _meshVO.path.lastIndexOf(".")) + BlStringUtils.vertexColorExtName;
				var vcLoader : BlVertexColorLoader = new BlVertexColorLoader;
				vcLoader.startLoad(sceneMesh, vcFileName, onVertexColor);
			}
			else
			{
				_meshNode.addChild(sceneMesh);
				_meshLoading = false;
				tellLoadSomething(sceneMesh.name);
			}
		}
		
		private function onMeshTexture(res:BlResource):void
		{
			if(!_isStart) return;
			
			var texRes : BlImageResource = BlImageResource(res);
			var meshRes : BlModelResource = BlModelResource(res.userObject);
			onMeshCreate(meshRes, texRes);
		}
		
		private function onMeshCreate(meshRes : BlModelResource, texRes : BlImageResource):void
		{
			// 创建Mesh
			var tex : BitmapTexture;
			if(texRes)
				tex = BitmapTextureCache.instance().getTexture(texRes.bmpData);
			else
				tex = DefaultMaterialManager.getDefaultTexture();
			var sceneMesh : Mesh = new Mesh(meshRes.geo, new TextureMaterial(tex, true, true));
			
			// 多级材质处理
			if( meshRes.tex_urls.length > 1)
			{
				for(var i:int=0; i<meshRes.tex_urls.length; i++)
				{
					var image : BlImageResource = BlResourceManager.instance().findImageResource( meshRes.tex_urls[i] );
					if(image)
					{
						tex = BitmapTextureCache.instance().getTexture(image.bmpData);
						sceneMesh.subMeshes[i].material = new TextureMaterial(tex, true, true);
					}
				}
			}
			
			sceneMesh.name = meshRes.url;
			if(texRes)
			{
				texRes.userObject = null;
				sceneMesh.material.bitmapDataUrl = texRes.url;
			}
			
			processMesh(sceneMesh, _meshVO);
			
			if(_meshVO.hasVertexColor)
			{	// 加载顶点色文件
				var vcFileName : String = _meshVO.path.substr(0, _meshVO.path.lastIndexOf(".")) + BlStringUtils.vertexColorExtName;
				var vcLoader : BlVertexColorLoader = new BlVertexColorLoader;
				vcLoader.startLoad(sceneMesh, vcFileName, onVertexColor);
			}
			else
			{
				_meshNode.addChild(sceneMesh);
				BlSceneManager.instance().dispatchEvent(new BlSceneEvent(BlSceneEvent.SCENE_ADD_OBJECT, _scene, sceneMesh));
				_meshLoading = false;
				tellLoadSomething(sceneMesh.name);
			}
		}
		
		private function onVertexColor(sceneMesh:Mesh):void
		{
			_meshNode.addChild(sceneMesh);
			BlSceneManager.instance().dispatchEvent(new BlSceneEvent(BlSceneEvent.SCENE_ADD_OBJECT, _scene, sceneMesh));
			_meshLoading = false;
			tellLoadSomething(sceneMesh.name);
		}
		
		private function processMesh(mesh:Mesh, meshvo:MeshVO):void
		{
			// 渲染层
			if(meshvo.writeZ == false)
			{
				mesh.renderLayer = Entity.Decal_Layer;
			}
			else
			{
				mesh.renderLayer = Entity.Normal_Layer;
			}
			// 设置Mesh位置
			var mat : Matrix3D = meshvo.rot.toMatrix3D();
			mat.position = meshvo.pos;
			mesh.transform = mat;
			mesh.scaleX = meshvo.scale.x;
			mesh.scaleY = meshvo.scale.y;
			mesh.scaleZ = meshvo.scale.z;
			
			mesh.castsShadows = meshvo.isCastShadow;		// 是否产生阴影
			
			// 设置mesh的材质
			var i:int;
			var meshMaterials : Vector.<TextureMaterial> = new Vector.<TextureMaterial>;
			if(mesh.material)
				meshMaterials.push(mesh.material);
			
			for(i=0; i<mesh.subMeshes.length; i++)
			{
				if(mesh.subMeshes[i].material)
					meshMaterials.push(mesh.subMeshes[i].material);
			}
			
			for(i=0;i <meshMaterials.length; i++)
			{
				var material : TextureMaterial = meshMaterials[i];
				// 接受阴影
				var shadowMapMethod : NearShadowMapMethod = new NearShadowMapMethod(new FilteredShadowMapMethod(BlSceneManager.instance().whiteLight));
				shadowMapMethod.epsilon = .0007;
				material.shadowMethod = shadowMapMethod;			
				material.lightPicker = BlSceneManager.instance().lightPicker;
				// 接受场景灯
				if(_meshVO.isRecvTexLight)
					material.lightMapMethod = new SceneLightMapMethod(BlSceneManager.instance().texLight);		// 接受场景lightmap的渲染方法
				// 是否半透明
				material.alphaBlending = meshvo.isBlend;
				// alpha裁剪
				material.alphaThreshold = Number(10)/255;
				// zbais
				material.zBias = meshvo.zBias;
			}
			
		}
		
		private function tellLoadSomething(tell:String):void
		{
			Debug.log("+ "+tell);
			_loadCount--;
			if(_loadCount == 0)
			{
				Debug.log("scene: " + _scene.name + " load end!");
				stopLoad();		// 加载完毕
				_callback();
			}
			else if(_loadCount < 0)
				Debug.assert(false, "scene load error");
		}
		
		// 获得某个位置的地形高度
		public function getTerrainHeight(x : Number, y : Number) : Number 
		{
			if(!_terrainCollision)
				return 0;
			return _terrainCollision.GetTerrainHeight(x,y);
		}
		// 通过屏幕上一点,获得对应地形上的位置
		public function getTerrainPosByScreenPoint(x : Number, y : Number) : Vector3D
		{
			if(!_terrainCollision)
				return null;
			return _terrainCollision.ScreenPointToTerrain(x, y);
		}
		// 通过屏幕上一点,获得对应地形上的位置,不会返回null
		public function getTerrainPosByScreenPointNoNull(x : Number, y : Number) : Vector3D
		{
			if(!_terrainCollision)
				return new Vector3D(0, 0, 0);
			return _terrainCollision.ScreenPointToTerrain(x, y, true);
		}
		
		public function dispose() : void
		{
			if(_terrainCollision)
				_terrainCollision.dispose();
		}
		
	}
}