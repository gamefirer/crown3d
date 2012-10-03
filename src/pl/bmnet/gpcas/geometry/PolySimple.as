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
	
	import pl.bmnet.gpcas.util.ArrayList;
	import pl.bmnet.gpcas.util.List;
	


/**
 * <code>PolySimple</code> is a simple polygon - contains only one inner polygon.
 * <p>
 * <strong>WARNING:</strong> This type of <code>Poly</code> cannot be used for an
 * inner polygon that is a hole.
 *
 * @author  Dan Bridenbecker, Solution Engineering, Inc.
 */
public class PolySimple implements Poly
{
   // -----------------
   // --- Constants ---
   // -----------------
   
   // ------------------------
   // --- Member Variables ---
   // ------------------------
   /**
    * The list of Point objects in the polygon.
    */
   protected var m_List:List= new ArrayList();

   /** Flag used by the Clip algorithm */
   private var m_Contributes:Boolean= true ;
   
   // --------------------
   // --- Constructors ---
   // --------------------
   /** Creates a new instance of PolySimple */
   public function PolySimple()
   {
   }
   
   // ----------------------
   // --- Object Methods ---
   // ----------------------
   /**
    * Return true if the given object is equal to this one.
    * <p>
    * <strong>WARNING:</strong> This method failse if the first point
    * appears more than once in the list.
    */
   public function equals( obj:Object):Boolean {
      if( !(obj is PolySimple) )
      {
         return false;
      }
      var that:PolySimple= PolySimple(obj);
      
      var this_num:int= this.m_List.size();
      var that_num:int= that.m_List.size();
      if( this_num != that_num ) return false ;
      
      // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      // !!! WARNING: This is not the greatest algorithm.  It fails if !!!
      // !!! the first point in "this" poly appears more than once.    !!!
      // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      if( this_num > 0)
      {
         var this_x:Number= this.getX(0);
         var this_y:Number= this.getY(0);
         var that_first_index:int= -1;
		 var that_x:Number;
		 var that_y:Number;
         for( var that_index:int= 0; (that_first_index == -1) && (that_index < that_num) ; that_index++ )
         {
            that_x = that.getX(that_index);
            that_y = that.getY(that_index);
            if( (this_x == that_x) && (this_y == that_y) )
            {
               that_first_index = that_index ;
            }
         }
         if( that_first_index == -1) return false ;
         that_index = that_first_index ;
         for( var this_index:int= 0; this_index < this_num ; this_index++ )
         {
            this_x = this.getX(this_index);
            this_y = this.getY(this_index);
            that_x = that.getX(that_index);
            that_y = that.getY(that_index);
            
            if( (this_x != that_x) || (this_y != that_y) ) return false;
               
            that_index++ ;
            if( that_index >= that_num )
            {
               that_index = 0;
            }
         }
      }
      return true ;
   }
   
   /**
    * Return the hashCode of the object.
    * <p>
    * <strong>WARNING:</strong>Hash and Equals break contract.
    *
    * @return an integer value that is the same for two objects
    * whenever their internal representation is the same (equals() is true)
    */
   public function hashCode():int {
      // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      // !!! WARNING:  This hash and equals break the contract. !!!
      // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      var result:int= 17;
      result = 37*result + m_List.hashCode();
      return result;
   }
   
   /**
    * Return a string briefly describing the polygon.
    */
   public function toString():String {
      return "PolySimple: num_points="+getNumPoints();
   }
   
