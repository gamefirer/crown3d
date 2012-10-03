--crown的morph动画文件导出脚本
global CrownExport		-- 界面
global errString = stringstream""	-- 错误描述
global gMesh			-- 导出mesh
global gMorpher		-- morpher
global channelList = #()		-- 有数据的channel
global meshString = stringstream""	-- 文件字串
global errString = stringstream""	-- 错误描述
global savePath = ""	-- 保存的目录
global morphFileName = ""		-- morph mesh名
global textureFileName = ""		-- 贴图名
global animationNames = #()		-- 所有动画的名字
global animationTimePairs = #()	-- 所有动画的开始和结束时间

-- 去掉字符串头尾的空格
function filterSpace instring =
(
	outstring = instring 
	while (outstring[1] == " ") do
	(
		outstring = substring outstring 2 -1
	)
	while (outstring[outstring.count] == " ") do
	(
		outstring = substring outstring 1 (outstring.count-1)
	)
	return outstring
)
-- 转换小写
function lowercase instring = -- beginning of function definition
(
	local upper, lower, outstring -- declare variables as local
	upper="ABCDEFGHIJKLMNOPQRSTUVWXYZ" -- set variables to literals
	lower="abcdefghijklmnopqrstuvwxyz"
	outstring = copy instring
	for i=1 to outstring.count do
	(
		j = findString upper outstring[i]
		if (j != undefined) do outstring[i]=lower[j]
	)
	return outstring
)
-- 设置进度条
function progress pro =
(
	CrownExport.progExport.value = pro	-- 进度条
)
-- 导出Mesh的贴图
function TextureExport edmesh =
(
	-- 导出贴图
	srcAllFileName = edmesh.material.diffuseMap.filename
	srcFileName = getFilenameFile srcAllFileName + getFilenameType srcAllFileName

	--desFileName = getFilenameFile srcAllFileName + getFilenameType srcAllFileName 
	--desFileName = getFilenameFile srcAllFileName + ".tga"	-- 贴图存为tga
	desFileName = getFilenameFile srcAllFileName + ".dds"	-- 贴图存为dds

	desAllFileName = savePath + desFileName
	desAllFileName = lowercase desAllFileName		-- 小写
	-- 检查贴图名长度
	justFileName = getFilenameFile desFileName
	justExtName = getFilenameType desFileName

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

	srcBmp = edmesh.material.diffuseMap.bitmap
	desBmp = bitmap srcBmp.width srcBmp.height filename:desAllFileName 
		
	copy srcBmp desBmp
	save desBmp
	close desBmp
	
	format "导出贴图 % 结束\n" desAllFileName	
	return desAllFileName
)

-- 检查导出合法性
function checkMesh =
(
	-- 导出前检查
	if gMesh == undefined then
	(
		format "请选择要导出的物体\n" to:errString 
		return false
	)
	if (classof gMesh)!=editable_mesh then
	(
		format "选择的物体%不是editable_mesh\n" gMesh.name to:errString
		return false
	)
	-- 有且仅有一个morpher
	mods = gMesh.modifiers
	if mods.count != 1 then 
	(
		format "该物体%必须只有一个modifier,且为Morpher\n" gMesh.name to:errString
		return false
	)
	gMorpher = mods[1]	
	if (classof gMorpher as string != "Morpher") do
	(
		format "该物体%没有morpher\n" gMesh.name to:errString
		return false
	)
	
	WM3_RebuildInternalCache gMorpher
	
	-- 检查有哪些channel
	channelList.count = 0
	for ci=1 to 100 do
	(
		WM3_MC_Rebuild gMorpher ci
		if WM3_MC_HasData gMorpher ci then
		(
			append channelList ci
		)		
	)
	-- 检查每个channel
	vertexCount = gMesh.numverts
	format "顶点数=%\n" vertexCount
	for ci=1 to channelList.count do
	(
		vc = WM3_MC_NumPts gMorpher channelList[ci]
		format "channel % %\n" channelList[ci] vc
		if vertexCount != vc then
		(
			format "顶点不匹配\n" to:errString
			return false
		)
	)
	-- 检查贴图
	if( (classof gMesh.material) as string != "Standardmaterial" ) then
	(
		format "% 的材质不是Standardmateria\n" gMesh.name to:errString
		return false
	)
		
	if( (classof gMesh.material.diffuseMap) as string != "Bitmaptexture" ) then
	(
		format "% 的材质的diffusemap不是Bitmaptexture\n" gMesh.name to:errString
		return false
	)
	
	textureFileName = gMesh.material.diffuseMap.filename
	format "导出贴图为%\n" textureFileName 

	-- 检查动画
	animationNames = #()
	animationTimePairs = #()
	
	modPanel.setCurrentObject gMorpher
	tagsNum = FrameTagManager.GetTagCount()		-- 根据timetag导出
	if tagsNum == 0 then 
	(
		format "没有设置Time Tag\n" to:errString
		return false
	)
	
	tagsPairNum = tagsNum / 2
	for pi = 1 to tagsPairNum do
	(
		tagId = FrameTagManager.GetTagID (pi*2-1)
		tagId2 = FrameTagManager.GetTagID (pi*2)
		tagName = FrameTagManager.GetNameByID tagId
		tagTime = FrameTagManager.GetTimeByID tagId
		tagTime2 = FrameTagManager.GetTimeByID tagId2

		tagTimeStr = tagTime as string
		tagTime2Str = tagTime2 as string
		t1 = (substring tagTimeStr 1 (tagTimeStr.count-1)) as number
		t2 = (substring tagTime2Str 1 (tagTime2Str.count-1)) as number
		tagName = filterSpace tagName 
		format "动画(%) [%, %]\n" tagName t1 t2
		
		append animationNames tagName
		append animationTimePairs t1
		append animationTimePairs t2
	)
	
	progress 20
	
	return true
)

