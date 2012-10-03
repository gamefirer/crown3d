// glaze - 2D rigid body dynamics & game engine
// Copyright (c) 2010, Richard Jewson
// 
// This project also contains work derived from the Chipmunk & APE physics engines.  
// 
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// * Redistributions of source code must retain the above copyright notice,
//   this list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
// CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

package org.rje.glaze.util {

	public class Counter {
	
		public var counter:int;
		
		public var totalcounter:int;
		
		public var cycleCount:int;
		
		public var min:Number = 0;
		public var max:Number= 0;
		public var mean:Number= 0;
		
		public var name:String;
		
		public function Counter( name:String ) {
			this.name = name;
			reset();
		}
		
		public function endCycle():void {
			cycleCount++;
			if (counter < min) min = counter;
			if (counter > max) max = counter;
			totalcounter += counter;
			//mean = totalcounter / cycleCount;
			mean = (0.5 * mean) + ((1 - 0.5) * (counter));
			counter = 0;
		}
		
		public function reset():void {
			counter = 0;
			totalcounter = 0;
			cycleCount = 0;
			min = Number.MAX_VALUE;
			max = Number.MIN_VALUE;
			mean = 0;
		}
		
		public function toString():String {
			var result:String = name +":  min=" + min + "  max=" + max + "  mean=" + int(mean) + "  totalcycles=" + cycleCount+"\n";
			return result;
		}
		
	}
	
}
