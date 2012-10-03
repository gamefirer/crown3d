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

package pl.bmnet.gpcas.geometry {
	import flash.geom.Point;

public interface Poly
{
   // ----------------------
   // --- Public Methods ---
   // ----------------------
   /**
    * Remove all of the points.  Creates an empty polygon.
    */
   function clear():void ;
   
   /**
    * Add a point to the first inner polygon.
    */
   function add(... args):void;
    
   function addPointXY( x:Number, y:Number):void ;
   
   /**
    * Add a point to the first inner polygon.
    */
   function addPoint( p:Point):void ;
   
   /**
    * Add an inner polygon to this polygon - assumes that adding polygon does not
    * have any inner polygons.
    */
   function addPoly( p:Poly):void ;
   
   /**
    * Return true if the polygon is empty
    */
   function isEmpty():Boolean ;
   
   /**
    * Returns the bounding rectangle of this polygon.
    */
   function getBounds():Rectangle ;
   
   /**
    * Returns the polygon at this index.
    */
   function getInnerPoly( polyIndex:int):Poly ;
   
   /**
    * Returns the number of inner polygons - inner polygons are assumed to return one here.
    */
   function getNumInnerPoly():int ;   
   
   /**
    * Return the number points of the first inner polygon
    */
   function getNumPoints():int ;
   
   /**
    * Return the X value of the point at the index in the first inner polygon
    */
   function getX( index:int):Number ;
   
   /**
    * Return the Y value of the point at the index in the first inner polygon
    */
   function getY( index:int):Number ;
   
   function getPoint(index:int):Point;
   
   function getPoints():Array;
   
   /**
    * Return true if this polygon is a hole.  Holes are assumed to be inner polygons of
    * a more complex polygon.
    *
    * @throws IllegalStateException if called on a complex polygon.
    */
   function isHole():Boolean ;
   
   function isPointInside(point:Point):Boolean;
   
   /**
    * Set whether or not this polygon is a hole.  Cannot be called on a complex polygon.
    *
    * @throws IllegalStateException if called on a complex polygon.
    */
   function setIsHole(isHole:Boolean):void ;
   
   /**
    * Return true if the given inner polygon is contributing to the set operation.
    * This method should NOT be used outside the Clip algorithm.
    */
   function isContributing(polyIndex:int):Boolean ;
   
   /**
    * Set whether or not this inner polygon is constributing to the set operation.
    * This method should NOT be used outside the Clip algorithm.
    */
   function setContributing(polyIndex:int, contributes:Boolean):void ;
   
   /**
    * Return a Poly that is the intersection of this polygon with the given polygon.
    * The returned polygon could be complex.
    */
   function intersection( p:Poly):Poly ;
      
   /**
    * Return a Poly that is the union of this polygon with the given polygon.
    * The returned polygon could be complex.
    */
   function union( p:Poly):Poly ;
   
   /**
    * Return a Poly that is the exclusive-or of this polygon with the given polygon.
    * The returned polygon could be complex.
    */
   function xor( p:Poly):Poly ;
   
   /**
	* Return a Poly that is the exclusive-or of this polygon with the given polygon.
	* The returned polygon could be complex. TODO
	*/
   function difference(p:Poly):Poly;
   
   /**
    * Return the area of the polygon in square units.
    */
   function getArea():Number ;
}
}
