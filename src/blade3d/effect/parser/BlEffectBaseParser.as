package blade3d.effect.parser
{
	import away3d.animators.BlUVAnimator;
	import away3d.animators.ColorAnimator;
	import away3d.animators.PathAnimator;
	import away3d.animators.RotateAnimator;
	import away3d.animators.ScaleAnimator;
	import away3d.animators.data.ColorAnimationFrame;
	import away3d.animators.data.ColorAnimationSequence;
	import away3d.animators.data.PathAnimationFrame;
	import away3d.animators.data.RotateAnimationFrame;
	import away3d.animators.data.RotateAnimationSequence;
	import away3d.animators.data.ScaleAnimationFrame;
	import away3d.animators.data.ScaleAnimationSequence;
	import away3d.animators.data.UVAnimationFrame;
	import away3d.animators.data.UVAnimationSequence;
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Object3D;
	import away3d.debug.Debug;
	import away3d.entities.Mesh;
	import away3d.paths.PathMaker;
	
	import blade3d.resource.BlResourceManager;
	
	import flash.geom.Vector3D;

	public class BlEffectBaseParser
	{
		// 解析 共有基础属性
		static public function parseCommonProperty(xml:XML, object:Object3D) : void
		{
			// 位移
			var pos : Vector3D = parseVector3D(xml.@pos.toString());
			object.x = pos.x;
			object.y = pos.y;
			object.z = pos.z;
			// 旋转
			if(xml.@rot)
			{
				var rot : Vector3D = parseVector3D(xml.@rot.toString());
				object.rotationX = rot.x;
				object.rotationY = rot.y;
				object.rotationZ = rot.z;
			}
			// 名字
//			var label : String = xml.@label.toString();
//			if(label.length > 0)
//			{
//				_labels[label] = object;		// 记录该特效元素
//			}
			// 材质的blendMode
//			var blendMode : String = xml.@blendmode.toString();
//			object.extra2 = blendMode;
		}
		
		static public function parseMeshAnimator(xml:XML, mesh:Mesh) : void
		{
			// UV动画
			var uv_xml : XML = xml.uv[0];
			if(uv_xml)
			{
				mesh.uvAnimator = parseUVAnimation(uv_xml);
			}
			// 颜色动画
			var color_xml : XML = xml.color[0];
			if(color_xml)
			{
				mesh.colorAnimator = parseColorAnimation(color_xml);
			}
			
			parseObject3DAnimator(xml, mesh);
		}
		
		static public function parseObject3DAnimator(xml:XML, object:ObjectContainer3D) : void
		{
			// Path动画
			var path_xml : XML = xml.path[0];
			if(path_xml)
			{
				object.pathAnimator = parsePathAnimation(path_xml);
			}
			// Scale动画
			var scale_xml : XML = xml.scale[0];
			if(scale_xml)
			{
				object.scaleAnimator = parseScaleAnimation(scale_xml);
			}
			// 旋转动画
			var rotate_xml : XML = xml.rotate[0];
			if(rotate_xml)
			{
				object.rotateAnimator = parseRotateAnimation(rotate_xml);
			}
		}
		
		// 旋转动画
		static public function parseRotateAnimation(xml:XML) : RotateAnimator
		{
			var rotateAnimator : RotateAnimator= new RotateAnimator(null);
			
			var clip : RotateAnimationSequence = new RotateAnimationSequence("rotate");
			clip.fixedFrameRate = false;
			
			var hasFrame : Boolean = false;
			
			var rotateFrame_xmls : XMLList = xml.frame;
			var frame_xml : XML;
			for each(frame_xml in rotateFrame_xmls)
			{
				var rotateDurTime:int = int(frame_xml.@durtime.toString());
				
				var rotX : Number = Number(frame_xml.@x.toString());
				var rotY : Number = Number(frame_xml.@y.toString());
				var rotZ : Number = Number(frame_xml.@z.toString());
				
				clip.addFrame(new RotateAnimationFrame(rotX, rotY, rotZ), rotateDurTime);
				hasFrame = true;
			}
			
			rotateAnimator.addSequence(clip);
			clip.looping = (xml.@loop.toString() == "false") ? false : true;
			
			if(hasFrame)
				return rotateAnimator;
			else
				return null;
		}		
		// Scale缩放动画
		static public function parseScaleAnimation(xml:XML) : ScaleAnimator
		{
			var scaleAnimator : ScaleAnimator= new ScaleAnimator(null);
			
			var clip : ScaleAnimationSequence = new ScaleAnimationSequence("scale");
			clip.fixedFrameRate = false;
			
			var hasFrame : Boolean = false;
			
			var scaleFrame_xmls : XMLList = xml.frame;
			var frame_xml : XML;
			for each(frame_xml in scaleFrame_xmls)
			{
				var scaleDurTime:int = int(frame_xml.@durtime.toString());
				
				var scaleX : Number = Number(frame_xml.@x.toString());
				var scaleY : Number = Number(frame_xml.@y.toString());
				var scaleZ : Number = Number(frame_xml.@z.toString());
				
				clip.addFrame(new ScaleAnimationFrame(scaleX, scaleY, scaleZ), scaleDurTime);
				hasFrame = true;
			}
			
			scaleAnimator.addSequence(clip);
			clip.looping = (xml.@loop.toString() == "false") ? false : true;
			if(hasFrame)
				return scaleAnimator;
			else
				return null;
		}		
		// UV动画
		public static function parseUVAnimation(xml:XML) : BlUVAnimator
		{
			var uvAnimator : BlUVAnimator = new BlUVAnimator(null);
			uvAnimator.smooth = (xml.@smooth.toString() == "true");
			uvAnimator.repeat = (xml.@repeat.toString() == "true");
			
			var clip : UVAnimationSequence = new UVAnimationSequence("uv");
			clip.fixedFrameRate = false;
			
			var hasFrame : Boolean = false;
			
			var uvFrame_xmls : XMLList = xml.frame;
			var frame_xml : XML;
			for each(frame_xml in uvFrame_xmls)
			{
				var uvDurTime:int = int(frame_xml.@durtime.toString());
				
				var offsetU : Number = Number(frame_xml.@u.toString());
				var offsetV : Number = Number(frame_xml.@v.toString());
				var scaleU : Number = Number(frame_xml.@su.toString());
				var scaleV : Number = Number(frame_xml.@sv.toString());
				var rot : Number = Number(frame_xml.@r.toString());
				clip.addFrame(new UVAnimationFrame(offsetU, offsetV, scaleU, scaleV, rot), uvDurTime);
				hasFrame = true;
			}
			
			uvAnimator.addSequence(clip);
			if(hasFrame)
				return uvAnimator;
			else
				return null;
		}
		// 颜色动画
		public static function parseColorAnimation(xml:XML) : ColorAnimator
		{
			var colorAnimator : ColorAnimator = new ColorAnimator(null);
			
			var clip : ColorAnimationSequence = new ColorAnimationSequence("color");
			clip.fixedFrameRate = false;
			
			var hasFrame : Boolean = false;
			
			var colorFrame_xmls : XMLList = xml.frame;
			var frame_xml : XML;
			for each(frame_xml in colorFrame_xmls)
			{
				var clrDurTime:int = int(frame_xml.@durtime.toString());
				
				var A : int = int(frame_xml.@a.toString());
				var R : int = int(frame_xml.@r.toString());
				var G : int = int(frame_xml.@g.toString());
				var B : int = int(frame_xml.@b.toString());
				
				clip.addFrame(new ColorAnimationFrame(A, R, G, B), clrDurTime);
				hasFrame = true;
			}
			
			colorAnimator.addSequence(clip);
			
			if(hasFrame)
				return colorAnimator;
			else
				return null;
		}
		// Path动画
		public static function parsePathAnimation(xml:XML) : PathAnimator
		{
			var pathPoint_xmls : XMLList = xml.frame;
			var pathPoint_xml : XML;
			
			var hasFrame : Boolean = false;
			
			var pathData : Vector.<PathAnimationFrame> = new Vector.<PathAnimationFrame>();
			
			for each(pathPoint_xml in pathPoint_xmls)
			{	
				var pathKeyFrame : PathAnimationFrame = new PathAnimationFrame;
				pathKeyFrame.durtime = uint(pathPoint_xml.@durtime.toString());
				
				pathKeyFrame.pos.x = Number(pathPoint_xml.@x.toString());
				pathKeyFrame.pos.y = Number(pathPoint_xml.@y.toString());
				pathKeyFrame.pos.z = Number(pathPoint_xml.@z.toString());
				
				pathData.push(pathKeyFrame);
				hasFrame = true;
			}		
			
			if(!hasFrame)
				return null;
			
			var pathMaker : PathMaker = new PathMaker;
			
			for(var i:int=0; i<pathData.length; i++)
			{
				pathMaker.duration += pathData[i].durtime;
				pathMaker.pointData.push(pathData[i].pos);
			}

			var pathAnimator : PathAnimator = new PathAnimator(pathMaker);
			return pathAnimator;
		}
		
		// 解析 3元向量
		static public function parseVector3D(vectorString : String) : Vector3D
		{
			var vec : Vector3D = new Vector3D();
			var numberString : String = "";
			var negative : Boolean = false;
			
			var i:int;
			var j:int = 0;
			for(i=0; i<=vectorString.length; i++)
			{
				if( i != vectorString.length &&
					vectorString.charAt(i) >= '0' && vectorString.charAt(i) <= '9')
				{
					numberString += vectorString.charAt(i);
				}
				else if(i != vectorString.length &&
					vectorString.charAt(i) == '-')
				{
					negative = true;
				}
				else 
				{
					if(numberString.length > 0)
					{
						var f : Number = parseFloat(numberString);
						if (isNaN(f))
							throw new Error("effect loader parse vector error");
						if(negative)
							f = -f;						
						
						if(j==0)
							vec.x = f;
						else if(j==1)
							vec.y = f;
						else
							vec.z = f;
						
						negative = false;						
						j++;
						numberString = "";
					}
					if(j == 3)
						break;
				}
			}
			
			return vec;
		}
		// 解析 资源名(资源的url, 资源所在的目录)
		static public function findValidPath(url:String, path:String):String
		{
			if( BlResourceManager.instance().findResource(url) )
				return url;
			
			url = path + url;
			
			if( BlResourceManager.instance().findResource(url) )
				return url;
			
			Debug.assert(false, "url not exist!");
			return url;
		}
		
	}
}