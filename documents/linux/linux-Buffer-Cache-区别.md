
buffer 是磁盘缓存, 缓存的是连续的block
cache 文件缓存, 缓存的是组成文件的非连续的block, 

示例:
某个磁盘中的 block 编号 1 - 10,

buffer 缓存: 依据磁盘的局部性原理, 其缓存的是 从 编号5-10 的block;

cache 缓存: 某个文件存放该磁盘上, 并且占据所有编号为奇数的block.