package org.rje.glaze.engine.collision {
	import org.rje.glaze.engine.collision.shapes.*;
	import org.rje.glaze.engine.dynamics.Arbiter;	

	/**
	* ...
	* @author Default
	*/
	public interface ICollide {
		
		function poly2poly( shape1:Polygon , shape2:Polygon , arb:Arbiter ):Boolean
		function circle2circle( circle1:Circle , circle2:Circle , arb:Arbiter ):Boolean
		function circle2segment( circle:Circle , seg:Segment , arb:Arbiter ):Boolean
		function segment2poly( seg:Segment , poly:Polygon , arb:Arbiter):Boolean
		function circle2poly( circle:Circle , poly:Polygon , arb:Arbiter):Boolean
		
	}
	
}