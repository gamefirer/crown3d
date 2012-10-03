-- Crown的场景导出脚本
global isExportHide = true
global sceneFileName = ""	-- 保存的文件名
global savePath = ""	-- 保存的目录
global texturePath = ""	-- 贴图目录
global effectPath=""	-- 特效目录
global soundPath=""	-- 音效目录
global terrainTexturePath = ""	-- 地表贴图目录
global xmlString = stringstream""	-- 场景描述的xml
global errString = stringstream""	-- 错误描述
global CrownExport		-- 界面
global maxX, maxY, minX, minY	-- 场景boundingbox
global exportTextureArray = #()	-- 导出贴图列表
global triggerNameList= #()		-- trigger
global triggerCount = 0			-- trigger名

function uppercase instring = -- beginning of function definition
(
	local upper, lower, outstring -- declare variables as local
	upper="ABCDEFGHIJKLMNOPQRSTUVWXYZ" -- set variables to literals
	lower="abcdefghijklmnopqrstuvwxyz"
	-- create an unique copy of the string referenced by instring, and store
	-- reference to unique copy in outstring
	outstring=copy instring
	-- increment from 1 to number of character in string
	for i=1 to outstring.count do
		-- see if the single character at index i in outstring is present in string lower
		-- If so, j equals position in string lower. If not, j equals undefined
	(
		j=findString lower outstring[i]
		-- if character was found in lower, replace with corresponding character in upper
		if (j != undefined) do outstring[i]=upper[j]
	)
	return outstring -- value of outstring will be returned as function result

) -- end of fn uppercase

function lowercase instring = -- beginning of function definition
(
	local upper, lower, outstring -- declare variables as local
	upper="ABCDEFGHIJKLMNOPQRSTUVWXYZ" -- set variables to literals
	lower="abcdefghijklmnopqrstuvwxyz"
	-- create an unique copy of the string referenced by instring, and store
	-- reference to unique copy in outstring
	outstring = copy instring
	-- increment from 1 to number of character in string
	for i=1 to outstring.count do
	(
		j = findString upper outstring[i]
		if (j != undefined) do outstring[i]=lower[j]
	)
	return outstring

) -- end of fn lowercase

function updateBound mesh =
(
--	format "debug=% %\n" mesh.max mesh.min
	if maxX < mesh.max.x do maxX = mesh.max.x
	if maxY < mesh.max.y do maxY = mesh.max.y
	if minX > mesh.min.x do minX = mesh.min.x
	if minY > mesh.min.y do minY = mesh.min.y
)

-- 导出顶点色文件
function VertexColorExport edmesh =
(
	format "导出%的顶点色\n" edmesh.name
	isBinary = true
	-- 顶点色文件名
	meshFileName = savePath  + edmesh.name + ".3dc"
--	defaultVCFaces edmesh
-- 	buildVCFaces edmesh false
	cpvNum = getNumCPVVerts edmesh
	vertexNum = getNumVerts edmesh
	faceNum = getNumFaces edmesh
	format "vertexNum=% cpvNum=% faceNum=%\n" vertexNum cpvNum faceNum
	
	-- 检查顶点色数必须是面数的3倍
	if (faceNum*3) != cpvNum do
	(
		format "模型% 的顶点色数与面数*3不符\n" edmesh.name
		format "模型% 的顶点色数与面数*3不符\n" edmesh.name to: errString 
		return false
	)
	
	if isBinary then
		clrFile = fopen (lowercase meshFileName) "wb"
	else
		clrFile = openFile (lowercase meshFileName) mode:"wt"
	
	result = true

	if clrFile != undefined then
	(
		try
		(
			if false then
			(	-- version 1
				if isBinary then
				(
					WriteLong clrFile 1 unsigned		-- 版本号
					WriteLong clrFile cpvNum unsigned	-- 顶点色数
				)
				else
				(
					format "cpvNum %\n" cpvNum --to:clrFile
				)
				
				for i=1 to faceNum do
				(
					for j=1 to 3 do
					(
						cpvIndex = (i-1)*3 + j
						color = getVertColor edmesh cpvIndex
						if isBinary then
						(
							WriteByte clrFile color.red unsigned
							WriteByte clrFile color.green unsigned
							WriteByte clrFile color.blue unsigned
						)
						else
						(
							format "% % %\n" \
							color.red color.green color.blue --to:clrFile
						)
					)
				)
			)
			else
			(	-- version 2
				WriteLong clrFile 2 unsigned		-- 版本号
				
				WriteLong clrFile cpvNum unsigned	-- 顶点色数
				colorArray = #()
				-- 写颜色引索
				for i=1 to faceNum do
				(
					--xx = getVCFace edmesh i
					--format "% % " i xx
					
					--yy = getFace edmesh i
					--format "%" yy
					
					for j=1 to 3 do
					(
						cpvIndex = (i-1)*3 + j
						
						color = getVertColor edmesh cpvIndex
						-- 颜色值取模(压缩颜色数)
						color.r = floor (color.r/5) * 5
						color.g = floor (color.g/5) * 5
						color.b = floor (color.b/5) * 5
											
						clrIndex = findItem colorArray color
						if clrIndex > 0 then
							WriteShort clrFile (clrIndex-1) unsigned
						else
						(
							append colorArray color
							clrIndex = (colorArray.count-1)
							WriteShort clrFile (colorArray.count-1) unsigned							
						)
						
						--format " % %" clrIndex color
					)
					
					--format "\n"
				)
				
				WriteLong clrFile colorArray.count unsigned		-- 颜色数
				-- 写颜色列表
				for i=1 to colorArray.count do
				(
					WriteByte clrFile colorArray[i].r unsigned
					WriteByte clrFile colorArray[i].g unsigned
					WriteByte clrFile colorArray[i].b unsigned
				)
			)
		)
		catch
		(
			format "% 导出顶点色文件错误\n" edmesh.name
			format "% 导出顶点色文件错误\n" edmesh.name to: errString 
			result = false
		)
		if isBinary then
			fclose clrFile
		else
			close clrFile
	)
	
	return result
)

