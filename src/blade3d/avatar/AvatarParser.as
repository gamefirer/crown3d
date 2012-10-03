/**
 *	Avatar文件的解析器 
 */
package blade3d.avatar
{
	import away3d.animators.SkeletonAnimationState;
	import away3d.animators.data.Skeleton;
	import away3d.animators.data.SkeletonJoint;
	import away3d.animators.data.SkeletonKeyframeAnimationSequence;
	import away3d.animators.data.SkeletonPose;
	import away3d.animators.nodes.SkeletonKeyFrameClipNode;
	import away3d.core.math.Quaternion;
	import away3d.loaders.parsers.ParserBase;
	import away3d.loaders.parsers.ParserDataFormat;
	
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;

	public class AvatarParser extends ParserBase
	{
		private static const COMMENT_TOKEN : String = "//";				// 注释
		private static const VERSION_TOKEN : String = "blaversion";
		private static const NUM_BONE_TOKEN : String = "boneNum";
		private static const TEXTURE_TOKEN : String = "tex";
		private static const MESH_TOKEN : String = "mesh";
		private static const HIERARCHY_TOKEN : String = "hierarchy";
		private static const BONES_TOKEN : String = "bones";
		private static const BONETAGS_TOKEN : String = "bonetags";
		private static const ANIMATION_TOKEN : String = "animation";
		
		
		private var _version : int;				// 版本号
		private var _parseIndex : int;				// 第几个字符
		private var _line : int;					// 当前行
		private var _charLineIndex : int;			// 当前列
		private var _reachedEOF : Boolean;
		
		private var _rotationQuat : Quaternion;		// 3dmax空间->flash3d空间转换用
		
		public var _meshNames : Vector.<String> = new Vector.<String>;		// 部件名
		public var _textureFileName : String;			// 贴图名
		private var _numBones : int;
		private var _bindPoses : Vector.<Matrix3D>;
		private var _skeleton : Skeleton;
		// 动画相关
		public var _sequences : Vector.<SkeletonKeyframeAnimationSequence> = new Vector.<SkeletonKeyframeAnimationSequence>;
		
		// 骨骼绑定点相关
		public var _boneTagsName : Vector.<String> = new Vector.<String>;
		public var _boneTagParentIndex : Vector.<int> = new Vector.<int>;
		public var _boneTagMat : Vector.<Matrix3D> = new Vector.<Matrix3D>;
		
		
		public function AvatarParser(url:String)
		{
			super(ParserDataFormat.PLAIN_TEXT);
			this.url = url;
			
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
		public function get bindPose() : Vector.<Matrix3D> {return _bindPoses;}
		public function get skeleton() : Skeleton {return _skeleton;}
		
		protected override function startParsing(frameLimit : Number) : void {
			_reachedEOF = false;
			_parseIndex = 0;
			super.startParsing(frameLimit);
		}
		
		protected override function proceedParsing() : Boolean
		{
			var token : String;
			while (hasTime())
			{
				token = getNextToken();
//				Debug.bltrace(token);
				switch (token) 
				{
					case COMMENT_TOKEN:
						ignoreLine();
						break;
					case VERSION_TOKEN:
						_version = getNextInt();
						if (_version != 1) throw new Error("Unknown version number encountered!");
						break;
					case NUM_BONE_TOKEN:
						_numBones = getNextInt();
						_bindPoses = new Vector.<Matrix3D>(_numBones, true);
						break;
					case TEXTURE_TOKEN:
						_textureFileName = parseLiteralString();
						break;
					case MESH_TOKEN:
						parseMesh();			// 部件mesh
						break;
					case HIERARCHY_TOKEN:
						parseHierarchy();		// 骨骼
						break;
					case BONES_TOKEN:
						parseBones();			// 骨骼位置
						break;
					case BONETAGS_TOKEN:		// 骨骼绑定点
						parseBoneTags();
						break;
					case ANIMATION_TOKEN:
						parseAnimation();		// 动画数据
						break;
				}
				if (_reachedEOF)
				{	// 创建AvatarMesh
					
					return ParserBase.PARSING_DONE;		
				}
			}
			return ParserBase.MORE_TO_PARSE;
		}
		
		private function parseAnimation() : void
		{
			var ch : String;
			var animationName : String; 
			var boneIndex : int;
			var keyFrame : int;
			var keyFramePos : Vector3D;
			var keyFrameQuat : Quaternion;
			var skelPose : SkeletonPose;
			var sequence : SkeletonKeyframeAnimationSequence;
			
			animationName = parseLiteralString();
//			Debug.bltrace("animationName "+animationName);
			var token : String = getNextToken();
			if (token != "{") sendUnknownKeywordError();
			
			sequence = new SkeletonKeyframeAnimationSequence(animationName, _numBones);
			
			do
			{
				if (_reachedEOF) sendEOFError();
				
				token = getNextToken();
				if (token != "bone") sendUnknownKeywordError();
				boneIndex = getNextInt();		// 骨头index
				
				token = getNextToken();
				if (token != "{") sendUnknownKeywordError();
				// parse bone key frame
				do
				{
					token = getNextToken();
					if (token != "time") sendUnknownKeywordError();
								
					keyFrame = getNextInt();
					keyFramePos = parseVector3D();
					keyFrameQuat = parseQuaternion();
					
					skelPose = new SkeletonPose();
					
					sequence.addBoneKeyframe(boneIndex, keyFrame, keyFramePos, keyFrameQuat);			// 3dmax 默认一帧30ms
					
					
					ch = getNextChar();
					if (ch != "}") putBack();
				}while (ch != "}");
				
				skipWhiteSpace();
				
				ch = getNextChar();
				if (ch != "}") putBack();
			}while (ch != "}");
			
			sequence.name = animationName;
			_sequences.push(sequence);
			
		}
		
		private function parseBoneTags() : void
		{
			var boneTagName : String;
			var parentBoneIndex : int;
			var boneTagPos : Vector3D;
			var boneTagQuat : Quaternion;
			var bonePose : Matrix3D;
			var ch : String;
			var token : String = getNextToken();
			
			if (token != "{") sendUnknownKeywordError();
			
			do
			{
				if (_reachedEOF) sendEOFError();
				
				boneTagName = parseLiteralString();
				parentBoneIndex = getNextInt();
				boneTagPos = parseVector3D();
				boneTagQuat = parseQuaternion();
				
				bonePose = boneTagQuat.toMatrix3D();
				bonePose.appendTranslation(boneTagPos.x, boneTagPos.y, boneTagPos.z);
				
				_boneTagsName.push(boneTagName);
				_boneTagParentIndex.push(parentBoneIndex);
				_boneTagMat.push( bonePose );
				
				ch = getNextChar();
				if (ch != "}") putBack();				
			} while (ch != "}");
		}
		
		private function parseBones() : void
		{
			var joint : SkeletonJoint;
			var boneIndex : int;
			var bonePos : Vector3D;
			var boneQuat : Quaternion;
			var ch : String;
			var token : String = getNextToken();
			
			
			if (token != "{") sendUnknownKeywordError();
			
			do
			{
				if (_reachedEOF) sendEOFError();
				boneIndex = getNextInt();
				bonePos = parseVector3D();
				bonePos = _rotationQuat.rotatePoint(bonePos);
				boneQuat = parseQuaternion();
				
				_bindPoses[boneIndex] = boneQuat.toMatrix3D();
				_bindPoses[boneIndex].appendTranslation(bonePos.x, bonePos.y, bonePos.z);
				var inv : Matrix3D = _bindPoses[boneIndex].clone();
				inv.invert();
				
				_skeleton.joints[boneIndex].inverseBindPose = inv.rawData;		// 骨头变换矩阵的逆
				
				ch = getNextChar();
				if (ch != "}") putBack();				
			} while (ch != "}");
		}
		
		private function parseMesh() : void
		{
			var ch : String;
			var token : String = getNextToken();
			
			if (token != "{") sendUnknownKeywordError();
			
			do
			{
				if (_reachedEOF) sendEOFError();
				
				ch = getNextToken();
				_meshNames.push(ch);		// 读入部件名
							
				ch = getNextChar();
				if (ch != "}") putBack();				
			} while (ch != "}");
		}
		
		private function parseHierarchy() : void
		{
			var i : int = 0;
			var ch : String;
			var boneName : String;
			var bone : SkeletonJoint;
			var token : String = getNextToken();
			
			if (token != "{") sendUnknownKeywordError();
			
			_skeleton = new Skeleton();
			
			do
			{
				if (_reachedEOF) sendEOFError();
				
				bone = new SkeletonJoint();
				bone.name = parseLiteralString();
				bone.parentIndex = getNextInt();
				
				_skeleton.joints[i++] = bone;
				
				ch = getNextChar();
				if (ch != "}") putBack();				
			} while (ch != "}");
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