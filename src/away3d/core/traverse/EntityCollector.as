package away3d.core.traverse
{
	import away3d.arcane;
	import away3d.cameras.Camera3D;
	import away3d.core.base.IRenderable;
	import away3d.core.data.EntityListItem;
	import away3d.core.data.EntityListItemPool;
	import away3d.core.data.RenderableListItem;
	import away3d.core.data.RenderableListItemPool;
	import away3d.core.partition.NodeBase;
	import away3d.entities.Entity;
	import away3d.entities.Sprite3D;
	import away3d.library.assets.AssetType;
	import away3d.lights.DirectionalLight;
	import away3d.lights.LightBase;
	import away3d.lights.LightProbe;
	import away3d.lights.PointLight;
	import away3d.materials.MaterialBase;
	import away3d.particle.ParticleSystem;
	
	import blade3d.profiler.Profiler;

	use namespace arcane;

	/**
	 * The EntityCollector class is a traverser for scene partitions that collects all scene graph entities that are
	 * considered potientially visible.
	 *
	 * @see away3d.partition.Partition3D
	 * @see away3d.partition.Entity
	 */
	public class EntityCollector extends PartitionTraverser
	{
		protected var _skyBox : IRenderable;
		
		protected var _lightMapRenderableHead : RenderableListItem;		// 投影灯层
		protected var _opaqueRenderableHead : RenderableListItem;			// 不透明物体层
		protected var _decalRenderableHead : RenderableListItem;			// 地表贴花层
		protected var _avatarRenderableHead : RenderableListItem;			// 角色渲染层
		protected var _blendedRenderableHead : RenderableListItem;			// 透明物体层
		protected var _particleRenderableHead : RenderableListItem;		// 特效渲染层
		protected var _editorRenderableHead : RenderableListItem;			// 编辑器渲染层
		
		private var _entityHead:EntityListItem;
		protected var _renderableListItemPool : RenderableListItemPool;
		protected var _entityListItemPool : EntityListItemPool;
		
		protected var _lights : Vector.<LightBase>;
		private var _directionalLights : Vector.<DirectionalLight>;
		private var _pointLights : Vector.<PointLight>;
		private var _lightProbes : Vector.<LightProbe>;
		
		protected var _numEntities : uint;
		
		protected var _numTexLights : uint;
		protected var _numOpaques : uint;
		protected var _numAvatars : uint;
		protected var _numBlended : uint;
		protected var _numParticles : uint;		// 特效数
		protected var _numEditors : uint;			// 编辑器数
		
		protected var _numLights : uint;
		protected var _numTriangles : uint;		// 渲染的三角面计数
		protected var _numMouseEnableds : uint;
		protected var _camera : Camera3D;
		private var _numDirectionalLights : uint;
		private var _numPointLights : uint;
		private var _numLightProbes : uint;
	
		private var _callPreRender : Boolean = false;
		/**
		 * Creates a new EntityCollector object.
		 */
		public function EntityCollector()
		{
			init();
			if( (this is ShadowCasterCollector)
				|| (this is LightCasterCollector) )
			{
				// no preRender
			}
			else
				_callPreRender = true;
		}

		private function init() : void
		{
//			_opaqueRenderables = new Vector.<IRenderable>();
//			_blendedRenderables = new Vector.<IRenderable>();
			_lights = new Vector.<LightBase>();
			_directionalLights = new Vector.<DirectionalLight>();
			_pointLights = new Vector.<PointLight>();
			_lightProbes = new Vector.<LightProbe>();
			_renderableListItemPool = new RenderableListItemPool();
			_entityListItemPool = new EntityListItemPool();
		}

		public function get numEntities() : uint { return _numEntities; }
		public function get numTexLights() : uint { return _numTexLights; }
		public function get numOpaques() : uint { return _numOpaques; }
		public function get numAvatars() : uint { return _numAvatars; }
		public function get numBlended() : uint { return _numBlended; }
		public function get numParticles() : uint { return _numParticles; }
		public function get numEditors() : uint { return _numEditors; }
		/**
		 * The camera that provides the visible frustum.
		 */
		public function get camera() : Camera3D
		{
			return _camera;
		}

		public function set camera(value : Camera3D) : void
		{
			_camera = value;
			_entryPoint = _camera.scenePosition;
		}

		/**
		 * The amount of IRenderable objects that are mouse-enabled.
		 */
		public function get numMouseEnableds() : uint
		{
			return _numMouseEnableds;
		}

		/**
		 * The sky box object if encountered.
		 */
		public function get skyBox() : IRenderable
		{
			return _skyBox;
		}

		/**
		 * The list of opaque IRenderable objects that are considered potentially visible.
		 * @param value
		 */
		public function get opaqueRenderableHead() : RenderableListItem
		{
			return _opaqueRenderableHead;
		}

		public function set opaqueRenderableHead(value : RenderableListItem) : void
		{
			_opaqueRenderableHead = value;
		}

		/**
		 * The list of IRenderable objects that require blending and are considered potentially visible.
		 * @param value
		 */
		public function get blendedRenderableHead() : RenderableListItem
		{
			return _blendedRenderableHead;
		}

		public function set blendedRenderableHead(value : RenderableListItem) : void
		{
			_blendedRenderableHead = value;
		}
		// 地表贴花层
		public function get decalRenderableHead() : RenderableListItem
		{
			return _decalRenderableHead;
		}
		
		public function set decalRenderableHead(value : RenderableListItem) : void
		{
			_decalRenderableHead = value;
		}
		// 粒子的渲染列表
		public function get particleRenderableHead() : RenderableListItem
		{
			return _particleRenderableHead;
		}
		
		public function set particleRenderableHead(value : RenderableListItem) : void
		{
			_particleRenderableHead = value;
		}
		// 角色的渲染列表
		public function get avatarRenderableHead() : RenderableListItem
		{
			return _avatarRenderableHead;
		}
		
		public function set avatarRenderableHead(value : RenderableListItem) : void
		{
			_avatarRenderableHead = value;
		}
		// 场景灯渲染列表
		public function get lightMapRenderableHead() : RenderableListItem
		{
			return _lightMapRenderableHead;
		}
		
		public function set lightMapRenderableHead(value : RenderableListItem) : void
		{
			_lightMapRenderableHead = value;
		}
		// 编辑器渲染列表
		public function get editorRenderableHead() : RenderableListItem
		{
			return _editorRenderableHead
		}
		
		public function set editorRenderableHead(value : RenderableListItem) : void
		{
			_editorRenderableHead = value;
		}
		

		public function get entityHead():EntityListItem {
			return _entityHead;
		}

		/**
		 * The lights of which the affecting area intersects the camera's frustum.
		 */
		public function get lights() : Vector.<LightBase>
		{
			// todo: provide separate containers per default light type, otherwise store here
			return _lights;
		}

		public function get directionalLights() : Vector.<DirectionalLight>
		{
			return _directionalLights;
		}

		public function get pointLights() : Vector.<PointLight>
		{
			return _pointLights;
		}

		public function get lightProbes() : Vector.<LightProbe>
		{
			return _lightProbes;
		}

		/**
		 * Clears all objects in the entity collector.
		 * @param time The time taken by the last render
		 * @param camera The camera that provides the frustum.
		 */
		public function clear() : void
		{
			_numEditors = 0;
			_numTexLights = _numParticles = _numAvatars = 0;
			_numEntities = _numOpaques = _numBlended = _numLights = 0;
			_numTriangles = _numMouseEnableds = 0;
			
			_editorRenderableHead = null;
			_lightMapRenderableHead = null;
			_particleRenderableHead = null;
			_avatarRenderableHead = null;
			_decalRenderableHead = null;
			_blendedRenderableHead = null;
			_opaqueRenderableHead = null;
			_entityHead = null;
			
			_renderableListItemPool.freeAll();
			_entityListItemPool.freeAll();
			_skyBox = null;
			if (_numLights > 0) _lights.length = _numLights = 0;
			if (_numDirectionalLights > 0) _directionalLights.length = _numDirectionalLights = 0;
			if (_numPointLights > 0) _pointLights.length = _numPointLights = 0;
			if (_numLightProbes > 0) _lightProbes.length = _numLightProbes = 0;
		}

		/**
		 * Returns true if the current node is at least partly in the frustum. If so, the partition node knows to pass on the traverser to its children.
		 *
		 * @param node The Partition3DNode object to frustum-test.
		 */
		override public function enterNode(node : NodeBase) : Boolean
		{
			// 渲染层过滤
			if(!node.isInRenderLayer(this))
				return false;
			// 摄像机裁剪
			Profiler.start("enterNode");
			var ret:Boolean = node.isInFrustum(_camera);
			Profiler.end("enterNode");
			return ret;
//			return node.isInFrustum(_camera);
		}
		
		override public function get layerMask() : uint 
		{
			return Entity.All_Layer;			// 主采集器必须遍历所有物体以更新动画及billboard设置等
		}

		/**
		 * Adds a skybox to the potentially visible objects.
		 * @param renderable The skybox to add.
		 */
		override public function applySkyBox(renderable : IRenderable) : void
		{
			_skyBox = renderable;
		}

		/**
		 * Adds an IRenderable object to the potentially visible objects.
		 * @param renderable The IRenderable object to add.
		 */
		override public function applyRenderable(renderable : IRenderable) : void
		{
			var material : MaterialBase;

			if( renderable.mouseEnabled )
				++_numMouseEnableds;
			_numTriangles += renderable.numTriangles;

			material = renderable.material;
			if (material) 
			{
				var item : RenderableListItem = _renderableListItemPool.getItem();
				item.renderable = renderable;
				item.materialId = material._uniqueId;
				item.renderOrderId = material._renderOrderId;
				item.zIndex = renderable.zIndex;
				item.renderPriority = material.renderPriority;		// 渲染优先级
				
				// 分派渲染队列
				if(renderable.sourceEntity.renderLayer == Entity.SceneLight_Layer)
				{	// 场景灯层
					item.next = _lightMapRenderableHead;
					_lightMapRenderableHead = item;
					++_numTexLights;
				}
				else if(renderable.sourceEntity.renderLayer == Entity.Character_Layer)
				{	// 角色渲染层
					item.next = _avatarRenderableHead;
					_avatarRenderableHead = item;					
					++_numAvatars;
				}
				else if(renderable.sourceEntity.renderLayer == Entity.Effect_Layer)
				{	// 特效渲染层
					item.next = _particleRenderableHead;
					_particleRenderableHead = item;
					++_numParticles;
				}
				else if(renderable.sourceEntity.renderLayer == Entity.Decal_Layer)
				{	// 地表贴花渲染层
					item.next = _decalRenderableHead;
					_decalRenderableHead = item;
					++_numBlended;
				}
				else if(renderable.sourceEntity.renderLayer == Entity.Editor_Layer)
				{	// 编辑器层
					item.next = _editorRenderableHead;
					_editorRenderableHead = item;
					++_numEditors;
				}
				else if (material.requiresBlending) 
				{
					item.next = _blendedRenderableHead;
					_blendedRenderableHead = item;
					++_numBlended;
				}
				else 
				{
					item.next = _opaqueRenderableHead;
					_opaqueRenderableHead = item;
					++_numOpaques;
				}
			}
		}

		override public function applyParticle(particleSystem : ParticleSystem) : void
		{
			if(particleSystem.particleNum == 0)
				return;
			
			var material : MaterialBase;
			material = particleSystem.material;
			_numParticles += particleSystem.particleNum;
			
			if (material)
			{
				var item : RenderableListItem = _renderableListItemPool.getItem();
				item.renderable = particleSystem;
				item.materialId = material._uniqueId;
				item.renderOrderId = material._renderOrderId;
				item.zIndex = particleSystem.zIndex;
				item.renderPriority = material.renderPriority;		// 渲染优先级
				
				// 加粒子到对应的渲染列表中
				item.next = _particleRenderableHead;
				_particleRenderableHead = item;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function applyEntity(entity : Entity) : void
		{
			++_numEntities;

			var item:EntityListItem = _entityListItemPool.getItem();
			item.entity = entity;

			item.next = _entityHead;
			_entityHead = item;
			
			entity.isRendering = true;			// 该对象被渲染
			// pre render
			if(_callPreRender)
			{
				entity.preRender(this);			// 场景渲染前调用
			}
			
		}

		/**
		 * Adds a light to the potentially visible objects.
		 * @param light The light to add.
		 */
		override public function applyUnknownLight(light : LightBase) : void
		{
			_lights[_numLights++] = light;
		}

		override public function applyDirectionalLight(light : DirectionalLight) : void
		{
			_lights[_numLights++] = light;
			_directionalLights[_numDirectionalLights++] = light;
		}

		override public function applyPointLight(light : PointLight) : void
		{
			_lights[_numLights++] = light;
			_pointLights[_numPointLights++] = light;
		}

		override public function applyLightProbe(light : LightProbe) : void
		{
			_lights[_numLights++] = light;
			_lightProbes[_numLightProbes++] = light;
		}



		/**
		 * The total number of triangles collected, and which will be pushed to the render engine.
		 */
		public function get numTriangles() : uint
		{
			return _numTriangles;
		}
		
		public function get numLights() : uint
		{
			return _numLights;
		}

		/**
		 * Cleans up any data at the end of a frame.
		 */
		public function cleanUp() : void
		{
			var node : EntityListItem = _entityHead;
			while (node) 
			{
				node.entity.popModelViewProjection();
				node = node.next;
			}
		}
	}
}