function exportHeader = 
(
	format "blfversion 1\n" to:meshString
	format "\n" to:meshString
	format "tex \"%\"\n" (getFilenameFile textureFileName) to:meshString
	format "\n" to:meshString
	-- 导出贴图
	TextureExport gMesh	
)

struct blVertexData
(
	vertex,
	uv,
	vertexIndex		-- 该顶点在mesh中的引索
)

blVertices = #()	-- 顶点序列
blIndices = #()	-- 引索序列

function exportMesh =
(
	-- 选中modifier中的Editable Mesh,以导出原始模型
	setCommandPanelTaskMode mode:#modify
	modPanel.setCurrentObject gMesh
	
	vertexNum = getNumVerts gMesh
	faceNum = getNumFaces gMesh
	
	blVertices = #()
	blIndices = #()
	
	-- 导出	
	for fi=1 to faceNum do
	(
		vertindices = getFace gMesh fi		-- 顶点引索
		tvertindices = meshop.getmapface gMesh 1 fi --uv引索
		-- 对三角面三个顶点
		for fvi=1 to 3 do
		(
			vert = getVert gMesh vertindices[fvi]
			uv = meshop.getmapvert gMesh 1 tvertindices[fvi]
			
			--format "face=% vi=% verti=% vert=% uvi=% uv=%\n" \
			--	fi fvi vertindices[fvi] vert tvertindices[fvi] uv
			
			blIndex = 0
			for blVi=1 to blVertices.count do
			(
				if (blVertices[blVi].vertex == vert and blVertices[blVi].uv == uv) do
				(
					blIndex = blVi
					exit
				)
			)
									
			if blIndex == 0 then
			(	-- 顶点序列中无此顶点
				newblVert =  blVertexData()
				
				newblVert.vertex = vert
				newblVert.uv = uv
				newblVert	.vertexIndex = vertindices[fvi] as integer
								
				append blVertices newblVert
				blIndex = blVertices.count	
			)
			else
			(	-- 顶点序列中有此顶点了
			
			)
			append blIndices (blIndex-1)
		)		
	)
	
	-- 导出顶点和引索数据
	format "vertexNum %\n" blVertices.count to:meshString
	format "faceNum %\n" faceNum to:meshString
	format "indexNum %\n" blIndices.count to:meshString
	format "channelNum %\n" channelList.count to:meshString
	format "animationNum %\n" animationNames.count to:meshString
	format "\n" to:meshString
	
	format "vertices {\n" to:meshString
	for vi=1 to blVertices.count do
	(
		format "\tv % {\n" (vi-1) to:meshString
		-- 顶点位置
		format "\t\t% % %\n" \
			blVertices[vi].vertex[1] blVertices[vi].vertex[3] blVertices[vi].vertex[2] to:meshString-- 位置
		-- uv
		format "\t\t% %\n" blVertices[vi].uv[1] (1-blVertices[vi].uv[2]) to:meshString
				
		format "\t}\n" to:meshString
	)
	format "}\n" to:meshString
	
	format "indices {\n" to:meshString
	for fi=1 to faceNum  do
	(	-- 反序
		format "\t% % %\n" blIndices[fi*3] blIndices[fi*3-1] blIndices[fi*3-2] to:meshString
	)
	format "}\n" to:meshString
	
	progress 40

)

