package blade3d.editor
{
	import away3d.animators.data.SkeletonKeyframeAnimationSequence;
	import away3d.animators.transitions.CrossfadeStateTransition;
	import away3d.containers.ObjectContainer3D;
	import away3d.debug.Trident;
	import away3d.debug.WireframeAxesGrid;
	import away3d.entities.BoneTag;
	
	import blade3d.avatar.blAvatarManager;
	import blade3d.avatar.blAvatarMesh;
	import blade3d.scene.BlSceneEvent;
	import blade3d.scene.BlSceneManager;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.aswing.ASColor;
	import org.aswing.BorderLayout;
	import org.aswing.Component;
	import org.aswing.JCheckBox;
	import org.aswing.JComboBox;
	import org.aswing.JFrame;
	import org.aswing.JList;
	import org.aswing.JPanel;
	import org.aswing.JScrollPane;
	import org.aswing.SoftBoxLayout;
	import org.aswing.VectorListModel;
	import org.aswing.border.LineBorder;
	import org.aswing.event.SelectionEvent;
	
	public class BlAvatarEditor extends JFrame
	{
		private var _panel : JPanel;		// 底panel
		private var _leftPanel : JPanel;
		private var _rightPanel : JPanel;
		
		private var _avatarNode : ObjectContainer3D;
		private var _avatarMesh : blAvatarMesh;
		private var _boneTagShower : Trident;
		
		// avatar列表
		private var _avatarList : JList;		
		// 动画列表
		private var _animationList : JList;	
		private var _animationListModel : VectorListModel;
		// 骨骼绑定点
		private var _boneTagBox : JComboBox;
		private var _boneTagListModel : VectorListModel;
		
		// 按钮
		private var _showBoundChk : JCheckBox;
		
		
		public function BlAvatarEditor(owner:*=null, title:String="", modal:Boolean=false)
		{
			super(owner, title, modal);
			
			setSizeWH(300, 600);
			var parent:Sprite = Sprite(owner);
			setLocationXY( parent.width - (300+30), 0 );
			
			// panel
			_panel = new JPanel(new BorderLayout(2,2));
			setContentPane(_panel);
			_panel.setBorder(new LineBorder(null, ASColor.BLUE));		// _panel边
			
			_leftPanel = new JPanel(new SoftBoxLayout(SoftBoxLayout.Y_AXIS));
			_leftPanel.setPreferredWidth(150);
			_panel.append(_leftPanel, BorderLayout.WEST);
			_leftPanel.setAlignmentX(0);
			
			_rightPanel = new JPanel(new SoftBoxLayout(SoftBoxLayout.Y_AXIS));
			_rightPanel.setBorder(new LineBorder(null, ASColor.CYAN));
			_panel.append(_rightPanel, BorderLayout.CENTER);
			
			
			show();
			
			// 创建avatar列表
			_leftPanel.append(createAvatarList());
			// 创建动画列表
			_leftPanel.append(createAnimationList());
			// 显示boundingbox
			_showBoundChk = new JCheckBox("包围框");
			_leftPanel.append(_showBoundChk);
			_showBoundChk.addActionListener(onBound);
			// 骨骼绑定点
			_boneTagListModel = new VectorListModel();
			_boneTagBox = new JComboBox(_boneTagListModel);
			_boneTagBox.addActionListener(onBoneTag);
			_leftPanel.append(_boneTagBox);
			
			_avatarNode = new ObjectContainer3D;
			_avatarNode.name = "BlAvatarEditor";
			
			BlSceneManager.instance().currentScene.addEditor(_avatarNode);
			BlSceneManager.instance().addEventListener(BlSceneEvent.SCENE_LEAVE, onSceneLeave);
			BlSceneManager.instance().addEventListener(BlSceneEvent.SCENE_ENTER, onSceneChange);
		}
		
		private function onSceneLeave(evt:Event):void
		{
			_avatarNode.detachParent();
		}
		
		private function onSceneChange(event:Event):void
		{
			BlSceneManager.instance().currentScene.addEditor(_avatarNode);
		}
		
		private function createAvatarList():Component
		{
			var arr:Array = new Array();
			
			var avatarNames : Vector.<String> = blAvatarManager.instance().avatarNames;
			for(var i:int=0; i<avatarNames.length; i++)
			{
				arr.push(avatarNames[i]);
			}
			
			var listData:VectorListModel = new VectorListModel(arr);
			_avatarList = new JList(listData);
			_avatarList.setBorder(new LineBorder(null, ASColor.RED, 1));
			_avatarList.addSelectionListener(onAvatarListSelected);
			
			return new JScrollPane(_avatarList);
		}
		
		private function createAnimationList():Component
		{
			var arr:Array = new Array();
			_animationListModel = new VectorListModel(arr);
			_animationList = new JList(_animationListModel);
			_animationList.setBorder(new LineBorder(null, ASColor.ORANGE, 1));
			_animationList.addSelectionListener(onAnimationListSelected);
			return new JScrollPane(_animationList);
		}
		// 更新骨骼绑定点
		private function updateBoneTagList():void
		{
			_boneTagListModel.clear();
			
			if(!_avatarMesh) return;
			if(!_avatarMesh.avatarStore._boneTagsName) return;
			
			for(var i:int=0; i<_avatarMesh.avatarStore._boneTagsName.length; i++)
			{
				var boneTagName : String = _avatarMesh.avatarStore._boneTagsName[i];
				_boneTagListModel.append(boneTagName);
			}
			
			_boneTagBox.updateUI(); 
		}
		
		private function onBoneTag(evt:Event):void
		{
			if(!_boneTagShower)
				_boneTagShower = new Trident(100);
			
			var boneTagName : String = _boneTagBox.getSelectedItem();
			var boneTag:BoneTag = _avatarMesh.getBoneTag(boneTagName);
			if(boneTag)
			{
				boneTag.addChild(_boneTagShower);
			}
			
		}
		
		// 更新动画列表
		private function updateAnimationList():void
		{
			if(!_avatarMesh) return;
			
			_animationListModel.clear();
			
			var arr:Array = new Array();
			var seq : Vector.<SkeletonKeyframeAnimationSequence> = _avatarMesh.avatarStore.getSequence();
			for(var i:int=0; i<seq.length; i++)
			{
				arr.push(seq[i].name);
			}
			
			_animationListModel.appendAll(arr);
			_panel.updateUI();
		}
		
		// 选择avatar
		private var _avatarTimer : Timer = new Timer(500);
		private function onAvatarListSelected(evt:SelectionEvent):void
		{
			var avatarName : String = _avatarList.getSelectedValue();
			if(!_avatarMesh || avatarName != _avatarMesh.avatarStore.name)
			{
				// 回收当前avatar
				if(_avatarMesh)
				{
					_avatarMesh.recycle();	
				}
				// 创建新avatar
				_avatarMesh = blAvatarManager.instance().createAvatarMesh(avatarName);
			}
			_avatarNode.addChild(_avatarMesh);
			
			updateAvatarUI(null);
		}
		
		private function updateAvatarUI(evt:Event):void
		{
			if(_avatarMesh.avatarStore.isLoaded())
			{
				_avatarTimer.stop();
				_avatarTimer.removeEventListener(TimerEvent.TIMER, updateAvatarUI);
			}
			else
			{
				_avatarTimer.addEventListener(TimerEvent.TIMER, updateAvatarUI);
				_avatarTimer.start();
				return;
			}
			
			_avatarMesh.material.bothSides = true;
//			_avatarMesh.material.lightPicker = BlSceneManager.instance().lightPicker;
			
			updateAnimationList();
			updateBoneTagList();
		}
		
		// 选择动画
		private function onAnimationListSelected(evt:SelectionEvent):void
		{
			var aniName : String = _animationList.getSelectedValue();
			if(aniName)
				_avatarMesh.animator.play(aniName);
		}
		// 显示包围框
		private function onBound(evt:Event):void
		{
			if(_avatarMesh)
				_avatarMesh.showBounds = _showBoundChk.isSelected();
		}
			
		
	}
}