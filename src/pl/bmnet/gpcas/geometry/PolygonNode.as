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


   /**
    * Internal contour / tristrip type
    */
   public class PolygonNode
   {
      public var active:int;                 /* Active flag / vertex count        */
	  public var hole:Boolean;                   /* Hole / external contour flag      */
	  public var v:Array= new Array(2) ; /* Left and right vertex list ptrs   */
	  public var next:PolygonNode;                   /* Pointer to next polygon contour   */
	  public var proxy:PolygonNode;                  /* Pointer to actual structure used  */
      
      public function PolygonNode( next:PolygonNode, x:Number, y:Number)
      {
         /* Make v[Clip.LEFT] and v[Clip.RIGHT] point to new vertex */
         var vn:VertexNode= new VertexNode( x, y );
         this.v[Clip.LEFT ] = vn ;
         this.v[Clip.RIGHT] = vn ;
         
         this.next = next ;
         this.proxy = this ; /* Initialise proxy to point to p itself */
         this.active = 1; //TRUE
      }
      
      public function add_right( x:Number, y:Number):void {
         var nv:VertexNode= new VertexNode( x, y );
         
         /* Add vertex nv to the right end of the polygon's vertex list */
         proxy.v[Clip.RIGHT].next= nv;
         
         /* Update proxy->v[Clip.RIGHT] to point to nv */
         proxy.v[Clip.RIGHT]= nv;
      }
      
      public function add_left( x:Number, y:Number):void {
         var nv:VertexNode= new VertexNode( x, y );
         
         /* Add vertex nv to the left end of the polygon's vertex list */
         nv.next= proxy.v[Clip.LEFT];
         
         /* Update proxy->[Clip.LEFT] to point to nv */
         proxy.v[Clip.LEFT]= nv;
      }

   }


}
