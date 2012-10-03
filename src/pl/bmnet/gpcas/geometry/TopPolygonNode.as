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
	import away3d.debug.Debug;


   public class TopPolygonNode
   {
	   public var top_node:PolygonNode= null ;
      
      public function add_local_min( x:Number, y:Number):PolygonNode {
         var existing_min:PolygonNode= top_node;
         
         top_node = new PolygonNode( existing_min, x, y );
         
         return top_node ;
      }
      
      public function merge_left( p:PolygonNode, q:PolygonNode):void {
         /* Label contour as a hole */
         q.proxy.hole = true ;
         
         if (p.proxy != q.proxy)
         {
            /* Assign p's vertex list to the left end of q's list */
            p.proxy.v[Clip.RIGHT].next= q.proxy.v[Clip.LEFT];
            q.proxy.v[Clip.LEFT]= p.proxy.v[Clip.LEFT];
            
            /* Redirect any p.proxy references to q.proxy */
            var target:PolygonNode= p.proxy ;
            for(var node:PolygonNode= top_node; (node != null); node = node.next)
            {
               if (node.proxy == target)
               {
                  node.active= 0;
                  node.proxy= q.proxy;
               }
            }
         }
      }

      public function merge_right( p:PolygonNode, q:PolygonNode):void {
         /* Label contour as external */
         q.proxy.hole = false ;
         
         if (p.proxy != q.proxy)
         {
            /* Assign p's vertex list to the right end of q's list */
            q.proxy.v[Clip.RIGHT].next= p.proxy.v[Clip.LEFT];
            q.proxy.v[Clip.RIGHT]= p.proxy.v[Clip.RIGHT];
            
            /* Redirect any p->proxy references to q->proxy */
            var target:PolygonNode= p.proxy ;
            for (var node:PolygonNode= top_node ; (node != null ); node = node.next)
            {
               if (node.proxy == target)
               {
                  node.active = 0;
                  node.proxy= q.proxy;
               }
            }
         }
      }
      
      public function count_contours():int {
         var nc:int= 0;
         for ( var polygon:PolygonNode= top_node; (polygon != null) ; polygon = polygon.next)
         {
            if (polygon.active != 0)
            {
               /* Count the vertices in the current contour */
               var nv:int= 0;
               for (var v:VertexNode= polygon.proxy.v[Clip.LEFT]; (v != null); v = v.next)
               {
                  nv++;
               }
               
               /* Record valid vertex counts in the active field */
               if (nv > 2)
               {
                  polygon.active = nv;
                  nc++;
               }
               else
               {
                  /* Invalid contour: just free the heap */
//                  VertexNode nextv = null ;
//                  for (VertexNode v= polygon.proxy.v[Clip.LEFT]; (v != null); v = nextv)
//                  {
//                     nextv= v.next;
//                     v = null ;
//                  }
                  polygon.active= 0;
               }
            }
         }
         return nc;
      }
      
      public function getResult( polyClass:String):Poly {
         var result:Poly= Clip.createNewPoly( polyClass );
         var num_contours:int= count_contours();
         if (num_contours > 0)
         {
            var c:int= 0;
            var npoly_node:PolygonNode= null ;
            for (var poly_node:PolygonNode= top_node; (poly_node != null); poly_node = npoly_node)
            {
               npoly_node = poly_node.next;
               if (poly_node.active != 0)
               {
                  var poly:Poly= result ;
                  if( num_contours > 1)
                  {
                     poly = Clip.createNewPoly( polyClass );
                  }
                  if( poly_node.proxy.hole )
                  {
                     poly.setIsHole( poly_node.proxy.hole );
                  }
                  
                  // ------------------------------------------------------------------------
                  // --- This algorithm puts the verticies into the poly in reverse order ---
                  // ------------------------------------------------------------------------
                  for (var vtx:VertexNode= poly_node.proxy.v[Clip.LEFT]; (vtx != null) ; vtx = vtx.next )
                  {
                     poly.add( vtx.x, vtx.y );
                  }
                  if( num_contours > 1)
                  {
                     result.addPoly( poly );
                  }
                  c++;
               }
            }
            
            // -----------------------------------------
            // --- Sort holes to the end of the list ---
            // -----------------------------------------
            var orig:Poly= result ;
			var inner:Poly;
            result = Clip.createNewPoly( polyClass );

            for( var i:int= 0; i < orig.getNumInnerPoly() ; i++ )
            {
               inner = orig.getInnerPoly(i);
               if( !inner.isHole() )
               {
                  result.addPoly(inner);
               }
            }
            for(i= 0; i < orig.getNumInnerPoly() ; i++ )
            {
               inner = orig.getInnerPoly(i);
               if( inner.isHole() )
               {
                  result.addPoly(inner);
               }
            }
         }
         return result ;
      }
      
      public function print():void {
         Debug.trace("---- out_poly ----");
         var c:int= 0;
         var npoly_node:PolygonNode= null ;
         for (var poly_node:PolygonNode= top_node; (poly_node != null); poly_node = npoly_node)
         {
            Debug.trace("contour="+c+"  active="+poly_node.active+"  hole="+poly_node.proxy.hole);
            npoly_node = poly_node.next;
            if (poly_node.active != 0)
            {
               var v:int=0;
               for (var vtx:VertexNode= poly_node.proxy.v[Clip.LEFT]; (vtx != null) ; vtx = vtx.next )
               {
                  Debug.trace("v="+v+"  vtx.x="+vtx.x+"  vtx.y="+vtx.y);
               }
               c++;
            }
         }
      }         
   }

}
