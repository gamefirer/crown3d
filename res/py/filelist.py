# -*- coding: utf-8 -*-
import os
import string

index_file_name = 'filelist.txt'

filer_dir = ['py']
filer_file = ['filelist.txt', 'list.py']

fl = None
recur_dir = ''

# 生成文件列表
def list_files(current_dir):
    current_dir = string.lower(current_dir)
    print 'list_files: '+current_dir

    fl = open(current_dir + '/' + index_file_name, 'w')

    recur_files(current_dir, '', fl)

    fl.close()

    print '\n'

def recur_files(current_dir, write_dir, fl):
    file_list = os.listdir(current_dir)

    file_record = []
    dir_record = []
    for each_file in file_list:
        all_file_name = current_dir + '/' + each_file

        is_exist = os.path.exists(all_file_name)
        if is_exist == False:
            print "error + "+all_file_name
            raise

        all_file_name = string.lower(all_file_name)
        each_file = string.lower(each_file)

        is_dir = os.path.isdir(all_file_name)
        if is_dir:
            if (each_file not in filer_dir):
                dir_record.append(each_file)
        else:
            if (each_file not in filer_file):
                file_record.append(each_file)
    
    # 写文件列表
    for each_file in file_record:
        if each_file.find(index_file_name) == -1:
            each_file = write_dir + each_file
            fl.write(each_file+'\n')
            print each_file

    # 递归目录
    for each_dir in dir_record:
        #print each_dir + ' '+write_dir+each_dir
        recur_files(current_dir+'/'+each_dir, write_dir+each_dir+'/', fl)