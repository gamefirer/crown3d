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
   public class ItNodeTable
   {
	   public var top_node:ItNode;

      public function build_intersection_table(aet:AetTree, dy:Number):void {
         var st:StNode= null ;
         
         /* Process each AET edge */
         for (var edge:EdgeNode= aet.top_node ; (edge != null); edge = edge.next)
         {
            if( (edge.bstate[Clip.ABOVE] == BundleState.BUNDLE_HEAD) ||
                (edge.bundle[Clip.ABOVE][Clip.CLIP] != 0) ||
                (edge.bundle[Clip.ABOVE][Clip.SUBJ] != 0) )
            {
               st = Clip.add_st_edge(st, this, edge, dy);
            }
         }
      }
   }

}
