package sl2d.utils
{
	public class MathUtil {
		public static function sinD(angle : Number) : Number {
			return Math.sin(angle * (Math.PI / 180));
		}

		public static function cosD(angle : Number) : Number {
			return Math.cos(angle * (Math.PI / 180));
		}

		public static function tanD(angle : Number) : Number {
			return Math.tan(angle * (Math.PI / 180));
		}

		public static function asinD(ratio : Number) : Number {
			return Math.asin(ratio) * (180 / Math.PI);
		}

		public static function acosD(ratio : Number) : Number {
			return Math.acos(ratio) * (180 / Math.PI);
		}

		public static function atanD(ratio : Number) : Number {
			return Math.atan(ratio) * (180 / Math.PI);
		}

		public static function atan2D(y : Number, x : Number) : Number {
			return Math.atan2(y, x) * (180 / Math.PI);
		}

		public static function distance(x1 : Number, y1 : Number, x2 : Number, y2 : Number) : Number {
			var dx : Number = x2 - x1;
			var dy : Number = y2 - y1;
			return Math.sqrt(dx * dx + dy * dy);
		}

		public static function angleOfLine(x1 : Number, y1 : Number, x2 : Number, y2 : Number) : Number {
			return atan2D(y2 - y1, x2 - x1);
		}

		public static function degreesToRadians(angle : Number) : Number {
			return angle * (Math.PI / 180);
		}

		public static function radiansToDegrees(angle : Number) : Number {
			return angle * (180 / Math.PI);
		}

		public static function fixAngle(angle : Number) : Number {
			return ((angle %= 360) < 0) ? angle + 360 : angle;
		}

		public static function cartesianToPolar(p : VectorUtil) : Object {
			var radius : Number = Math.sqrt(p.x * p.x + p.y * p.y);
			var theta : Number = atan2D(p.y, p.x);
			return {r:radius, t:theta};
		}
	}
}
