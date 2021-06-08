
# kubernetes 源码学习笔记

## Kubernetes 源码结构与编译构建

## kubernetes 代码生成详解

## kubernetes 核心数据结构


## kubernetes 源码解析
目录
```markdown
### 第1章Kubernetes架构 1 sum(13)
1.1 Kubernetes的发展历史 1
1.2 Kubernetes架构图 2
1.3 Kubernetes各组件的功能 4
    1.3.1 kubectl 5
    1.3.2 client-go 5
    1.3.3 kube-apiserver 5
    1.3.4 kube-controller-manager 6
    1.3.5 kube-scheduler 7
    1.3.6 kubelet 7
    1.3.7 kube-proxy 8
1.4 KubernetesProjectLayout设计 9

 
### 第2章Kubernetes构建过程 13 sum(43)
2.1 构建方式 13
2.2 本地环境构建 15
    2.2.1 一切都始于Makefile 16
    2.2.2 本地构建过程 17
2.3 容器环境构建 18
2.4 Bazel环境构建 22
    2.4.1 使用Bazel构建和测试Kubernetes源码 23
    2.4.2 Bazel的工作原理 25
2.5 代码生成器 26
    2.5.1 Tags 27
    2.5.2 deepcopy-gen代码生成器 29
    2.5.3 defaulter-gen代码生成器 30
    2.5.4 conversion-gen代码生成器 32
    2.5.5 openapi-gen代码生成器 34
    2.5.6 go-bindata代码生成器 36
2.6 代码生成过程 37
2.7 gengo代码生成核心实现 40
    2.7.1 代码生成逻辑与编译器原理 41
    2.7.2 收集Go包信息 42
    2.7.3 代码解析 45
    2.7.4 类型系统 48
    2.7.5 代码生成 5 1

### 第3章Kubernetes核心数据结构 57  sum(44)
3.1 Group、Version、Resource核心数据结构 57
3.2 ResourceList 59
3.3 Group 62
3.4 Version 63
3.5 Resource 65
    3.5.1 资源外部版本与内部版本 66
    3.5.2 资源代码定义 68
    3.5.3 将资源注册到资源注册表中 71
    3.5.4 资源首选版本 71
    3.5.5 资源操作方法 72
    3.5.6 资源与命名空间 75
    3.5.7 自定义资源 77
    3.5.8 资源对象描述文件定义 78
3.6 Kubernetes内置资源全图 79
3.7 runtime.Object类型基石 83
3.8 Unstructured数据 85
3.9 Scheme资源注册表 87
    3.9.1 Scheme资源注册表数据结构 87
    3.9.2 资源注册表注册方法 91
    3.9.3 资源注册表查询方法 92
3.10 Codec编解码器 92
    3.10.1 Codec编解码实例化 94
    3.10.2 jsonSerializer与yamlSerializer序列化器 95
    3.10.3 protobufSerializer序列化器 98
3.11 Converter资源版本转换器 100
    3.11.1 Converter转换器数据结构 101
    3.11.2 Converter注册转换函数 102
    3.11.3 Converter资源版本转换原理 104

### 第4章kubectl命令行交互 111 sum(17)
4.1 kubectl命令行参数详解 111
4.2 Cobra命令行参数解析 114
4.3 创建资源对象的过程 119
    4.3.1 编写资源对象描述文件 120
    4.3.2 实例化Factory接口 120
    4.3.3 Builder构建资源对象 121
    4.3.4 Visitor多层匿名函数嵌套 122

### 第5章client-go编程式交互 128 sum(59)
5.1 client-go源码结构 128
5.2 Client客户端对象 129
    5.2.1 kubeconfig配置管理 130
    5.2.2 RESTClient客户端 134
    5.2.3 ClientSet客户端 137
    5.2.4 DynamicClient客户端 139
    5.2.5 DiscoveryClient客户端 141
5.3 Informer机制 144
    5.3.1 Informer机制架构设计 145
    5.3.2 Reflector 149
    5.3.3 DeltaFIFO 154
    5.3.4 Indexer 158
5.4 WorkQueue 162
    5.4.1 FIFO队列 163
    5.4.2 延迟队列 165
    5.4.3 限速队列 166
5.5 EventBroadcaster事件管理器 170
5.6 代码生成器 176
    5.6.1 client-gen代码生成器 176
    5.6.2 lister-gen代码生成器 180
    5.6.3 informer-gen代码生成器 182
5.7 其他客户端 185

### 第6章Etcd存储核心实现 187 sum(27)
6.1 Etcd存储架构设计 187
6.2 RESTStorage存储服务通用接口 189
6.3 RegistryStore存储服务通用操作 190
6.4 Storage.Interface通用存储接口 192
6.5 CacherStorage缓存层 194
    6.5.1 CacherStorage缓存层设计 195
    6.5.2 ResourceVersion资源版本号 199
    6.5.3 watchCache缓存滑动窗口 201
6.6 UnderlyingStorage底层存储对象 204
6.7 Codec编解码数据 206
6.8 Strategy预处理 209
    6.8.1 创建资源对象时的预处理操作 209
    6.8.2 更新资源对象时的预处理操作 211
    6.8.3 删除资源对象时的预处理操作 212
    6.8.4 导出资源对象时的预处理操作 213

### 第7章kube-apiserver核心实现 214  sum(107)
7.1 热身概念 215
    7.1.1 go-restful核心原理 215
    7.1.2 一次HTTP请求的完整生命周期 218
    7.1.3 OpenAPI/Swagger核心原理 219
    7.1.4 HTTPS核心原理 222
    7.1.5 gRPC核心原理 224
    7.1.6 go-to-protobuf代码生成器 225
7.2 kube-apiserver命令行参数详解 231
7.3 kube-apiserver架构设计详解 243
7.4 kube-apiserver启动流程 244
    7.4.1 资源注册 245
    7.4.2 Cobra命令行参数解析 248
    7.4.3 创建APIServer通用配置 249
    7.4.4 创建APIExtensionsServer 257
    7.4.5 创建KubeAPIServer 261
    7.4.6 创建AggregatorServer 266
    7.4.7 创建GenericAPIServer 269
    7.4.8 启动HTTP服务 270
    7.4.9 启动HTTPS服务 272
7.5 权限控制 272
7.6 认证 273
    7.6.1 BasicAuth认证 276
    7.6.2 ClientCA认证 277
    7.6.3 TokenAuth认证 278
    7.6.4 BootstrapToken认证 279
    7.6.5 RequestHeader认证 281
    7.6.6 WebhookTokenAuth认证 282
    7.6.7 Anonymous认证 284
    7.6.8 OIDC认证 285
    7.6.9 ServiceAccountAuth认证 288
7.7 授权 291
    7.7.1 AlwaysAllow授权 295
    7.7.2 AlwaysDeny授权 296
    7.7.3 ABAC授权 297
    7.7.4 Webhook授权 298
    7.7.5 RBAC授权 300
    7.7.6 Node授权 309

7.8 准入控制器 310
    7.8.1 AlwaysPullImages准入控制器 315
    7.8.2 PodNodeSelector准入控制器 316
7.9 进程信号处理机制 318
    7.9.1 常驻进程实现 318
    7.9.2 进程的优雅关闭 319
    7.9.3 向systemd报告进程状态 320

### 第8章kube-scheduler核心实现 321  sum(40)
8.1 kube-scheduler命令行参数详解 321
8.2 kube-scheduler架构设计详解 324
8.3 kube-scheduler组件的启动流程 326
    8.3.1 内置调度算法的注册 327
    8.3.2 Cobra命令行参数解析 328
    8.3.3 实例化Scheduler对象 329
    8.3.4 运行EventBroadcaster事件管理器 331
    8.3.5 运行HTTP或HTTPS服务 331
    8.3.6 运行Informer同步资源 332
    8.3.7 领导者选举实例化 332
    8.3.8 运行sched.Run调度器 333
8.4 优先级与抢占机制 333
8.5 亲和性调度 335
    8.5.1 NodeAffinity 336
    8.5.2 PodAffinity 337
    8.5.3 PodAntiAffinity 338
8.6 内置调度算法 339
    8.6.1 预选调度算法 339
    8.6.2 优选调度算法 340
8.7 调度器核心实现 342
    8.7.1 调度器运行流程 342
    8.7.2 调度过程 343
    8.7.3 Preempt抢占机制 351
    8.7.4 bind绑定机制 356
8.8 领导者选举机制 357
    8.8.1 资源锁 358
    8.8.2 领导者选举过程 360
```
