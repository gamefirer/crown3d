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

package pl.bmnet.gpcas.geometry
{
	import flash.geom.Point;
	
	
	public class Polygon
	{
		private var maxTop : Point;
		private var maxBottom : Point;
		private var maxLeft : Point;
		private var maxRight : Point;
		public var vertices : Array /* of Point */;
		
		public function Polygon(){
		}
		
		public function fromArray(v:Array):void{
			vertices = [];
			for each (var pointArr : Array in v){
				vertices.push(new Point(pointArr[0],pointArr[1]));
			} 
		}
		
		/*Normalize vertices in polygon to be ordered clockwise from most left point*/
		public function normalize():void{
			var maxLeftIndex : int;
			var newVertices : Array =vertices;
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
				for (var i:int=maxLeftIndex; i<vertices.length;i++){
					newVertices[j++]=vertices[i];
				}
				for (var i:int=0; i<maxLeftIndex; i++){
					newVertices[j++]=vertices[i];
				}
				vertices=newVertices;
			}
			var reverse  : Boolean = false;
			for each (var vertex : Point in  vertices){
				if (vertex.equals(maxBottom)){
					reverse=true;
					break;
				} else if (vertex.equals(maxTop)){
					break;
				} 
			}
			if (reverse){
				newVertices=new Array(vertices.length);
				newVertices[0]=vertices[0];
				var j : int=1;
				for (var i:int=vertices.length-1; i>0; i--){
					newVertices[j++]=vertices[i];
				}
				vertices=newVertices;
			}
		}
		
		public function getVertexIndex(vertex:Point):int{
			for (var i:int=0; i<vertices.length; i++){
				if ((vertices[i] as Point).equals(vertex)){
					return i;
				}
			}
			return -1;
		}
		
		public function insertVertex(vertex1:Point,vertex2:Point, newVertex:Point):Boolean{
			var vertex1Index : int = getVertexIndex(vertex1);
			var vertex2Index  : int = getVertexIndex(vertex2);
			if ((vertex1Index==-1)||(vertex2Index==-1)){
				return false;
			}
			if (vertex2Index<vertex1Index){
				var i : int = vertex1Index;
				vertex1Index=vertex2Index;
				vertex2Index=i;
			}
			if (vertex2Index==vertex1Index+1){
				var newVertices : Array = new Array(vertices.length+1);
				for (var i : int=0; i<=vertex1Index; i++){
					newVertices[i]=vertices[i];
				}
				newVertices[vertex2Index]=newVertex;
				for (var i : int=vertex2Index; i<vertices.length; i++){
					newVertices[i+1]=vertices[i];
				}
				vertices=newVertices;
			} else if ((vertex2Index==vertices.length-1)&&(vertex1Index==0)){
				vertices.push(newVertex);
			}
			return true;
		}
		
		public function clone():Polygon{
			var res : Polygon = new Polygon();
			res.vertices=vertices.slice(vertices.length-1);
			return res;
		}
		
		public function toString():String{
			var res : String = "[";
			for (var i :int =0; i<vertices.length; i++){
				var vertex : Point = vertices[i] as Point;
				res+=(i>0?",":"")+"["+vertex.x+","+vertex.y+"]";
			}
			res+="]";
			return res;
		}
		
		

	}
}
