/**
 *	发射器编辑界面 
 */
package blade3d.editor.effect
{
	import away3d.debug.Debug;
	
	import blade3d.effect.parser.BlEffectBaseParser;
	
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	import org.aswing.ASColor;
	import org.aswing.BorderLayout;
	import org.aswing.JAdjuster;
	import org.aswing.JCheckBox;
	import org.aswing.JComboBox;
	import org.aswing.JLabel;
	import org.aswing.JPanel;
	import org.aswing.JScrollPane;
	import org.aswing.JStepper;
	import org.aswing.JTextArea;
	import org.aswing.JTextField;
	import org.aswing.LayoutManager;
	import org.aswing.SoftBoxLayout;
	import org.aswing.VectorListModel;
	import org.aswing.border.LineBorder;
	import org.aswing.colorchooser.VerticalLayout;
	
	public class BlEffectParticleEmitterPanel extends JPanel
	{
		private var _emitXML : XML;
		
		// panel
		private var _leftPanel : JPanel;
		private var _rightPanel : JPanel;
		
		// 显示发射器
		private var _showEmitter : JCheckBox;
		
		// 发射器类型
		private var _emitterTypeComboBox : JComboBox;
		private var _emitterTypeModel : VectorListModel;
		
		// 发射率
		private var _emitRateText : JStepper;
		
		// 生命期
		private var _lifeTimeMinText : JStepper;
		private var _lifeTimeMaxText : JStepper;
		
		// 初始颜色
		private var _colorA : JAdjuster;
		private var _colorR : JAdjuster;
		private var _colorG : JAdjuster;
		private var _colorB : JAdjuster;
		
		private var _colorA2 : JAdjuster;
		private var _colorR2 : JAdjuster;
		private var _colorG2 : JAdjuster;
		private var _colorB2 : JAdjuster;
		
		// 粒子大小
		private var _sizeX : JStepper;
		private var _sizeY : JStepper;
		private var _sizeRange : JStepper;
		
		// 发射方向
		private var _directionFromX : JStepper;
		private var _directionFromY : JStepper;
		private var _directionFromZ : JStepper;
		
		private var _directionToX : JStepper;
		private var _directionToY : JStepper;
		private var _directionToZ : JStepper;
		
		// 速度
		private var _velmin : JStepper;
		private var _velmax : JStepper;
		
		// 发射时间和周期
		private var _emitTime : JStepper;
		private var _emitPeriod : JStepper;
		
		// 初始角度和旋转速度
		private var _rotmin : JStepper;
		private var _rotmax : JStepper;
		private var _rotvelmin : JStepper;
		private var _rotvelmax : JStepper;
		
		// 发射器面板
		private var _rectEmitterPanel : BlEffectParticleRectEmitterPanel;
		private var _circleEmitterPanel : BlEffectParticleCircleEmitterPanel;
		private var _sphereEmitterPanel : BlEffectParticleSphereEmitterPanel;
		
		public function BlEffectParticleEmitterPanel()
		{
			super(new SoftBoxLayout(SoftBoxLayout.X_AXIS));
			initUI();
		}
		
		private function initUI():void
		{
			setBorder(new LineBorder(null, ASColor.GREEN, 1));
			
			_leftPanel = new JPanel(new VerticalLayout());
			_rightPanel = new JPanel();
			append(new JScrollPane(_leftPanel));
			append(_rightPanel, BorderLayout.CENTER);
			
			// 显示发射器
			_showEmitter = new JCheckBox("显示发射器");
			_showEmitter.addActionListener(updateData);
			_leftPanel.append(_showEmitter);
			
			// 发射器类型
			_emitterTypeModel = new VectorListModel;
			_emitterTypeModel.append("矩形发射器");
			_emitterTypeModel.append("圆柱发射器");
			_emitterTypeModel.append("球形发射器");
			_emitterTypeComboBox = new JComboBox(_emitterTypeModel);
			_emitterTypeComboBox.setPreferredWidth(100);
			_emitterTypeComboBox.addActionListener(
				function(evt:Event):void
				{
					var i:int = _emitterTypeComboBox.getSelectedIndex();
					switch(i)
					{
						case 0:		// 矩形发射器
							_emitXML.setName("rect_emitter");
							break;
						case 1:		// 圆柱发射器
							_emitXML.setName("circle_emitter");
							break;
						case 2:		// 球形发射器
							_emitXML.setName("sphere_emitter");
							break;
						default:
							Debug.assert(false);
							break;
					}
					updateEmitterPanel();
				}
			);
			_leftPanel.append(_emitterTypeComboBox);
			
			var p:JPanel;
			// 发射率
			_leftPanel.append(p = new JPanel);
			p.append(new JLabel("发射率"));
			
			_emitRateText = new JStepper(5);
			_emitRateText.addActionListener(
				function(evt:Event):void
				{
					_emitXML.@emitrate = _emitRateText.getValue();
				}
				);
			
			p.append(_emitRateText);
			
			// 生命期
			_leftPanel.append(p = new JPanel);
			p.append(new JLabel("生命器(最小/最大)"));
			
			_lifeTimeMinText = new JStepper(5);
			_lifeTimeMinText.setMinimum(0);
			_lifeTimeMinText.setMaximum(9999999);
			_lifeTimeMinText.addActionListener(
				function(evt:Event):void
				{
					_emitXML.@lifetime = _lifeTimeMinText.getValue();
				}
				);
			p.append(_lifeTimeMinText);
			_lifeTimeMaxText = new JStepper(5);
			_lifeTimeMaxText.setMinimum(0);
			_lifeTimeMaxText.setMaximum(9999999);
			_lifeTimeMaxText.addActionListener(
				function(evt:Event):void
				{
					_emitXML.@lifetimerange = (_lifeTimeMaxText.getValue() - _lifeTimeMinText.getValue());
				}
				);
			p.append(_lifeTimeMaxText);
			
			// 颜色
			_leftPanel.append(p = new JPanel);
			p.append(new JLabel("颜色A(最小/最大)"));
			_colorA = new JAdjuster(2);
			_colorA.setMinimum(0);
			_colorA.setMaximum(255);
			p.append(_colorA);
			_colorA2 = new JAdjuster(2);
			_colorA2.setMinimum(0);
			_colorA2.setMaximum(255);
			p.append(_colorA2);
			
			_leftPanel.append(p = new JPanel);
			p.append(new JLabel("颜色R(最小/最大)"));
			_colorR = new JAdjuster(2);
			_colorR.setMinimum(0);
			_colorR.setMaximum(255);
			p.append(_colorR);
			_colorR2 = new JAdjuster(2);
			_colorR2.setMinimum(0);
			_colorR2.setMaximum(255);
			p.append(_colorR2);
			
			_leftPanel.append(p = new JPanel);
			p.append(new JLabel("颜色G(最小/最大)"));
			_colorG = new JAdjuster(2);
			_colorG.setMinimum(0);
			_colorG.setMaximum(255);
			p.append(_colorG);
			_colorG2 = new JAdjuster(2);
			_colorG2.setMinimum(0);
			_colorG2.setMaximum(255);
			p.append(_colorG2);
			
			_leftPanel.append(p = new JPanel);
			p.append(new JLabel("颜色B(最小/最大)"));
			_colorB = new JAdjuster(2);
			_colorB.setMinimum(0);
			_colorB.setMaximum(255);
			p.append(_colorB);
			_colorB2 = new JAdjuster(2);
			_colorB2.setMinimum(0);
			_colorB2.setMaximum(255);
			p.append(_colorB2);
			
			_colorA.addActionListener(updateData);
			_colorA2.addActionListener(updateData);
			_colorR.addActionListener(updateData);
			_colorR2.addActionListener(updateData);
			_colorG.addActionListener(updateData);
			_colorG2.addActionListener(updateData);
			_colorB.addActionListener(updateData);
			_colorB2.addActionListener(updateData);
			
			// 粒子大小
			_leftPanel.append(p = new JPanel);
			p.append(new JLabel("大小(X/Y/范围)"));
			_sizeX = new JStepper;
			p.append(_sizeX);
			_sizeY = new JStepper;
			p.append(_sizeY);
			_sizeRange = new JStepper;
			p.append(_sizeRange);
			
			_sizeX.addActionListener(updateData);
			_sizeY.addActionListener(updateData);
			_sizeRange.addActionListener(updateData);
			
			// 发射方向
			_leftPanel.append(p = new JPanel);
			p.append(new JLabel("发射方向(X/Y/Z)"));
			_leftPanel.append(p = new JPanel);
			p.append(new JLabel("从"));
			_directionFromX = new JStepper;
			p.append(_directionFromX);
			_directionFromY = new JStepper;
			p.append(_directionFromY);
			_directionFromZ = new JStepper;
			p.append(_directionFromZ);
			_leftPanel.append(p = new JPanel);
			p.append(new JLabel("到"));
			_directionToX = new JStepper;
			p.append(_directionToX);
			_directionToY = new JStepper;
			p.append(_directionToY);
			_directionToZ = new JStepper;
			p.append(_directionToZ);
			
			_directionFromX.addActionListener(updateData);
			_directionFromY.addActionListener(updateData);
			_directionFromZ.addActionListener(updateData);
			_directionToX.addActionListener(updateData);
			_directionToY.addActionListener(updateData);
			_directionToZ.addActionListener(updateData);
			
			// 速度
			_leftPanel.append(p = new JPanel);
			p.append(new JLabel("速度(最小/最大)"));
			_velmin = new JStepper;
			p.append(_velmin);
			_velmax = new JStepper;
			p.append(_velmax);
			
			_velmin.addActionListener(updateData);
			_velmax.addActionListener(updateData);
			
			// 初始角度
			_leftPanel.append(p = new JPanel);
			p.append(new JLabel("初始角度(最小/最大)"));
			_rotmin = new JStepper;
			p.append(_rotmin);
			_rotmax = new JStepper;
			p.append(_rotmax);
			
			_rotmin.addActionListener(updateData);
			_rotmax.addActionListener(updateData);
			
			// 旋转速度
			_leftPanel.append(p = new JPanel);
			p.append(new JLabel("旋转速度(最小/最大)"));
			_rotvelmin = new JStepper;
			p.append(_rotvelmin);
			_rotvelmax = new JStepper;
			p.append(_rotvelmax);
			
			_rotvelmin.addActionListener(updateData);
			_rotvelmax.addActionListener(updateData);
			
			
			// 发射时间和周期
			_leftPanel.append(p = new JPanel);
			p.append(new JLabel("发射时间/周期"));
			_emitTime = new JStepper;
			p.append(_emitTime);
			_emitPeriod = new JStepper;
			p.append(_emitPeriod);
			
			_emitTime.addActionListener(updateData);
			_emitPeriod.addActionListener(updateData);
			
		}
		
		private function updateData(evt:Event):void
		{
			if(!_emitXML) return;
			
			// 显示发射器
			_emitXML.@showemit = _showEmitter.isSelected() ? 1 : 0;
			
			// 颜色
			var A:uint = _colorA.getValue();
			var R:uint = _colorR.getValue();
			var G:uint = _colorG.getValue();
			var B:uint = _colorB.getValue();
			
			var AR:uint = Math.max( (_colorA2.getValue() - _colorA.getValue()), 0);
			var RR:uint = Math.max( (_colorR2.getValue() - _colorR.getValue()), 0);
			var GR:uint = Math.max( (_colorG2.getValue() - _colorG.getValue()), 0);
			var BR:uint = Math.max( (_colorB2.getValue() - _colorB.getValue()), 0);
			
			_emitXML.@a = A;
			_emitXML.@r = R;
			_emitXML.@g = G;
			_emitXML.@b = B;
			
			_emitXML.@arange = AR;
			_emitXML.@rrange = RR;
			_emitXML.@grange = GR;
			_emitXML.@brange = BR;
			// 大小
			_emitXML.@sizeX = Number(_sizeX.getValue() / 100).toFixed(2);
			_emitXML.@sizeY = Number(_sizeY.getValue() / 100).toFixed(2);
			_emitXML.@sizerange = Number(_sizeRange.getValue() / 100).toFixed(2);
			
			// 发射方向
			_emitXML.@directionfrom = _directionFromX.getValue()+" "+_directionFromY.getValue()+" "+_directionFromZ.getValue();
			_emitXML.@directionto = _directionToX.getValue()+" "+_directionToY.getValue()+" "+_directionToZ.getValue();
			
			// 速度
			var v:int = _velmin.getValue();
			var vr:int = Math.max(_velmax.getValue() - v, 0);
			_emitXML.@vel = v;
			_emitXML.@velrange = vr;
			
			// 初始角度
			var r:int = _rotmin.getValue();
			var rr:int = Math.max(_rotmax.getValue() - r, 0);
			_emitXML.@rot = r;
			_emitXML.@rotrange = rr;
			
			// 旋转角度
			var rv:int = _rotvelmin.getValue();
			var rvr:int = Math.max(_rotvelmax.getValue() - rv, 0);
			_emitXML.@rotvel = rv;
			_emitXML.@rotvelrange = rvr;
			
			// 发射时间与周期
			_emitXML.@emittime = _emitTime.getValue();
			_emitXML.@emitperiod = _emitPeriod.getValue();
		}
		
		private function updateUIByData():void
		{
			// 显示发射器模型
			_showEmitter.setSelected( Boolean(_emitXML.@showemit.toString()) );
			// 发射器类型
			if(_emitXML.name() == "rect_emitter")
			{
				_emitterTypeComboBox.setSelectedIndex(0);
			}
			else if(_emitXML.name() == "circle_emitter")
			{
				_emitterTypeComboBox.setSelectedIndex(1);
			}
			else if(_emitXML.name() == "sphere_emitter")
			{
				_emitterTypeComboBox.setSelectedIndex(2);
			}
			else
			{
				Debug.assert(false);
			}
			// 发射率
			_emitRateText.setValue(int(_emitXML.@emitrate.toString()));
			
			// 生命期
			var lifetime : int = int(_emitXML.@lifetime.toString());
			var range:int = Math.max( (_lifeTimeMaxText.getValue() - _lifeTimeMinText.getValue()), 0 );
			_lifeTimeMinText.setValue( lifetime );
			_lifeTimeMaxText.setValue( lifetime + range );
			
			// 颜色
			var A:uint = uint(_emitXML.@a.toString());
			var R:uint = uint(_emitXML.@r.toString());
			var G:uint = uint(_emitXML.@g.toString());
			var B:uint = uint(_emitXML.@b.toString());
			
			var AR:uint = uint(_emitXML.@arange.toString());
			var RR:uint = uint(_emitXML.@rrange.toString());
			var GR:uint = uint(_emitXML.@grange.toString());
			var BR:uint = uint(_emitXML.@brange.toString());
			
			_colorA.setValue(A);
			_colorA2.setValue(A+AR);
			_colorR.setValue(R);
			_colorR2.setValue(R+RR);
			_colorG.setValue(G);
			_colorG2.setValue(G+GR);
			_colorB.setValue(B);
			_colorB2.setValue(B+BR);
			
			// 大小
			_sizeX.setValue( Number(_emitXML.@sizeX.toString()) * 100 );
			_sizeY.setValue( Number(_emitXML.@sizeY.toString()) * 100 );
			_sizeRange.setValue( Number(_emitXML.@sizerange.toString()) * 100 );
			
			// 发射方向
			var dirFrom:Vector3D = BlEffectBaseParser.parseVector3D(_emitXML.@directionfrom.toString());
			var dirTo:Vector3D = BlEffectBaseParser.parseVector3D(_emitXML.@directionto.toString());
			_directionFromX.setValue(dirFrom.x);
			_directionFromY.setValue(dirFrom.y);
			_directionFromZ.setValue(dirFrom.z);
			_directionToX.setValue(dirTo.x);
			_directionToY.setValue(dirTo.y);
			_directionToZ.setValue(dirTo.z);
			
			// 速度
			_velmin.setValue( int(_emitXML.@vel.toString()) );
			_velmax.setValue( int(_emitXML.@vel.toString()) + int(_emitXML.@velrange.toString()) );
			
			// 初始角度
			_rotmin.setValue( int(_emitXML.@rot.toString()) );
			_rotmax.setValue( int(_emitXML.@rot.toString()) + int(_emitXML.@rotrange.toString()) );
			
			// 旋转角度
			_rotvelmin.setValue( int(_emitXML.@rotvel.toString()) );
			_rotvelmax.setValue( int(_emitXML.@rotvel.toString()) + int(_emitXML.@rotvelrange.toString()) );
			
			// 发射时间与周期
			_emitTime.setValue( int(_emitXML.@emittime.toString()) );
			_emitPeriod.setValue( int(_emitXML.@emitperiod.toString()) );
		}
		
		private function updateEmitterPanel():void
		{
			_rightPanel.removeAll();
			// 矩形发射器界面
			if(_emitXML.name() == "rect_emitter")
			{
				_rectEmitterPanel ||= new BlEffectParticleRectEmitterPanel;
				_rightPanel.append(_rectEmitterPanel);
				_rectEmitterPanel.srcData = _emitXML;
			}
			// 圆柱发射器界面
			else if(_emitXML.name() == "circle_emitter")
			{
				_circleEmitterPanel ||= new BlEffectParticleCircleEmitterPanel;
				_rightPanel.append(_circleEmitterPanel);
				_circleEmitterPanel.srcData = _emitXML;
			}
			// 球形发射器界面
			else if(_emitXML.name() == "sphere_emitter")
			{
				_sphereEmitterPanel ||= new BlEffectParticleSphereEmitterPanel;
				_rightPanel.append(_sphereEmitterPanel);
				_sphereEmitterPanel.srcData = _emitXML;
			}
		}
		
		public function set srcData(emitXML:XML):void
		{
			_emitXML = emitXML;
			updateUIByData();
		}
	}
}