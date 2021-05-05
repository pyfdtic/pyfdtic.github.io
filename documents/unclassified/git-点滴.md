---
title: git-点滴
date: 2018-03-16 17:17:26
categories:
- Tools
tags:
- git
- 代码管理
---
### git commit 
`git commit` 命令执行后, git 主要执行了三个操作:

1. 为每一个文件生成一个快照
    
    每一个文件其实是真的数据, 所以 git 会把整个文件内容转成二进制, 然后经过压缩直接存储在键值对数据库中, 对应的键值就是文件中的内容, 再加上一些头信息的 40 位校验 和 sha-1 . 

    文件快照的类型为 blob 类型(binary large object) , 即大型二进制对象类型.

2. 为每一个文件夹生成一个快照
    
    文件夹并不是直接的文字数据, 其主要记录的是文件夹的结构和每个文件或者文件夹对应的快照键值, 所以文件夹的快照内容是其包含的所有文件和文件夹的键值信息总和, 附加一些头信息, 如文件名,文件夹名. 对应快照键值为快照内容的 40位校验和 sha-1 ,

    文件夹快照对应的类型为 tree.

3. 生成一个项目快照
    
    即 生成一个 commit, 项目快照的内容摘要包含四部分信息, 根项目目录的快照/提交人信息/项目快照说明/父项目快照. 其中项目文件快照, 只要根目录的目录快照即可. 

    项目快照 commit 的键值为 项目快照内容的 40位校验和 sha-1. 

    项目快照类型为 commit 类型.


git 中生成的所有 object 都存在 `.git/objects/` 文件夹中, 每一个 object 保存时, 取其 40位检验和 sha-1 的前两位生成文件夹, 后 38 位作为文件名, 存储对应的数据. 

只有变化的文件或文件夹才会形成新的快照, 没有变化的文件不会形成新的快照.

### git branch 
branch 信息记录在 `.git/refs/heads/` 目录下

    $cat .git/refs/heads/master 
    1e3db1046b3f0d07aeb51d9704792e611a1a7a80

branche 仅仅是指向一个 commit 的指针而已, 指向一个 commit, 而一个 comit 同时指向其父 commit, 如此循环形成一个 branch.


### git HEAD 指针

git 有一个独立的 HEAD 指针, 记录项目现在所在的位置.

    $cat .git/HEAD 
    ref: refs/heads/master  # 此时指针指向 master , 表示现在在 master 分支上.

当我们创建新的分支 test 时, git 会在 `.git/refs/heads/` 目录下生成一个文件 test, 并将其指向当前 HEAD 所指向的分支 master 所指向的提交 , 并把 HEAD 指向新的分支 test .

    $cat .git/refs/heads/master 
    1e3db1046b3f0d07aeb51d9704792e611a1a7a80

    $cat .git/refs/heads/test 
    1e3db1046b3f0d07aeb51d9704792e611a1a7a80

当我们在新的分支生成新的 commit 时, git 会将 HEAD 所指向的分支 test 所指向的 commit 作为新 commit 的父 commit, 然后将 HEAD 所指向的分支 test 移动指向新的提交.