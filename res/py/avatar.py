# -*- coding: utf-8 -*-
import os
import string

avatar_file_name = 'avatar.txt'



# 生成avatar列表
def list_avatar(avatar_dir):
    avatar_dir = string.lower(avatar_dir)
    print 'list_avatar: '+avatar_dir
    # 创建文件
    avatar_fl = open(avatar_dir + '/' + avatar_file_name, 'w')
    # 写列表
    filter_name = []
    file_list = os.listdir(avatar_dir)
    for each_file in file_list:
        all_file_name = avatar_dir + '/' + each_file
        #print all_file_name
        is_dir = os.path.isdir(all_file_name)
        if is_dir==False:
            continue
        if each_file in filter_name:
            continue
        avatar_fl.write(each_file+'\n')
        print all_file_name
		# 创建avatar目录的描述文件
        create_describe(all_file_name)
		
    # 关闭文件
    avatar_fl.close()

    print '\n'

def create_describe(character_dir):
    # 创建模型描述文件
    print "create mesh.txt"
    mesh_fl = open(character_dir + '/' + 'mesh.txt', 'w')
    file_list = os.listdir(character_dir)
    for each_file in file_list:
        #print each_file
        file_name = os.path.splitext(each_file)[0][0:]
        ext_name = os.path.splitext(each_file)[1][0:]
        #print file_name + ' ' + ext_name
        if ext_name == '.blm':
            mesh_fl.write(file_name+'\n')
    mesh_fl.close()
    
	# 创建动画描述文件
    print "create animation.txt"
    animation_fl = open(character_dir + '/' + 'animation.txt', 'w')
    file_list = os.listdir(character_dir)
    for each_file in file_list:
        #print each_file
        file_name = os.path.splitext(each_file)[0][0:]
        ext_name = os.path.splitext(each_file)[1][0:]
        #print file_name + ' ' + ext_name
        if ext_name == '.blq':
            animation_fl.write(file_name+'\n')
    animation_fl.close()
	
    # 创建贴图描述文件
    print "create texture.txt"
    texture_fl = open(character_dir + '/' + 'texture.txt', 'w')
    file_list = os.listdir(character_dir)
    texture_fl.close()
