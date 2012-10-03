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

package org.rje.glaze.engine.math {

	public class PrimeNumber {
		
		public static const primes:Array = [
			5,          //2^2  + 1
			11,         //2^3  + 3
			17,         //2^4  + 1
			37,         //2^5  + 5
			67,         //2^6  + 3
			131,        //2^7  + 3
			257,        //2^8  + 1
			521,        //2^9  + 9
			1031,       //2^10 + 7
			2053,       //2^11 + 5
			4099,       //2^12 + 3
			8209,       //2^13 + 17
			16411,      //2^14 + 27
			32771,      //2^15 + 3
			65537,      //2^16 + 1
			131101,     //2^17 + 29
			262147,     //2^18 + 3
			524309,     //2^19 + 21
			1048583,    //2^20 + 7
			2097169,    //2^21 + 17
			4194319,    //2^22 + 15
			8388617,    //2^23 + 9
			16777259,   //2^24 + 43
			33554467,   //2^25 + 35
			67108879,   //2^26 + 15
			134217757,  //2^27 + 29
			268435459,  //2^28 + 3
			536870923,  //2^29 + 11
			1073741827, //2^30 + 3
			0];

		public static function next_prime(n:int):int {
			var i:int = 0;
			while(n > primes[i]) i++;
			return primes[i];
		}
		
	}
	
}
