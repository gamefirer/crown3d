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

package org.rje.glaze.engine.collision.shapes {
	import org.rje.glaze.engine.dynamics.Material;
	import org.rje.glaze.engine.dynamics.RigidBody;
	import org.rje.glaze.engine.math.Ray;
	import org.rje.glaze.engine.math.Vector2D;

	import flash.display.Graphics;

	/**
	 * The abstract base class for all shapes.
	 * 
	 * <p>
	 * You should not instantiate this class directly -- instead use one of the subclasses.
	 * </p>
	 */
	public class GeometricShape {

		/**
		 * These static constants are use for fast type checking by the shapeType member variable.
		 */
		public static const AXIS_ALIGNED_BOX_SHAPE : int 	= 0;
		public static const CIRCLE_SHAPE : int 				= 1;
		public static const SEGMENT_SHAPE : int 			= 2;
		public static const POLYGON_SHAPE : int			 	= 3;

		/**
		 * This constant scales the mass to a more reasonable amount per pixel
		 */
		public static const areaMassRatio : Number = 1 / 100;

		/**
		 * Used for ordering and fast type checking (can be CIRCLE_SHAPE,SEGMENT_SHAPE or POLYGON_SHAPE)
		 */
		public var shapeType : int;			

		/**
		 * The body this shape is part of.
		 */
		public var body : RigidBody;			

		/**
		 * Offset position of the shape, realtive to the position of the body 
		 */
		public var offset : Vector2D;

		/**
		 * If set to true, collisions result in no contacts.
		 */
		public var isSensor:Boolean;
		
		/**
		 * Experimental collision callback
		 */
		//TODO validate
		public var collisionCallback:Function;

		/**
		 * The AABB of the shape.  Calculated when the shape is updated.  
		 */
		public var aabb : AABB;
		
		/**
		 * Unique shape ID assigned at creation
		 */
		public var shapeID : uint;						

		/**
		 * User Data that can be stored on the shape
		 */
		public var data : *;					

		/**
		 * Material this shape is made off. Affects collisions.
		 */
		public var material : Material;

		/**
		 * ?
		 */
		public var surface_v : Vector2D;

		/**
		 * Calculated area of this shape.
		 */
		public var area : Number;
		
		/**
		 * Used by broadphase to check if its still in use.
		 */
		public var referenceCount : int;
		
		/**
		 * Linked list pointer.  
		 * <strong>Do not modify this!</strong>
		 */
		public var next : GeometricShape;
		/**
		 * Linked list pointer.  
		 * <strong>Do not modify this!</strong>
		 */		
		public var prev : GeometricShape;

		/**
		 * Next shapeID static counter
		 */
		public static var nextShapeID : uint = 0;		

		public var lineWidth : Number = 1;
		public var lineColour : uint = 0x333333;
		public var fillColour : uint = 0xDFECEC;

		/* Some good colours:
		 * 0xD2D3C4
		 * 0xD1D4B5
		 * 0xC1D4B5
		 * 0xB5D4B8
		 * 0xB5D4C7
		 * 0xD4C7B5
		 * 0xB8BD8F
		 * 0xA0A668
		 * 0xB5D1D4
		 */
		
		/** 
		 * 
		 */
		public function GeometricShape( shapeType : int, material : Material ) {
			
			this.shapeType = shapeType;
			aabb = new AABB();
			shapeID = nextShapeID++;

			if (material == null) {
				this.material = Material.defaultMaterial;
			} else {
				this.material = material;
			}
			
			this.area = 0;
			surface_v = new Vector2D();
			isSensor = false;			
			body = null;
		}

		public virtual function InitShape( offset : Vector2D, shapeData1 : *, shapeData2 : * = null, shapeData3 : * = null ) : * {
			return false;
		}

		/** 
		 * When called, updates this shapes transfomed vertex and axis list with the position and orientation
		 * of the parent rigid body.
		 */		
		public function Update() : void {
			UpdateShape(body.p, body.rot);
		}

		/** 
		 * This is called by the parent body when a shape is added to it.
		 */	
		public function registerBody( body : RigidBody ) : void {
			this.body = body;
		}

		public function unregisterBody() : void {
			this.body = null;
		}

		/** 
		 * Returns the mass of this shape as a function of (area x areaMassRatio x density)
		 */			
		public function get mass() : Number {
			return area * areaMassRatio * material.density;
		}

		/** 
		 * Utiliy function that can be use by Array.sort to sort and array of shapes in assending
		 * AABB order (using the top of the box as the reference)
		 */			
		public static function sortOnAABBDecending(a : GeometricShape, b : GeometricShape) : Number {
			var aTop : Number = a.aabb.t;
			var bTop : Number = b.aabb.t;
			if(aTop < bTop) {
				return -1;
			} 
			return 1;
		}

		/** 
		 * Transforms the shapes vertex and axis lists with position and orientation parameter
		 */			
		public virtual function UpdateShape( p : Vector2D, rot : Vector2D ) : void {
		}

		/** 
		 * Tests the shape contains the passed point
		 */		
		public virtual function ContainsPoint( point : Vector2D ) : Boolean {
			return false;
		}

		/** 
		 * Tests the shape intersects with ray
		 */		
		public virtual function IntersectRay( ray : Ray ) : Boolean {
			return false;
		}

		/** 
		 * Tests the shape intersects with ray
		 */		
		public virtual function IntersectRaySegment( ray : Ray ) : Boolean {
			return false;
		}

		
		/** 
		 * Calculates the inertia of the shape
		 */			
		public virtual function CalculateInertia( m : Number , offset : Vector2D ) : Number {
			return 1;
		}

		protected function get actualFillColour():uint {
			if (body.isSleeping ) return 0xE6DC64;
			if (body.canSleep) return 0x73E366;
			return fillColour;
		}

		/** 
		 * Draws the shape to the supplied graphics context
		 */			
		public virtual function draw( g : Graphics ) : void {
		}
	}
}
