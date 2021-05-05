---
title: PyStdLib--shutil
date: 2018-03-19 18:31:56
categories:
- Python
tags:
- python 标准库
---
## shutil

#### shutil.move(src,dst)
    shutil.move('/tmp/20170223/new','/tmp/20170223/test')   # 移动文件, 重命名等

#### shutil.copytree(src, dst, symlinks=False, ignore=None)
    shutil.copytree('/tmp/20170223/','/tmp/20170223-2/')    # 递归复制
    shutil.copytree('folder1', 'folder2', ignore=shutil.ignore_patterns('*.pyc', 'tmp*'))

#### shutil.rmtree(path, ignore_errors=False, onerror=None)
    shutil.rmtree('/tmp/20170223-2/')   # 递归删除目录树

#### shutil.get_archive_formats()
    shutil.get_archive_formats()    # 返回支持的 压缩格式列表, 如 [(name,desc),('tar','uncompressed tar file')],

#### shutil.make_archive(base_name, format, root_dir=None, base_dir=None, verbose=0, dry_run=0, owner=None, group=None, logger=None) 
    shutil.make_archive('/tmp/20170223/new2','zip',root_dir='/tmp/20170223/')   # 创建压缩文件,
    
    base_name : 压缩包的文件名, 也可以使压缩包的路径. 
    format : 压缩种类
    root_dir : 要压缩的文件夹路径, 默认当前目录
    owner : 用户, 默认当前用户
    group : 组, 默然当前组

#### shutil.copy(src, dst)
    shutil.copy('/tmp/20170223/new','/tmp/20170223/new2')   # 复制文件及权限, Copy data and mode bits

#### shutil.copyfileobj(fsrc, fdst, length=16384)
    shutil.copyfileobj(open('old.xml','r'), open('new.xml', 'w'))
    # 将文件内容拷贝到另一个文件, copy data from file-like object fsrc to file-like object fdst

#### shutil.copyfile(src, dst)
    shutil.copyfile('f1.log', 'f2.log')  # 拷贝文件, Copy data from src to dst

#### shutil.copymode(src, dst)
    shutil.copymode('f1.log', 'f2.log')     # 仅拷贝权限,内容,用户,组不变,  Copy mode bits from src to dst

#### shutil.copystat(src, dst) 
    shutil.copystat('f1.log', 'f2.log')     # 仅拷贝状态信息, Copy all stat info (mode bits, atime, mtime, flags) from src to dst

#### shutil.copy2(src, dst) 
    shutil.copy2('f1.log', 'f2.log')    # 拷贝文件和状态信息, Copy data and all stat info