/**
 * This license does NOT supersede the original license of GPC.  Please see:
 * http://www.cs.man.ac.uk/~toby/alan/software/#Licensing
 *
 * This license does NOT supersede the original license of SEISW GPC Java port.  Please see:
 * http://www.seisw.com/GPCJ/GpcjLicenseAgreement.txt
 *
 * Copyright (c) 2009, Jakub Kaniewski, jakub.kaniewsky@gmail.com
 * BMnet software http://www.bmnet.pl/
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *   - Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   - Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *   - Neither the name of the BMnet software nor the
 *     names of its contributors may be used to endorse or promote products
 *     derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY JAKUB KANIEWSKI, BMNET ''AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL JAKUB KANIEWSKI, BMNET BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

package pl.bmnet.gpcas.util
{
	import flash.geom.Point;
	

	
	public class ArrayHelper
	{
		public function ArrayHelper()
		{
		}
		
		public static function create2DArray(x:int,y:int):Array{
			var a : Array = new Array(x);
			for (var i:int=0; i<x; i++){
				a[i]=new Array(y);
			}
			return a;
		}
		
		public static function valueEqual(obj1:Object, obj2:Object):Boolean{
			if (obj1==obj2) return true;
			try{
				if (obj1.equals(obj2)==true) return true;
			} catch (e:Error){};
			return false;
		}
		
		public static function sortPointsClockwise(vertices:Object):Object{
			var isArrayList : Boolean = false;
			if (vertices is ArrayList){
				vertices=(vertices as ArrayList).toArray();
				isArrayList=true;
			}
			var maxTop  	: Point = null;
			var maxBottom 	: Point = null;
			var maxLeft  	: Point = null;
			var maxRight 	: Point = null;
			var maxLeftIndex : int;
			var newVertices : Array =vertices as Array;
			for (var i : int = 0; i<vertices.length; i++){
				var vertex : Point = vertices[i] as Point;
				if ((maxTop==null)||(maxTop.y>vertex.y)||((maxTop.y==vertex.y)&&(vertex.x<maxTop.x))){
						maxTop=vertex;	
				}
				if ((maxBottom==null)||(maxBottom.y<vertex.y)||((maxBottom.y==vertex.y)&&(vertex.x>maxBottom.x))){
						maxBottom=vertex;	
				}
 				if ((maxLeft==null)||(maxLeft.x>vertex.x)||((maxLeft.x==vertex.x)&&(vertex.y>maxLeft.y))){
						maxLeft=vertex;
						maxLeftIndex=i;	
				} 
				if ((maxRight==null)||(maxRight.x<vertex.x)||((maxRight.x==vertex.x)&&(vertex.y<maxRight.y))){
						maxRight=vertex;	
				}
			}
			
			if (maxLeftIndex>0){
				newVertices = new Array(vertices.length);
				var j : int = 0;
				for (i=maxLeftIndex; i<vertices.length;i++){
					newVertices[j++]=vertices[i];
				}
				for (i=0; i<maxLeftIndex; i++){
					newVertices[j++]=vertices[i];
				}
				vertices=newVertices;
			}
			var reverse  : Boolean = false;
			for each (var vertex1 : Point in  vertices){
				if (vertex1.equals(maxBottom)){
					reverse=true;
					break;
				} else if (vertex1.equals(maxTop)){
					break;
				} 
			}
			if (reverse){
				newVertices=new Array(vertices.length);
				newVertices[0]=vertices[0];
				var k : int=1;
				for (i=vertices.length-1; i>0; i--){
					newVertices[k++]=vertices[i];
				}
				vertices=newVertices;
			}
			return (isArrayList?(new ArrayList(vertices as Array)):(vertices as Array));
		}
		
	}
}
