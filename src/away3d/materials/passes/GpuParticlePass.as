/**
 *	GPU粒子渲染用的pass 
 */
package away3d.materials.passes
{
	import away3d.arcane;
	import away3d.cameras.Camera3D;
	import away3d.core.base.IRenderable;
	import away3d.core.managers.Stage3DProxy;
	import away3d.materials.lightpickers.LightPickerBase;
	import away3d.materials.utils.DefaultMaterialManager;
	import away3d.particle.Displayer.GpuDisplayer;
	import away3d.particle.Effector.AlphaEffector;
	import away3d.particle.Effector.AttractEffector;
	import away3d.particle.Effector.ColorEffector;
	import away3d.particle.Effector.ForceEffector;
	import away3d.particle.Effector.ParticleEffectorBase;
	import away3d.particle.Effector.SizeEffector;
	import away3d.particle.Effector.UVEffector;
	import away3d.particle.ParticleSystem;
	import away3d.textures.BitmapTexture;
	import away3d.textures.BitmapTextureCache;
	
	import flash.display.BitmapData;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.geom.Vector3D;

	use namespace arcane;
	
	public class GpuParticlePass extends MaterialPassBase
	{
		public static var BillboardType_billboard 	: int = 0;
		public static var BillboardType_X 			: int = 1;
		public static var BillboardType_Y 			: int = 2;
		public static var BillboardType_Z 			: int = 3;
		public static var BillboardType_YBillboard 	: int = 4;
		public static var BillboardType_Vel 			: int = 5;
		
		public static const gpuEffectorKeyFrameMax : uint = 3;
		
		private var _orient : int = BillboardType_billboard;
		private var _isGlobal : Boolean = true;
		
		private var _hasColorEffector : Boolean = false;
		private var _hasAlphaEffector : Boolean = false;
		private var _hasSizeEffector : Boolean = false;
		private var _hasUVEffector : Boolean = false;
		private var _hasForceEffector : Boolean = false;
		private var _hasAttractEffector : Boolean = false;
		
		private var _ps : ParticleSystem;
		private var _particleTexture : BitmapTexture;			// 粒子贴图
		
		private var _commonConst4 : Vector.<Number> = Vector.<Number>([0, 1, 2, 0]);			// 常用常量
		private var _commonConst5 : Vector.<Number> = Vector.<Number>([1000, 0, 0, 0]);		// 常用常量
		
		private var _isUpdateEffectors : Boolean = false;
		
		private var _colorEffectorVect43 : Vector.<Number>;
		private var _alphaEffectorVect43 : Vector.<Number>;
		private var _sizeEffectorVect43 : Vector.<Number>;
		private var _uvEffectorVect43 : Vector.<Number>;
		private var _forceEffectorVect4 : Vector.<Number>;
		private var _attractEffectorVect4 : Vector.<Number>;
		private var _timeVect4 : Vector.<Number>;
		
		
		
		public function GpuParticlePass()
		{
			super();
			
			_numUsedStreams = 5;
			_numUsedTextures = 1;
			_numUsedVertexConstants = 36;
			
			_particleTexture = DefaultMaterialManager.getDefaultTexture();		//  默认贴图
			
			var i:uint;
			
			_colorEffectorVect43 = new Vector.<Number>(4*gpuEffectorKeyFrameMax, true);
			for(i=0; i<gpuEffectorKeyFrameMax;i++)
			{
				_colorEffectorVect43[i*4] = 1.0;
				_colorEffectorVect43[i*4+1] = 1.0;
				_colorEffectorVect43[i*4+2] = 1.0;
				_colorEffectorVect43[i*4+3] = 1.0;
			}
			
			_alphaEffectorVect43 = new Vector.<Number>(4*gpuEffectorKeyFrameMax, true);
			for(i=0; i<gpuEffectorKeyFrameMax;i++)
			{
				_alphaEffectorVect43[i*4] = 1.0;
				_alphaEffectorVect43[i*4+1] = 1.0;
				_alphaEffectorVect43[i*4+2] = 1.0;
				_alphaEffectorVect43[i*4+3] = 1.0;
			}
			
			_sizeEffectorVect43 = new Vector.<Number>(4*gpuEffectorKeyFrameMax, true);
			for(i=0; i<gpuEffectorKeyFrameMax;i++)
			{
				_sizeEffectorVect43[i*4] = 1.0;
				_sizeEffectorVect43[i*4+1] = 1.0;
				_sizeEffectorVect43[i*4+2] = 1.0;
				_sizeEffectorVect43[i*4+3] = 1.0;
			}
			
			_uvEffectorVect43 = new Vector.<Number>(4*gpuEffectorKeyFrameMax*2, true);
			for(i=0; i<gpuEffectorKeyFrameMax*2;i++)
			{
				_uvEffectorVect43[i*4] = 1.0;
				_uvEffectorVect43[i*4+1] = 1.0;
				_uvEffectorVect43[i*4+2] = 1.0;
				_uvEffectorVect43[i*4+3] = 1.0;
			}
			
			_forceEffectorVect4 = new Vector.<Number>(4, true);
			_forceEffectorVect4[0] = 0.0;
			_forceEffectorVect4[1] = 0.0;
			_forceEffectorVect4[2] = 0.0;
			_forceEffectorVect4[3] = 0.0;
			
			_attractEffectorVect4 = new Vector.<Number>(4, true);
			_attractEffectorVect4[0] = 0.0;
			_attractEffectorVect4[1] = 0.0;
			_attractEffectorVect4[2] = 0.0;
			_attractEffectorVect4[3] = 0.0;
			
			_timeVect4 = new Vector.<Number>(4, true);
			_timeVect4[0] = 0;
			_timeVect4[1] = 0;
			_timeVect4[2] = 0;
			_timeVect4[3] = 0;
		}
		
		public function get bitmapData() : BitmapData
		{
			return _particleTexture.bitmapData;
		}
		
		public function set bitmapData(value : BitmapData) : void
		{
			if(value)
				_particleTexture.bitmapData = value;
			else
				_particleTexture.bitmapData = DefaultMaterialManager.getDefaultBitmapData();
		}
		
		public function set currentTime(value:int):void
		{
			_timeVect4[0] = value;
		}
		
		public function setParitlceSystem(ps : ParticleSystem) : void
		{
			_ps = ps;
			if(!_ps)
				return;
			
			if(_ps.isBillBoard)
				_orient = BillboardType_billboard;
			else
			{
				switch(_ps.particleOrient)
				{
					case 0:
						_orient = BillboardType_X;
						break;
					case 1:
						_orient = BillboardType_Y;
						break;
					case 2:
						_orient = BillboardType_Z;
						break;
					case 3:
						_orient = BillboardType_YBillboard;
						break;
					case 4:
					default:
						_orient = BillboardType_Vel;
						break;
				}
			}
			
			_isGlobal = _ps.isWolrdParticle;
			
			invalidateShaderProgram();
		}
		
		public function updateBitmapData() : void
		{
			_particleTexture.invalidateContent();
		}
		
		private function judgeEffector() : void
		{
			// 检查粒子控制器
			var effectors : Vector.<ParticleEffectorBase> = _ps.getEffectors();
			
			_hasColorEffector = false;
			_hasAlphaEffector = false;
			_hasSizeEffector = false;
			_hasUVEffector = false;
			_hasForceEffector = false;
			_hasAttractEffector = false;
			for(var ei:int=0; ei<effectors.length; ei++)
			{
				if(effectors[ei] is ColorEffector 
					&& ColorEffector(effectors[ei]).keyFrameCount() > 0 )
				{
					_hasColorEffector = true;
				}
				else if(effectors[ei] is AlphaEffector
					&& AlphaEffector(effectors[ei]).keyFrameCount() > 0 )
				{
					_hasAlphaEffector = true;
				}
				else if(effectors[ei] is SizeEffector
					&& SizeEffector(effectors[ei]).keyFrameCount() > 0 )
				{
					_hasSizeEffector = true;
				}
				else if(effectors[ei] is UVEffector
					&& UVEffector(effectors[ei]).keyFrameCount() > 0 )
				{
					_hasUVEffector = true;
				}
				else if(effectors[ei] is ForceEffector)
				{
					_hasForceEffector = true;
				}
				else if(effectors[ei] is AttractEffector)
				{
					_hasAttractEffector = true;
				}
			}
		}
		/**
		 *	输入寄存器的使用
		 * va0		起始位置(x,y,z)
		 * va1		uv和顶点偏移(u,v,sizeX,sizeY)
		 * va2		生命值和旋转(starttime, lifetime, rot, rotv)
		 * va3		速度(Vx,Vy,Vz)
		 * va4		颜色(r,g,b,a) 
		 * 
		 */		
		/**
		 * 常量寄存器的使用
		 * vc0-3	MVP
		 * vc4		ratio
		 * vc5-7	保留
		 * vcStart=8
		 * vcStart+ 0		常用常量
		 * vcStart+ 1		常用常量
		 * vcStart+ 2-5		M
		 * vcStart+ 6-9		inverse M
		 * vcStart+ 10-13	camera transform
		 * vcStart+ 14		camera Z
		 * vcStart+ 15		保留
		 * vcStart+ 16-18	color effector(r,g,b,t)		3 kf
		 * vcStart+ 19-21	alpha effector(a,0,0,t)		3 kf
		 * vcStart+ 22-24	size effector(x,y,0,t)		3 kf
		 * vcStart+ 25-30	uv effector(u,v,0,t)		6 kf
		 * vcStart+ 31		force effector(fx,fy,fz)
		 * vcStart+ 32		attract effector(x,y,z,force)
		 * vcStart+ 33		current time
		 */		
		/**
		 * vt的使用
		 * vt0 vt1 vt2 vt3 vt4 任意使用
		 *  
		 * vt5( xyz粒子的速度, w 粒子经过的时间)
		 * vt6( x 生命比例, y 旋转弧度, z sin(旋转弧度), w cos(旋转弧度) )
		 * vt7( x x方向拉伸, y y方向拉伸 )
		 */		
		arcane override function getVertexCode(code:String) : String
		{
			judgeEffector();			// 检查控制器
			
			var vc1:uint;
			var vc2:uint;
			var vci:uint;
			
			var code : String = "";
			
			// clear 暂存寄存器(0,0,0,1)
			code +=
				"mov vt2, vc"+(vcStart)+".xxxy\n"+
				"mov vt7, vc"+(vcStart)+".xxxy\n";
			
			// 计算粒子的生命比例 vt6.x存放生命比例
			code +=
				"sub vt5.w, vc"+(vcStart+33)+".x, va2.x\n" +	// vt5.w 为粒子已经经过的时间
				"div vt6.x, vt5.w, va2.y\n";		// vt6.x 为粒子生命比例
			
			// uv effector vcStart+ 25-30(u,v,0,t)
			vc1= vcStart+25;
			code +=
				"mov vt4, vc"+(vcStart)+".x\n";
			if(_hasUVEffector)
			{
				for(vci=0; vci<(gpuEffectorKeyFrameMax*2-1); vci++,vc1++)
				{
					vc2=vc1+1;
					
					code +=
						"sge vt0.x, vt6.x, vc"+vc1+".w\n"+		// vt0.x为判断值(在区间内为1)
						"slt vt0.y, vt6.x, vc"+vc2+".w\n"+
						"mul vt0.x, vt0.x, vt0.y\n"+
						
						"mov vt2, vc"+vc1+"\n"+
						
						// if
						"mul vt2, vt2, vt0.x\n"+
						"add vt4, vt4, vt2\n";
				}
				code +=
					"add vt4, vt4, va1\n"+
					"mov v0, vt4\n";
			}
			else
			{
				code += 
					"mov v0, va1\n";		// uv->v0 传入pixelshader中
			}
			
			// color effector vcStart+ 16-18 (r,g,b,t)
			vc1= vcStart + 16;
			
			code +=
				"mov vt4, vc"+vcStart+".x\n";			// clear vt4,用vt4来存放结果,(use va4)
			
			if(_hasColorEffector)
			{
				for(vci=0; vci<(gpuEffectorKeyFrameMax-1); vci++,vc1++)
				{
					vc2=vc1+1;
					
					code +=
						"sge vt0.x, vt6.x, vc"+vc1+".w\n"+		// vt0.x为判断值(在区间内为1)
						"slt vt0.y, vt6.x, vc"+vc2+".w\n"+
						"mul vt0.x, vt0.x, vt0.y\n"+
						
						"mov vt1.x, vc"+vc2+".w\n"+
						"sub vt1.x, vt1.x, vc"+vc1+".w\n"+
						"sub vt1.y, vt6.x, vc"+vc1+".w\n"+
						"div vt1.x, vt1.y, vt1.x\n"+			// vt1.x = weight
						"sub vt1.y, vc"+vcStart+".y, vt1.x\n"+			// vt1.y = 1 - weight
						
						// color
						"mul vt2.xyz, vc"+vc1+".xyz, vt1.y\n"+		// color = color(t1)*(1-weight)+color(t2)*weight
						"mul vt3.xyz, vc"+vc2+".xyz, vt1.x\n"+
						"add vt2.xyz, vt2.xyz, vt3.xyz\n"+
						
						// if
						"mul vt2, vt2, vt0.x\n"+
						"add vt4, vt4, vt2\n";
				}
				
				code +=
					"mov v1.xyz, va4.xyz\n"+			// just use va4
					"mov v1.xyz, vt4.xyz\n";			// rgb -> v1
//					"mul v1.xyz, va4.xyz, vt4.xyz\n";		// 原色*colorEffector -> v1
			}
			else
			{
				code +=
					"mov v1.xyz, va4.xyz\n";
			}
			
			// alpha effector vcStart+ 19-21 (a,0,0,t)
			vc1= vcStart + 19;
			
			code +=
				"mov vt4, vc"+vcStart+".x\n";			// clear vt4
			
			if(_hasAlphaEffector)
			{
				for(vci=0; vci<(gpuEffectorKeyFrameMax-1); vci++,vc1++)
				{
					vc2=vc1+1;
					
					code +=
						"sge vt0.x, vt6.x, vc"+vc1+".w\n"+		// vt0.x为判断值(在区间内为1)
						"slt vt0.y, vt6.x, vc"+vc2+".w\n"+
						"mul vt0.x, vt0.x, vt0.y\n"+
						
						"mov vt1.x, vc"+vc2+".w\n"+
						"sub vt1.x, vt1.x, vc"+vc1+".w\n"+
						"sub vt1.y, vt6.x, vc"+vc1+".w\n"+
						"div vt1.x, vt1.y, vt1.x\n"+			// vt1.x = weight
						"sub vt1.y, vc"+vcStart+".y, vt1.x\n"+			// vt1.y = 1 - weight
						// a
						"mul vt2.x, vc"+vc1+".x, vt1.y\n"+		// alpha = alpha(t1)*(1-weight)+alpha(t2)*weight
						"mul vt3.x, vc"+vc2+".x, vt1.x\n"+
						"add vt2.x, vt2.x, vt3.x\n"+
												
						// if
						"mul vt2.x, vt2.x, vt0.x\n"+
						"add vt4.x, vt4.x, vt2.x\n";
				}
				
				code +=
					"mov v1.w, vt4.x\n";	
			}
			else
			{
				code +=
					"mov v1.w, va4.w\n";
			}
			
			// size effector vcStart+ 22-24 (x,y,0,t)
			vc1=vcStart+22;
			
			code +=
				"mov vt4, vc"+vcStart+".x\n";			// clear
			
			if(_hasSizeEffector)
			{
				for(vci=0; vci<(gpuEffectorKeyFrameMax-1); vci++,vc1++)
				{
					vc2=vc1+1;
					
					code +=
						"sge vt0.x, vt6.x, vc"+vc1+".w\n"+		// vt0.x为判断值(在区间内为1)
						"slt vt0.y, vt6.x, vc"+vc2+".w\n"+
						"mul vt0.x, vt0.x, vt0.y\n"+
						
						"mov vt1.x, vc"+vc2+".w\n"+
						"sub vt1.x, vt1.x, vc"+vc1+".w\n"+
						"sub vt1.y, vt6.x, vc"+vc1+".w\n"+
						"div vt1.x, vt1.y, vt1.x\n"+			// vt1.x = weight
						"sub vt1.y, vc"+vcStart+".y, vt1.x\n"+			// vt1.y = 1 - weight
						// x
						"mul vt2.xy, vc"+vc1+".xy, vt1.y\n"+		// size = size(t1)*(1-weight)+size(t2)*weight
						"mul vt3.xy, vc"+vc2+".xy, vt1.x\n"+
						"add vt2.xy, vt2.xy, vt3.xy\n"+
						
						// if
						"mul vt2.xy, vt2.xy, vt0.xx\n"+
						"add vt4.xy, vt4.xy, vt2.xy\n";
				}
				
				code +=
					"mov vt7.xy, va1.zw\n"+
					"abs vt0, vt7\n"+
					"div vt7, vt7, vt0\n"+				// vt7 -> 1
					"mul vt7.xy, vt7.xy, vt4.xy\n"+		// vt7 * size
					"div vt7, vt7, vc"+vcStart+".z\n";				// vt7 * size / 2
			}
			else
			{
				code +=
					"mov vt7.xy, va1.zw\n";
			}
			
			// 计算粒子的旋转 vt6.y存放旋转弧度 vt6.z=sin(rot) vt6.w=cos(rot)
			code +=
				"mul vt6.y, va2.w, vt5.w\n"+		// rotv * passtime
				"div vt6.y, vt6.y, vc"+(vcStart+1)+".x\n"+		// 除1000
				"add vt6.y, vt6.y, va2.z\n"+		// rot + rotv * passtime
				"sin vt6.z, vt6.y\n"+
				"cos vt6.w, vt6.y\n";
			
			// 计算粒子的速度 vt5 存放粒子的速度
			
			// 力场
			if(_hasForceEffector)
			{
				code +=
					"div vt0.x, vt5.w, vc"+(vcStart+1)+".x\n"+			// t=passtime/1000
					"mul vt0.x, vt0.x, vt0.x\n"+			// t*t
					"div vt0.x, vt0.x, vc"+vcStart+".z\n"+			// t*t/2
					"mul vt0, vc"+(vcStart+31)+", vt0.x\n" +			// a*t*t/2
					"add vt5.xyz, va3.xyz, vt0.xyz\n";	// v= v(t) + a*t*t/2
			}
			else
			{
				code +=
					"mov vt5.xyz, va3.xyz\n";
			}
			// 吸引器
			if(_hasAttractEffector)
			{
				if(_isGlobal)
				{
					code +=
						"mov vt0.xyz, vc"+(vcStart+32)+".xyz\n"+
						"mov vt0.w, vc"+vcStart+".y\n"+
						"m44 vt0, vt0, vc"+(vcStart+2)+"\n"+			// 转换吸引点到全局空间
						"sub vt0, vt0, va0\n"+			// 力的方向=吸引器位置 - 粒子初始位置
						"nrm vt0.xyz, vt0\n"+
						"mul vt0, vt0, vc"+(vcStart+32)+".w\n";
				}
				else
				{
					code +=
						"sub vt0, vc"+(vcStart+32)+", va0\n"+			// 力的方向=吸引器位置 - 粒子初始位置
						"nrm vt0.xyz, vt0\n"+
						"mul vt0, vt0, vc"+(vcStart+32)+".w\n";			// 力=方向*力的大小
				}
					
				code +=
					"div vt1.x, vt5.w, vc"+(vcStart+1)+".x\n"+			// t=passtime/1000
					"mul vt1.x, vt1.x, vt1.x\n"+			// t*t
					"div vt1.x, vt1.x, vc"+(vcStart)+".z\n"+			// t*t/2
					"mul vt1, vt0, vt1.x\n"+				// a*t*t/2
					"add vt5.xyz, vt5.xyz, vt1\n";				// v = v + a*t*t/2
			}
			else
			{
				
			}
			
			// 计算粒子的位置 vt0 存放粒子的位置
			code +=
				"mov vt0, va0\n" +	// vt0 = 粒子初始位置
				"mov vt1.xyz, vt5.xyz\n"+	// vt1 = 粒子速度
				"mov vt1.w, vc"+vcStart+".x\n" +		// vt1.w = 0
				"mul vt1, vt1, vt5.w\n" +	// vt1 = 粒子速度*粒子生命/1000
				"div vt1, vt1, vc"+(vcStart+1)+".x\n" +	// /1000
				"add vt0, vt0, vt1\n";		// p = p + vt
					
			// 投影前.... vt0为粒子位置
			if(_orient == BillboardType_billboard)
			{
				if(_isGlobal)
				{
					code+=
						"m44 vt0, vt0, vc"+(vcStart+6)+"\n";		// * inverse m
				}
				// billboard(1,1,0,0)
				code +=
					"mov vt1, vc"+(vcStart)+".x\n"+
					"mov vt1.xy, vt7.xy\n"+			// xy偏移
					
					// 旋转
					"mul vt2.x, vt1.x, vt6.w\n"+		
					"mul vt2.y, vt1.x, vt6.z\n"+
					"mul vt2.w, vt1.y, vt6.z\n"+
					"neg vt2.w, vt2.w\n"+
					"mul vt2.z, vt1.y, vt6.w\n"+
					"mov vt1.xy, vt2.xy\n"+
					"add vt1.xy, vt1.xy, vt2.wz\n"+
					
					"m33 vt1.xyz, vt1.xyz, vc"+(vcStart+10)+"\n"+		// * camera transform
					"m33 vt1.xyz, vt1.xyz, vc"+(vcStart+6)+"\n"+		// * inverse m
					
					"add vt0, vt0, vt1\n";
			}
			else if(_orient == BillboardType_X)
			{
				// 面向X(1,0,1,0)
				code +=
					"mov vt1.xy, vt7.xy\n"+
					"neg vt1.x, vt1.x\n"+
					
					// 旋转
					"mul vt2.xyw, vt1.xxy, vt6.wzz\n"+
					"mul vt2.z, vt1.y, vt6.w\n"+
					"neg vt2.w, vt2.w\n"+
					"add vt1.xy, vt2.xy, vt2.wz\n"+
					
					"add vt0.y, vt0.y, vt1.y\n"+
					"add vt0.z, vt0.z, vt1.x\n";
				
				if(_isGlobal)
				{
					code+=
						"m44 vt0, vt0, vc"+(vcStart+6)+"\n";		// * inverse m
				}
			}
			else if	(_orient == BillboardType_Y)
			{
				// 面向Y(1,0,0,1)
				code +=
					"mov vt1.xy, vt7.xy\n"+
					
					// 旋转
					"mul vt2.xyw, vt1.xxy, vt6.wzz\n"+
					"mul vt2.z, vt1.y, vt6.w\n"+
					"neg vt2.w, vt2.w\n"+
					"add vt1.xy, vt2.xy, vt2.wz\n"+
					
					"add vt0.x, vt0.x, vt1.x\n"+
					"add vt0.z, vt0.z, vt1.y\n";
				
				if(_isGlobal)
				{
					code+=
						"m44 vt0, vt0, vc"+(vcStart+6)+"\n";		// * inverse m
				}
			}
			else if(_orient == BillboardType_Z)
			{
				
				// 面向Z(0,1,1,0)
				code +=
					"mov vt1.xy, vt7.xy\n"+
					
					// 旋转
					"mul vt2.xyw, vt1.xxy, vt6.wzz\n"+
					"mul vt2.z, vt1.y, vt6.w\n"+
					"neg vt2.w, vt2.w\n"+
					"add vt1.xy, vt2.xy, vt2.wz\n"+
					
					"add vt0.x, vt0.x, vt1.x\n"+
					"add vt0.y, vt0.y, vt1.y\n";
				
				if(_isGlobal)
				{
					code+=
						"m44 vt0, vt0, vc"+(vcStart+6)+"\n";		// * inverse m
				}
			}
			else if(_orient == BillboardType_YBillboard)
			{
				if(_isGlobal)
				{
					code+=
						"m44 vt0, vt0, vc"+(vcStart+6)+"\n";		// * inverse m
				}
				// Y轴向billboard(0,1,0,1)
				code +=
					"mov vt2.xyz, vc"+vcStart+".xyx\n"+		// make vt2=(0,1,0)
					"crs vt1.xyz, vt2, vc"+(vcStart+14)+"\n"+			// (0,1,0) * cameraZ = x偏移方向
					"nrm vt1.xyz, vt1.xyz\n"+
					
					// 旋转
					"mul vt3, vt1, vt6.w\n"+
					"mul vt4, vt2, vt6.z\n"+
					"add vt4, vt3, vt4\n"+
					
					"mul vt3, vt2, vt6.w\n"+
					"mul vt2, vt1, vt6.z\n"+
					"neg vt2, vt2\n"+
					
					"add vt2, vt3, vt2\n"+
					"mov vt1, vt4\n"+
					
					"mul vt1, vt1, vt7.x\n"+			//vt1 = x偏移量
					"mul vt2, vt2, vt7.y\n"+
					"add vt1, vt1, vt2\n"+
				
					"m33 vt1.xyz, vt1.xyz, vc"+(vcStart+6)+"\n"+		// * inverse m
					
					"add vt0, vt0, vt1\n";
			}
			else if(_orient == BillboardType_Vel)
			{
				if(_isGlobal)
				{
					code+=
						"m44 vt0, vt0, vc"+(vcStart+6)+"\n";		// * inverse m
				}
				// 平行于运动方向(0,0,1,1),旋转无作用
				code +=
					"mov vt2, vc"+vcStart+".x\n";		// clear vt2
					
				if(_isGlobal)
				{
					code +=
						"mov vt2.xyz, vt5.xyz\n";	
				}
				else
				{
					code +=
						"m33 vt2.xyz, vt5.xyz, vc"+(vcStart+2)+"\n";
				}
				
				code +=
					"crs vt1.xyz, vt2, vc"+(vcStart+14)+"\n"+				//	x偏移方向 = v * cameraZ
					"nrm vt1.xyz, vt1.xyz\n"+
					
					"crs vt2.xyz, vt1, vc"+(vcStart+14)+"\n"+ 				// y偏移方向 = dirX * cameraZ
					"nrm vt2.xyz, vt2.xyz\n"+
					"neg vt2, vt2\n"+
					
					// 旋转
					"mul vt1, vt1, vt7.x\n"+
					"mul vt2, vt2, vt7.y\n"+
					"add vt1, vt1, vt2\n"+
					"mov vt1.w, vc"+vcStart+".x\n"+
					
					"m33 vt1.xyz, vt1.xyz, vc"+(vcStart+6)+"\n"+		// * inverse m
					
					"add vt0, vt0, vt1\n";
			}
									
			// vt0为粒子的位置, vt7为投影后位置
			code +=
				"m44 vt7, vt0, vc0\n";		// vt7 = 粒子投影空间位置 = 粒子当前位置 * MVP
			
			// 投影后....
			
			
			// 粒子死亡判断
			code +=
				"slt vt0.x, vt5.w, va2.y\n"+		// if 粒子死亡 vt0.x = 0 else vt0.x = 1
				"mul op, vt7, vt0.x\n"+			// vt7 * vt0.x
				
				"sub v2, vt0.x, vc"+(vcStart)+".y";				// 死亡不渲染判断
				
			return code;
		}
		/**
		 *	v0	[u, v, ?, ?] 
		 * 	v1	[r,	g, b, a]
		 *  v2	[dead, ?, ?, ?]		// x 是否粒子死亡不渲染-1
		 */	
		arcane override function getFragmentCode() : String
		{
			var wrap : String = _repeat ? "wrap" : "clamp";
			var filter : String;
			
			if (_smooth) 
				filter = _mipmap ? "linear,miplinear" : "linear";
			else 
				filter = _mipmap ? "nearest,mipnearest" : "nearest";
			
			var code : String;
			
			code =
				"kil v2.x\n"+
				"tex ft0, v0, fs0 <2d,"+filter+","+wrap+">\n" +			// 贴图采样
				"mul ft0, ft0, v1\n" +			// tex * color
				"mov oc, ft0\n";
			
			return 	code;
		}
		
		private static var tmpVec3 : Vector3D = new Vector3D;
		private static var tmpVec4 : Vector.<Number> = Vector.<Number>([0, 0, 0, 0]);
		// 设置常量寄存器(从8开始，0-3留给MVP了, 4是ratio， 5-7保留）
		private static var vcStart : int = 8;
		arcane override function render(renderable : IRenderable, stage3DProxy : Stage3DProxy, camera : Camera3D, lightPicker : LightPickerBase) : void
		{
			var ps : ParticleSystem = ParticleSystem(renderable);
			var displayer : GpuDisplayer = GpuDisplayer(ps.displayer);
			
			stage3DProxy.setSimpleVertexBuffer(1, displayer.getVertexBuffer1(stage3DProxy), Context3DVertexBufferFormat.FLOAT_4);
			stage3DProxy.setSimpleVertexBuffer(2, displayer.getVertexBuffer2(stage3DProxy), Context3DVertexBufferFormat.FLOAT_4);
			stage3DProxy.setSimpleVertexBuffer(3, displayer.getVertexBuffer3(stage3DProxy), Context3DVertexBufferFormat.FLOAT_4);
			stage3DProxy.setSimpleVertexBuffer(4, displayer.getVertexBuffer4(stage3DProxy), Context3DVertexBufferFormat.FLOAT_4);
			
			
			// 0,1
			stage3DProxy._context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, vcStart, _commonConst4, 1);
			stage3DProxy._context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, vcStart+1, _commonConst5, 1);
			
			// 2-5 M
			stage3DProxy._context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, vcStart+2, renderable.sceneTransform, true);
			// 6-9 inverse M
			stage3DProxy._context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, vcStart+6, renderable.inverseSceneTransform, true);
			// 10-13 camera transform
			stage3DProxy._context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, vcStart+10, camera.sceneTransform, true);
			
			// 14 camear Z
			tmpVec3.setTo(0, 0, 1);
			tmpVec3 = camera.sceneTransform.deltaTransformVector(tmpVec3);
			tmpVec4[0] = tmpVec3.x; tmpVec4[1] = tmpVec3.y; tmpVec4[2] = tmpVec3.z; tmpVec4[3] = 0;
			stage3DProxy._context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, vcStart+14, tmpVec4, 1);
			
			// 15 保留
			
			// 粒子控制器的处理
			if(!_isUpdateEffectors)
			{
				UpdateEffectors();			// 计算粒子控制器的向量
				_isUpdateEffectors = true;
			}
			
			// 16-18 Color Effector
			stage3DProxy._context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, vcStart+16, _colorEffectorVect43, gpuEffectorKeyFrameMax);
			// 19-21 Alpha Effector
			stage3DProxy._context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, vcStart+19, _alphaEffectorVect43, gpuEffectorKeyFrameMax);
			// 22-24 Size Effector
			stage3DProxy._context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, vcStart+22, _sizeEffectorVect43, gpuEffectorKeyFrameMax);
			// 25-30 UV	Effector
			stage3DProxy._context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, vcStart+25, _uvEffectorVect43, gpuEffectorKeyFrameMax*2);
			// 31 force Effector
			stage3DProxy._context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, vcStart+31, _forceEffectorVect4, 1);
			// 32 attract Effector
			stage3DProxy._context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, vcStart+32, _attractEffectorVect4, 1);
			// 33 current time
			stage3DProxy._context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, vcStart+33, _timeVect4, 1);
			
			super.render(renderable, stage3DProxy, camera, lightPicker);	
		}
		
		private function UpdateEffectors() : void
		{
			var effectors : Vector.<ParticleEffectorBase> = _ps.getEffectors();
			
			var colorEffector : ColorEffector = null;
			var alphaEffector : AlphaEffector = null;
			var sizeEffector : SizeEffector = null;
			var uvEffector : UVEffector = null;
			var forceEffector : ForceEffector = null;
			var attractEffecotr : AttractEffector = null;
			
			for(var ei:int=0; ei<effectors.length; ei++)
			{
				if(effectors[ei] is ColorEffector)
					colorEffector = ColorEffector(effectors[ei]);
				else if(effectors[ei] is AlphaEffector)
					alphaEffector = AlphaEffector(effectors[ei]);
				else if(effectors[ei] is SizeEffector)
					sizeEffector = SizeEffector(effectors[ei]);
				else if(effectors[ei] is UVEffector)
					uvEffector = UVEffector(effectors[ei]);
				else if(effectors[ei] is ForceEffector)
					forceEffector = ForceEffector(effectors[ei]);
				else if(effectors[ei] is AttractEffector)
					attractEffecotr = AttractEffector(effectors[ei]);
			}
			
			var i:uint;
			// 颜色控制器(r,g,b,t)
			if(colorEffector && _hasColorEffector)
			{
				colorEffector.updateGpuData(_colorEffectorVect43);
			}
			else
			{
				_colorEffectorVect43[0] = 1.0;
				_colorEffectorVect43[1] = 0.0;
				_colorEffectorVect43[2] = 0.0;
				_colorEffectorVect43[3] = 0.0;
				
				_colorEffectorVect43[4] = 0.7;
				_colorEffectorVect43[5] = 0.0;
				_colorEffectorVect43[6] = 0.0;
				_colorEffectorVect43[7] = 0.3;
				
				_colorEffectorVect43[8] = 0.3;
				_colorEffectorVect43[9] = 0.0;
				_colorEffectorVect43[10] = 0.5;
				_colorEffectorVect43[11] = 1.0;				
				
			}
			// alpha控制器(a,0,0,t)
			if(alphaEffector && _hasAlphaEffector)
			{
				alphaEffector.updateGpuData(_alphaEffectorVect43);
			}
			else
			{
				_alphaEffectorVect43[0] = 0.0;
				_alphaEffectorVect43[1] = 0.0;
				_alphaEffectorVect43[2] = 0.0;
				_alphaEffectorVect43[3] = 0.0;
				
				_alphaEffectorVect43[4] = 1.0;
				_alphaEffectorVect43[5] = 0.0;
				_alphaEffectorVect43[6] = 0.0;
				_alphaEffectorVect43[7] = 0.3;
				
				_alphaEffectorVect43[8] = 1.0;
				_alphaEffectorVect43[9] = 0.0;
				_alphaEffectorVect43[10] = 0.0;
				_alphaEffectorVect43[11] = 1.0;
								
			}
			// size控制器(x,y,0,t)
			if(sizeEffector && _hasSizeEffector)
			{
				sizeEffector.updateGpuData(_sizeEffectorVect43);
			}
			else
			{
				_sizeEffectorVect43[0] = 100.0;
				_sizeEffectorVect43[1] = 100.0;
				_sizeEffectorVect43[2] = 0.0;
				_sizeEffectorVect43[3] = 0.0;
				
				_sizeEffectorVect43[4] = 200.0;
				_sizeEffectorVect43[5] = 200.0;
				_sizeEffectorVect43[6] = 0.0;
				_sizeEffectorVect43[7] = 0.3;
				
				_sizeEffectorVect43[8] = 50.0;
				_sizeEffectorVect43[9] = 50.0;
				_sizeEffectorVect43[10] = 0.0;
				_sizeEffectorVect43[11] = 1.0;
			}
			
			// uv控制器(u,v,0,t)
			if(uvEffector && _hasUVEffector)
			{
				uvEffector.updateGpuData(_uvEffectorVect43);
			}
			else
			{
				_uvEffectorVect43[0] = 0.0;
				_uvEffectorVect43[1] = 0.0;
				_uvEffectorVect43[2] = 0.0;
				_uvEffectorVect43[3] = 0.0;
				
				_uvEffectorVect43[4] = 0.2;
				_uvEffectorVect43[5] = 0.0;
				_uvEffectorVect43[6] = 0.0;
				_uvEffectorVect43[7] = 0.2;
				
				_uvEffectorVect43[8] = 0.4;
				_uvEffectorVect43[9] = 0.0;
				_uvEffectorVect43[10] = 0.0;
				_uvEffectorVect43[11] = 0.4;
				
				_uvEffectorVect43[12] = 0.6;
				_uvEffectorVect43[13] = 0.0;
				_uvEffectorVect43[14] = 0.0;
				_uvEffectorVect43[15] = 0.6;
				
				_uvEffectorVect43[16] = 0.8;
				_uvEffectorVect43[17] = 0.0;
				_uvEffectorVect43[18] = 0.0;
				_uvEffectorVect43[19] = 0.8;
				
				_uvEffectorVect43[20] = 0.0;
				_uvEffectorVect43[21] = 0.0;
				_uvEffectorVect43[22] = 0.0;
				_uvEffectorVect43[23] = 1.0;
			}
			// force控制器
			if(forceEffector && _hasForceEffector)
			{
				forceEffector.updateGpuData(_forceEffectorVect4);
			}
			else
			{
				_forceEffectorVect4[0] = 0.0;
				_forceEffectorVect4[1] = 100.0;
				_forceEffectorVect4[2] = 0.0;
				_forceEffectorVect4[3] = 0.0;
			}
			// attract控制器
			if(attractEffecotr && _hasAttractEffector)
			{
				attractEffecotr.updateGpuData(_attractEffectorVect4);
			}
			else
			{
				_attractEffectorVect4[0] = 0.0;
				_attractEffectorVect4[1] = 0.0;
				_attractEffectorVect4[2] = 0.0;
				_attractEffectorVect4[3] = 1000.0;
			}
			
		}
		
		arcane override function activate(stage3DProxy : Stage3DProxy, camera : Camera3D, textureRatioX : Number, textureRatioY : Number) : void
		{
			super.activate(stage3DProxy, camera, textureRatioX, textureRatioY);
			
			// 设置贴图寄存器
			if(_particleTexture)
			{				
				stage3DProxy.setTextureAt(0, _particleTexture.getTextureForStage3D(stage3DProxy));
			}
		}
		
		arcane override function deactivate(stage3DProxy : Stage3DProxy) : void
		{
			super.deactivate(stage3DProxy);
		}
		
		override public function dispose() : void
		{
			if(_particleTexture)
			{
				BitmapTextureCache.instance().freeTexture(_particleTexture);
			}
			
			super.dispose();
			
			_isUpdateEffectors = false;
		}
	}
}