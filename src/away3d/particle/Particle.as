/*
 *	粒子对象
 */
package away3d.particle
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;

	public class Particle
	{
		public var index : int;			// 在particleSystem中的index
		public var noDead : Boolean = false;	// 不会死亡
		private var _remainTime : int;			// 剩下的时间 ( >0 活 <=0 死 )
		public var startTime : int;			// 开始时间
		public var pastTime : int;			// 经过的时间（ 经过的时间+剩下的时间=生命期 ）
		public var pos : Vector3D = new Vector3D;			// 位置
		public var dir : Vector3D = new Vector3D;			// 运动方向
		public var vel : Number = 0;			// 运动速度
		public var sizeX : Number  = 0;		// 大小
		public var sizeY : Number = 0;
		
		public var rot : Number = 0;			// 旋转(顺时针,弧度)
		public var rotVel : Number = 0;		// 旋转速度(每秒)
		public var color : uint = 0xffffff;	// 颜色
		public var alpha : Number = 1.0;		// 透明度[0,1] 
		public var u : Number = 0.0;			// u offset
		public var v : Number = 0.0;			// v offset
		public var su : Number = 1.0;			// u scale
		public var sv : Number = 1.0;			// v scale
		
		public var shake : Number = 0.0;		// 抖动值(条带用)
		
		public var rotMat : Matrix3D = new Matrix3D;	// 旋转矩阵(非billboard时用,只保存旋转)(条带系统用)
		
		public function Particle(index : int)
		{
			this.index = index;
			reset();
		}
		
		public function get r() : Number {return ((color & 0xff0000) >> 16) / 0xff;}
		public function get g() : Number {return ((color & 0x00ff00) >> 8) / 0xff;}
		public function get b() : Number {return (color & 0x0000ff) / 0xff;}
		
		public function reset() : void
		{
			startTime = 0;
			_remainTime = 0;
			pastTime = 0;
			sizeX = 0;
			sizeY = 0;
			vel = 0;
			rot = 0;
			rotVel = 0;
			color = 0xffffff;
			alpha = 1.0;
			u = 0;
			v = 0;
			pos.setTo(0,0,0);
			dir.setTo(0,1,0);
			rotMat.identity();
		}
		
		// 设置粒子的生命
		public function set remainTime(value : int) : void
		{
			_remainTime = value;
			pastTime = 0;
		}
		
		public function get remainTime() : int {return _remainTime;}
		
		public function IsDead() : Boolean {return _remainTime <= 0 && !noDead ; } 
		public function Dead() : void { pastTime += _remainTime; _remainTime = 0; noDead = false; }
		
		private static var tmp : Vector3D = new Vector3D;
		public function Update(deltaTime : int) : void
		{
			_remainTime -= deltaTime;
			pastTime += deltaTime;
			
			if(noDead && _remainTime<=0)
			{
				_remainTime = pastTime + _remainTime;
				pastTime = 0;
			}
			tmp.copyFrom(dir);
			tmp.scaleBy( Number(vel*deltaTime)/1000 );
			pos.incrementBy(tmp);
			
			rot += rotVel * deltaTime / 1000;
			//Debug.bltrace("pos=" + pos.x.toFixed(2) + " " + pos.y.toFixed(2) + " " + pos.z.toFixed(2) + " rot=" + rot.toFixed(2));
		}
		
		public function UpdateForGpu(deltaTime :int) : void
		{
			_remainTime -= deltaTime;
			pastTime += deltaTime;
			if(noDead && _remainTime<=0)
			{
				_remainTime = pastTime + _remainTime;
				pastTime = 0;
			}
		}
	}
}