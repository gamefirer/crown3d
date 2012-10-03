/**
 *	物件基础动画面板 
 */
package blade3d.editor.scene
{
	import away3d.animators.PathAnimator;
	import away3d.animators.RotateAnimator;
	import away3d.animators.ScaleAnimator;
	import away3d.animators.data.RotateAnimationFrame;
	import away3d.animators.data.RotateAnimationSequence;
	import away3d.animators.data.ScaleAnimationFrame;
	import away3d.animators.data.ScaleAnimationSequence;
	import away3d.containers.ObjectContainer3D;
	import away3d.paths.PathMaker;
	import away3d.paths.QuadraticPath;
	
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.net.Socket;
	
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
	import org.aswing.plaf.basic.background.PanelBackground;
	
	public class BlSceneAnimationPanel extends JPanel
	{
		private var _obj:ObjectContainer3D;
		
		// 位移
		private var _pathMaker : PathMaker;
		private var pathAniList : JList;
		private var pathPlay : JCheckBox;
		private var pathDurationTime : JStepper;
		private var pathX: JStepper;
		private var pathY: JStepper;
		private var pathZ: JStepper;
		private var pathGlobal : JCheckBox;
		
		// 旋转
		private var _rotSequence : RotateAnimationSequence;
		private var rotAniList : JList;
		private var rotPlay : JCheckBox;
		private var rotDurationTime : JStepper;
		private var rotX: JStepper;
		private var rotY: JStepper;
		private var rotZ: JStepper;
		
		// 缩放
		private var _sclSequence : ScaleAnimationSequence;
		private var sclAniList : JList;
		private var sclPlay : JCheckBox;
		private var sclDurationTime : JStepper;
		private var sclX: JStepper;
		private var sclY: JStepper;
		private var sclZ: JStepper;
		
		
		public function BlSceneAnimationPanel()
		{
			super(new SoftBoxLayout(SoftBoxLayout.Y_AXIS, 1));
			
			initPanel();
		}
		
		private function initPanel():void
		{
			initPathPanel();
			initRotPanel();
			initSclPanel();
		}
		
		private function initPathPanel():void
		{
			append(new JLabel("位移动画"));
			
			pathAniList = new JList;
			pathAniList.setBorder(new LineBorder(null, ASColor.RED));
			append(pathAniList);
			pathAniList.addSelectionListener(onSelectPathFrame);
			
			var pathPanel : JPanel = new JPanel;
			append(pathPanel);
			
			var addBtn:JButton = new JButton("添加");
			pathPanel.append(addBtn);
			addBtn.addActionListener(onAddPathPoint);
			
			var delBtn:JButton = new JButton("删除");
			pathPanel.append(delBtn);
			delBtn.addActionListener(onDelPathPoint);
			
			pathPlay = new JCheckBox("播放");
			pathPanel.append(pathPlay);
			pathPlay.addActionListener(
				function(evt:Event):void
				{
					if(!_obj) return;
					if(!_obj.pathAnimator) return;
					if(pathPlay.isSelected())
					{
						_obj.pathAnimator.pathMaker = _pathMaker;		// 重新生成path
						_obj.pathAnimator.start();
					}
					else
						_obj.pathAnimator.stop();
				}
			);
			
			pathGlobal = new JCheckBox("世界空间");
			pathPanel.append(pathGlobal);
			pathGlobal.addActionListener(
				function(evt:Event):void
				{
					if(!_obj) return;
					if(!_obj.pathAnimator) return;
					_obj.pathAnimator.global = pathGlobal.isSelected();
				}
				);
			
			var durPanel : JPanel = new JPanel;
			append(durPanel);
			
			pathDurationTime = new JStepper(5);
			pathDurationTime.addActionListener(onChangePath);
			durPanel.append(pathDurationTime);
			
			var valPanel : JPanel = new JPanel;
			append(valPanel);
			
			pathX = new JStepper();
			pathX.addActionListener(onChangePath);
			valPanel.append(pathX);
			
			pathY = new JStepper();
			pathY.addActionListener(onChangePath);
			valPanel.append(pathY);
			
			pathZ = new JStepper();
			pathZ.addActionListener(onChangePath);
			valPanel.append(pathZ);
		}
		
		private function initRotPanel():void
		{
			append(new JLabel("旋转动画"));
			
			rotAniList = new JList();
			rotAniList.setBorder(new LineBorder(null, ASColor.RED));
			append(rotAniList);
			rotAniList.addSelectionListener(onSelectRotFrame);
			
			var rotPanel : JPanel = new JPanel;
			append(rotPanel);
			
			var addBtn:JButton = new JButton("添加");
			rotPanel.append(addBtn);
			addBtn.addActionListener(onAddRotFrame);
			
			var delBtn:JButton = new JButton("删除");
			rotPanel.append(delBtn);
			delBtn.addActionListener(onDelRotFrame);
			
			rotPlay = new JCheckBox("播放");
			rotPanel.append(rotPlay);
			rotPlay.addActionListener(
				function(evt:Event):void
				{
					if(!_obj) return;
					if(!_obj.rotateAnimator) return;
					if(rotPlay.isSelected())
					{
						_obj.rotateAnimator.playDefault();
					}
					else
						_obj.rotateAnimator.stop();
				}
			);
			
			var durPanel : JPanel = new JPanel;
			append(durPanel);
			
			rotDurationTime = new JStepper(5);
			rotDurationTime.addActionListener(onChangeRot);
			durPanel.append(rotDurationTime);
			
			var valPanel : JPanel = new JPanel;
			append(valPanel);
			
			rotX = new JStepper();
			rotX.addActionListener(onChangeRot);
			valPanel.append(rotX);
			
			rotY = new JStepper();
			rotY.addActionListener(onChangeRot);
			valPanel.append(rotY);
			
			rotZ = new JStepper();
			rotZ.addActionListener(onChangeRot);
			valPanel.append(rotZ);
		}
		
		private function initSclPanel():void
		{
			append(new JLabel("缩放动画"));
			
			sclAniList = new JList();
			sclAniList.setBorder(new LineBorder(null, ASColor.RED));
			append(sclAniList);
			sclAniList.addSelectionListener(onSelectScaleFrame);
			
			var sclPanel : JPanel = new JPanel;
			append(sclPanel);
			
			var addBtn:JButton = new JButton("添加");
			sclPanel.append(addBtn);
			addBtn.addActionListener(onAddScaleFrame);
			
			var delBtn:JButton = new JButton("删除");
			sclPanel.append(delBtn);
			delBtn.addActionListener(onDelScaleFrame);
			
			sclPlay = new JCheckBox("播放");
			sclPanel.append(sclPlay);
			sclPlay.addActionListener(
				function(evt:Event):void
				{
					if(!_obj) return;
					if(!_obj.scaleAnimator) return;
					if(sclPlay.isSelected())
					{
						_obj.scaleAnimator.playDefault();
					}
					else
						_obj.scaleAnimator.stop();
				}
				);
			
			var durPanel : JPanel = new JPanel;
			append(durPanel);
			
			sclDurationTime = new JStepper(5);
			sclDurationTime.addActionListener(onChangeScale);
			durPanel.append(sclDurationTime);
			
			var valPanel : JPanel = new JPanel;
			append(valPanel);
			
			sclX = new JStepper();
			sclX.addActionListener(onChangeScale);
			valPanel.append(sclX);
			
			sclY = new JStepper();
			sclY.addActionListener(onChangeScale);
			valPanel.append(sclY);
			
			sclZ = new JStepper();
			sclZ.addActionListener(onChangeScale);
			valPanel.append(sclZ);
		}
		
		private function onAddPathPoint(evt:Event):void
		{
			if(!_obj) return;
			
			if(!_pathMaker)
			{
				_pathMaker = new PathMaker;
				_obj.pathAnimator = new PathAnimator(_pathMaker, _obj);
			}
			
			var selIndex : int = pathAniList.getSelectedIndex();
			
			_pathMaker.pointData.splice(selIndex+1, 0, new Vector3D(0,0,0));
			
			updatePanel();
		}
		
		private function onDelPathPoint(evt:Event):void
		{
			if(!_obj) return;
			if(!_pathMaker) return;
			
			var selIndex : int = pathAniList.getSelectedIndex();
			_pathMaker.pointData.splice(selIndex, 1);
			
			if(_pathMaker.pointData.length == 0)
			{
				_obj.pathAnimator = null;
				_pathMaker = null;
			}
			
			pathAniList.setSelectedIndex(-1);
			
			updatePanel();
		}
		
		private function onSelectPathFrame(evt:Event):void
		{
			if(!_pathMaker) return;
			
			var selIndex : int = pathAniList.getSelectedIndex();
			if(selIndex < 0)
				return;
			
			var v:Vector3D = _pathMaker.pointData[selIndex];
			
			pathX.setValue(v.x);
			pathY.setValue(v.y);
			pathZ.setValue(v.z);
			
			rotDurationTime.setValue(_pathMaker.duration);
		}
		
		private function onChangePath(evt:Event):void
		{
			if(!_pathMaker) return;
			
			_pathMaker.duration = pathDurationTime.getValue();
			
			var selIndex : int = pathAniList.getSelectedIndex();
			if(selIndex < 0 )return;
			
			var v:Vector3D = _pathMaker.pointData[selIndex];
			
			v.x = pathX.getValue();
			v.y = pathY.getValue();
			v.z = pathZ.getValue();
		}
		
		private function onAddRotFrame(evt:Event):void
		{
			if(!_obj) return;
			
			if(!_rotSequence)
			{
				_obj.rotateAnimator= new RotateAnimator(_obj);
				_rotSequence = new RotateAnimationSequence("default");
				_obj.rotateAnimator.addSequence(_rotSequence);
			}
			
			var selIndex : int = rotAniList.getSelectedIndex();
			var newFrame : RotateAnimationFrame = new RotateAnimationFrame;
			newFrame.rotX = 0;
			newFrame.rotY = 0;
			newFrame.rotZ = 0;
			_rotSequence.insertFrame(newFrame, 1000, selIndex);
			
			updatePanel();
		}
		
		private function onDelRotFrame(evt:Event):void
		{
			if(!_obj) return;
			if(!_rotSequence) return;
			
			var selIndex : int = rotAniList.getSelectedIndex();
			_rotSequence.removeFrame(selIndex);
			
			if(_rotSequence.frames.length == 0)
			{
				_obj.rotateAnimator = null;
				_rotSequence = null;
			}
			
			rotAniList.setSelectedIndex(-1);
			
			updatePanel();
		}
		
		private function onSelectRotFrame(evt:Event):void
		{
			if(!_rotSequence) return;
			
			var selIndex : int = rotAniList.getSelectedIndex();
			
			var rotFrame : RotateAnimationFrame = _rotSequence.frames[selIndex];
			rotX.setValue(rotFrame.rotX * 180 / Math.PI);
			rotY.setValue(rotFrame.rotY * 180 / Math.PI);
			rotZ.setValue(rotFrame.rotZ * 180 / Math.PI);
			
			rotDurationTime.setValue(_rotSequence.getFrameTime(selIndex));
		}
		
		private function onChangeRot(evt:Event):void
		{
			if(!_rotSequence) return;
			
			var selIndex : int = rotAniList.getSelectedIndex();
			if(selIndex < 0 )return;
			
			var rotFrame : RotateAnimationFrame = _rotSequence.frames[selIndex];
			rotFrame.rotX = Number(rotX.getValue()) * Math.PI / 180;
			rotFrame.rotY = Number(rotY.getValue()) * Math.PI / 180;
			rotFrame.rotZ = Number(rotZ.getValue()) * Math.PI / 180;
			
			_rotSequence.changeFrameTime(selIndex, rotDurationTime.getValue());
		}
		
		private function onAddScaleFrame(evt:Event):void
		{
			if(!_obj) return;
			
			if(!_sclSequence)
			{
				_obj.scaleAnimator = new ScaleAnimator(_obj);
				_sclSequence = new ScaleAnimationSequence("default");
				_obj.scaleAnimator.addSequence(_sclSequence);
			}
			
			var selIndex : int = sclAniList.getSelectedIndex();
			var newFrame : ScaleAnimationFrame = new ScaleAnimationFrame;
			newFrame.scaleX = 1;
			newFrame.scaleY = 1;
			newFrame.scaleZ = 1;
			_sclSequence.insertFrame(newFrame, 1000, selIndex);
			
			updatePanel();
		}
		
		private function onDelScaleFrame(evt:Event):void
		{
			if(!_obj) return;
			if(!_sclSequence) return;
			
			var selIndex : int = sclAniList.getSelectedIndex();
			_sclSequence.removeFrame(selIndex);
			
			if(_sclSequence.frames.length == 0)
			{
				_obj.scaleAnimator = null;
				_sclSequence = null;
			}
			
			sclAniList.setSelectedIndex(-1);
			
			updatePanel();
		}
		
		private function onSelectScaleFrame(evt:Event):void
		{
			if(!_sclSequence) return;
			
			var selIndex : int = sclAniList.getSelectedIndex();
			if(selIndex < 0 )return;
			
			var sclFrame : ScaleAnimationFrame = _sclSequence.frames[selIndex];
			sclX.setValue(sclFrame.scaleX * 100);
			sclY.setValue(sclFrame.scaleY * 100);
			sclZ.setValue(sclFrame.scaleZ * 100);
			
			sclDurationTime.setValue(_sclSequence.getFrameTime(selIndex));
			
		}
		
		private function onChangeScale(evt:Event):void
		{
			if(!_sclSequence) return;
			
			var selIndex : int = sclAniList.getSelectedIndex();
			
			var sclFrame : ScaleAnimationFrame = _sclSequence.frames[selIndex];
			sclFrame.scaleX = Number(sclX.getValue())/100;
			sclFrame.scaleY = Number(sclY.getValue())/100;
			sclFrame.scaleZ = Number(sclZ.getValue())/100;
			
			_sclSequence.changeFrameTime(selIndex, sclDurationTime.getValue());
			
		}
		
		public function setObj(obj:ObjectContainer3D):void
		{
			_sclSequence = null;
			_rotSequence = null;
			_pathMaker = null;
			
			_obj = obj;
			if(!_obj) return;
			
			updatePanel();
		}
		
		private function updatePanel():void
		{
			var i:int;
			var arr : Array = new Array;
			
			if(_obj.pathAnimator)
			{
				_pathMaker = _obj.pathAnimator.pathMaker;
				arr.length = 0;
				for(i=0; i<_pathMaker.pointData.length; i++)
				{
					arr.push("point "+(i+1));
				}
				pathAniList.setModel(new VectorListModel(arr));
				pathAniList.updateUI();
				
				pathPlay.setSelected( _obj.pathAnimator.isPlaying );
				pathGlobal.setSelected(_obj.pathAnimator.global);
				
				pathDurationTime.setEnabled(true);
				pathX.setEnabled(true);
				pathY.setEnabled(true);
				pathZ.setEnabled(true);
				
				pathDurationTime.setValue(_pathMaker.duration);
			}
			else
			{
				pathAniList.setModel(new VectorListModel());
				pathPlay.setSelected(false);
				pathGlobal.setSelected(false);
				
				pathDurationTime.setEnabled(false);
				pathX.setEnabled(false);
				pathY.setEnabled(false);
				pathZ.setEnabled(false);
				
				pathDurationTime.setValue(0);
			}
			
			pathX.setValue(0);
			pathY.setValue(0);
			pathZ.setValue(0);
			
			
			if(_obj.rotateAnimator)
			{
				_rotSequence = _obj.rotateAnimator.activeSequence;
				arr.length = 0;
				for(i=0; i<_rotSequence.frames.length; i++)
				{
					arr.push("frame "+(i+1));
				}
				rotAniList.setModel(new VectorListModel(arr));
				rotAniList.updateUI();
				
				rotPlay.setSelected( _obj.rotateAnimator.isPlay );
				
				rotDurationTime.setEnabled(true);
				rotX.setEnabled(true);
				rotY.setEnabled(true);
				rotZ.setEnabled(true);
			}
			else
			{
				rotAniList.setModel(new VectorListModel());
				rotPlay.setSelected(false);
				
				rotDurationTime.setEnabled(false);
				rotX.setEnabled(false);
				rotY.setEnabled(false);
				rotZ.setEnabled(false);
			}
			
			rotX.setValue(0);
			rotY.setValue(0);
			rotZ.setValue(0);
			
			if(_obj.scaleAnimator)
			{
				_sclSequence = _obj.scaleAnimator.activeSequence;
				arr.length = 0;
				for(i=0; i<_sclSequence.frames.length; i++)
				{
					arr.push("frame "+(i+1));
				}
				sclAniList.setModel(new VectorListModel(arr));
				sclAniList.updateUI();
				
				sclPlay.setSelected( _obj.scaleAnimator.isPlay );
				
				sclDurationTime.setEnabled(true);
				sclX.setEnabled(true);
				sclY.setEnabled(true);
				sclZ.setEnabled(true);
			}
			else
			{
				sclAniList.setModel(new VectorListModel());
				sclPlay.setSelected(false);
				
				sclDurationTime.setEnabled(false);
				sclX.setEnabled(false);
				sclY.setEnabled(false);
				sclZ.setEnabled(false);
			}
			
			sclX.setValue(0);
			sclY.setValue(0);
			sclZ.setValue(0);
		}
	}
}