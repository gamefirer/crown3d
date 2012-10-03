# -*- coding: utf-8 -*-
import os
import string

scene_file_name = 'scene.txt'

def list_scene(scene_dir):
    scene_dir = string.lower(scene_dir)
    print 'list_scene: '+scene_dir
    # 过滤目录
    filter_name = []
    # 创建文件
    scene_fl = open(scene_dir + '/' + scene_file_name, 'w')
    # 写入列表
    file_list = os.listdir(scene_dir)
    for each_file in file_list:
        all_file_name = scene_dir + '/' + each_file
        #print all_file_name
        is_dir = os.path.isdir(all_file_name)
        if is_dir==False:
            continue
        # 检查该目录下是否有map.xml文件
        file_list = os.listdir(all_file_name)
        if ("map.xml" in file_list) == False:
            continue
        #过滤
        if each_file in filter_name:
            continue
        scene_fl.write(each_file+'\n')
        print all_file_name
    # 关闭文件
    scene_fl.close()

    print '\n'