   // --------------------
   // --- Poly Methods ---
   // --------------------
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
   			for each (var val : Object in args[0] as Array){
   				add(val);
   			}
   		}
   	}
 	}
   	
   
   /**
    * Add a point to the first inner polygon.
    */
   public function addPointXY(x:Number, y:Number):void {
      addPoint( new Point( x, y ) );
   }
   
   /**
    * Add a point to the first inner polygon.
    */
   public function addPoint(p:Point):void {
      m_List.add( p );
   }
   
   /**
    * Throws IllegalStateexception if called
    */
   public function addPoly(p:Poly):void {
      throw new Error("Cannot add poly to a simple poly.");
   }
   
   /**
    * Return true if the polygon is empty
    */
   public function isEmpty():Boolean {
      return m_List.isEmpty();
   }
   
   /**
    * Returns the bounding rectangle of this polygon.
    */
   public function getBounds():Rectangle {
      var xmin:Number=  Number.MAX_VALUE ;
      var ymin:Number=  Number.MAX_VALUE ;
      var xmax:Number= -Number.MAX_VALUE ;
      var ymax:Number= -Number.MAX_VALUE ;
      
      for( var i:int= 0; i < m_List.size() ; i++ )
      {
         var x:Number= getX(i);
         var y:Number= getY(i);
         if( x < xmin ) xmin = x;
         if( x > xmax ) xmax = x;
         if( y < ymin ) ymin = y;
         if( y > ymax ) ymax = y;
      }
      
      return new Rectangle( xmin, ymin, (xmax-xmin), (ymax-ymin) );
   }
   
   /**
    * Returns <code>this</code> if <code>polyIndex = 0</code>, else it throws
    * IllegalStateException.
    */
   public function getInnerPoly(polyIndex:int):Poly {
      if( polyIndex != 0)
      {
         throw new Error("PolySimple only has one poly");
      }
      return this ;
   }
   
   /**
    * Always returns 1.
    */
   public function getNumInnerPoly():int {
      return 1;
   }
   
   /**
    * Return the number points of the first inner polygon
    */
   public function getNumPoints():int {
      return m_List.size();
   }   

   /**
    * Return the X value of the point at the index in the first inner polygon
    */
   public function getX(index:int):Number {
      return (Point(m_List.get(index))).x;
   }
   
   /**
    * Return the Y value of the point at the index in the first inner polygon
    */
   public function getY(index:int):Number {
      return (Point(m_List.get(index))).y;
   }
   
   public function getPoint(index:int):Point{
		return (Point(m_List.get(index)));
   }
   
   public function getPoints():Array{
		return m_List.toArray();
   }
   
   public function isPointInside(point:Point):Boolean{
         var points : Array = getPoints();  
         var j : int  = points.length - 1;              
         var oddNodes: Boolean = false;              
                                                     
         for (var i : int = 0; i < points.length; i++)  
         {                                            
             if (points[i].y < point.y && points[j].y >= point.y ||  
                 points[j].y < point.y && points[i].y >= point.y)    
             {                                                                   
                 if (points[i].x +                                          
                     (point.y - points[i].y)/(points[j].y - points[i].y)*(points[j].x - points[i].x) < point.x)  
                 {                                                                                                                          
                     oddNodes = !oddNodes;                                                                                                  
                 }                                                                                                                          
             }                                                                                                                              
             j = i;                                                                                                                         
         }                                                                                                                                  
         return oddNodes;                                                                                                                   
   }              
   
   
   /**
    * Always returns false since PolySimples cannot be holes.
    */
   public function isHole():Boolean {
      return false ;
   }
   
   /**
    * Throws IllegalStateException if called.
    */
   public function setIsHole(isHole:Boolean):void {
      throw new Error("PolySimple cannot be a hole");
   }
   
   /**
    * Return true if the given inner polygon is contributing to the set operation.
    * This method should NOT be used outside the Clip algorithm.
    *
    * @throws IllegalStateException if <code>polyIndex != 0</code>
    */
   public function isContributing( polyIndex:int):Boolean {
      if( polyIndex != 0)
      {
         throw new Error("PolySimple only has one poly");
      }
      return m_Contributes ;
   }
   
   /**
    * Set whether or not this inner polygon is constributing to the set operation.
    * This method should NOT be used outside the Clip algorithm.
    *
    * @throws IllegalStateException if <code>polyIndex != 0</code>
    */
   public function setContributing( polyIndex:int, contributes:Boolean):void {
      if( polyIndex != 0)
      {
         throw new Error("PolySimple only has one poly");
      }
      m_Contributes = contributes ;
   }
   
   /**
    * Return a Poly that is the intersection of this polygon with the given polygon.
    * The returned polygon is simple.
    *
    * @return The returned Poly is of type PolySimple
    */
   public function intersection(p:Poly):Poly {
      return Clip.intersection( this, p,"PolySimple");
   }
   
   /**
    * Return a Poly that is the union of this polygon with the given polygon.
    * The returned polygon is simple.
    *
    * @return The returned Poly is of type PolySimple
    */
   public function union(p:Poly):Poly {
      return Clip.union( this, p, "PolySimple");
   }
   
   /**
    * Return a Poly that is the exclusive-or of this polygon with the given polygon.
    * The returned polygon is simple.
    *
    * @return The returned Poly is of type PolySimple
    */
   public function xor(p:Poly):Poly {
      return Clip.xor( p, this, "PolySimple");
   }
   
   /**
	* Return a Poly that is the difference of this polygon with the given polygon.
	* The returned polygon could be complex.
	*
	* @return the returned Poly will be an instance of PolyDefault.
	*/
   public function difference(p:Poly):Poly{
	  return Clip.difference(p,this,"PolySimple");
   }
         
   /**
    * Returns the area of the polygon.
    * <p>
    * The algorithm for the area of a complex polygon was take from
    * code by Joseph O'Rourke author of " Computational Geometry in C".
    */
   public function getArea():Number {
      if( getNumPoints() < 3)
      {
         return 0.0;
      }
      var ax:Number= getX(0);
      var ay:Number= getY(0);
      var area:Number= 0.0;
      for( var i:int= 1; i < (getNumPoints()-1) ; i++ )
      {
         var bx:Number= getX(i);
         var by:Number= getY(i);
         var cx:Number= getX(i+1);
         var cy:Number= getY(i+1);
         var tarea:Number= ((cx - bx)*(ay - by)) - ((ax - bx)*(cy - by));
         area += tarea ;
      }
      area = 0.5*Math.abs(area);
      return area ;
   }
   
   // -----------------------
   // --- Package Methods ---
   // -----------------------
}
}
