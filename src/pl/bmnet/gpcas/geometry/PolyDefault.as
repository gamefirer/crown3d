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
	
	import pl.bmnet.gpcas.util.ArrayHelper;
	import pl.bmnet.gpcas.util.ArrayList;
	import pl.bmnet.gpcas.util.List;
	

/**
 * <code>PolyDefault</code> is a default <code>Poly</code> implementation.  
 * It provides support for both complex and simple polygons.  A <i>complex polygon</i> 
 * is a polygon that consists of more than one polygon.  A <i>simple polygon</i> is a 
 * more traditional polygon that contains of one inner polygon and is just a 
 * collection of points.
 * <p>
 * <b>Implementation Note:</b> If a point is added to an empty <code>PolyDefault</code>
 * object, it will create an inner polygon of type <code>PolySimple</code>.
 *
 * @see PolySimple
 *
 * @author  Dan Bridenbecker, Solution Engineering, Inc.
 */
public class PolyDefault implements Poly
{
   // -----------------
   // --- Constants ---
   // -----------------
   
   // ------------------------
   // --- Member Variables ---
   // ------------------------
   /**
    * Only applies to the first poly and can only be used with a poly that contains one poly
    */
   private   var m_IsHole:Boolean= false ;
   protected var m_List:List= new ArrayList();
   
   // --------------------
   // --- Constructors ---
   // --------------------
   public function PolyDefault( isHole:Boolean = false)
   {
      m_IsHole = isHole ;
   }
   
   // ----------------------
   // --- Object Methods ---
   // ----------------------
   /**
    * Return true if the given object is equal to this one.
    */
   public function equals( obj:Object):Boolean {
      if( !(obj is PolyDefault) )
      {
         return false;
      }
      var that:PolyDefault= PolyDefault(obj);

      if( this.m_IsHole != that.m_IsHole ) return false ;
      if( !this.m_List.equals( that.m_List ) ) return false ;
      
      return true ;
   }
   
   /**
    * Return the hashCode of the object.
    *
    * @return an integer value that is the same for two objects
    * whenever their internal representation is the same (equals() is true)
    **/
   public function hashCode():int {
      var result:int= 17;
      result = 37*result + m_List.hashCode();
      return result;
   }
   
   
   
   // ----------------------
   // --- Public Methods ---
   // ----------------------
   /**
    * Remove all of the points.  Creates an empty polygon.
    */
   public function clear():void {
      m_List.clear();
   }
   
   public function add(... args):void{
   	if (args.length==2){
		addPointXY(args[0] as Number, args[1] as Number);
   	} else if (args.length==1){
   		if (args[0] is Point){
   			addPoint(args[0] as Point);	
   		} else if (args[0] is Poly){
   			addPoly(args[0] as Poly);
   		} else if (args[0] is Array){
   			var arr : Array = args[0] as Array;
   			if ((arr.length==2)&&(arr[0] is Number)&&(arr[1] is Number)){
   				add(arr[0] as Number,arr[1] as Number)
   			} else {
   				for each (var val : Object in args[0] as Array){
   					add(val);
   				}
   			}
   		}
   	}
   }
   
   /**
    * Add a point to the first inner polygon.
    * <p>
    * <b>Implementation Note:</b> If a point is added to an empty PolyDefault object,
    * it will create an inner polygon of type <code>PolySimple</code>.
    */
   public function addPointXY(x:Number, y:Number):void {
      addPoint( new Point( x, y ) );
   }
   
   /**
    * Add a point to the first inner polygon.
    * <p>
    * <b>Implementation Note:</b> If a point is added to an empty PolyDefault object,
    * it will create an inner polygon of type <code>PolySimple</code>.
    */
   public function addPoint( p:Point):void {
      if( m_List.size() == 0)
      {
         m_List.add( new PolySimple() );
      }
      (Poly(m_List.get(0))).addPoint( p );
   }
   
   /**
    * Add an inner polygon to this polygon - assumes that adding polygon does not
    * have any inner polygons.
    *
    * @throws IllegalStateException if the number of inner polygons is greater than
    * zero and this polygon was designated a hole.  This would break the assumption
    * that only simple polygons can be holes.
    */
   public function addPoly( p:Poly):void {
      if( (m_List.size() > 0) && m_IsHole )
      {
         throw new Error("Cannot add polys to something designated as a hole.");
      }
      m_List.add( p );
   }
   
   /**
    * Return true if the polygon is empty
    */
   public function isEmpty():Boolean {
      return m_List.isEmpty();
   }
   
   /**
    * Returns the bounding rectangle of this polygon.
    * <strong>WARNING</strong> Not supported on complex polygons.
    */
   public function getBounds():Rectangle {
      if( m_List.size() == 0)
      {
         return new Rectangle();
      }
      else if( m_List.size() == 1)
      {
         var ip:Poly= getInnerPoly(0);
         return ip.getBounds();
      }
      else
      {
         throw new Error("getBounds not supported on complex poly.");
      }
   }
   
   /**
    * Returns the polygon at this index.
    */
   public function getInnerPoly(polyIndex:int):Poly {
      return m_List.get(polyIndex) as Poly;
   }
   
