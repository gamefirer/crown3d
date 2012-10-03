package sl2d.utils
{
	public class VectorUtil 
	{

		public static function formatAngle(r : Number) : Number 
		{
			if (r > 180) 
			{
				r = r - 360;
			}
			if (r < -180) 
			{
				r = r + 360;
			}
			return r;
		}

		public static function formatAngle90(r : Number) : Number 
		{
			if (r > 90) 
			{
				r = 180 - r;
			}
			if (r < -90) 
			{
				r = r + 180;
			}
			return r;
		}

		//属性
		public var x : Number;
		public var y : Number;
		//方法
		public function VectorUtil(px : Number = 0, py : Number = 0) 
		{
			x = px;
			y = py;
		}

		public function setTo(px : Number, py : Number) : void 
		{
			x = px;
			y = py;
		}

		public function copy(v : VectorUtil) : void 
		{
			x = v.x;
			y = v.y;
		}

		public function toString() : String 
		{
			var rx : Number = Math.round(this.x * 1000) / 1000;
			var ry : Number = Math.round(this.y * 1000) / 1000;
			return "[" + rx + ", " + ry + "]";
		}

		public function getClone() : VectorUtil 
		{
			return new VectorUtil(this.x, this.y);
		}

		public function plus(v : VectorUtil) : VectorUtil 
		{
			return new VectorUtil(x + v.x, y + v.y); 
		}

		public function plusEquals(v : VectorUtil) : VectorUtil 
		{
			x += v.x;
			y += v.y;
			return this;
		}

		public function minus(v : VectorUtil) : VectorUtil 
		{
			return new VectorUtil(x - v.x, y - v.y);    
		}

		public function minusEquals(v : VectorUtil) : VectorUtil 
		{
			x -= v.x;
			y -= v.y;
			return this;
		}

		public function negateEquals() : void 
		{
			x = -x;
			y = -y;
		}

		public function negate() : VectorUtil 
		{
			return new VectorUtil(-x, -y);
		}

		public function mult(s : Number) : VectorUtil 
		{
			return new VectorUtil(x * s, y * s);
		}

		public function multEquals(s : Number) : VectorUtil 
		{
			x *= s;
			y *= s;
			return this;
		}

		public function rotateEquals(ang : Number) : void 
		{
			var ca : Number = MathUtil.cosD(ang);
			var sa : Number = MathUtil.sinD(ang);
			var rx : Number = this.x * ca - this.y * sa;
			var ry : Number = this.x * sa + this.y * ca;
			this.x = rx;
			this.y = ry;
		}

		public function rotate(ang : Number) : VectorUtil 
		{
			var v : VectorUtil = new VectorUtil(x, y);
			v.rotateEquals(ang);
			return v;
		}

		public function dot(v : VectorUtil) : Number 
		{
			return x * v.x + y * v.y;
		}

		public function cross(v : VectorUtil) : Number 
		{
			return x * v.y - y * v.x;
		}

		public function times(v : VectorUtil) : VectorUtil 
		{
			return new VectorUtil(x * v.x, y * v.y);
		}

		public function divEquals(s : Number) : VectorUtil 
		{
			if (s == 0) s = 0.0001;
			x /= s;
			y /= s;
			return this;
		}

		
		public function distance(v : VectorUtil) : Number 
		{
			var delta : VectorUtil = this.minus(v);
			return delta.getLength();
		}

		
		public function normalize() : VectorUtil 
		{
			var m : Number = getLength();
			if (m == 0) m = 0.0001;
			return mult(1 / m);
		}

		public function getNormal() : VectorUtil 
		{
			return new VectorUtil(-y, x);
		}

		public function isNormalTo(v : VectorUtil) : Boolean 
		{
			return (this.dot(v) == 0);
		}

		public function angleBetween(v : VectorUtil) : Number 
		{
			var dp : Number = this.dot(v);
			// find dot product
			// divide by the lengths of the two vectors
			var cosAngle : Number = dp / (this.getLength() * v.getLength());
			return MathUtil.acosD(cosAngle);
		// take the inverse cosine
		}

		//隐式获取
		public function getLength() : Number 
		{
			return Math.sqrt(x * x + y * y);
		}

		public function setLength(len : Number) : void 
		{
			var r : Number = this.getLength();
			if (r) 
			{
				this.multEquals(len / r);
			} else 
			{
				this.x = len;
			}
		}

		public function getAngle() : Number 
		{
			return MathUtil.atan2D(y, x);
		}

		public function setAngle(ang : Number) : void 
		{
			var r : Number = getLength();
			x = r * MathUtil.cosD(ang);
			y = r * MathUtil.sinD(ang);
		}
	}
}
