
# kubernetes 源码学习笔记

## Kubernetes 源码结构与编译构建

## kubernetes 代码生成详解

## kubernetes 核心数据结构


## kubernetes 源码解析
目录
```markdown
### 第1章Kubernetes架构1
1.1 Kubernetes的发展历史1
1.2 Kubernetes架构图2
1.3 Kubernetes各组件的功能4
    1.3.1 kubectl5
    1.3.2 client-go5
    1.3.3 kube-apiserver5
    1.3.4 kube-controller-manager6
    1.3.5 kube-scheduler7
    1.3.6 kubelet7
    1.3.7 kube-proxy8
1.4 KubernetesProjectLayout设计9

### 第2章Kubernetes构建过程13
2.1 构建方式13
2.2 本地环境构建15
    2.2.1 一切都始于Makefile16
    2.2.2 本地构建过程17
2.3 容器环境构建18
2.4 Bazel环境构建22
    2.4.1 使用Bazel构建和测试Kubernetes源码23
    2.4.2 Bazel的工作原理25
2.5 代码生成器26
    2.5.1 Tags27
    2.5.2 deepcopy-gen代码生成器29
    2.5.3 defaulter-gen代码生成器30
    2.5.4 conversion-gen代码生成器32
    2.5.5 openapi-gen代码生成器34
    2.5.6 go-bindata代码生成器36
2.6 代码生成过程37
2.7 gengo代码生成核心实现40
    2.7.1 代码生成逻辑与编译器原理41
    2.7.2 收集Go包信息42
    2.7.3 代码解析45
    2.7.4 类型系统48
    2.7.5 代码生成51

### 第3章Kubernetes核心数据结构57
3.1 Group、Version、Resource核心数据结构57
3.2 ResourceList59
3.3 Group62
3.4 Version63
3.5 Resource65
    3.5.1 资源外部版本与内部版本66
    3.5.2 资源代码定义68
    3.5.3 将资源注册到资源注册表中71
    3.5.4 资源首选版本71
    3.5.5 资源操作方法72
    3.5.6 资源与命名空间75
    3.5.7 自定义资源77
    3.5.8 资源对象描述文件定义78
3.6 Kubernetes内置资源全图79
3.7 runtime.Object类型基石83
3.8 Unstructured数据85
3.9 Scheme资源注册表87
    3.9.1 Scheme资源注册表数据结构87
    3.9.2 资源注册表注册方法91
    3.9.3 资源注册表查询方法92
3.10 Codec编解码器92
    3.10.1 Codec编解码实例化94
    3.10.2 jsonSerializer与yamlSerializer序列化器95
    3.10.3 protobufSerializer序列化器98
3.11 Converter资源版本转换器100
    3.11.1 Converter转换器数据结构101
    3.11.2 Converter注册转换函数102
    3.11.3 Converter资源版本转换原理104

### 第4章kubectl命令行交互111
4.1 kubectl命令行参数详解111
4.2 Cobra命令行参数解析114
4.3 创建资源对象的过程119
    4.3.1 编写资源对象描述文件120
    4.3.2 实例化Factory接口120
    4.3.3 Builder构建资源对象121
    4.3.4 Visitor多层匿名函数嵌套122

### 第5章client-go编程式交互128
5.1 client-go源码结构128
5.2 Client客户端对象129
    5.2.1 kubeconfig配置管理130
    5.2.2 RESTClient客户端134
    5.2.3 ClientSet客户端137
    5.2.4 DynamicClient客户端139
    5.2.5 DiscoveryClient客户端141
5.3 Informer机制144
    5.3.1 Informer机制架构设计145
    5.3.2 Reflector149
    5.3.3 DeltaFIFO154
    5.3.4 Indexer158
5.4 WorkQueue162
    5.4.1 FIFO队列163
    5.4.2 延迟队列165
    5.4.3 限速队列166
5.5 EventBroadcaster事件管理器170
5.6 代码生成器176
    5.6.1 client-gen代码生成器176
    5.6.2 lister-gen代码生成器180
    5.6.3 informer-gen代码生成器182
5.7 其他客户端185

### 第6章Etcd存储核心实现187
6.1 Etcd存储架构设计187
6.2 RESTStorage存储服务通用接口189
6.3 RegistryStore存储服务通用操作190
6.4 Storage.Interface通用存储接口192
6.5 CacherStorage缓存层194
    6.5.1 CacherStorage缓存层设计195
    6.5.2 ResourceVersion资源版本号199
    6.5.3 watchCache缓存滑动窗口201
6.6 UnderlyingStorage底层存储对象204
6.7 Codec编解码数据206
6.8 Strategy预处理209
    6.8.1 创建资源对象时的预处理操作209
    6.8.2 更新资源对象时的预处理操作211
    6.8.3 删除资源对象时的预处理操作212
    6.8.4 导出资源对象时的预处理操作213

### 第7章kube-apiserver核心实现214
7.1 热身概念215
    7.1.1 go-restful核心原理215
    7.1.2 一次HTTP请求的完整生命周期218
    7.1.3 OpenAPI/Swagger核心原理219
    7.1.4 HTTPS核心原理222
    7.1.5 gRPC核心原理224
    7.1.6 go-to-protobuf代码生成器225
7.2 kube-apiserver命令行参数详解231
7.3 kube-apiserver架构设计详解243
7.4 kube-apiserver启动流程244
    7.4.1 资源注册245
    7.4.2 Cobra命令行参数解析248
    7.4.3 创建APIServer通用配置249
    7.4.4 创建APIExtensionsServer257
    7.4.5 创建KubeAPIServer261
    7.4.6 创建AggregatorServer266
    7.4.7 创建GenericAPIServer269
    7.4.8 启动HTTP服务270
    7.4.9 启动HTTPS服务272
7.5 权限控制272
7.6 认证273
    7.6.1 BasicAuth认证276
    7.6.2 ClientCA认证277
    7.6.3 TokenAuth认证278
    7.6.4 BootstrapToken认证279
    7.6.5 RequestHeader认证281
    7.6.6 WebhookTokenAuth认证282
    7.6.7 Anonymous认证284
    7.6.8 OIDC认证285
    7.6.9 ServiceAccountAuth认证288
7.7 授权291
    7.7.1 AlwaysAllow授权295
    7.7.2 AlwaysDeny授权296
    7.7.3 ABAC授权297
    7.7.4 Webhook授权298
    7.7.5 RBAC授权300
    7.7.6 Node授权309

7.8 准入控制器310
    7.8.1 AlwaysPullImages准入控制器315
    7.8.2 PodNodeSelector准入控制器316
7.9 进程信号处理机制318
    7.9.1 常驻进程实现318
    7.9.2 进程的优雅关闭319
    7.9.3 向systemd报告进程状态320

### 第8章kube-scheduler核心实现321
8.1 kube-scheduler命令行参数详解321
8.2 kube-scheduler架构设计详解324
8.3 kube-scheduler组件的启动流程326
    8.3.1 内置调度算法的注册327
    8.3.2 Cobra命令行参数解析328
    8.3.3 实例化Scheduler对象329
    8.3.4 运行EventBroadcaster事件管理器331
    8.3.5 运行HTTP或HTTPS服务331
    8.3.6 运行Informer同步资源332
    8.3.7 领导者选举实例化332
    8.3.8 运行sched.Run调度器333
8.4 优先级与抢占机制333
8.5 亲和性调度335
    8.5.1 NodeAffinity336
    8.5.2 PodAffinity337
    8.5.3 PodAntiAffinity338
8.6 内置调度算法339
    8.6.1 预选调度算法339
    8.6.2 优选调度算法340
8.7 调度器核心实现342
    8.7.1 调度器运行流程342
    8.7.2 调度过程343
    8.7.3 Preempt抢占机制351
    8.7.4 bind绑定机制356
8.8 领导者选举机制357
    8.8.1 资源锁358
    8.8.2 领导者选举过程360
```

