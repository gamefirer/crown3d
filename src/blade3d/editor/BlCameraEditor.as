/**
 *	Camera编辑界面 
 */
package blade3d.editor
{
	import away3d.cameras.lenses.LensBase;
	import away3d.cameras.lenses.PerspectiveLens;
	
	import blade3d.camera.BlCameraControllerBase;
	import blade3d.camera.BlCameraEvent;
	import blade3d.camera.BlCameraManager;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import org.aswing.ASColor;
	import org.aswing.BorderLayout;
	import org.aswing.JButton;
	import org.aswing.JComboBox;
	import org.aswing.JFrame;
	import org.aswing.JLabel;
	import org.aswing.JPanel;
	import org.aswing.JStepper;
	import org.aswing.SoftBoxLayout;
	import org.aswing.VectorListModel;
	import org.aswing.border.LineBorder;
	import org.aswing.colorchooser.VerticalLayout;
	
	public class BlCameraEditor extends JFrame
	{
		private var _panel : JPanel;
		private var _upPanel : JPanel;
		private var _centerPanel : JPanel;
		private var _downPanel : JPanel;
		
		private var _cameraComboBox : JComboBox;
		
		
		// camera属性
		private var _curCamera : BlCameraControllerBase;
		
		private var _moveSpeed : JStepper;
		private var _rotSpeed : JStepper;
		
		private var _near : JStepper;
		private var _far : JStepper;
		private var _fov : JStepper;
		
		
		public function BlCameraEditor(owner:*=null, title:String="", modal:Boolean=false)
		{
			super(owner, title, modal);
			
			setSizeWH(300, 500);
			var parent:Sprite = Sprite(owner);
			setLocationXY( parent.width - (300+30), 0 );
			
			_panel = new JPanel(new BorderLayout(1, 1));
			setContentPane(_panel);
			_panel.setBorder(new LineBorder(null, ASColor.BLACK));
			
			show();
			
			initPanel();
			
			BlCameraManager.instance().addEventListener(BlCameraEvent.CAMERA_CHANGE, 
				function(evt:BlCameraEvent):void
				{
					setCamera(evt.cam);
				}
			);
		}
		
		private function initPanel():void
		{
			_upPanel = new JPanel(new VerticalLayout());
			_centerPanel = new JPanel(new SoftBoxLayout(SoftBoxLayout.Y_AXIS));
			_downPanel = new JPanel(new SoftBoxLayout(SoftBoxLayout.Y_AXIS));
			
			_panel.append(_upPanel, BorderLayout.NORTH);
			_panel.append(_centerPanel, BorderLayout.CENTER);
			_panel.append(_downPanel, BorderLayout.SOUTH);
			
			initUpPanel();
			
			setCamera(BlCameraManager.instance().currentCamera);
		}
		
		private function initUpPanel():void
		{
			_upPanel.append(new JLabel("当前摄像机"));
			
			_cameraComboBox = new JComboBox();
			_cameraComboBox.setPreferredWidth(100)
			updateCameraList();
			_upPanel.append(_cameraComboBox);
			
			_cameraComboBox.setSelectedIndex(0);
			
			_cameraComboBox.addActionListener(
				function(evt:Event):void
				{
					var cameraName : String = _cameraComboBox.getSelectedItem();
					BlCameraManager.instance().switchCameraByName(cameraName);
				}
			);
			
			// 添加摄像机按钮
			var addCamBtn : JButton = new JButton("添加摄像机");
			_upPanel.append(addCamBtn);
			addCamBtn.addActionListener(
				function(evt:Event):void
				{
					addCamera();
				}
				);
			
			// 摄像机参数
			_upPanel.append(new JLabel("移动速度"));
			_upPanel.append(_moveSpeed = new JStepper(5));
			_moveSpeed.addActionListener(onUIChange);
			
			_upPanel.append(new JLabel("旋转速度"));
			_upPanel.append(_rotSpeed = new JStepper(5));
			_rotSpeed.addActionListener(onUIChange);
			
			_upPanel.append(new JLabel("近平面"));
			_upPanel.append(_near = new JStepper(5));
			_near.addActionListener(onUIChange);
			
			_upPanel.append(new JLabel("远平面"));
			_upPanel.append(_far = new JStepper(5));
			_far.addActionListener(onUIChange);
			
			_upPanel.append(new JLabel("fov"));
			_upPanel.append(_fov = new JStepper(5));
			_fov.addActionListener(onUIChange);
		}
		
		private function initCenterPanel():void
		{
			
		}
		
		private function updateCameraList():void
		{
			var cameraListModel : VectorListModel = new VectorListModel;
			for(var i:int=0; i<BlCameraManager.instance().cameras.length; i++)
			{
				cameraListModel.append(BlCameraManager.instance().cameras[i].name);
			}
			_cameraComboBox.setModel(cameraListModel);
			_cameraComboBox.updateUI();
		}
				
		private function addCamera():void
		{
			var name:String = "free"+BlCameraManager.instance().cameras.length;
			BlCameraManager.instance().addFreeCamera(name);
			updateCameraList();
		}
		
		private function setCamera(cam:BlCameraControllerBase):void
		{
			_curCamera = cam;
			if(!_curCamera) return;

			var lens : LensBase = _curCamera.camera.lens;
			
			_moveSpeed.setValue(_curCamera.moveSpeed);
			_rotSpeed.setValue(_curCamera.rotSpeed * 180 / Math.PI);
			
			_near.setValue(lens.near);
			_far.setValue(lens.far);
			
			if( lens is PerspectiveLens)
			{
				_fov.visible = true;
				_fov.setValue( PerspectiveLens(lens).fieldOfView );
			}
			else
				_fov.visible = false;
		}
		
		private function onUIChange(evt:Event):void
		{
			if(!_curCamera) return;
			
			_curCamera.moveSpeed = _moveSpeed.getValue();
			_curCamera.rotSpeed = Number(_rotSpeed.getValue()) / 180 * Math.PI;
			
			var lens : LensBase = _curCamera.camera.lens;
			lens.near = _near.getValue();
			lens.far = _far.getValue();
			if( lens is PerspectiveLens)
			{
				PerspectiveLens(lens).fieldOfView = _fov.getValue();
			}
		}
	}
}