-- 导出Mesh的贴图
function TextureExport edmesh =
(
	if( (classof edmesh.material) as string != "Standardmaterial" ) then
	(
		format "% 的材质不是Standardmateria\n" edmesh.name
		return undefined
	)
	
	if( (classof edmesh.material.diffuseMap) as string != "Bitmaptexture" ) then
	(
		format "% 的材质的diffusemap不是Bitmaptexture\n" edmesh.name
		return undefined
	)
	-- 设置导出贴图的目录
	desPath = ""
	if texturePath.count > 0 then
	(
		desPath = savePath
		desPath = substring desPath 1 (desPath.count-1)
		desPath = getFilenamePath desPath
		desPath = desPath + texturePath + "\\"
		--format "desPath=%\n" desPath
	)
	else
		desPath = savePath
	
	-- 导出贴图
	srcAllFileName = edmesh.material.diffuseMap.filename
	srcFileName = getFilenameFile srcAllFileName + getFilenameType srcAllFileName
	
	--desFileName = getFilenameFile srcAllFileName + getFilenameType srcAllFileName 
	desFileName = getFilenameFile srcAllFileName + ".dds"	-- 贴图存为
	desAllFileName = desPath + desFileName
	desAllFileName = lowercase desAllFileName		-- 小写
	-- 检查贴图名长度
	justFileName = getFilenameFile desFileName
	justExtName = getFilenameType desFileName
	if(justFileName.count > 8) then
	(
		format "贴图 % 名超过8个字符\n" justFileName
		format "贴图 % 名超过8个字符\n" justFileName to:errString
		justFileName = substring justFileName 1 8
		desAllFileName = desPath + justFileName + justExtName
		format "贴图名改为%\n" desAllFileName 
		--return undefined
	)

	if(justExtName != ".png" and justExtName != ".jpg" and justExtName != ".tga" and justExtName != ".dds") then
	(
		format "贴图 % 不为tga,png,dds或jpg\n" srcAllFileName
		format "贴图 % 不为tga,png,dds或jpg\n" srcAllFileName to: errString
		return undefined
	)
	
	format "导出模型 % 的贴图 %\n" edmesh.name desAllFileName 
		
	-- 检查源贴图是否存在
	isExist = false
	if( doesFileExist srcAllFileName ) then isExist = true

	testFileName = sysInfo.currentdir + "\\" + srcFileName;
	if( doesFileExist testFileName ) then isExist = true

	testFileName = maxFilePath + srcFileName;
	if( doesFileExist testFileName ) then isExist = true
 
	if(isExist == false) then
	(
		format "贴图 % 不存在\n" srcAllFileName
		format "贴图 % 不存在\n" srcAllFileName to: errString
		return undefined
	)
	
	-- 检查贴图是否已经导出过
	if (findItem exportTextureArray desAllFileName) != 0 then
	(
		format "贴图 % 已经导出\n" desAllFileName
		return desAllFileName
	)
		
	-- 导出贴图
	try(
		srcBmp = edmesh.material.diffuseMap.bitmap
		--format "%\n" srcBmp
		desBmp = bitmap srcBmp.width srcBmp.height filename:desAllFileName 

		copy srcBmp desBmp
		save desBmp
		close desBmp
	)
	catch
	(
		format "%导出贴图失败\n" edmesh.name
		format "%导出贴图失败\n" edmesh.name to:errString
		return undefined
	)
	-- 记录导出的贴图
	append exportTextureArray desAllFileName
	
	format "导出贴图 % 结束\n" desAllFileName	
	return desAllFileName
)
-- 导出场景Mesh
function MeshExport edmesh =
(
	-- 导出该Mesh的贴图
	texOk = TextureExport edmesh
	if(texOk != undefined) then
	(	
		-- 保存位移,旋转
		oldPosition = edmesh.position
		edmesh.position = [0,0,0]
		oldRotation = edmesh.rotation
		edmesh.rotation.x = 0
		edmesh.rotation.y = 0
		edmesh.rotation.z = 0
		edmesh.rotation.w = 1
		
		-- 导出名字
		meshFileName = savePath  + edmesh.name + ".3ds"
		-- 导出该选中物体
		format "导出模型 %\n" meshFileName 
		exportFile (lowercase meshFileName) #noPrompt selectedOnly:true	
		
		-- 还原位移,旋转
		edmesh.rotation = oldRotation
		edmesh.position = oldPosition
		
		-- 该物体是否透明
		isBlended = false
		if edmesh.material.opacityMap != undefined do
			isBlended  = true
		-- 是否是双面渲染
		isTwoSided = false
		if edmesh.material.twoSided do
			isTwoSided = true
		-- layer属性
		layer = 0
		value = getUserProp edmesh "layer"
		if value != undefined and (isKindOf value number) then
			layer = value 
		-- shadow属性(是否产生阴影)
		shadow = false
		value = getUserProp edmesh "shadow"
		if value != undefined then
			shadow = value
		-- 受光属性(是否接受场景灯光照)
		light = true
		value = getUserProp edmesh "light"
		if value != undefine and value==false then
			light = false
		-- 缩放
		scale = 1.0
		value = getUserProp edmesh "scale"
		if value != undefine then
			scale = value
		-- zwrite属性
		zWrite = undefined
		value = getUserProp edmesh "zwrite"
		if value != undefined then
			zWrite = value
		-- ztest属性
		zTest = undefined
		value = getUserProp edmesh "ztest"
		if value != undefined then
			zTest = value
		-----------------------------------------------
		-- 场景动画	
		hasAnimation = false
		-- 位移动画
		ani_path = undefined
		value = getUserProp edmesh "ani_path"
		if value != undefined then
		(
			ani_path = value
			hasAnimation = true
		)
		-- 旋转动画
		ani_rot = undefined
		value = getUserProp edmesh "ani_rot"
		if value != undefined then
		(
			ani_rot = value
			hasAnimation = true
		)
		-- 缩放动画
		ani_scl = undefined
		value = getUserProp edmesh "ani_scl"
		if value != undefined then
		(
			ani_scl = value
			hasAnimation = true
		)
		-- 颜色动画
		ani_clr = undefined
		value = getUserProp edmesh "ani_clr"
		if value != undefined then
		(
			ani_clr = value
			hasAnimation = true
		)
		-- UV动画
		ani_uv = undefined
		value = getUserProp edmesh "ani_uv"
		if value != undefined then
		(
			ani_uv = value;
			hasAnimation = true
		)
			
		-- 地表渲染属性
		terrainTex = ""
		value = getUserProp edmesh "terraintex"		-- 混合贴图
		if value != undefined then
			terrainTex = value
		terrainTex1 = ""
		value = getUserProp edmesh "terraintex1"	-- 地表纹理1
		if value != undefined then
			terrainTex1 = value
		terrainTex2 = ""
		value = getUserProp edmesh "terraintex2"	-- 地表纹理2
		if value != undefined then
			terrainTex2 = value
		terrainTex3 = ""
		value = getUserProp edmesh "terraintex3"	-- 地表纹理3
		if value != undefined then
			terrainTex3 = value
		terrainTex4 = ""
		value = getUserProp edmesh "terraintex4"	-- 地表纹理4
		if value != undefined then
			terrainTex4 = value
		uvScale = 1
		value = getUserProp edmesh "uvscale"		-- UV倍数
		if value != undefined then
			uvScale = value
		
		
		-- 导出顶点色文件
		hasVertexColor = false
		cpvNum = getNumCPVVerts edmesh
		if cpvNum != 0 do
		(
			hasVertexColor = VertexColorExport edmesh
		)
			
		-- 导出xml
		format "<mesh name=\"%\" vertexColor=\"%\">\n" \
			(lowercase edmesh.name) hasVertexColor to:xmlString
		
		-- 在xml加入对该对象的位移和旋转(SWAP YZ,镜像空间),
		format "\t<pos x=\"%\" y=\"%\" z=\"%\"></pos>\n" \
			edmesh.position.x edmesh.position.z edmesh.position.y to:xmlString
		format "\t<rot rx=\"%\" ry=\"%\" rz=\"%\" rw=\"%\"></rot>\n" \
			-edmesh.rotation.x -edmesh.rotation.z -edmesh.rotation.y edmesh.rotation.w\
			to:xmlString
		format "\t<scale s=\"%\"></scale>\n" \
			scale \
			to:xmlString
		-- 材质
		format "\t<mat blend=\"%\" twoSide=\"%\" layer=\"%\" shadow=\"%\" light=\"%\"" \
			isBlended isTwoSided layer shadow light to:xmlString
		if zWrite != undefined then
			format " zwrite=\"%\"" zWrite to:xmlString
		if zTest != undefined then
			format " ztest=\"%\"" zTest to:xmlString

		format "></mat>\n" to:xmlString
		-- 场景动画
		if hasAnimation then
		(
			format "\t<animation>\n" to:xmlString
			if ani_path != undefined then
			(
				format "\t\t%\n" ani_path to:xmlString
			)			
			-- 旋转动画
			if ani_rot != undefined then
			(
				format "\t\t%\n" ani_rot to:xmlString
			)
			-- 缩放动画
			if ani_scl != undefined then
			(
				format "\t\t%\n" ani_scl to:xmlString
			)
			-- 颜色动画
			if ani_clr != undefined then
			(
				format "\t\t%\n" ani_clr to:xmlString
			)
			-- UV动画
			if ani_uv != undefined then
			(
				format "\t\t%\n" ani_uv to:xmlString
			)
			format "\t</animation>\n" to:xmlString
		)
		-- 地表材质
		if terrainTex.count > 0 then
		(
			format "\t<terraintex tex=\"%\" tex1=\"%\" tex2=\"%\" tex3=\"%\" tex4=\"%\" uvscale=\"%\"/>\n" \
				terrainTex terrainTex1 terrainTex2 terrainTex3 terrainTex4 uvScale \
				to:xmlString
		)
		
		format "</mesh>\n" to:xmlString
		
		updateBound edmesh			-- 更新世界范围		
	)else(
		format "模型% 因贴图问题不导出\n" edmesh.name
		format "模型% 因贴图问题不导出\n" edmesh.name to: errString 
	)
)

