# 社区优秀开源框架对比

## 常见 Web 框架

最简单的框架, 只需三个组件:
- `Router`
- `Middleware`
- `Context`

框架: 
- httprouter: 
    - 几乎是所有 GO web 框架的 router 实现的 爸爸. 一个简单的 radix tree 的实现.
    - 一个简单的 radix tree 的实现
- go-chi: 简单, 适合看代码
- gin: router, middleware, binding, logger.
    - Route 支持分组
    - Middleware
    - binding, 将 decoder 和  validator 合二为一.
    - Logger, 功能比较弱
    - Context
- Beego
    - Router 支持分组
    - Filter, 即 middleware
    - Context
    - Task, 定时任务
    - orm, httpclient, cache, validator, config, swagger, template 等.

## 微服务框架

相比 web 框架, 微服务框架组件更多:
- `Config`: 配置管理组件
- `Registry`: 服务发现组件, 必须.
- `Logger`: 遵守第三方日志收集规范的日志组件: 格式统一 + 性能.
- `Metrics`: 使框架能够与 Prometheus 等监控系统集成的 metrics 组件.
- `Tracing`: 遵守 OpenTelemetry 的 tracing 组件
- `MQ`: 可切换不同队列实现的 mq 组件.
- `依赖注入`: wire, dig 等组件

常见框架:
- [go-micro](https://github.com/asim/go-micro)

    框架设计的很好: 
    
    主要组件:

    接口:

- [go-zero](https://github.com/tal-tech/go-zero)
- [yoyogo](https://github.com/yoyofx/yoyogo)
- [dubbo go](https://github.com/apache/dubbo-go)
- [kratos](https://github.com/go-kratos/kratos.git)


## 如何评判框架优劣

总结:
- 企业场景: 大而全即好
- 开源场景: 给用户选择选即好

框架设计需要考虑的问题:
- 自动化
    - Layout 代码自动生产(DDD/Clean Arch)
    - 服务上线自动发布
    - 自动生成接口文档
    - 服务接入 SDK 自动生成
    - 常见 code snippet (boilerplate) 内置在 CLI 工具内.
    - 不要让用户去复制粘贴, 我们来帮他自动写好
- 平台化
    - IDL 在平台管理
    - 接口文档可检索
    - 服务 上线/部署 流水线化
- 集成化
    - 框架提供所需基础设施 SDK(log/tracing/config center/orm sql builder/es/clickhouse/mq etc...)
    - 开箱即用, 核心依赖无需外部站点寻找
    - 专门的 organization 下维护其他非核心依赖
    - 解决用户的选择困难症
- 组件化
    - 稳定性需求, 沉淀为统一组件
    - 故障经验沉淀为 避免/解决 问题的组件: 可以是重试组件中的规则, 也可以是静态扫描工具中的一个 linter.
    - 不要让每个人都必须读一遍 Google SRE 书才能做好稳定性.
- 插件化
    - 面向接口编程
    - 组件以 plugin 形式提供
- 通用化
    - 主要针对开源框架
    - Leave options open by Uncle Bob
    - 让用户有选择权, 可以通过插件化来达成
    - go-micro 是一个很好的返利.
    - 对于企业内部框架来说, 通用并**不是**一定要追求的目标.

## 如何看待社区观点
- IDL 之间可以用技术手段互相转换
- 要做平台化, 可以适当屏蔽 IDL 语言, 可以参考 openapi
- 业务代码入口不应于任何协议绑定

## 参考
- https://shimo.im/docs/yTQHRjHkW83qDqtQ
