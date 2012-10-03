/// Copyright (c) 2007 Scott Lembcke
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// 

package org.rje.glaze.engine.dynamics {
	import org.rje.glaze.engine.math.Vector2D;

	/**
	 * 
	 */
	public class Contact {
		
		public const p:Vector2D = new Vector2D();			//Contact point
		public const n:Vector2D = new Vector2D();			//Contact normal
		public var dist:Number;			//Contact penetration distance
		
		public const r1:Vector2D = new Vector2D();			//Prestep values
		public const r2:Vector2D = new Vector2D();

		public const r1n:Vector2D = new Vector2D();		//Prestep values (cached normals)
		public const r2n:Vector2D = new Vector2D();		
		
		public var nMass:Number;		//Prestep values
		public var tMass:Number;
		public var bounce:Number;
		
		public var jnAcc:Number;		//Persistant contact infomation
		public var jtAcc:Number;
		public var jBias:Number;
		public var bias:Number;
		
		public var hash:uint;			//Contact hash
		public var updated:Boolean;		//Update flag.  If not updated then the contact is remove
		
		public var next:Contact;		//Linked list values
		//public var prev:Contact;
		//public var sentinel:Boolean;
		
		public static var contactPool:Contact;
		
		public function Contact( ) {
			
			nMass = tMass = bounce = 0;
			jnAcc = jtAcc = jBias = bias = 0;
			
		}
		
		public function toString():String {
			return "Contact: p=" + p.toString() + " n=" + n.toString() + " dist=" + dist + " hash=" + hash + " jnAcc=" + jnAcc + " jtAcc=" + jtAcc;
		}
		
	}
	
}
