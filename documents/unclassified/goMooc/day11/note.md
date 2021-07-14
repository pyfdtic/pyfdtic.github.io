# 设计互联网高并发数据中台

## 中台到底是个啥

supercell

互联网公司成长过程:
CRUD --> 平台化 --> 中台化(多个事业部的大公司)

分类:
1. 业务中台
2. 数据中台
3. 移动中台
4. 技术中台

数据中台发展路径:


Go 在数据中台中的应用:
- beats: 数据采集
- go-mysql: 解析 binlog
- log-agent: 收集日志
- apache beam: 好像比较拉胯 --> 书 streaming system


## CRUD 如何进步
- 自动化
- 配置化
- 平台化


## 参考

- https://shimo.im/docs/wyKKc6wVRjdQvHhT/
- [Apache Beam 架构原理及应用实践](https://www.infoq.cn/article/aly182jgm6mtitg7nl0r)
- greenplum
- 推书:
    1. 数据中台
    2. 企业 IT 架构转型之道
    3. streaming system
- http://research.google/pubs/?area=distributed-systems-and-parallel-computing