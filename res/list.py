# -*- coding: utf-8 -*-
# 生成所有资源列表
import os
import string
import py.scene
import py.avatar
import py.filelist


scene_fl = None
avatar_fl = None

def main():
    curdir = os.path.abspath('.')
    print curdir
	
	# 生成场景列表文件
    py.scene.list_scene(curdir+'/scene')
    # 生成avatar列表文件
    py.avatar.list_avatar(curdir+'/character')
    # 生成文件列表
    py.filelist.list_files(curdir)

if __name__ == '__main__':
    main()