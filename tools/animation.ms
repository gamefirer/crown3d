global isExportHide = true		-- 是否导出隐藏物体
global isExportKeyFrame = false		-- 是否只导出关键帧
global frameSampleRate = 5			-- 逐帧导出采样率
global isExportBlt = true			-- 是否导出绑定点
global isExportBla = true			-- 是否导出骨骼
global isExportBlm = true			-- 是否导出模型
global isExportBlq = false			-- 是否导出动画
global isSkinCheck = true			-- 是否做skin数据检查


global CrownExport		-- 界面
global savePath = ""	-- 保存的目录
global avatarFileName = ""		-- 要保存的角色文件名
global textureFileName = ""		-- 贴图名
global mesh_array = #()		-- 要导出的mesh数组
global bone_array = #()		-- 骨骼中的骨头
global helper_array = #()	-- 骨骼绑定点
global aniString = stringstream""	-- 角色文件字串
global meshString = stringstream""	-- 模型文件字串
global errString = stringstream""	-- 错误描述
global baseFrame = 0		-- 设定第0帧为默认帧

global isBinary = true	-- 字节流
global chunkid_bla_mesh = 0x0100
global chunkid_bla_hierarchy = 0x0200
global chunkid_bla_bones = 0x0300
global chunkid_bla_bonetags = 0x0400
global chunkid_blq_animation = 0x0500
global chunkid_blq_bone = 0x0600
global chunkid_blq_time = 0x0700
global chunkid_blm_vertex = 0x0800
global chunkid_blm_index = 0x0900