   /**
    * Returns the number of inner polygons - inner polygons are assumed to return one here.
    */
   public function getNumInnerPoly():int {
      return m_List.size();
   }
   
   /**
    * Return the number points of the first inner polygon
    */
   public function getNumPoints():int {
      return (Poly(m_List.get(0))).getNumPoints() ;
   }
   
   /**
    * Return the X value of the point at the index in the first inner polygon
    */
   public function getX(index:int):Number {
      return (Poly(m_List.get(0))).getX(index) ;
   }
   
   public function getPoint(index:int):Point{
		return (Poly(m_List.get(0))).getPoint(index) ;
   }
   
   public function getPoints():Array{
		return (Poly(m_List.get(0))).getPoints();
   }
   
   
   public function isPointInside(point:Point):Boolean{
   		if (!(Poly(m_List.get(0))).isPointInside(point)) return false;
   		for (var i : int = 0; i<m_List.size(); i++){
   			var poly : Poly = m_List.get(i) as Poly;
   			if ((poly.isHole())&&(poly.isPointInside(point))) return false;
   		}
   		return true;
   }
   
   /**
    * Return the Y value of the point at the index in the first inner polygon
    */
   public function getY(index:int):Number {
      return (Poly(m_List.get(0))).getY(index) ;
   }
   
   /**
    * Return true if this polygon is a hole.  Holes are assumed to be inner polygons of
    * a more complex polygon.
    *
    * @throws IllegalStateException if called on a complex polygon.
    */
   public function isHole():Boolean {
      if( m_List.size() > 1)
      {
         throw new Error( "Cannot call on a poly made up of more than one poly." );
      }
      return m_IsHole ;
   }
   
   /**
    * Set whether or not this polygon is a hole.  Cannot be called on a complex polygon.
    *
    * @throws IllegalStateException if called on a complex polygon.
    */
   public function setIsHole( isHole:Boolean):void {
      if( m_List.size() > 1)
      {
         throw new Error( "Cannot call on a poly made up of more than one poly." );
      }
      m_IsHole = isHole ;
   }
   
   /**
    * Return true if the given inner polygon is contributing to the set operation.
    * This method should NOT be used outside the Clip algorithm.
    */
   public function isContributing( polyIndex:int):Boolean {
      return (Poly(m_List.get(polyIndex))).isContributing(0);
   }
   
   /**
    * Set whether or not this inner polygon is constributing to the set operation.
    * This method should NOT be used outside the Clip algorithm.
    *
    * @throws IllegalStateException if called on a complex polygon
    */
   public function setContributing( polyIndex:int, contributes:Boolean):void {
      if( m_List.size() != 1)
      {
         throw new Error( "Only applies to polys of size 1" );
      }
      (Poly(m_List.get(polyIndex))).setContributing( 0, contributes );
   }
   
   /**
    * Return a Poly that is the intersection of this polygon with the given polygon.
    * The returned polygon could be complex.
    *
    * @return the returned Poly will be an instance of PolyDefault.
    */
   public function intersection(p:Poly):Poly {
      return Clip.intersection( p, this, "PolyDefault");
   }
   
   /**
    * Return a Poly that is the union of this polygon with the given polygon.
    * The returned polygon could be complex.
    *
    * @return the returned Poly will be an instance of PolyDefault.
    */
   public function union(p:Poly):Poly {
      return Clip.union( p, this, "PolyDefault");
   }
   
   /**
    * Return a Poly that is the exclusive-or of this polygon with the given polygon.
    * The returned polygon could be complex.
    *
    * @return the returned Poly will be an instance of PolyDefault.
    */
   public function xor(p:Poly):Poly {
      return Clip.xor( p, this, "PolyDefault" );
   }
   
   /**
	* Return a Poly that is the difference of this polygon with the given polygon.
	* The returned polygon could be complex.
	*
	* @return the returned Poly will be an instance of PolyDefault.
	*/
   public function difference(p:Poly):Poly{
	   return Clip.difference(p,this,"PolyDefault");
   }
   
   /**
    * Return the area of the polygon in square units.
    */
   public function getArea():Number {
      var area:Number= 0.0;
      for( var i:int= 0; i < getNumInnerPoly() ; i++ )
      {
         var p:Poly= getInnerPoly(i);
         var tarea:Number= p.getArea() * (p.isHole() ? -1.0: 1.0);
         area += tarea ;
      }
      return area ;
   }

   // -----------------------
   // --- Package Methods ---
   // -----------------------
   public function toString():String {
      var res :String = "";
      for( var i:int= 0; i < m_List.size() ; i++ )
      {
         var p:Poly= getInnerPoly(i);
         res+=("InnerPoly("+i+").hole="+p.isHole() + " numPoly= " + p.getNumInnerPoly());
         var points : Array = [];
         for( var j:int= 0; j < p.getNumPoints() ; j++ )
         {
         	points.push(new Point(p.getX(j),p.getY(j)));
         }
         points = ArrayHelper.sortPointsClockwise(points) as Array;
         for each (var pt : Point in points){
         	res+=pt.toString();
         }
		 res+="\n";
      }
      return res;
   }
   
}
}