-- 导出天空盒
function SkyBoxExport  edmesh =
(
	format "导出天空盒 %\n" edmesh.name
	
	-- 天空盒的位置和旋转都为0
	edmesh.position = [0,0,0]
	edmesh.rotation.x = 0
	edmesh.rotation.y = 0
	edmesh.rotation.z = 0
	edmesh.rotation.w = 1
	-- 导出天空盒贴图
	texOk = TextureExport edmesh
	if(texOk != undefined) then
	(
		-- 导出名字
		meshFileName = savePath  + edmesh.name + ".3ds"
		-- 导出该选中物体
		format "导出模型 %\n" meshFileName 
		exportFile meshFileName #noPrompt selectedOnly:true	
			
		-- 在xml加入对该对象的位移和旋转(SWAP YZ,镜像空间),
		format "<skybox name=\"%\"></skybox>\n" edmesh.name to:xmlString
	)else(
		format "天空盒% 因贴图问题不导出\n" edmesh.name
		format "天空盒% 因贴图问题不导出\n" edmesh.name to: errString 

	)
)
-- 导出地形Mesh
function TerrainExport edmesh =
(
	format "导出地形 %\n" edmesh.name
	
	-- 地形的位置和旋转都为0
	edmesh.position = [0,0,0]
	edmesh.rotation.x = 0
	edmesh.rotation.y = 0
	edmesh.rotation.z = 0
	edmesh.rotation.w = 1
		
	-- 导出名字
	meshFileName = savePath  + edmesh.name + ".3ds"
	-- 导出该选中物体
	format "导出模型 %\n" meshFileName 
	exportFile meshFileName #noPrompt selectedOnly:true	
		
	-- 在xml加入对该对象的位移和旋转(SWAP YZ,镜像空间),
	format "<terrain name=\"%\"></terrain>\n" edmesh.name to:xmlString
)
-- 导出场景灯
function LightExport edmesh =
(
	format "导出灯 %\n" edmesh.name
	texName = TextureExport edmesh
	if(texName != undefined) then
	(
		texFileName = filenameFromPath texName 
		lightPos = edmesh.position
		-- 获得灯的大小
		value = getUserProp edmesh "size"
		lightSize = 100
		--format "%\n" (isKindOf strSize integer)
		if value != undefined and (isKindOf value integer) then
			lightSize = value 
		-- 获得灯的旋转
		lightRot = (asin(edmesh.rotation.z)*2) + 90
		-- 获得灯的颜色
		clrR = 255
		clrG = 255
		clrB = 255
		value = getUserProp edmesh "clrR"
		if value != undefined and (isKindOf value integer) then
			clrR = value
		value = getUserProp edmesh "clrG"
		if value != undefined and (isKindOf value integer) then
			clrG = value
		value = getUserProp edmesh "clrB"
		if value != undefined and (isKindOf value integer) then
			clrB = value
		-- 获得光照强度
		bright = 1.0
		value = getUserProp edmesh "bright"
		if value != undefined and (isKindOf value number) then
			bright = value

		format "<light name=\"%\" tex=\"%\" size=\"%\" bright=\"%\" x=\"%\" z=\"%\" rot=\"%\" r=\"%\" g=\"%\" b=\"%\"></light>\n" \
			(lowercase edmesh.name) (lowercase texFileName) lightSize bright \
			edmesh.position.x edmesh.position.y  \
			lightRot \
			clrR clrG clrB \
			to:xmlString
	)
	else
	(
		format "模型% 因贴图问题不导出\n" edmesh.name
		format "模型% 因贴图问题不导出\n" edmesh.name to: errString 

	)
)
-- 导出特效
function EffectExport edmesh =
(
	effectName = undefined
	value = getUserProp edmesh "effect"
	if value != undefined then
		effectName = value
	
	if effectName == undefined then
	(
		format "特效%没有定义\n" edmesh.name
		return undefined
	)
	
	format "导出特效 % %\n" edmesh.name effectName 
	
	format "<effect name=\"%\" file=\"%\">\n" edmesh.name effectName to:xmlString

	format "\t<pos x=\"%\" y=\"%\" z=\"%\"></pos>\n" \
		edmesh.position.x edmesh.position.z edmesh.position.y to:xmlString
	format "\t<rot rx=\"%\" ry=\"%\" rz=\"%\" rw=\"%\"></rot>\n" \
		-edmesh.rotation.x -edmesh.rotation.z -edmesh.rotation.y edmesh.rotation.w\
		to:xmlString
		
	format "</effect>\n" to:xmlString

)
-- 导出音效
function SoundExport edmesh =
(
	soundName = undefined
	value = getUserProp edmesh "sound"
	if value != undefined then
		soundName = value
	
	if soundName == undefined then
	(
		format "音效%没有定义\n" edmesh.name
		return undefined
	)
	
	soundRange = 1000
	value = getUserProp edmesh "range"
	if value != undefined then
		soundRange = value
	
	format "导出音效 % %\n" edmesh.name soundName 
	
	format "<sound name=\"%\" file=\"%\" range=\"%\">\n" edmesh.name soundName soundRange to:xmlString

	format "\t<pos x=\"%\" y=\"%\" z=\"%\"></pos>\n" \
		edmesh.position.x edmesh.position.z edmesh.position.y to:xmlString
	format "</sound>\n" to:xmlString

)
-- 导出水
function WaterExport edmesh =
(
	-- 导出该Mesh的贴图
	texOk = TextureExport edmesh
	if(texOk != undefined) then
	(
		-- 保存位移,旋转
		oldPosition = edmesh.position
		edmesh.position = [0,0,0]
		oldRotation = edmesh.rotation
		edmesh.rotation.x = 0
		edmesh.rotation.y = 0
		edmesh.rotation.z = 0
		edmesh.rotation.w = 1
		
		-- 导出名字
		meshFileName = savePath  + edmesh.name + ".3ds"
		-- 导出该选中物体
		format "导出模型 %\n" meshFileName 
		exportFile (lowercase meshFileName) #noPrompt selectedOnly:true	
		
		-- 还原位移,旋转
		edmesh.rotation = oldRotation
		edmesh.position = oldPosition
		-- 水属性
		alpha = 1.0
		value = getUserProp edmesh "alpha"
		if value != undefined then
			alpha = value
		uspeed = 0
		value = getUserProp edmesh "uspeed"
		if value != undefined then
			uspeed = value
				
		-- 导出xml
		format "<water name=\"%\">\n" (lowercase edmesh.name) to:xmlString
		
		-- 在xml加入对该对象的位移和旋转(SWAP YZ,镜像空间),
		format "\t<pos x=\"%\" y=\"%\" z=\"%\"></pos>\n" \
			edmesh.position.x edmesh.position.z edmesh.position.y to:xmlString
		format "\t<rot rx=\"%\" ry=\"%\" rz=\"%\" rw=\"%\"></rot>\n" \
			-edmesh.rotation.x -edmesh.rotation.z -edmesh.rotation.y edmesh.rotation.w\
			to:xmlString

		format "\t<property alpha=\"%\" uspeed=\"%\"></property>\n" alpha uspeed to:xmlString
		format "</water>\n" to:xmlString
	)
	else
	(
		format "水% 因贴图问题不导出\n" edmesh.name
		format "水% 因贴图问题不导出\n" edmesh.name to: errString 

	)
)
--导出环境配置
function EnvExport edmesh =
(
	format "导出场景配置\n"
	-- 灯光背景色
	LightBackGroundR = 100
	LightBackGroundG = 100
	LightBackGroundB = 100

	value = getUserProp edmesh "LightBackGroundR"
	if value != undefined then LightBackGroundR = value
	value = getUserProp edmesh "LightBackGroundG"
	if value != undefined then LightBackGroundG = value
	value = getUserProp edmesh "LightBackGroundB"
	if value != undefined then LightBackGroundB = value
	
	-- 雾
	fogColorR = 0
	fogColorG = 0
	fogColorB = 0
	fogNear = 10000
	fogFar = 20000
	fogAlpha = 1
	
	value = getUserProp edmesh "fogR"
	if value != undefined then fogColorR = value
	value = getUserProp edmesh "fogG"
	if value != undefined then fogColorG = value
	value = getUserProp edmesh "fogB"
	if value != undefined then fogColorB = value
	value = getUserProp edmesh "fogNear"
	if value != undefined then fogNear = value
	value = getUserProp edmesh "fogFar"
	if value != undefined then fogFar = value
	value = getUserProp edmesh "fogAlpha"
	if value != undefined then fogAlpha = value

		
	format "<env>\n" to:xmlString
	
	format "\t<LightBackGround r=\"%\" g=\"%\" b=\"%\"></LightBackGround>\n" \
		LightBackGroundR LightBackGroundG LightBackGroundB to:xmlString
	format "\t<Fog r=\"%\" g=\"%\" b=\"%\" near=\"%\" far=\"%\" alpha=\"%\"></Fog>\n" \
		fogColorR fogColorG fogColorB fogNear fogFar fogAlpha to:xmlString

	
	format "</env>\n" to:xmlString
)
-- 导出物理碰撞范围
global hasWorld = false
function WallExport line =
(
	pointNum = numKnots line 
	format "导出物理碰撞范围 % pointNum=%\n" line.name pointNum -- 点数
	
	format "有几个线段%\n" (numSplines line)
	if (numSplines line)>1 then
	(
		format "%有超过一个线段\n" line.name 
		format "%有超过一个线段\n" line.name to: errString
	)
	--format "是否闭合%\n" (isClosed line 1)
	if (isClosed line 1) == false then
	(
		format "%不闭合\n" line.name 
		format "%不闭合\n" line.name to: errString
	)

	type = 1		-- 1 world, 2 wall, 3 hole, 4 monster
	tag = ""
	if lowercase line.name == "world" then 
	(
		type = 1
		tag = "world"
		hasWorld = true
	)
	else if lowercase (substring line.name 1 7) == "monster" then
	(
		type = 4
		tag = "monster"
	)
	else if lowercase (substring line.name 1 4) == "wall" then
	(
		type = 2
		tag = "wall"
	)
	else
	(
		type = 3
		tag = "hole"
	)
	
	if type == 4 then
	(
		format "<% name=\"%\">\n" tag line.name to:xmlString
	)
	else
	(
		format "<%>\n" tag to:xmlString
	)
	
	-- 导出线段中的点
	lastPointPos = undefined
	for pointI=1 to pointNum do
	(
		pro = (pointI-1) as Float
		pro = pro / pointNum 
		points = pathInterp line 1 pro
		-- 检验两个点不可以距离太近
		if lastPointPos != undefined then
		(
			dis = distance lastPointPos points
			if dis < 1 then
			(
				format "%的点%距离上一个点太近\n" line.name pointI
				format "%的点%距离上一个点太近\n" line.name pointI to: errString
			)
		)
		else
			lastPointPos = points 
		
		format "% % %\n" pointI pro points 
		format "\t<point x=\"%\" z=\"%\"></point>\n" \
			points[1] points[2] \
			to:xmlString			
	)
	
	format "</%>\n" tag to:xmlString
	
)
-- 导出dummy
function DummyExport dummy =
(
	-- 检查没有重复的名字
	isNameExist = false
	for nameI=1 to triggerNameList.count do
	(
		if triggerNameList[nameI] == (lowercase dummy.name) then
		(
			format "名字重复%\n" dummy.name
			isNameExist = true
		)
	)
	if isNameExist == true do
	(
		format "dummy有重复的名字%\n" dummy.name to: errString
		return undefined
	)
	-- 检查是否hide
	if dummy.isHidden and isExportHide == false do
	(
		format "% 隐藏\n" dummy.name
		return undefined
	)
		
	append triggerNameList (lowercase dummy.name)
	
	format "导出dummy %\n" dummy.name
	
	dummyRot = (asin(dummy.rotation.z)*2) + 90
	
	triggerCount += 1
	format "<trigger name=\"%\" x=\"%\" y=\"%\" z=\"%\" rot=\"%\"></trigger>\n" \
		triggerCount dummy.position.x dummy.position.z dummy.position.y -(dummyRot)\
		to:xmlString
		
	
)
-- 导出场景函数
function SceneExport = 
(	
	clearSelection()
	setCommandPanelTaskMode #create	-- 选择创建界面以避免界面刷新
	-- 初始化最大最小值
	maxX = -9999999
	maxY = -9999999
	minX = 9999999
	minY = 9999999
	
	format "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n" to:xmlString
	format "<scene xmlns=\"\">\n" to:xmlString
	format "<texturepath path=\"%\"/>\n" texturePath to:xmlString
	format "<terraintexturepath path=\"%\"/>\n" terrainTexturePath to:xmlString
	format "<effectpath path=\"%\"/>\n" effectPath to:xmlString
	format "<soundpath path=\"%\"/>\n" soundPath to:xmlString
	
	format "当前目录 %\\\n" sysInfo.currentdir
	format "当前max文件目录%\n" maxFilePath
	format "保存目录 %\n" savePath 
	-- 对场景中所有Editable_mesh
	meshNameList = #()
	exportTextureArray = #()
	triggerNameList = #()
	
	triggerCount = 0		-- trigger数归0
	geocount = geometry.count
	geoi = 0
	for meshi in geometry do
	(	
		geoi += 1
		CrownExport.progExport.value = 90 * geoi / geocount	-- 进度条
		select meshi 		-- 选中该物体
		-- 排除非Editable_mesh
		if (((classof meshi ) as string) != "Editable_mesh") do
		(
			if (((classof meshi ) as string) == "Box") then
			(	-- Box物体作为dummy
				DummyExport meshi
			)
			else
			(
				format "geometry % is not Editable_mesh\n" meshi
				format "geometry % is not Editable_mesh\n" meshi to: errString
			)
			continue
		)
		-- 检查没有重复的名字
		isNameExist = false
		for nameI=1 to meshNameList.count do
		(
			if meshNameList[nameI] == (lowercase meshi.name) then
			(
				--format "名字重复%\n" meshi.name
				format "复用物体%\n" meshi.name
				isNameExist = true
			)
		)
		if isNameExist == true do
		(
			format "有重复的名字%\n" meshi.name to: errString
			--continue
		)
		-- 检查没有顶点的mesh
		if (getNumVerts meshi) == 0 do
		(
			format "%的顶点数为0\n" meshi.name to: errString
			continue
		)
		-- 检查没有face的mesh
		if (meshi.numfaces) == 0 do
		(
			format "%的面数为0\n" meshi.name to: errString
			continue
		)
		-- 检查mesh的顶点数和面数上限
		if (meshi.numfaces > 65536) or (meshi.numverts > 65536) do
		(
			format "%的面数或顶点数>65536\n" meshi.name to: errString
			continue
		)
		
		-- 检查是否hide
		if meshi.isHidden and isExportHide == false do
		(
			format "% 隐藏\n" meshi.name
			continue
		)
			
		append meshNameList (lowercase meshi.name)
		--format "处理%\n" meshi.name
		
		-- 导出地形mesh
		if lowercase meshi.name == "terrain" do
		(
			TerrainExport meshi 
			continue
		)
		-- 导出场景灯
		if lowercase (substring meshi.name 1 5) == "light" do
		(
			LightExport meshi
			continue
		)
		-- 导出特效
		if lowercase (substring meshi.name 1 6) == "effect" do
		(
			EffectExport meshi
			continue
		)
		-- 导出音效
		if lowercase (substring meshi.name 1 5) == "sound" do
		(
			SoundExport meshi
			continue
		)
		-- 导出水
		if lowercase (substring meshi.name 1 5) == "water" do
		(
			WaterExport meshi
			continue
		)
		-- 导出环境配置
		if (lowercase meshi.name) == "environment" do
		(
			EnvExport meshi
			continue
		)
		-- 导出天空盒
		if (lowercase meshi.name) == "skybox" do
		(
			SkyBoxExport meshi 
			continue
		)
		
		-- 导出普通Mesh
		format "导出第%个模型\n" geoi
		d = geoi - (geoi/100)*100;
		if(d == 0) do
		(
			gc true true
			format "gc\n"
		)
		MeshExport meshi 
	)
	-- 对场景中所有shape
	shapeNameList = #()
	shapecount = shapes.count
	shapeIndex = 0
	for shapei in shapes do
	(
		shapeIndex += 1
		CrownExport.progExport.value =  90 + (10 * shapeIndex / shapecount)	-- 进度条
		select shapei 	-- 选中该物体
		
		-- 检查没有重复的名字
		isNameExist = false
		for nameI=1 to shapeNameList.count do
		(
			if shapeNameList[nameI] == (lowercase shapei.name) then
			(
				format "名字重复%\n" shapei.name
				isNameExist = true
			)
		)
		if isNameExist == true do
		(
			format "有重复的名字%\n" shapei.name to: errString
			continue
		)
		-- 检查是否hide
		if shapei.isHidden and isExportHide == false do
		(
			format "% 隐藏\n" shapei.name
			continue
		)

		append shapeNameList (lowercase shapei.name)

		isShapeUsed = false
		format "% %\n" (isKindOf shapei shape) shapei.name
		-- 线的处理
		if ( isKindOf shapei shape ) do
		(	
			isShapeUsed = true
			WallExport shapei
		)
		-- 错误检测,是否该shape有被使用
		if isShapeUsed == false do
		(
			format "%不是导出物体\n" shapei.name
			format "%不是导出物体\n" shapei.name to: errString
		)
	)
	if hasWorld == false do
	(
		format "没有名为\"world\"的Shape\n"
		format "没有名为\"world\"的Shape\n" to: errString
	)
	
	clearSelection()
	format "<scenebound minX=\"%\" maxX=\"%\" minY=\"%\" maxY=\"%\"/>\n" \
		minX maxX minY maxY to:xmlString
	format "</scene>\n" to:xmlString
	
	format "导出结束\n"
)
--
function CheckDirectory srcPath= 
(
	--format "srcPath=%\n" srcPath
	desPath = ""
	if srcPath.count == 0 then
		return undefined
		
	desPath = savePath
	desPath = substring desPath 1 (desPath.count-1)
	desPath = getFilenamePath desPath
	desPath = desPath + srcPath+ "\\"
	--format "desPath=%\n" desPath
	
	exist = if (doesFileExist desPath) and (getfileattribute desPath #directory) then true else false
	if not exist then
	(
		val = makeDir desPath
		if val then
			format "创建目录%\n" desPath
		else
			format "创建目录%失败\n" desPath
	)	
	
)
-- 界面
rollout CrownExport "Crown场景导出工具" width:200 height:270
(
	button btnExport "导出场景" width:65 height:20
	checkbox exportHide "Checkbox" pos:[30,32] width:16 height:16 checked:true
	label lbl1 "导出隐藏物体" pos:[45,32] width:112 height:16
	label lbl2 "导出文件名" pos:[10,50] width:152 height:16
	edittext fileNameEditor "" pos:[2,70] width:190 height:16
	label lbl3 "贴图库目录名" pos:[10,90]
	edittext textureDirectoryEditor pos:[2,110] width:190 text:""
	label lbl4 "地表贴图库目录名" pos:[10,130]
	edittext terrainTextureDicectoryEditor pos:[2,150] width:190 text:"terrain"
	label lbl5 "特效库目录名" pos:[10,170]
	edittext effectDirectoryEditor pos:[2,190] width:190 text:"effect"
	label lbl6 "音效库目录名" pos:[10, 210]
	edittext soundDirectoryEditor pos:[2, 230] width:190 text:"sound"

	
	progressbar progExport color:blue visible:false
	--button test "test" width:65
	
	on test pressed do
	(
		if $ != undefined then
		(
			
		)
	)
	
	on btnExport pressed do
	(	
		if heapSize < 10000000 then
			heapSize = 10000000
				
		isExportHide = exportHide.checked		
		-- 场景目录文件
		if (CrownExport.fileNameEditor.text.count > 0) then
		(
			sceneFileName = CrownExport.fileNameEditor.text
		)
		else
		(
			sceneFileName = "map.xml"		
		)
		-- 贴图目录&地表地图库目录&特效库目录
		texturePath = CrownExport.textureDirectoryEditor.text
		terrainTexturePath = CrownExport.terrainTextureDicectoryEditor.text
		effectPath = CrownExport.effectDirectoryEditor.text
		soundPath = CrownExport.soundDirectoryEditor.text
					
		sceneFileName = getsavefilename caption:"保存场景" \
			filename:sceneFileName \
			types:"Crown SceneFile (*.xml)|*.xml|All Files (*.*)|*.*|"
		--sceneFileName = "C:\JerryO\3D\scene\map.xml"
		if sceneFileName != undefined then
		(	
			CrownExport.fileNameEditor.text = sceneFileName
			progExport.visible = true;
			
			format "场景文件 %\n" sceneFileName 			
			scenefile = createfile sceneFileName		-- 创建场景描述文件
			try
			(
				if (scenefile != undefined) then
				(
					xmlString = stringstream""
					
					savePath = getFilenamePath sceneFileName 
					
					-- 检查目录是否存在
					CheckDirectory texturePath
					CheckDirectory terrainTexturePath
					CheckDirectory effectPath
					CheckDirectory soundPath
					
					SceneExport()
					
					format "%" (xmlString as string) to:scenefile 
					-- 错误处理
					if ((errString as string).count > 0)  then
					(
						format "错误处理\n"
						format "%" (errString as string)
						messageBox (errString as string) title:"警告!"
					)else(
					
					)
										
					errString  = stringstream""
				)
				else
				(
					messagebox "创建场景文件失败"
				)
			)
			catch
			(
				exceptionString = stringstream""
				format "导出时发生错误!\n*** % ***\n" (getCurrentException()) to:exceptionString
				format "异常 %!\n" (exceptionString as string)
				messageBox (exceptionString as string) title:"导出错误"
			)
			format "关闭场景文件\n"
			close scenefile
						
			progExport.visible = false
			
			-- 列出导出贴图
			format "导出贴图:\n"
			for i=1 to exportTextureArray.count do
			(
				format "%\n" exportTextureArray[i]
			)
			-- 列出导出的trigger
			format "导出Trigger:\n"
			for i=1 to triggerNameList.count do
			(
				format "%\n" triggerNameList[i]
			)

			
			-- 转换所有tag为blt
			--thisMaxScriptDir = getSourceFileName()
			--thisMaxScriptDir = getFilenamePath thisMaxScriptDir 
			--commandStr = thisMaxScriptDir + "ConvertTgaToBlt.exe " + (getFilenamePath sceneFileName)
			--format "DOS:%\n" commandStr 			
			--DOSCommand commandStr 
		)
		else
		(
			sceneFileName = ""	
		)
	)
)

-- 创建对话框
if CrownExportFloater != undefined do
(
	closerolloutfloater CrownExportFloater 
)
CrownExportFloater = newRolloutFloater "场景导出 2.5.23" 210 300 \
	(mouse.screenpos[1]-85) (mouse.screenpos[2]-60) -- 创建一个Rollout
addRollout CrownExport CrownExportFloater 