function exportMorph =
(
	if true do
	(
		-- 显示原mesh的顶点
		format "mesh:\n"
		for vi=1 to gMesh.numverts do
		(
			v = getvert gMesh vi
			--format "p % = %\n" vi v
		)
		format "mesh:\n"
		for vi=1 to blVertices.count do
		(
			v = getvert gMesh blVertices[vi].vertexIndex
			--format "p% % = %\n" vi blVertices[vi].vertexIndex v
		)
		-- 导出每个channel的顶点数据
		for ci=1 to channelList.count do
		(
			vertexCount = WM3_MC_NumMPts gMorpher channelList[ci]
			format "channel %:\n" channelList[ci]
			for vi=1 to blVertices.count do
			(
				point = WM3_MC_GetMorphPoint gMorpher channelList[ci] (blVertices[vi].vertexIndex-1)
				--format "p% % = %\n" vi blVertices[vi].vertexIndex point
			)			
		)
	)
	
	-- 导出每个channel的顶点数据
	for ci=1 to channelList.count do
	(
		vertexCount = WM3_MC_NumMPts gMorpher channelList[ci]
		format "channel % {\n" ci to:meshString
		for vi=1 to blVertices.count do
		(
			point = WM3_MC_GetMorphPoint gMorpher channelList[ci] (blVertices[vi].vertexIndex-1)
	
			format "\tv % {\n" (vi-1) to:meshString
				format "\t\t% % %\n" point[1] point[3] point[2] to:meshString
				format "\t}\n" to:meshString
		)
		format "}\n" to:meshString
		
		progress (40 + 30*ci/channelList.count)
	)

)

