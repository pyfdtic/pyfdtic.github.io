## 传统分层
MVC

前后端分离

贫血模式: 
- 业务逻辑都在 Logic 层内
- Struct, Class 上没有任何逻辑, 或只有少量逻辑

充血模式: 
- 要让 domain object 即 entity 有更多逻辑
- 通过聚合来组合 entity 的咯及

SOLID 架构

## 整洁架构 Style

核心观点: 
- 不与框架绑定: 业务不应该与某个 web 框架绑定，应该做到想换就换。
    1. 业务代码入口不应于任何协议绑定
    2. 框架代码(如 gin.Context) 不要入侵到业务层.
- 可测试: 业务逻辑应该在没有 UI、database 环境、web server 等所有外部环境的前提下做到可测试。
    mock
- 不与 UI 绑定: 不与具体的 UI 库绑定，项目应该做到随意切换外部 UI，比如可以将 web UI 替换为 console UI，同时无需业务逻辑做修改。
    前后分离
- 不与数据库绑定: 可以把 Oracle 换成  SQL Server，也可以换成Mongo，换成 BigTable，换成 CouchDB。业务不依赖具体存储方式。
    需要借助 DDD 中的 Repo 设计方式: Rep interface --> implementations
- 不依赖任何外部代理: 你的业务应该对外部环境一无所知。比较困难.

https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html

使用 Go 实现 clean architecture: https://eltonminetto.dev/en/post/2020-07-06-clean-architecture-2years-later/
相关代码: https://github.com/eminetto/clean-architecture-go-v2

## DDD style

名词多:
- Value Object(Value Type): 是不可变的(immutable), 可比较的(comparable)值.
- Entity:

    - Entity 的关键是其有 ID 作为**唯一标识**
    - Value type 则没有 ID
    - 有 ID 意味着 entity 是可变(mutable)的，会随着时间更新

- Aggregate
    - Aggregate 和 entity 设计上类似，也有 ID，也是可变(mutable)的
    - 聚合可以用 entity + value object 构成
    - 每一个聚合对应一个 Repo interface
    - 聚合需要对聚合内的数据一致性负责，可以认为聚合是数据一致性的边界
    - 聚合之外的一致性采用最终一致性保证RepoAggregate

    1. 一个聚合可以只有一个 entity
    2. 也可以有多个 entity 和 value object

- Aggregate Root

    - 聚合根也是聚合
    - 与普通聚合**唯一差别** : 聚合根对外暴露，要关联某个领域内的对象，一定是通过聚合根的 id 来进行关联的。
    - 在聚合内的一些 entity 一般不对外暴露，但随着时间的推移也可能变成聚合根。

- Repository: 业务代码不会和任意数据库实现绑定

六边形架构(ports && adapters): 也被称为端口与适配器架构, 所有外部类型都有适配器与之对应外部通过 API 与内部交互`《实现领域驱动设计-ch4》`
```
Ports = interface
Adapters = instances
```


## 插件化架构


## 其他

1. 依赖注入工具

    main 模块是上帝模块，需要负责初始化所有内部类

    - 如果初始化关系很复杂 --> 可以使用 [wire](https://github.com/google/wire) 来简化初始化过程.
    - 如果测试阶段也需要写这么多初始化代码呢？

## 参考

- https://shimo.im/docs/c999gcd8jRrkTcYt/