-- 计算两点间距离
function vdistance v1 v2 =
(
	dis = sqrt( (pow (v1[1]-v2[1]) 2) + (pow (v1[2]-v2[2]) 2) + (pow (v1[3]-v2[3]) 2) )
	return dis
)
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

) -- end of fn lowercase
-- 设置进度条
function progress pro =
(
	CrownExport.progExport.value = pro	-- 进度条
)
-- 导出数据检查
function SkinCheck =
(
	-- 检查导出数据合法性
	geocount = geometry.count
	--format "geocount = %\n" geocount 
	mi = 1
	proi = 1	
	for meshi in geometry do
	(
		progress( 20 * proi / geocount )	-- 进度条
		proi += 1
		-- 是否导出隐藏物体
		if meshi.isHidden and isExportHide == false do
		(
			format "% 隐藏\n" meshi.name
			continue
		)
		-- 必须是Editable_mesh
		if ( ((classof meshi ) as string) != "Editable_mesh" ) do
			continue
		if meshi.modifiers == undefined do continue
		
		format "检查%\n" meshi.name

		checkok = true
		-- 有且仅有一个skin
		mods = meshi.modifiers
		if mods.count != 1 do continue
		skin = mods[1]
		if (classof skin as string != "Skin") do
		(
			format "mesh %并非有且仅有一个skin,不导出\n" meshi.name
			format "mesh %并非有且仅有一个skin,不导出\n" meshi.name to:errString
			continue
		)
		
		select meshi-- 选中该mesh
		setCommandPanelTaskMode mode:#modify
		modPanel.setCurrentObject skin 	-- 选中skin界面
		
		-- 是否有贴图
		--format "是否有贴图\n"
		isHaveUV = (meshop.getMapSupport meshi 1)
		if isHaveUV == false then
		(
			format "mesh %没有UV数据不导出\n" meshi.name
			format "mesh %没有UV数据不导出\n" meshi.name to:errString
			checkok = false
			continue
		)
		
		-- 检查只能有一个材质
		--format "检查只能有一个材质\n"
		faceNum = getNumFaces meshi
		isOnlyOneMat = true
		matId = -1
		for fi=1 to faceNum do
		(		
			if fi == 1 then
				matId = getFaceMatID meshi fi
			else
			(
				if matId != (getFaceMatID meshi fi) then
				(
					format "mesh %有多个材质不导出\n" meshi.name
					format "mesh %有多个材质不导出\n" meshi.name to:errString
					isOnlyOneMat = false
					exit
				)
			)
		)
				
		if isOnlyOneMat == false then
		(
			checkok = false
			continue
		)
		-- 检查所有mesh是否是用同一张贴图
		--format "检查所有mesh是否是用同一张贴图\n"
		if( (classof meshi.material) as string != "Standardmaterial" ) then
		(
			format "% 的材质不是Standardmateria\n" meshi.name
			format "% 的材质不是Standardmateria\n" meshi.name to:errString
			checkok = false
			continue
		)
		
		if( (classof meshi.material.diffuseMap) as string != "Bitmaptexture" ) then
		(
			format "% 的材质的diffusemap不是Bitmaptexture\n" meshi.name
			checkok = false
			continue
		)
		if mi == 1 then
		(
			textureFileName = meshi.material.diffuseMap.filename
			format "导出贴图为%\n" textureFileName 
		)
		else
		(
			-- 不做贴图检查
			--if textureFileName != meshi.material.diffuseMap.filename then
			--(
			--	format "% 的贴图%与其它模型的贴图不符\n" meshi.name textureFileName 
			--	format "% 的贴图%与其它模型的贴图不符\n" meshi.name textureFileName to:errString
			--	checkok = false
			--	continue
			--)
		)
		
		-- 检查骨骼是否匹配
		--format "检查骨骼是否匹配\n"
		boneCount = skinOps.GetNumberBones skin
		
		if mi == 1 then
		(
			-- 记录骨头
			for bi=1 to boneCount do
			(
				boneName = skinOps.GetBoneName skin bi 0
				format "骨头:%\n" boneName
				append bone_array boneName
			)
			format "骨头数:%\n" bone_array.count
		)
		else
		(
			-- 检查骨头数相符
			if boneCount != bone_array.count do
			(
				format "mesh % 的skin中骨骼数不符\n" meshi.name
				format "mesh % 的skin中骨骼数不符\n" meshi.name to:errString
				checkok = false
			)
			-- 检查骨头名字相符			
			for bi=1 to boneCount do
			(
				boneName = skinOps.GetBoneName skin bi 1
				index = findItem bone_array boneName
				if index == 0 then
				(
					format "mesh % 的skin的中的骨头%与其它skin不符\n" meshi.name boneName
					format "mesh % 的skin的中的骨头%与其它skin不符\n" meshi.name boneName to:errString
					checkok = false
				)
			)
		)
				
		-- 检查每个顶点上的权值不能超过4个
		--format "检查每个顶点上的权值不能超过4个\n"
		vertexNum = getNumVerts meshi
		format "vertexNum=%\n" vertexNum 
		for vi=1 to vertexNum do
		(
			weightCount = skinops.getvertexweightcount skin vi
			if weightCount > 4 then
			(
				format "mesh %的第%个顶点的骨骼权重数超过4个\n" meshi.name (vi-1)
				format "mesh %的第%个顶点的骨骼权重数超过4个\n" meshi.name (vi-1) to:errString
				checkok = false
			)
		)
		
		-- 记录要导出的mesh
		if checkok then
		(
			append mesh_array meshi
			format "导出列表加入第%个mesh: %\n" mi meshi.name
		)
		else
		(
			format "mesh: % %骨骼不符不导出\n" mi meshi.name
			format "mesh: % %骨骼不符不导出\n" mi meshi.name to:errString
		)
		
		mi += 1
	)
	-- 对骨骼排序(保证parent骨头在前面)
	newBone_array = #()
	lastBoneArrayCount = bone_array.count
	while bone_array.count > 0 do
	(
		for bi=1 to bone_array.count do
		(
			boneNode = getnodebyname bone_array[bi]
			isInsert = false
			--format "boneNode=%\n" boneNode.name
			if boneNode.parent == undefined then
			(
				append newBone_array boneNode.name
				--format "insert 根节点 %\n" boneNode.name
				isInsert = true
			)
			else
			(
				if (findItem newBone_array boneNode.parent.name) != 0 then
				(
					append newBone_array boneNode.name
					--format "insert 子节点 % %\n" boneNode.name boneNode.parent
					isInsert = true
				)				
			)
			
			if isInsert then
			(	
				bone_array = deleteItem bone_array bi
				exit
			)
		)
		
		--format "bone_array.count=%\n" bone_array.count
		if lastBoneArrayCount == bone_array.count then
		(
			format "skin中的骨骼不全\n"
			format "skin中的骨骼不全\n" to:errString
			newBone_array.count = 0
			exit
		)

		lastBoneArrayCount = bone_array.count		
	)

	bone_array = newBone_array
	
	-- 检测要导出的骨骼绑定点
	helper_array = #()
	for helper in helpers do
	(
		if helper.parent == undefined then continue	-- dummy物体没有parent
		if findItem bone_array helper.parent.name == 0 then continue -- dummy的parent不是要导出的骨骼
		-- 排除cs骨骼默认的dummy点
		if helper.name == "Bip01 HeadNub" or 
			helper.name == "Bip01 R Finger0Nub" or
			helper.name == "Bip01 L Finger0Nub" or
			helper.name == "Bip01 R Toe0Nub" or
			helper.name == "Bip01 L Toe0Nub" or
			helper.name == "Bip01 R Finger1Nub" or
			helper.name == "Bip01 L Finger1Nub"			
		then continue
		
		append helper_array helper.name
		--format "%\n" helper.name
	)
		
	-- 显示要输出的mesh和骨头
	format "要导出的mesh(数量%):\n" mesh_array.count
	for mi=1 to mesh_array.count do
	(
		format "%\n" mesh_array[mi].name
	)
	format "要导出的骨头(数量%):\n" bone_array.count
	for bi=1 to bone_array.count do
	(
		format "%\n" bone_array[bi]
	)
	format "要导出的骨骼绑定点(数量%):\n" helper_array.count
	for hi=1 to helper_array.count do
	(
		format "%\n" helper_array[hi]
	)
	
	if mesh_array.count == 0 do
	(	
		format "导出mesh数为0\n"
		return false
	)
	
	if bone_array.count == 0 or bone_array.count > 38 do
	(
		format "骨头数大于38或为0\n"
		format "骨头数大于38或为0\n" to:errString
		return false
	)
	
	if helper_array.count == 0 then
	(
		format "必须至少有一个合法骨骼绑定点\n"
		format "必须至少有一个合法骨骼绑定点\n" to:errString
		return false
	)
		
	return true
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
function MyWriteString file string =
(
	WriteShort file string.count unsigned 	-- 字符串长度
	WriteString file string					-- 字符串
)
-- 动画文件头
function WriteAniHeader file =
(
	if isBinary then
	(		
		WriteLong file 2 unsigned		-- 版本号
		WriteLong file bone_array.count 	-- 骨骼数
		MyWriteString file (getFilenameFile textureFileName) 		-- 贴图名
		
		-- mesh描述chunk
		WriteShort file chunkid_bla_mesh unsigned
		WriteLong file mesh_array.count unsigned
		-- mesh描述数据
		for mi=1 to mesh_array.count do
		(
			MyWriteString file mesh_array[mi].name
		)
	)
	else
	(
		format "blaversion %\n" 1 to:file
		format "\n" to:file
		format "boneNum %\n" bone_array.count to:file
		format "\n" to:file
		format "tex \"%\"\n" (getFilenameFile textureFileName) to:file
		format "\n" to:file
			
		format "mesh {\n" to:file
		for mi=1 to mesh_array.count do
		(
			format "\t%\n" mesh_array[mi].name to:file
		)
		format "}\n" to:file
		format "\n" to:file
	)

)
-- 骨骼关系
function WriteBoneHierarchy file =
(
	if isBinary then
	(
		-- 骨骼继承关系chunk
		WriteShort file chunkid_bla_hierarchy unsigned
		WriteLong file bone_array.count unsigned
		-- 骨骼继承关系数据
		for bi=1 to bone_array.count do
		(			
			boneNode = getnodebyname bone_array[bi]
			if boneNode.parent == undefined then
			(				
				MyWriteString file bone_array[bi]
				WriteShort file -1
			)
			else
			(
				parentIndex = findItem bone_array boneNode.parent.name
				MyWriteString file bone_array[bi]
				WriteShort file (parentIndex-1)
			)
		)
	)
	else
	(
		format "hierarchy {\n" to:file
		for bi=1 to bone_array.count do
		(
			boneNode = getnodebyname bone_array[bi]
			if boneNode.parent == undefined then
			(
				format "\t\"%\" %\n" bone_array[bi] -1 to:file
			)
			else
			(
				parentIndex = findItem bone_array boneNode.parent.name
				format "\t\"%\" %\n" bone_array[bi] (parentIndex-1) to:file
			)			
		)
		format "}\n" to:file
		format "\n" to:file
	)
)
-- 骨骼数据
function WriteBonePosition file =
(
	if isBinary then
	(
		-- 骨骼数据chunk
		WriteShort file chunkid_bla_bones unsigned
		WriteLong file bone_array.count unsigned
		-- 骨骼数据
		for bi=1 to bone_array.count do
		(
			boneNode = getnodebyname bone_array[bi]
			boneMat = boneNode.transform
			bonePos = boneMat.translation
			boneRot = boneMat.rotationpart
			if boneRot.w < 0 then boneRot = -boneRot
			
			WriteFloat file bonePos.x
			WriteFloat file bonePos.z
			WriteFloat file bonePos.y
			WriteFloat file -boneRot.x
			WriteFloat file -boneRot.z
			WriteFloat file -boneRot.y
		)	
	)
	else
	(
		format "bones {\n" to:file
		for bi=1 to bone_array.count do
		(
			boneNode = getnodebyname bone_array[bi]
			boneMat = boneNode.transform
			bonePos = boneMat.translation
			boneRot = boneMat.rotationpart
			if boneRot.w < 0 then boneRot = -boneRot
			
			--format "%\n" boneNode.transform
			
			format "\t% ( % % % ) ( % % % )\n" \
			(bi-1) \
			bonePos.x bonePos.z bonePos.y \
			-boneRot.x -boneRot.z -boneRot.y \
			to:file
			--boneNode.rotation.x boneNode.rotation.y boneNode.rotation.z boneNode.rotation.w \
		)	
		format "}\n" to:file
		format "\n" to:file
	)
)
-- 骨骼绑定点
function WriteHelper file =
(
	if isBinary then
	(
		-- 骨骼绑定点chunk
		WriteShort file chunkid_bla_bonetags unsigned
		WriteLong file helper_array.count unsigned
		-- 骨骼绑定点数据
		for hi=1 to helper_array.count do
		(
			format "导出骨骼绑定点 %\n" helper_array[hi]
			helperNode = getnodebyname helper_array[hi]
			
			helperMat = helperNode.transform
			parentMat = helperNode.parent.transform
			parentMatInv = inverse parentMat
			helperMat = helperMat * parentMatInv
			helperPos = helperMat.translation
			helperRot = helperMat.rotationpart
			if helperRot.w < 0 then helperRot = -helperRot 
			
			parentBoneIndex = findItem bone_array helperNode.parent.name
			
			MyWriteString file helperNode.name
			WriteShort file (parentBoneIndex-1)
			
			WriteFloat file helperPos.x
			WriteFloat file helperPos.z
			WriteFloat file helperPos.y
			WriteFloat file -helperRot.x
			WriteFloat file -helperRot.z
			WriteFloat file -helperRot.y
		)
	)
	else
	(
		format "bonetags {\n" to:file
		for hi=1 to helper_array.count do
		(
			format "导出骨骼绑定点 %\n" helper_array[hi]
			helperNode = getnodebyname helper_array[hi]
			
			helperMat = helperNode.transform
			parentMat = helperNode.parent.transform
			parentMatInv = inverse parentMat
			helperMat = helperMat * parentMatInv
			helperPos = helperMat.translation
			helperRot = helperMat.rotationpart
			if helperRot.w < 0 then helperRot = -helperRot 
			
			parentBoneIndex = findItem bone_array helperNode.parent.name
			
			format "\t\"%\" % ( % % % ) ( % % % )\n" \
			helperNode.name (parentBoneIndex-1)  \
			helperPos.x helperPos.z helperPos.y \
			-helperRot.x -helperRot.z -helperRot.y\
			to:file
		)
		format "}\n" to:file
		format "\n" to:file
	)
)
-- 骨骼动画数据
function WriteBoneAnimation file aniName startTime endTime =
(
	if endTime < startTime then return undefined
		
	mustExportKeyFrame = false
	if (findItem CrownExport.animList.items aniName) != 0 then
		mustExportKeyFrame = true
	
	format "导出动画:% startTime=% endTime=% kf=%\n" \
		aniName startTime endTime (mustExportKeyFrame or isExportKeyFrame)
	
	-- 动画chunk	
	if isBinary then
	(
		WriteShort file chunkid_blq_animation unsigned
		WriteLong file bone_array.count unsigned
		MyWriteString file aniName
	)
	else
	(
		format "animation \"%\" {\n" aniName to:file
	)
		
	for bi=1 to bone_array.count do
	(
		-- 该动画的骨头chunk
		keyCountFilePos
		if isBinary then
		(
			WriteShort file chunkid_blq_bone unsigned
			keyCountFilePos = ftell file			
			WriteLong file 0 unsigned
		)
		else
		(
			format "\tbone % {\n" (bi-1) to:file
		)
		
		boneNode = getnodebyname bone_array[bi]
		select boneNode
		
		keyFrame = startTime 	-- start time
		lastKeyFrame = keyFrame 
		isEnd = false

		maxKey = 0
		do
		(
			set time keyFrame
			--format "bone=% time=% %\n" (bi-1) keyFrame boneNode.parent
			
			boneMat = boneNode.transform
			bonePos = boneMat.translation
			boneRot = boneMat.rotationpart
			if boneNode.parent != undefined then
			(
				parentMat = boneNode.parent.transform
				parentMatInv = inverse parentMat
				boneMat = boneMat * parentMatInv
				bonePos = boneMat.translation
				boneRot = boneMat.rotationpart
			)
			
			if boneRot.w < 0 then boneRot = -boneRot
 			
			-- SWAP YZ
			if isBinary then
			(
				WriteLong file keyFrame
				
				WriteFloat file bonePos.x
				WriteFloat file bonePos.z
				WriteFloat file bonePos.y
				WriteFloat file -boneRot.x
				WriteFloat file -boneRot.z
				WriteFloat file -boneRot.y
			)
			else
			(
				format "\t\ttime % ( % % % ) ( % % % )\n" keyFrame \
				bonePos.x bonePos.z bonePos.y \
				-boneRot.x -boneRot.z -boneRot.y  \
				to:file
			)

			-- 下一关键帧
			lastKeyFrame = keyFrame
			if mustExportKeyFrame or isExportKeyFrame then
			(	-- 只导出关键帧
				nextKeyTimeStr = trackbar.getNextKeyTime()
				if nextKeyTimeStr == undefined then
				(
					keyFrame = endTime+1
				)
				else
				(
					keyFrameStr = (nextKeyTimeStr as string)		-- 5f				
					keyFrameStr = substring keyFrameStr 1 (keyFrameStr.count-1)	-- 去掉f
					keyFrame = keyFrameStr as number
				)
			)
			else
			(	-- 隔帧采样
				if frameSampleRate < 1 then frameSampleRate = 1
				keyFrame = lastKeyFrame + frameSampleRate
			)
			
			if isEnd == false and keyFrame >= endTime then
			(				
				keyFrame = endTime
				isEnd = true;
			)
			
			maxKey += 1
			--format "keyFrame= % endTime=%\n" keyFrame endTime
		)
		while (keyFrame <= endTime and keyFrame >= lastKeyFrame and maxKey < 100)	-- maxKey最多关键帧
		
		if isBinary then
		(	
			ret = fseek file keyCountFilePos #seek_set 		-- 回到写keyframe数处
			if ret == false then throw "fseek error"
			
			ret = WriteLong file maxKey unsigned					-- 写入keyframe数
			
			ret = fseek file 0 #seek_end 				-- 回到文件尾
			if ret == false then throw "fseek error"
		)
		else
		(
			format "\t}\n" to:file
		)
	)
	
	if isBinary then
	(
	)
	else
	(
		format "}\n" to:file
	)
)
-- 导出模型
struct blVertexData
(
	vertex,
	uv,
	weights,
	boneIndexs,
	boneOffsets
)

function ExportMesh mesh file =
(
	mods = mesh.modifiers
	skin = mods[1]
	
	select mesh-- 选中该mesh
	setCommandPanelTaskMode mode:#modify
	modPanel.setCurrentObject skin 	-- 选中skin界面


	vertexNum = getNumVerts mesh		-- 顶点数
	--format "vertices=%\n" vertexNum
	faceNum = getNumFaces mesh			-- 三角面数
	--format "face=%\n" faceNum
	
		
	-- 导出
	blVertices = #()	-- 顶点序列
	blIndices = #()	-- 引索序列
	
	--format "NumMaps=%\n" (meshop.getNumMaps mesh)
 	MapVertNum = meshop.getNumMapVerts mesh 1
	--format "NumMapVerts=%\n" MapVertNum 
	
	if false do	-- 调试用
	(
		-- 显示所有顶点
		format "vertex\n"
		for vi=1 to vertexNum do
		(
			vertex = getVert mesh vi
			weightCount = skinops.getvertexweightcount skin vi
			boneIDs = #()
			weights = #()
			for wi=1 to weightCount do
			(
				boneid = skinops.getvertexweightboneid skin vi wi
				weight = skinops.getvertexweight skin vi wi
				append boneIDs boneid
				append weights weight
			)
			
			format "% % % % %\n" vi vertex weightCount boneIDs weights 
		)
		-- 显示所有UV
		format "uv\n"
		for mi=1 to MapVertNum do
		(
			tvertex = meshop.getmapvert mesh 1 mi	
			format "% %\n" mi tvertex
		)
		-- 显示骨骼
		format "bone\n"
		for bi=1 to bone_array.count do
		(
			boneNode = getnodebyname bone_array[bi]
			format "% %\n" bi boneNode.transform
		)

	)
	
	for fi=1 to faceNum do
	(
		vertindices = getFace mesh fi		-- 顶点引索
		tvertindices = meshop.getmapface mesh 1 fi --uv引索
		-- 对三角面三个顶点
		v1 = #()
		v2 = #()
		v3 = #()
		for fvi=1 to 3 do
		(
			vert = getVert mesh vertindices[fvi]
			uv = meshop.getmapvert mesh 1 tvertindices[fvi]
			
			if fvi==1 do v1=vert
			if fvi==2 do v2=vert
			if fvi==3 do v3=vert		
			
			weightCount = skinops.getvertexweightcount skin vertindices[fvi]
			boneIndexs = #()
			weights = #()
			boneOffsets = #()
			for wi=1 to weightCount do
			(
				boneid = skinops.getvertexweightboneid skin vertindices[fvi] wi
				weight = skinops.getvertexweight skin vertindices[fvi] wi
				boneName = skinops.getbonename skin boneid 0
				boneNode = getnodebyname boneName
				invBoneMat = inverse boneNode.transform
				boneOffset = vert * invBoneMat
				boneIndex = findItem bone_array boneName

				append boneIndexs boneIndex
				append weights weight
				append boneOffsets boneOffset
			)			
			--format "face=% vi=% verti=% vert=% uvi=% uv=% boneIDs=% w=% offset=%\n" \
			--	fi fvi vertindices[fvi] vert tvertindices[fvi] uv boneIDs weights boneOffsets 
			
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
				newblVert.weights = weights
				newblVert.boneIndexs = boneIndexs
				newblVert.boneOffsets = boneOffsets
				
				append blVertices newblVert
				blIndex = blVertices.count	
			)
			else
			(	-- 顶点序列中有此顶点了
			
			)
			append blIndices (blIndex-1)
		)
		-- 检验顶点不能重合
		dis1 = vdistance v1 v2
		dis2 = vdistance v1 v3
		dis3 = vdistance v2 v3
		--format "face=% v1=% v2=% v3=% d12=% d13=% d23=%\n" fi v1 v2 v3 dis1 dis2 dis3
		if dis1 < 0.01 or dis2 < 0.01 or dis3 < 0.01 do
		(
			format "mesh:%的第个%面有重合顶点% % %\n " mesh.name fi v1 v2 v3 to:errString
		)		
	)
	
	
	-- 导出顶点和引索数据
	if isBinary then
	(
		WriteLong file 2 unsigned		-- 版本号
		WriteLong file blVertices.count 	-- 顶点数
		WriteLong file faceNum  		-- 面数
		WriteLong file blIndices.count	-- 引索数
		
		-- vertex描述chunk
		WriteShort file chunkid_blm_vertex unsigned
		WriteLong file blVertices.count unsigned
		
		-- vertex数据		
		for vi=1 to blVertices.count do
		(			
			-- 顶点位置
			WriteFloat file blVertices[vi].vertex[1]
			WriteFloat file blVertices[vi].vertex[3]
			WriteFloat file blVertices[vi].vertex[2]
			-- uv
			WriteFloat file blVertices[vi].uv[1]
			WriteFloat file (1-blVertices[vi].uv[2])
			-- 骨骼权重数
			WriteByte file (blVertices[vi].weights.count) unsigned
			-- 骨骼权重
			for bi=1 to blVertices[vi].weights.count do
			(
				WriteShort file (blVertices[vi].boneIndexs[bi]-1)
				WriteFloat file blVertices[vi].weights[bi]
			)
		)
		
		-- index描述chunk
		WriteShort file chunkid_blm_index unsigned
		WriteLong file faceNum unsigned

		-- index数据
		for fi=1 to faceNum  do
		(
			WriteLong file blIndices[fi*3] unsigned
			WriteLong file blIndices[fi*3-1] unsigned
			WriteLong file blIndices[fi*3-2] unsigned
		)
	)
	else
	(
		format "animation %%\n" (getFilenameFile avatarFileName) (getFilenameType avatarFileName) to:file
		format "vertexNum %\n" blVertices.count to:file
		format "faceNum %\n" faceNum to:file
		format "indexNum %\n" blIndices.count to:file
		format "\n" to:file
		
		format "vertices {\n" to:file
		for vi=1 to blVertices.count do
		(
			format "\tv % {\n" (vi-1) to:file
			-- 顶点位置
			format "\t\t% % %\n" \
				blVertices[vi].vertex[1] blVertices[vi].vertex[3] blVertices[vi].vertex[2] to:file -- 位置
			-- uv
			format "\t\t% %\n" blVertices[vi].uv[1] (1-blVertices[vi].uv[2]) to:file
			-- 骨骼权重数
			format "\t\t%\n" (blVertices[vi].weights.count) to:file
			for bi=1 to blVertices[vi].weights.count do
			(
				-- 骨骼序号 权重 offset
	--			format "\t\t% % % % %\n" \
	--			(blVertices[vi].boneIndexs[bi]-1) blVertices[vi].weights[bi] \
	--			blVertices[vi].boneOffsets[bi].x blVertices[vi].boneOffsets[bi].z blVertices[vi].boneOffsets[bi].y\
	--			to:file
				format "\t\t% %\n" \
				(blVertices[vi].boneIndexs[bi]-1) blVertices[vi].weights[bi] \
				to:file
	
			)
				
			format "\t}\n" to:file
		)
		format "}\n" to:file
		
		format "indices {\n" to:file
		for fi=1 to faceNum  do
		(	-- 反序
			format "\t% % %\n" blIndices[fi*3] blIndices[fi*3-1] blIndices[fi*3-2] to:file
		)
		format "}\n" to:file
	)
)
-- 导出每个模型到文件
function ExportMeshs savePath =
(
	for mi=1 to mesh_array.count do
	(
		progress( 70 + (20 * mi / mesh_array.count) )	-- 进度条
		mesh = mesh_array[mi]
		meshFileName = savePath + mesh.name + ".blm"
		format "创建模型文件 %\n" meshFileName 
		if isBinary then
			meshFile = fopen meshFileName "wb"
		else
			meshFile = createfile meshFileName 	-- 创建模型文件
		try
		(
			if isBinary then
			(
				ExportMesh mesh meshFile
			)
			else
			(
				meshString = stringstream""
				ExportMesh mesh meshString 
				format "%" (meshString as string) to:meshFile 
			)
		)
		catch
		(
			format "导出模型 异常!\n"
			messageBox "导出模型发生错误!" title:"导出错误"
		)
		if isBinary then
			fclose meshFile 
		else
			close meshFile 
		format "关闭模型文件\n"
		
		-- 导出第一个模型的贴图,不导出贴图
		--if mi==1 then
		--(
		--	TextureExport mesh
		--)
	)
)
-- 导出函数
function ExportAnim fileName =
(
	isOk = true
	avatarFileName = fileName
	savePath = getFilenamePath avatarFileName
	
	-- 导出avatar文件（描述avatar骨骼的文件)
	if isExportBla do
	(
		format "导出avatar文件 %\n" avatarFileName 
		if isBinary then
			avatarFile = fopen (lowercase avatarFileName) "wb"
		else
			avatarFile = createfile avatarFileName 	-- 创建avatar文件
		try
		(
			set time baseFrame
			if isBinary then
			(
				WriteAniHeader avatarFile		-- 文件头
				WriteBoneHierarchy avatarFile	-- 骨骼关系
				WriteBonePosition avatarFile	-- 骨骼数据
				--WriteHelper avatarFile			-- 骨骼绑定点
			)
			else
			(
				avatarString = stringstream""
				WriteAniHeader avatarString 		-- 文件头
				WriteBoneHierarchy avatarString -- 骨骼关系
				WriteBonePosition avatarString -- 骨骼数据
				--WriteHelper avatarString 	-- 骨骼绑定点
				format "%" (avatarString as string) to:avatarFile 
			)
		)
		catch
		(
			format "导出avatar文件 异常!\n"
			messageBox "导出时发生错误!" title:"导出错误"
			isOk = false
		)
		if isBinary then
			fclose avatarFile
		else
			close avatarFile 
		format "关闭动画文件\n"
		if isOk == false then return undefined
	)
	
	-- 导出骨骼绑定点文件
	if isExportBlt do
	(
		-- 创建骨骼绑定点文件
		tagFileName = savePath + (getFilenameFile avatarFileName) + ".blt"
			
		if isBinary then
			tagFile = fopen tagFileName "wb"
		else
			tagFile = createfile tagFileName 
			
		try
		(
			if isBinary then
			(
				WriteHelper tagFile			-- 骨骼绑定点
			)
			else
			(
				tagString = stringstream""
				WriteHelper tagString 	-- 骨骼绑定点
				format "%" (tagString as string) to:tagFile 
			)
		)
		catch
		(
			format "导出骨骼绑定点文件 异常!\n"
			messageBox "导出时发生错误!" title:"导出错误"
			isOk = false
		)
		if isBinary then
			fclose tagFile 
		else
			close tagFile 
			
		format "关闭骨骼绑定点文件\n"
		if isOk == false then return undefined
	)
	
	
	-- 导出动作文件
	if isExportBlq do
	(
		tagsNum = FrameTagManager.GetTagCount()	-- 根据timetag导出		
		if tagsNum == 0 then format "没有设置Time Tag\n" to:errString 
		tagsPairNum = tagsNum / 2
		for pi = 1 to tagsPairNum do
		(
			CrownExport.progExport.value =  20 + (50 * pi / tagsPairNum )	-- 进度条
			
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
			
			-- 创建动画文件
			aniFileName = savePath + tagName + ".blq"
			
			if isBinary then
				aniFile = fopen aniFileName "wb"
			else
				aniFile = createfile aniFileName
			
			try
			(
				if isBinary then
				(
					WriteBoneAnimation aniFile tagName t1 t2
				)
				else
				(
					aniString = stringstream""
					WriteBoneAnimation aniString tagName t1 t2	-- 骨骼动画数据
					format "%" (aniString as string) to:aniFile
				)			
			)
			catch
			(			
				format "导出动画%异常! %\n" tagName (getCurrentException())
				messageBox "导出时发生错误!\n" title:"导出错误"
				isOk = false
			)
			
			if isBinary then
				fclose aniFile 
			else
				close aniFile 

			format "关闭动画文件%\n" tagName
			if isOk == false then return undefined
	
		)
	)
	
	-- 导出模型文件
	if isExportBlm do
	(
		format "导出模型文件到目录 %\n" savePath
		set time baseFrame
		ExportMeshs savePath
		format "导出模型完毕\n"
	)
		
)
-- 函数入口
function main =
(
	format "main start\n"
	-- 数据清空
	mesh_array.count = 0
	bone_array.count = 0
	helper_array.count = 0
	errString = stringstream""
	-- 指定保存文件
	if (CrownExport.fileNameEditor.text.count > 0) then
	(
		avatarFileName = CrownExport.fileNameEditor.text
	)
	else
	(
		avatarFileName = "avatar.bla"		
	)
	
	avatarFileName = getsavefilename caption:"保存角色" \
			filename:avatarFileName \
			types:"Crown AvatarFile (*.bla)|*.bla|All Files (*.*)|*.*|"
		if avatarFileName == undefined then return undefined
	
	CrownExport.fileNameEditor.text = avatarFileName
	
	format "保存到 %\n" avatarFileName 
	
	clearSelection()
	format "骨骼=% 模型=% 动画=%\n" isExportBla isExportBlm isExportBlq
	-- 检查数据合法性
	isOk = SkinCheck()
	-- 开始导出	
	if isOk or isSkinCheck==false then
	(	
		ExportAnim(avatarFileName)		
	)
	clearSelection()
	
	-- 转换所有tag为blt
	--thisMaxScriptDir = getSourceFileName()
	--thisMaxScriptDir = getFilenamePath thisMaxScriptDir 
	--commandStr = thisMaxScriptDir + "ConvertTgaToBlt.exe " + (getFilenamePath avatarFileName)
	--format "DOS:%\n" commandStr 			
	--DOSCommand commandStr 
		
	-- 结果报告
	if ((errString as string).count > 0)  then
	(
		format "错误报告\n"
		format "%" (errString as string)
		messageBox (errString as string) title:"警告!"
	)
	
	format "main end\n"
)

