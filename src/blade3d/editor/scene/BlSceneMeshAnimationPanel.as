/**
 *	Mesh所拥护的动画 
 */
package blade3d.editor.scene
{
	import away3d.animators.BlUVAnimator;
	import away3d.animators.ColorAnimator;
	import away3d.animators.data.ColorAnimationFrame;
	import away3d.animators.data.ColorAnimationSequence;
	import away3d.animators.data.UVAnimationFrame;
	import away3d.animators.data.UVAnimationSequence;
	import away3d.entities.Mesh;
	
	import flash.events.Event;
	
	import org.aswing.ASColor;
	import org.aswing.BorderLayout;
	import org.aswing.JButton;
	import org.aswing.JCheckBox;
	import org.aswing.JLabel;
	import org.aswing.JList;
	import org.aswing.JPanel;
	import org.aswing.JStepper;
	import org.aswing.LayoutManager;
	import org.aswing.SoftBoxLayout;
	import org.aswing.VectorListModel;
	import org.aswing.border.LineBorder;
	import org.aswing.colorchooser.VerticalLayout;
	
	public class BlSceneMeshAnimationPanel extends JPanel
	{
		private var _mesh:Mesh;
		
		// uv动画
		private var _uvSequence : UVAnimationSequence;
		private var uvAniList : JList;
		private var uvPlay : JCheckBox;
		private var uvDurationTime : JStepper;
		private var uvOffsetU : JStepper;
		private var uvOffsetV : JStepper;
		private var uvScaleU : JStepper;
		private var uvScaleV : JStepper;
		private var uvRotation : JStepper;
		
		private var uvSmooth : JCheckBox;
		private var uvRepeat : JCheckBox;
		
		// 颜色动画
		private var _clrSequence : ColorAnimationSequence;
		private var clrAniList : JList;
		private var clrPlay : JCheckBox;
		private var clrDurationTime : JStepper;
		private var clrA : JStepper;
		private var clrR : JStepper;
		private var clrG : JStepper;
		private var clrB : JStepper;
		
		
		public function BlSceneMeshAnimationPanel()
		{
			super(new SoftBoxLayout(SoftBoxLayout.Y_AXIS, 1));
			
			initPanel();
		}
		
		private function initPanel():void
		{
			initUVPanel();
			initClrPanel();
		}
		
		private function initUVPanel():void
		{
			append(new JLabel("UV动画"));
			uvAniList = new JList();
			uvAniList.setBorder(new LineBorder(null, ASColor.RED));
			append(uvAniList);
			uvAniList.addSelectionListener(onSelectUVFrame);
			
			var uvPanel : JPanel = new JPanel;
			append(uvPanel);
			
			var addBtn:JButton = new JButton("添加");
			uvPanel.append(addBtn);
			addBtn.addActionListener(onAddUVFrame);
			
			var delBtn:JButton = new JButton("删除");
			uvPanel.append(delBtn);
			delBtn.addActionListener(onDelUVFrame);
			
			uvPlay = new JCheckBox("播放");
			uvPanel.append(uvPlay);
			uvPlay.addActionListener(
				function(evt:Event):void
				{
					if(!_mesh) return;
					if(!_mesh.uvAnimator) return;
					if(uvPlay.isSelected())
					{
						_mesh.uvAnimator.playDefault();
					}
					else
						_mesh.uvAnimator.stop();
				}
			);
			
			var durPanel : JPanel = new JPanel;
			append(durPanel);
			
			uvDurationTime = new JStepper(5);
			uvDurationTime.addActionListener(onChangeUV);
			durPanel.append(uvDurationTime);
			
			var valPanel : JPanel = new JPanel;
			append(valPanel);
			
			valPanel.append(new JLabel("UV偏移"));
			uvOffsetU = new JStepper();
			uvOffsetU.addActionListener(onChangeUV);
			valPanel.append(uvOffsetU);
			
			uvOffsetV = new JStepper();
			uvOffsetV.addActionListener(onChangeUV);
			valPanel.append(uvOffsetV);
			
			append(valPanel = new JPanel);
			valPanel.append(new JLabel("UV缩放"));
				
			valPanel.append(uvScaleU = new JStepper);
			uvScaleU.addActionListener(onChangeUV);
			
			valPanel.append(uvScaleV = new JStepper);
			uvScaleV.addActionListener(onChangeUV);
			
			append(valPanel = new JPanel);
			valPanel.append(new JLabel("UV旋转"));
			
			valPanel.append(uvRotation = new JStepper);
			uvRotation.addActionListener(onChangeUV);
			
			append(uvSmooth = new JCheckBox("平滑动画"));
			uvSmooth.addActionListener(onChangeUV);
			
			append(uvRepeat = new JCheckBox("UV重复"));
			uvRepeat.addActionListener(onChangeUV);
			
		}
		
		private function initClrPanel():void
		{
			append(new JLabel("颜色动画"));
			clrAniList = new JList();
			clrAniList.setBorder(new LineBorder(null, ASColor.RED));
			append(clrAniList);
			clrAniList.addSelectionListener(onSelectClrFrame);
			
			var clrPanel : JPanel = new JPanel;
			append(clrPanel);
			
			var addBtn:JButton = new JButton("添加");
			clrPanel.append(addBtn);
			addBtn.addActionListener(onAddClrFrame);
			
			var delBtn:JButton = new JButton("删除");
			clrPanel.append(delBtn);
			delBtn.addActionListener(onDelClrFrame);
			
			clrPlay = new JCheckBox("播放");
			clrPanel.append(clrPlay);
			clrPlay.addActionListener(
				function(evt:Event):void
				{
					if(!_mesh) return;
					if(!_mesh.colorAnimator) return;
					if(clrPlay.isSelected())
					{
						_mesh.colorAnimator.playDefault();
					}
					else
						_mesh.colorAnimator.stop();
				}
			);
			
			var durPanel : JPanel = new JPanel;
			append(durPanel);
			
			clrDurationTime = new JStepper(5);
			clrDurationTime.addActionListener(onChangeClr);
			durPanel.append(clrDurationTime);
			
			var valPanel : JPanel = new JPanel;
			append(valPanel);
			
			valPanel.append(new JLabel("Alpha"));
			valPanel.append(clrA = new JStepper());
			clrA.setMinimum(0); clrA.setMaximum(255);
			clrA.addActionListener(onChangeClr);
			
			append(valPanel = new JPanel);
			valPanel.append(new JLabel("红"));
			valPanel.append(clrR = new JStepper());
			clrR.setMinimum(0); clrR.setMaximum(255);
			clrR.addActionListener(onChangeClr);
			
			append(valPanel = new JPanel);
			valPanel.append(new JLabel("绿"));
			valPanel.append(clrG = new JStepper());
			clrG.setMinimum(0); clrG.setMaximum(255);
			clrG.addActionListener(onChangeClr);
			
			append(valPanel = new JPanel);
			valPanel.append(new JLabel("蓝"));
			valPanel.append(clrB = new JStepper());
			clrB.setMinimum(0); clrB.setMaximum(255);
			clrB.addActionListener(onChangeClr);
			
		}
		
		private function onAddClrFrame(evt:Event):void
		{
			if(!_mesh) return;
			
			if(!_clrSequence)
			{
				_mesh.colorAnimator = new ColorAnimator(null);
				_clrSequence = new ColorAnimationSequence("default");
				_mesh.colorAnimator.addSequence(_clrSequence);
			}
			
			var selIndex : int = clrAniList.getSelectedIndex();
			var newFrame : ColorAnimationFrame = new ColorAnimationFrame;
			newFrame.A = 255;
			newFrame.R = 255;
			newFrame.G = 255;
			newFrame.B = 255;
			
			_clrSequence.insertFrame(newFrame, 1000, selIndex);
			
			updatePanel();
		}
		
		private function onDelClrFrame(evt:Event):void
		{
			if(!_mesh) return;
			if(!_clrSequence) return;
			
			var selIndex : int = clrAniList.getSelectedIndex();
			_clrSequence.removeFrame(selIndex);
			
			if(_clrSequence.frames.length == 0)
			{
				_mesh.colorAnimator = null;
				_clrSequence = null;
			}
			
			clrAniList.setSelectedIndex(-1);
			
			updatePanel();
		}
		
		private function onSelectClrFrame(evt:Event):void
		{
			if(!_clrSequence) return;
			
			var selIndex : int = clrAniList.getSelectedIndex();
			if(selIndex < 0 )return;
			
			var clrFrame : ColorAnimationFrame = _clrSequence.frames[selIndex];
			clrA.setValue(clrFrame.A);
			clrR.setValue(clrFrame.R);
			clrG.setValue(clrFrame.G);
			clrB.setValue(clrFrame.B);
			
			clrDurationTime.setValue(_clrSequence.getFrameTime(selIndex));
		}
		
		private function onChangeClr(evt:Event):void
		{
			if(!_clrSequence) return;
			
			var selIndex : int = clrAniList.getSelectedIndex();
			
			var clrFrame : ColorAnimationFrame = _clrSequence.frames[selIndex];
			clrFrame.A = clrA.getValue();
			clrFrame.R = clrR.getValue();
			clrFrame.G = clrG.getValue();
			clrFrame.B = clrB.getValue();
			
			_clrSequence.changeFrameTime(selIndex, clrDurationTime.getValue());
		}
		
		private function onAddUVFrame(evt:Event):void
		{
			if(!_mesh) return;
			
			if(!_uvSequence)
			{
				_mesh.uvAnimator = new BlUVAnimator(null);
				_uvSequence = new UVAnimationSequence("default");
				_mesh.uvAnimator.addSequence(_uvSequence);
			}
			
			var selIndex : int = uvAniList.getSelectedIndex();
			var newFrame : UVAnimationFrame = new UVAnimationFrame;
			newFrame.offsetU = 0;
			newFrame.offsetV = 0;
			newFrame.scaleU = 1;
			newFrame.scaleV = 1;
			newFrame.rotation = 0;
			
			_uvSequence.insertFrame(newFrame, 1000, selIndex);
			
			updatePanel();
		}
		
		private function onDelUVFrame(evt:Event):void
		{
			if(!_mesh) return;
			if(!_uvSequence) return;
			
			var selIndex : int = uvAniList.getSelectedIndex();
			_uvSequence.removeFrame(selIndex);
			
			if(_uvSequence.frames.length == 0)
			{
				_mesh.uvAnimator = null;
				_uvSequence = null;
			}
			
			uvAniList.setSelectedIndex(-1);
			
			updatePanel();
		}
		
		private function onSelectUVFrame(evt:Event):void
		{
			if(!_uvSequence) return;
			
			var selIndex : int = uvAniList.getSelectedIndex();
			if(selIndex < 0 )return;
			
			var uvFrame : UVAnimationFrame = _uvSequence.frames[selIndex];
			uvOffsetU.setValue(uvFrame.offsetU * 100);
			uvOffsetV.setValue(uvFrame.offsetV * 100);
			
			uvScaleU.setValue(uvFrame.scaleU * 100);
			uvScaleV.setValue(uvFrame.scaleV * 100);
			
			uvRotation.setValue(uvFrame.rotation);
			
			uvDurationTime.setValue(_uvSequence.getFrameTime(selIndex));
		}
		
		private function onChangeUV(evt:Event):void
		{
			if(!_uvSequence) return;
			
			var selIndex : int = uvAniList.getSelectedIndex();
			
			var uvFrame : UVAnimationFrame = _uvSequence.frames[selIndex];
			uvFrame.offsetU = Number(uvOffsetU.getValue())/100;
			uvFrame.offsetV = Number(uvOffsetV.getValue())/100;
			uvFrame.scaleU = Number(uvScaleU.getValue())/100;
			uvFrame.scaleV = Number(uvScaleV.getValue())/100;
			uvFrame.rotation = uvRotation.getValue();
			
			_uvSequence.changeFrameTime(selIndex, uvDurationTime.getValue());
			
			_mesh.uvAnimator.repeat = uvRepeat.isSelected();
			_mesh.uvAnimator.smooth = uvSmooth.isSelected();
			
		}
		
		public function setObj(mesh:Mesh):void
		{
			_uvSequence = null;
			_clrSequence = null;
			_mesh = mesh;
			if(!_mesh) return;
			
			updatePanel();
		}
		
		private function updatePanel():void
		{
			var i:int;
			var arr : Array = new Array;
			
			if(_mesh.uvAnimator)
			{
				_uvSequence = _mesh.uvAnimator.activeSequence();
				
				arr.length = 0;
				for(i=0; i<_uvSequence.frames.length; i++)
				{
					arr.push("frame "+(i+1));
				}
				uvAniList.setModel(new VectorListModel(arr));
				uvAniList.updateUI();
				
				uvPlay.setSelected( _mesh.uvAnimator.isPlay );
				uvSmooth.setSelected(_mesh.uvAnimator.smooth);
				uvRepeat.setSelected(_mesh.uvAnimator.repeat);
				
				uvDurationTime.setEnabled(true);
				uvOffsetU.setEnabled(true);
				uvOffsetV.setEnabled(true);
				uvScaleU.setEnabled(true);
				uvScaleV.setEnabled(true);
				uvRotation.setEnabled(true);
			}
			else
			{
				uvAniList.setModel(new VectorListModel());
				uvPlay.setSelected(false);
				uvSmooth.setSelected(false);
				uvRepeat.setSelected(false);
				
				uvDurationTime.setEnabled(false);
				uvOffsetU.setEnabled(false);
				uvOffsetV.setEnabled(false);
				uvScaleU.setEnabled(false);
				uvScaleV.setEnabled(false);
				uvRotation.setEnabled(false);
			}
			
			uvOffsetU.setValue(0);
			uvOffsetV.setValue(0);
			uvScaleU.setValue(0);
			uvScaleV.setValue(0);
			uvRotation.setValue(0);
			
			
			if(_mesh.colorAnimator)
			{
				 _clrSequence = _mesh.colorAnimator.activeSequence;
				 
				 arr.length = 0;
				 for(i=0; i<_clrSequence.frames.length; i++)
				 {
					 arr.push("frame "+(i+1));
				 }
				 clrAniList.setModel(new VectorListModel(arr));
				 clrAniList.updateUI();
				 
				 clrPlay.setSelected( _mesh.colorAnimator.isPlay );
				 
				 clrDurationTime.setEditable(true);
				 clrA.setEnabled(true);
				 clrR.setEnabled(true);
				 clrG.setEnabled(true);
				 clrB.setEnabled(true);
			}
			else
			{
				clrAniList.setModel(new VectorListModel());
				clrPlay.setSelected(false);
				
				clrDurationTime.setEnabled(false);
				clrA.setEnabled(false);
				clrR.setEnabled(false);
				clrG.setEnabled(false);
				clrB.setEnabled(false);
			}
			
			clrA.setValue(0);
			clrR.setValue(0);
			clrG.setValue(0);
			clrB.setValue(0);
		}
	}
}