function exportAnimation =
(
	modPanel.setCurrentObject gMorpher

	for pi = 1 to animationNames.count do
	(
		aniName = animationNames[pi]
		t1 = animationTimePairs[pi*2-1]
		t2 = animationTimePairs[pi*2]

		format "导出动画(%) [%, %]\n" aniName t1 t2
		
		keyFrame = t1 	-- start time
		lastKeyFrame = keyFrame 
		isEnd = false
		maxKey = 0
		
		-- 检查要改动画使用了哪几个channel
		usedChannelList = #()
		do
		(
			set time keyFrame
			for ci=1 to channelList.count do
			(
				val = WM3_MC_GetValue gMorpher channelList[ci]
				if val > 0 then
				(
					if (findItem usedChannelList ci) == 0 then
						append usedChannelList ci
				)
			)
			
			-- 下一关键帧
			lastKeyFrame = keyFrame
			nextKeyTimeStr = trackbar.getNextKeyTime()
			if nextKeyTimeStr == undefined then
			(
				keyFrame = t2+1
			)
			else
			(
				keyFrameStr = (nextKeyTimeStr as string)
				keyFrameStr = substring keyFrameStr 1 (keyFrameStr.count-1)	-- 去掉f
				keyFrame = keyFrameStr as number
			)
			
			if isEnd == false and keyFrame >= t2 then
			(				
				keyFrame = t2
				isEnd = true;
			)
			
			maxKey += 1
		)
		while (keyFrame <= t2 and keyFrame >= lastKeyFrame and maxKey < 100)	-- maxKey最多关键帧
		
		-- 显示使用的channel
		for ui = 1 to usedChannelList.count do
		(
			format "使用的channel: %\n" usedChannelList
		)
		if usedChannelList.count > 3 then
			format "动画%使用的channel数大于3\n" aniName to:errString
		
			
		keyFrame = t1 	-- start time
		lastKeyFrame = keyFrame 
		isEnd = false
		

		format "animation \"%\" {\n" aniName to:meshString
		-- 导出使用了哪几个channel
		format "\t% %\n" usedChannelList.count maxKey to:meshString
		format "\t" to:meshString
		for ui = 1 to usedChannelList.count do
		(
			format "% " usedChannelList[ui] to:meshString
		)
		format "\n" to:meshString

		maxKey = 0
		do
		(
			set time keyFrame
			format "\t%" keyFrame to:meshString
			
			for ci=1 to usedChannelList.count do
			(
				weight = WM3_MC_GetValue gMorpher channelList[usedChannelList[ci]]
				if weight < 0 then weight = 0.0
				if weight > 100 then weight = 100.0
				format " %" weight to:meshString
			)
			format "\n" to:meshString
			
			
			-- 下一关键帧
			lastKeyFrame = keyFrame
			nextKeyTimeStr = trackbar.getNextKeyTime()
			if nextKeyTimeStr == undefined then
			(
				keyFrame = t2+1
			)
			else
			(
				keyFrameStr = (nextKeyTimeStr as string)
				keyFrameStr = substring keyFrameStr 1 (keyFrameStr.count-1)	-- 去掉f
				keyFrame = keyFrameStr as number
			)
			
			if isEnd == false and keyFrame >= t2 then
			(				
				keyFrame = t2
				isEnd = true;
			)
			
			maxKey += 1
		)
		while (keyFrame <= t2 and keyFrame >= lastKeyFrame and maxKey < 100)	-- maxKey最多关键帧
		format "}\n" to:meshString
		
		progress (70 + 30*pi/animationNames.count)
	)
)
-- 函数入口
function main =
(
	-- 指定保存文件
	if (CrownExport.fileNameEditor.text.count > 0) then
	(
		morphFileName = CrownExport.fileNameEditor.text
	)
	else
	(
		morphFileName = "test.blf"		
	)
	
	morphFileName=getsavefilename caption:"保存Morph动画文件" \
			filename:morphFileName\
			types:"blf(*.blf)|*.blf"
	if morphFileName == undefined then return undefined
	
	CrownExport.fileNameEditor.text = morphFileName 
	--morphFileName = "C:\JerryO\3D\morph1\plane.blf"
	savePath = getFilenamePath morphFileName
	morphFile = createfile morphFileName 
	
	meshString = stringstream""
	errString = stringstream""
	
	try
	(
		gMesh = $
		if checkMesh() do
		(
			gMesh.position = [0,0,0]
			gMesh.rotation.x = 0
			gMesh.rotation.y = 0
			gMesh.rotation.z = 0
			gMesh.rotation.w = 1
			
			format "开始导出 %\n" gMesh
			exportHeader()		-- 文件头
			exportMesh()			-- 导出原始mesh数据
			exportMorph()			-- 导出channel数据
			exportAnimation()		-- 导出动画
			
			format "%" (meshString as string) to:morphFile
		)
	)
	catch
	(
		exceptionString = stringstream""
		format "导出时发生错误!\n*** % ***\n" (getCurrentException()) to:exceptionString
		messageBox (exceptionString as string) title:"错误!"
	)
	close morphFile
	format "关闭动画文件\n"
	
	-- 转换所有tag为blt
	--thisMaxScriptDir = getSourceFileName()
	--thisMaxScriptDir = getFilenamePath thisMaxScriptDir 
	--commandStr = thisMaxScriptDir + "ConvertTgaToBlt.exe " + (getFilenamePath morphFileName)
	--format "DOS:%\n" commandStr 			
	--DOSCommand commandStr 
	-- 错误报告
	if ((errString as string).count > 0)  then
	(
		format "错误报告\n"
		format "%" (errString as string)
		messageBox (errString as string) title:"错误!"
	)
)

rollout CrownExport "Crown Morph动画导出工具" width:160 height:160
(
	button bexport "    导出     "
	label lbl4 "导出文件名" pos:[10,40] width:152 height:16
	edittext fileNameEditor "" pos:[2,55] width:150 height:16 
	progressbar progExport color:blue visible:false
	
	-- 导出	
	on bexport pressed do
	( 
		progExport.visible = true
		progress 0
		main()
		progExport.visible = false
	)
)

-- 创建对话框
if CrownExportFloater != undefined do
(
	closerolloutfloater CrownExportFloater 
)
CrownExportFloater = newRolloutFloater "Morph导出" 170 160 \
	(mouse.screenpos[1]-85) (mouse.screenpos[2]-60) -- 创建一个Rollout
addRollout CrownExport CrownExportFloater 

--main()