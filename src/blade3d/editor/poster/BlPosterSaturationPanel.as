/**
 *	色调后期特效面板 
 */
package blade3d.editor.poster
{
	import away3d.filters.HueSaturationFilter3D;
	
	import blade3d.postprocess.BlSaturationPoster;
	
	import flash.events.Event;
	
	import org.aswing.JLabel;
	import org.aswing.JPanel;
	import org.aswing.JSlider;
	import org.aswing.JStepper;
	import org.aswing.LayoutManager;
	import org.aswing.colorchooser.VerticalLayout;
	
	public class BlPosterSaturationPanel extends JPanel
	{
		private var _poster : BlSaturationPoster;
		
		private var _saturation : JSlider;
		
		private var _r : JSlider;
		private var _g : JSlider;
		private var _b : JSlider;
		
		public function BlPosterSaturationPanel()
		{
			super(new VerticalLayout);
			
			append(new JLabel("红"));
			_r = new JSlider;
			_r.setMinimum(0);
			_r.setMaximum(255);
			_r.addStateListener(updateData);
			append(_r);
			
			append(new JLabel("绿"));
			_g = new JSlider;
			_g.setMinimum(0);
			_g.setMaximum(255);
			_g.addStateListener(updateData);
			append(_g);
			
			append(new JLabel("蓝"));
			_b = new JSlider;
			_b.setMinimum(0);
			_b.setMaximum(255);
			_b.addStateListener(updateData);
			append(_b);
			
			append(new JLabel("溶解度"));
			_saturation = new JSlider;
			_saturation.setMinimum(0);
			_saturation.setMaximum(100);
			_saturation.addStateListener(updateData);
			append(_saturation);
			
		}
		
		public function set poster(poster : BlSaturationPoster):void
		{
			_poster = null;
			if(!poster)
				return;
			
			var filter : HueSaturationFilter3D = HueSaturationFilter3D(poster.filter);
			_r.setValue( filter.r * 255 );
			_g.setValue( filter.g * 255 );
			_b.setValue( filter.b * 255 );
			
			_saturation.setValue( filter.saturation * 100 );
			
			_poster = poster;
		}
		
		private function updateData(evt:Event):void
		{
			if(!_poster)
				return;
			
			var filter : HueSaturationFilter3D = HueSaturationFilter3D(_poster.filter);
			
			filter.r = Number(_r.getValue())/255;
			filter.g = Number(_g.getValue())/255;
			filter.b = Number(_b.getValue())/255;
			
			filter.saturation = Number(_saturation.getValue())/100;
			
		}
	}
}