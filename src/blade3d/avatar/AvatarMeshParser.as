/**
 *	Avatar模型文件的解析器 
 */
package blade3d.avatar
{
	import away3d.arcane;
	import away3d.core.base.SkinnedSubGeometry;
	import away3d.core.math.Quaternion;
	import away3d.loaders.parsers.ParserBase;
	import away3d.loaders.parsers.ParserDataFormat;
	
	import flash.geom.Vector3D;
	
	use namespace arcane;

	public class AvatarMeshParser extends ParserBase
	{
		private static const INDEX_TOKEN : String = "indices";		// index
		private static const VERTEX_TOKEN : String = "vertices";		// 顶点
		private static const INDEX_NUM_TOKEN : String = "indexNum";		// index数(为面数的3倍)
		private static const FACE_NUM_TOKEN : String = "faceNum";		// 面数
		private static const VERTEX_NUM_TOKEN : String = "vertexNum";	// 顶点数
		private static const ANIMATION_TOKEN : String = "animation";	// 对应的avatar文件
		private static const COMMENT_TOKEN : String = "//";				// 注释
		
		private var _parseIndex : int;				// 第几个字符
		private var _line : int;					// 当前行
		private var _charLineIndex : int;			// 当前列
		private var _reachedEOF : Boolean;
		
		private var _rotationQuat : Quaternion;	// 3dmax空间->flash3d空间转换用
		// mesh数据
		//private var _avatarParser : AvatarParser;
		private var _subGeoName : String;
		private var _vertices : Vector.<Number>;
		private var _uvs : Vector.<Number>;
		private var _boneWeights : Vector.<Number>;
		private var _boneIndices : Vector.<Number>;
		private var _indices : Vector.<uint>;
		private var _subGeom : SkinnedSubGeometry;
		
		
		public function AvatarMeshParser(url:String)//, avatarParser : AvatarParser)
		{
			super(ParserDataFormat.PLAIN_TEXT);
			this.url = url;
			_subGeoName = this.url.substr(this.url.lastIndexOf("/")+1);
			_subGeoName = _subGeoName.substr(0, _subGeoName.lastIndexOf("."));
			//_avatarParser = avatarParser;
		}
		
		public function get subGeometry() : SkinnedSubGeometry {return _subGeom;}
		public function get subGeometryName() : String {return _subGeoName;}
		
		protected override function startParsing(frameLimit : Number) : void {
			_reachedEOF = false;
			_parseIndex = 0;
			super.startParsing(frameLimit);
			
			_rotationQuat = new Quaternion();
			var t1 : Quaternion = new Quaternion();
			var t2 : Quaternion = new Quaternion();
			
			t1.fromAxisAngle(Vector3D.X_AXIS, -Math.PI * .5);
			//t2.fromAxisAngle(Vector3D.Y_AXIS, 0);
			
			if (false) {
				var t3 : Quaternion = new Quaternion();
				t3.multiply(t2, t1);
				t1.fromAxisAngle(new Vector3D(0,1,0), 0);
				_rotationQuat.multiply(t1, t3);
			}
			else {
				//_rotationQuat.multiply(t2, t1);
			}
		}
		
		protected override function proceedParsing() : Boolean {
			
			var token : String;
			while (hasTime())
			{
				token = getNextToken();
				//Debug.bltrace(token);
				switch (token) 
				{
					case COMMENT_TOKEN:
						ignoreLine();
						break;
					case ANIMATION_TOKEN:
						ignoreLine();
						break;
					case VERTEX_NUM_TOKEN:
						var vertexNum:int = getNextInt();
						_vertices = new Vector.<Number>(vertexNum*3, true);
						_uvs = new Vector.<Number>(vertexNum*2, true);
						_boneIndices = new Vector.<Number>(vertexNum * 4, true);	// 最多4个权重
						_boneWeights = new Vector.<Number>(vertexNum * 4, true);
						break;
					case FACE_NUM_TOKEN:
						var faceNum:int = getNextInt();
						break;
					case INDEX_NUM_TOKEN:
						var indexNum:int = getNextInt();
						_indices = new Vector.<uint>(indexNum, true);
						break;
					case VERTEX_TOKEN:
						parseVertex();
						break;
					case INDEX_TOKEN:
						parseIndex();
						break;
				}
				
				if (_reachedEOF)
				{	// 创建AvatarMesh
					
					generateMesh();
					
					return ParserBase.PARSING_DONE;		
				}
			}
			return ParserBase.MORE_TO_PARSE;
		}
		
		private function parseVertex() : void
		{
			var ch : String;
			var vertexIndex : int;
			var pos : Vector3D = new Vector3D;
			
			var token : String = getNextToken();
			if (token != "{") sendUnknownKeywordError();
			
			do
			{
				if (_reachedEOF) sendEOFError();
				
				token = getNextToken();
				if (token != "v") sendUnknownKeywordError();
				vertexIndex = getNextInt();
				token = getNextToken();
				if (token != "{") sendUnknownKeywordError(); 
							
				_vertices[vertexIndex*3] = getNextNumber();			// 顶点
				_vertices[vertexIndex*3+1] = getNextNumber();
				_vertices[vertexIndex*3+2] = getNextNumber();
				
				_uvs[vertexIndex*2] = getNextNumber();				// uv
				_uvs[vertexIndex*2+1] = getNextNumber();
				
//				_vertices[vertexIndex*3] = 0;
//				_vertices[vertexIndex*3+1] = 0;
//				_vertices[vertexIndex*3+2] = 0;
				
				var i:int;
				var boneCount:int = getNextInt();
				for(i=0; i<boneCount; i++)
				{
					var boneIndex:int = getNextInt();								// bone index
					_boneIndices[vertexIndex*4+i] = boneIndex*3;					// 一个骨头占用3个vector
					var boneWeight:Number = getNextNumber();							// bone weight
					_boneWeights[vertexIndex*4+i] = boneWeight;
					// 此处注释勿删,以备后用
//					pos.setTo(getNextNumber(), getNextNumber(), getNextNumber());	// 顶点在bone空间的位置
//					
//					pos = _avatarParser.bindPose[boneIndex].transformVector(pos);	// 顶点在以骨骼中心为空间的位置
//					pos.scaleBy(boneWeight);					// 乘以权重
//					
//					_vertices[vertexIndex*3] += pos.x;
//					_vertices[vertexIndex*3+1] += pos.y;
//					_vertices[vertexIndex*3+2] += pos.z;
					
				}
				
				//Debug.bltrace("v="+_vertices[vertexIndex*3].toFixed(2)+" "+_vertices[vertexIndex*3+1].toFixed(2)+" "+_vertices[vertexIndex*3+2].toFixed(2));
				
				token = getNextToken();
				if (token != "}") sendUnknownKeywordError();
				skipWhiteSpace();
				
				ch = getNextChar();
				if (ch != "}") putBack();
			}while (ch != "}");
		}
		
		private function parseIndex() : void
		{
			var ch : String;
			var indexI : int;
			
			var token : String = getNextToken();
			if (token != "{") sendUnknownKeywordError();
			
			indexI = 0;
			do
			{
				if (_reachedEOF) sendEOFError();
				
				_indices[indexI++] = getNextInt();
				_indices[indexI++] = getNextInt();
				_indices[indexI++] = getNextInt();
				
				ch = getNextChar();
				if (ch != "}") putBack();
			}while (ch != "}");
		}
		
		private function generateMesh() : void
		{
			_subGeom = new SkinnedSubGeometry(4);
			_subGeom.updateVertexData(_vertices);
			_subGeom.updateUVData(_uvs);
			_subGeom.updateIndexData(_indices);
			_subGeom.updateJointIndexData(_boneIndices);
			_subGeom.updateJointWeightsData(_boneWeights);
		}

		
		private function getNextToken() : String
		{
			var ch : String;
			var token : String = "";
			
			while (!_reachedEOF) {
				ch = getNextChar();
				if (ch == " " || ch == "\r" || ch == "\n" || ch == "\t") {
					if (token != COMMENT_TOKEN)
						skipWhiteSpace();
					if (token != "")
						return token;
				}
				else token += ch;
				
				if (token == COMMENT_TOKEN) return token;
			}
			
			return token;
		}
		
		private function parseLiteralString() : String
		{
			skipWhiteSpace();
			
			var ch : String = getNextChar();
			var str : String = "";
			
			if (ch != "\"") sendParseError("\"");
			
			do {
				if (_reachedEOF) sendEOFError();
				ch = getNextChar();
				if (ch != "\"") str += ch;
			} while (ch != "\"");
			
			return str;
		}
		
		private function parseVector3D() : Vector3D
		{
			var vec : Vector3D = new Vector3D();
			var ch : String = getNextToken();
			
			if (ch != "(") sendParseError("(");
			vec.x = getNextNumber();
			vec.y = getNextNumber();
			vec.z = getNextNumber();
			
			if (getNextToken() != ")") sendParseError(")");
			
			return vec;
		}
		
		private function parseQuaternion() : Quaternion
		{
			var quat : Quaternion = new Quaternion();
			var ch : String = getNextToken();
			
			if (ch != "(") sendParseError("(");
			quat.x = getNextNumber();
			quat.y = getNextNumber();
			quat.z = getNextNumber();
			
			// quat supposed to be unit length
			var t : Number = 1 - quat.x * quat.x - quat.y * quat.y - quat.z * quat.z;
			quat.w = t < 0 ? 0 : -Math.sqrt(t);
			
			if (getNextToken() != ")") sendParseError(")");
			
			var rotQuat : Quaternion = new Quaternion();
			rotQuat.multiply(_rotationQuat, quat);
			
			return rotQuat;
		}
		
		private function skipWhiteSpace() : void
		{
			var ch : String;
			
			do {
				ch = getNextChar();
			} while (ch == "\n" || ch == " " || ch == "\r" || ch == "\t");
			
			putBack();
		}
		
		private function ignoreLine() : void
		{
			var ch : String;
			while (!_reachedEOF && ch != "\n")
				ch = getNextChar();
		}
		
		private function getNextChar() : String
		{
			var ch : String = getTextData().charAt(_parseIndex++);
			
			if (ch == "\n") {
				++_line;
				_charLineIndex = 0;
			}
			else if (ch != "\r") ++_charLineIndex;
			
			if (_parseIndex >= getTextData().length)
				_reachedEOF = true;
			
			return ch;
		}
		
		private function putBack() : void
		{
			_parseIndex--;
			_charLineIndex--;
			_reachedEOF = _parseIndex >= getTextData().length;
		}
		
		private function getNextInt() : int
		{
			var i : Number = parseInt(getNextToken());
			if (isNaN(i))
				sendParseError("int type");
			return i;
		}
		
		private function getNextNumber() : Number
		{
			var f : Number = parseFloat(getNextToken());
			if (isNaN(f))
				sendParseError("float type");
			return f;
		}
		
		private function sendEOFError() : void
		{
			throw new Error("Unexpected end of file");
		}
		
		private function sendParseError(expected : String) : void
		{
			throw new Error("Unexpected token at line " + (_line + 1) + ", character " + _charLineIndex + ". " + expected + " expected, but " + getTextData().charAt(_parseIndex - 1) + " encountered");
		}
		
		private function sendUnknownKeywordError() : void
		{
			throw new Error("Unknown keyword at line " + (_line + 1) + ", character " + _charLineIndex + ". ");
		}
	}
}