function trymain = 
(
	try
	(
		main()		
	)
	catch
	(
		exceptionString = stringstream""
		format "导出时发生错误!\n*** % ***\n" (getCurrentException()) to:exceptionString
		messageBox (exceptionString as string) title:"错误!"
	)
)

-- 界面
rollout CrownExport "Crown骨骼动画导出工具2.4.23版" width:205 height:500
(
	button btnExport "导出动画" width:85 height:20
	
	checkbox exportHide "Checkbox" pos:[40,32] width:16 height:16 checked:false
	label lbl1 "导出隐藏物体" pos:[55,32] width:112 height:16
	
	checkbox exportKeyFrame "Checkbox" pos:[40,50] width:16 height:16 checked:true
	label lbl2 "按关键帧导出" pos:[55,50] width:112 height:16
	
	checkbox exportNoBinary "Checkbox" pos:[0,70] width:16 height:16 checked:(not isBinary)
	label lbl9 "文本格式导出" pos:[15,70] width:112 height:16
	
	checkbox exportCheckSkin "Checkbox" pos:[100,70] width:16 height:16 checked:isSkinCheck
	label lbl11 "skin检测" pos:[115,70] width:112 height:16

	checkbox exportBla "Checkbox" pos:[5,90] width:16 height:16 checked:isExportBla enabled:true
	label lbl6 "骨骼" pos:[20,90] width:112 height:16
	
	checkbox exportBlt "Checkbox" pos:[50, 90] width:16 height:16 checked:isExportBlt enabled:true
	label lbl10 "绑定点" pos:[65, 90] width:112 height:16
	
	checkbox exportBlm "Checkbox" pos:[100,90] width:16 height:16 checked:isExportBlm
	label lbl7 "模型" pos:[115,90] width:112 height:16

	checkbox exportBlq "Checkbox" pos:[140,90] width:16 height:16 checked:isExportBlq
	label lbl8 "动画" pos:[155,90] width:112 height:16
	
	label lbl4 "导出文件名" pos:[10,110] width:172 height:16
	edittext fileNameEditor "" pos:[2,130] width:170 height:16 
	
	label lbl3 "采样帧率(每几帧采样一帧)" pos:[10,150] width:152 height:16 enabled:false
	spinner spn3 "" pos:[20,170] width:48 height:16 range:[1,10,5] type:#integer scale:1 enabled:false
		
	button btnTagList "更新动作列表" pos:[30,190] width:100 height:20 enabled:false
	label lbl5 "以下动作按关键帧导出" pos:[10,210] width:152 height:16 enabled:false
	listbox animList "" pos:[5, 230] width:148 height:15 enabled:false
	
	progressbar progExport color:blue visible:false
	
	
	on btnExport pressed do
	(
		progExport.visible = true
		isExportHide = exportHide.checked
		isExportKeyFrame = exportKeyFrame.checked
		frameSampleRate = spn3.value as integer
		format "isExportHide=% isExportKeyFrame=% frameSampleRate=%\n" \
			isExportHide isExportKeyFrame frameSampleRate 
			
		CrownExport.progExport.value = 0		-- 进度条
		trymain()
		CrownExport.progExport.value = 100
		progExport.visible = false
		
	)
	
	on exportKeyFrame changed theState do
	(
		if theState then
		(
			spn3.enabled = false
			lbl3.enabled = false
			btnTagList.enabled = false
			lbl5.enabled = false
			animList.enabled = false
		)
		else
		(
			spn3.enabled = true
			lbl3.enabled = true
			btnTagList.enabled = true
			lbl5.enabled = true
			animList.enabled = true
		)			
	)
	
	on exportCheckSkin changed theState do
	(
		isSkinCheck = theState		
	)
	
	on exportNoBinary changed theState do
	(
		isBinary = not theState
	)
	
	on exportBla changed theState do
	(
		isExportBla = theState
		if isExportBla then
		(
			isExportBlq = not theState
			exportBlq.checked = isExportBlq 
		)
	)
	
	on exportBlt changed theState do
	(
		isExportBlt = theState
		if isExportBlt then
		(
			isExportBlq = not theState
			exportBlq.checked = isExportBlq 
		)
	)
	
	on exportBlm changed theState do
	(
		isExportBlm = theState
		if isExportBlm then
		(
			isExportBlq = not theState
			exportBlq.checked = isExportBlq 		
		)
	)
	
	on exportBlq changed theState do
	(
		isExportBlq = theState
		if isExportBlq then
		(
			isExportBla = not theState
			exportBla.checked = isExportBla 
			isExportBlm = not theState
			exportBlm.checked = isExportBlm
			isExportBlt = not theState
			exportBlt.checked = isExportBlt
		)

	)
	
	on btnTagList pressed do
	(
		CrownExport.animList.items.count = 0
		
		tagNames = #()
		tagsNum = FrameTagManager.GetTagCount()
		tagsPairNum = tagsNum / 2
		for pi = 1 to tagsPairNum do
		(
			tagId = FrameTagManager.GetTagID (pi*2-1)
			tagId2 = FrameTagManager.GetTagID (pi*2)
			tagName = FrameTagManager.GetNameByID tagId
			tagName = filterSpace tagName
			append tagNames tagName 
		)
		CrownExport.animList.items = tagNames
	)
	
	on animList doubleClicked item do
	(
		temp = CrownExport.animList.items
		deleteItem temp item 
		CrownExport.animList.items = temp
	)
)
-- 创建对话框
if CrownExportFloater != undefined do
(	-- 更新对话框
	closerolloutfloater CrownExportFloater 
)
-- 创建一个RolloutFloater(对话框)
CrownExportFloater = newRolloutFloater "骨骼动画导出" 210 500 (mouse.screenpos[1]-85) (mouse.screenpos[2]-60)
addRollout CrownExport CrownExportFloater 	-- 添加rollout到对话框上


