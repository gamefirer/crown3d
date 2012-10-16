/**
 *	 模糊后期特效面板
 */
package blade3d.editor.poster
{
	import away3d.filters.BlurFilter3D;
	
	import blade3d.postprocess.BlBlurPoster;
	import blade3d.postprocess.BlPoster;
	
	import flash.events.Event;
	
	import org.aswing.ASColor;
	import org.aswing.JAdjuster;
	import org.aswing.JLabel;
	import org.aswing.JPanel;
	import org.aswing.JSlider;
	import org.aswing.LayoutManager;
	import org.aswing.border.LineBorder;
	import org.aswing.colorchooser.VerticalLayout;
	
	public class BlPosterBlurPanel extends JPanel
	{
		private var _poster : BlBlurPoster;
		
		private var _blurX : JSlider;
		private var _blurY : JSlider;
		private var _stepSize : JAdjuster;
		
		
		public function BlPosterBlurPanel()
		{
			super(new VerticalLayout);
			
			append(new JLabel("X模糊"));
			_blurX = new JSlider;
			_blurX.setMinimum(0);
			_blurX.setMaximum(10);
			_blurX.addStateListener(updateData);
			append(_blurX);
			
			append(new JLabel("Y模糊"));
			_blurY = new JSlider;
			_blurY.setMinimum(0);
			_blurY.setMaximum(10);
			_blurY.addStateListener(updateData);
			append(_blurY);
			
			append(new JLabel("StepSize"));
			_stepSize = new JAdjuster;
			_stepSize.setMinimum(-1);
			_stepSize.addActionListener(updateData);
			append(_stepSize);
		}
		
		public function set poster(poster : BlBlurPoster):void
		{
			_poster = null;
			if(!poster)
				return;
			
			var filter : BlurFilter3D = BlurFilter3D(poster.filter);
			
			_blurX.setValue( filter.blurX );
			_blurY.setValue( filter.blurY );
			_stepSize.setValue( filter.stepSize );		
			
			_poster = poster;
		}
		
		private function updateData(evt:Event):void
		{
			if(!_poster)
				return;
			
			var filter : BlurFilter3D = BlurFilter3D(_poster.filter);
			
			filter.blurX = _blurX.getValue();
			filter.blurY = _blurY.getValue();
			filter.stepSize = _stepSize.getValue();
			
		}
		
	}
}