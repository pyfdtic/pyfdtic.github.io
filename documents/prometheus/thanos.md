---
title: Thanos 学习笔记 
date: 2019-03-14 17:38:24
categories:
- Monitor 
tags:
- thanos
- prometheus
---

<!-- MarkdownTOC -->

- [参考文档](#%E5%8F%82%E8%80%83%E6%96%87%E6%A1%A3)
- [概述](#%E6%A6%82%E8%BF%B0)
- [组件](#%E7%BB%84%E4%BB%B6)
    - [1. Sidecar: connects to Prometheus and reads its data for query and/or upload it to cloud storage.](#1-sidecar-connects-to-prometheus-and-reads-its-data-for-query-andor-upload-it-to-cloud-storage)
        - [1.0 配置 Thanos 重载 Prometheus 配置](#10-%E9%85%8D%E7%BD%AE-thanos-%E9%87%8D%E8%BD%BD-prometheus-%E9%85%8D%E7%BD%AE)
        - [1.1 使用外部存储:](#11-%E4%BD%BF%E7%94%A8%E5%A4%96%E9%83%A8%E5%AD%98%E5%82%A8)
            - [1.1.1 Thanos 目前支持外部存储类型](#111-thanos-%E7%9B%AE%E5%89%8D%E6%94%AF%E6%8C%81%E5%A4%96%E9%83%A8%E5%AD%98%E5%82%A8%E7%B1%BB%E5%9E%8B)
        - [1.2 存储接口](#12-%E5%AD%98%E5%82%A8%E6%8E%A5%E5%8F%A3)
        - [1.3 Prometheus 扩展标签 及 全局唯一标志](#13-prometheus-%E6%89%A9%E5%B1%95%E6%A0%87%E7%AD%BE-%E5%8F%8A-%E5%85%A8%E5%B1%80%E5%94%AF%E4%B8%80%E6%A0%87%E5%BF%97)
    - [2. Store Gateway: exposes the content of a cloud storage bucket.](#2-store-gateway-exposes-the-content-of-a-cloud-storage-bucket)
    - [3. Compactor: compact and downsample data stored in remote storage](#3-compactor-compact-and-downsample-data-stored-in-remote-storage)
    - [4. Receiver: receives data from Prometheus's remote-write WAL, exposes it and/or upload it to cloud storage.](#4-receiver-receives-data-from-prometheuss-remote-write-wal-exposes-it-andor-upload-it-to-cloud-storage)
    - [5. Ruler: evaluates recording and alerting rules against data in Thanos for exposition and/or uploads.](#5-ruler-evaluates-recording-and-alerting-rules-against-data-in-thanos-for-exposition-andor-uploads)
        - [5.1 风险](#51-%E9%A3%8E%E9%99%A9)
        - [5.2 Partial Response](#52-partial-response)
        - [5.3 必不可少的 Ruler alert rule](#53-%E5%BF%85%E4%B8%8D%E5%8F%AF%E5%B0%91%E7%9A%84-ruler-alert-rule)
        - [5.4 扩展 label](#54-%E6%89%A9%E5%B1%95-label)
        - [5.5 Ruler UI](#55-ruler-ui)
        - [5.6 Ruler HA](#56-ruler-ha)
    - [6. Query Gateway: implements Prometheus’s v1 API to aggregate data from the underlying components](#6-query-gateway-implements-prometheus%E2%80%99s-v1-api-to-aggregate-data-from-the-underlying-components)
        - [6.1 数据去重](#61-%E6%95%B0%E6%8D%AE%E5%8E%BB%E9%87%8D)
        - [6.2 组件间通信](#62-%E7%BB%84%E4%BB%B6%E9%97%B4%E9%80%9A%E4%BF%A1)
        - [6.3 配置 query 与 sidecar/store 通信的方式, 自动发现](#63-%E9%85%8D%E7%BD%AE-query-%E4%B8%8E-sidecarstore-%E9%80%9A%E4%BF%A1%E7%9A%84%E6%96%B9%E5%BC%8F-%E8%87%AA%E5%8A%A8%E5%8F%91%E7%8E%B0)
- [部署](#%E9%83%A8%E7%BD%B2)
    - [1. prometheus](#1-prometheus)
        - [prometheus.service](#prometheusservice)
        - [alertmanager.service](#alertmanagerservice)
        - [prom-node-exporter.service](#prom-node-exporterservice)
        - [prometheus Doc](#prometheus-doc)
    - [2. thanos](#2-thanos)
        - [thanos-query.service](#thanos-queryservice)
        - [thanos-sidecar.service](#thanos-sidecarservice)
        - [thanos-store.service](#thanos-storeservice)
        - [thanos-ruler.service](#thanos-rulerservice)
        - [thanos-compactor.service](#thanos-compactorservice)
- [对象存储](#%E5%AF%B9%E8%B1%A1%E5%AD%98%E5%82%A8)
    - [S3](#s3)
- [服务发现](#%E6%9C%8D%E5%8A%A1%E5%8F%91%E7%8E%B0)
    - [Thanos 中需要服务发现的位置](#thanos-%E4%B8%AD%E9%9C%80%E8%A6%81%E6%9C%8D%E5%8A%A1%E5%8F%91%E7%8E%B0%E7%9A%84%E4%BD%8D%E7%BD%AE)
    - [Thanos 配置方式](#thanos-%E9%85%8D%E7%BD%AE%E6%96%B9%E5%BC%8F)
        - [1. flag](#1-flag)
        - [2. 基于文件的服务发现](#2-%E5%9F%BA%E4%BA%8E%E6%96%87%E4%BB%B6%E7%9A%84%E6%9C%8D%E5%8A%A1%E5%8F%91%E7%8E%B0)
            - [2.1 Query](#21-query)
            - [2.2 Rule](#22-rule)
        - [3. 基于 DNS 的服务发现](#3-%E5%9F%BA%E4%BA%8E-dns-%E7%9A%84%E6%9C%8D%E5%8A%A1%E5%8F%91%E7%8E%B0)
- [Prometheus](#prometheus)
    - [数据存储格式](#%E6%95%B0%E6%8D%AE%E5%AD%98%E5%82%A8%E6%A0%BC%E5%BC%8F)
    - [store](#store)
    - [Query Layer](#query-layer)
    - [Compactor](#compactor)
    - [Scaling](#scaling)
- [其他组件](#%E5%85%B6%E4%BB%96%E7%BB%84%E4%BB%B6)
    - [命令行工具](#%E5%91%BD%E4%BB%A4%E8%A1%8C%E5%B7%A5%E5%85%B7)
        - [1. bucket](#1-bucket)
        - [2. check](#2-check)
    - [compact](#compact)
    - [query](#query)
        - [1. partial response behaviour](#1-partial-response-behaviour)
            - [1.2 Partial Response Strategy](#12-partial-response-strategy)
        - [2. Deduplication Enable](#2-deduplication-enable)
        - [3. Auto downsampling](#3-auto-downsampling)
        - [4. custom reponse fields 自定义响应字段](#4-custom-reponse-fields-%E8%87%AA%E5%AE%9A%E4%B9%89%E5%93%8D%E5%BA%94%E5%AD%97%E6%AE%B5)
        - [5. 使用自定义 Path 暴露 Thanos UI](#5-%E4%BD%BF%E7%94%A8%E8%87%AA%E5%AE%9A%E4%B9%89-path-%E6%9A%B4%E9%9C%B2-thanos-ui)
    - [rule](#rule)
    - [sidecar](#sidecar)
    - [store](#store-1)
- [压力测试](#%E5%8E%8B%E5%8A%9B%E6%B5%8B%E8%AF%95)
- [Other](#other)
- [statsd-exporter](#statsd-exporter)
    - [协议](#%E5%8D%8F%E8%AE%AE)
    - [statsd 指标类型](#statsd-%E6%8C%87%E6%A0%87%E7%B1%BB%E5%9E%8B)
        - [counter 计数器](#counter-%E8%AE%A1%E6%95%B0%E5%99%A8)
        - [timer 计时器](#timer-%E8%AE%A1%E6%97%B6%E5%99%A8)
        - [gauge 标量](#gauge-%E6%A0%87%E9%87%8F)
        - [set](#set)
    - [statsite](#statsite)
    - [install](#install)
    - [Python StatD Client](#python-statd-client)
        - [Timers](#timers)
        - [Cunters](#cunters)
        - [Gauge](#gauge)
        - [Raw](#raw)
        - [Average](#average)
        - [Connection settings](#connection-settings)
        - [Advanced Usage](#advanced-usage)
        - [udpcopy](#udpcopy)
- [PromQL](#promql)
- [alertmanager](#alertmanager)
    - [配置](#%E9%85%8D%E7%BD%AE)
        - [配置段](#%E9%85%8D%E7%BD%AE%E6%AE%B5)
    - [核心特性](#%E6%A0%B8%E5%BF%83%E7%89%B9%E6%80%A7)
        - [1. Groupinbg](#1-groupinbg)
        - [2. Inhibition\(抑制\)](#2-inhibition%E6%8A%91%E5%88%B6)
        - [3. Silences\(静默\)](#3-silences%E9%9D%99%E9%BB%98)
        - [4. client behavior](#4-client-behavior)
        - [5. HA](#5-ha)

<!-- /MarkdownTOC -->

## 参考文档

```
http://dockone.io/article/6019
https://thanos.io/getting-started.md/
```
## 概述

![Thanos 组件架构图](http://wx3.sinaimg.cn/large/77fd5d57gy1g4fl0a15n5j20qo0k0dhb.jpg)

[Thanos Grafana Dashboard: 需要 kubernetes](https://github.com/improbable-eng/thanos/blob/7b72b18dea9747cf48fc41c2360ea221a29de6d0/examples/grafana/monitoring.md)

Thanos 可以实现 global query view, Prometheus 的 HA 以及 持久存储能力. Prometheus 的 metric data model 及 2.0 存储格式(spec, slides) 是 Thanos 组件的基础.

Thanos 部署方式支持云原生的部署, 也支持传统的部署方式.

Prometheus [metric data model](https://github.com/prometheus/tsdb/tree/master/docs/format) 和 [2.0 storage format](https://www.slideshare.net/FabianReinartz/storing-16-bytes-at-scale-81282712) 是 Thanos 组件的基础.

Thanos 组件职责分工明确, 方便解耦, 同时, 支持只部署部分组件实现快速实验. 其组件大致可以分为以下三类:

1. Metric Sources: 生产或者收集 metric data.
    - sidecar: 在 Prometheus's 的 HTTP 和 remote-read APIs 基础上, 实现了一个 gRPC 服务.
    - rule nodes: 基于 Prometheus 的存储引擎实现了 gRPC 服务.
2. Stores
3. Queriers

必要条件:
1. Prometheus v2.2.1 + 版本
  
  可以在 Thanos 的 `Makefile` 的 `PROM_VERSION` 变量中查找 Thanos 测试的基准版本.

2. go 1.10+
3. 对象存储(可选)

组件下载地址:
[github release](https://github.com/improbable-eng/thanos/releases)

## 组件
### 1. Sidecar: connects to Prometheus and reads its data for query and/or upload it to cloud storage.

Sidecar 实现在 Prometheus' remote-read API 的基础上实现了 Thanos's StoreAPI .

sidecar 与 Prometheus 位于同一个 server 上或者同一个 Pod 中.

功能: 链接本地 Prometheus, 为查询读取数据/上传数据到 云存储.

1. 备份 Prometheus 数据到远端云存储
2. 给其他组件通过 gRPC API 访问本地 Prometheus 提供准入.
3. Sidecat 使用 Prometheus 的 `reload` 机制, 需要确保 Prometheus 开启了 `--web.enable-lifecycle` 配置.


#### 1.0 配置 Thanos 重载 Prometheus 配置
Thanos 可以监控 Prometheus 的 rules 和 配置, 更新和查询环境变量, 并把变量指定给 Prometheus 并使 Prometheus 重载这些变量.

1. 需要 Prometheus 配置
    ```
    --web.enable-lifecycle
    ```

2. 配置 thanos sidecar
    
    `--reloader.rule-dir=DIR_NAME` 配置 Sidecar 监视某个 Rule 文件夹下的文件的变化.
    `--reloader.config-file=CONFIG_FILE` 配置 Sidecar 监视 `CONFIG_FILE` 计算环境变量, 并把发现的环境变量用于生成 `--reloader.config-envsubst-file=OUT_CONFIG_FIL` 配置的配置文件.


#### 1.1 使用外部存储:       
```
# 配置 sidecar 读取 prometheus 收集的数据, 并写入到远程的 对象存储中.
$ thanos sidecar \
    --tsdb.path            /var/prometheus \          # TSDB data directory of Prometheus
    --prometheus.url       "http://localhost:9090" \  # Be sure that the sidecar can use this url!
    --objstore.config-file bucket_config.yaml \       # Storage configuration for uploading data

```

以上配置对正在运行的 Prometheus 影响很小, 但最好确保数据是备份的. 

如果**不希望备份**任何数据, `--objstore.config-file` 可以忽略.

##### 1.1.1 Thanos 目前支持外部存储类型

|Provider | Maturity | Auto-tested on CI | Maintainers |
| -- | -- | -- | -- |
| Google Cloud Storage | Stable (production usage) |yes | @bwplotka |
| AWS S3 | Stable (production usage) |yes | @bwplotka |
| Azure Storage Account | Stable (production usage) |yes | @vglafirov |
| OpenStack Swift | Beta (working PoCs, testing usage)  |no  | @sudhi-vm |
| Tencent COS | Beta (testing usage)  |no  | @jojohappy |

#### 1.2 存储接口
`Sidecar` 实现并暴露了一个 gRPC 的 存储 API, 可以基于此 API 查询 prometheus 中存储的 metric 数据.

```
thanos sidecar \
    --tsdb.path                 /var/prometheus \
    --objstore.config-file      bucket_config.yaml \       # Bucket config file to send data to
    --prometheus.url            http://localhost:9090 \    # Location of the Prometheus HTTP server
    --http-address              0.0.0.0:19191 \            # HTTP endpoint for collecting metrics on the Sidecar
    --grpc-address              0.0.0.0:19090              # GRPC endpoint for StoreAPI
```

#### 1.3 Prometheus 扩展标签 及 全局唯一标志

Prometheus 允许配置一个给定实例的 `external labels`, 用于全局的定义该实例的角色标志. 由于 Thanos 的目标就是 跨 Prometheus 节点实现监控数据的聚合, 给 prometheus 实例提供一个全局唯一的标识十分重要.

```
global:
  external_labels:
    region: eu-west
    monitor: infrastructure
    replica: A
```

### 2. Store Gateway: exposes the content of a cloud storage bucket.

提供 云存储的 访问权限控制.

暴露 云存储接口, 查询所有历史数据. StoreGateway 实现了与 Sidecar 相同的 gRPC 数据 API, 只是, 其后端使用存储在云存储中的数据.

StoreGateway 暴露 StoreAPI, 并且需要被 QueryGateway 发现.

```
thanos store \
    --data-dir             /var/thanos/store \   # Disk space for local caches
    --objstore.config-file bucket_config.yaml \  # Bucket to fetch data from
    --http-address         0.0.0.0:19191 \       # HTTP endpoint for collecting metrics on the Store Gateway
    --grpc-address         0.0.0.0:19090         # GRPC endpoint for StoreAPI
```

StoreGateway 需要占用一部分本地存储空间, 几个 Gb 即可, 主要用来缓存对象存储中监控数据的元信息, 以提高 **启动时间**. 这些数据很有用, 但是, 并不一定要持久化. 基本上, 大概一个 block 配置 1MB 大小的本地空间即可.

StoreGateway 每次在启动时, 会从 对象存储中拉取对象存储中历史数据的元信息, 并保存在本地, 在没有缓存所有历史数据元信息之前, 不会向外提供服务.

`objstore.config-file` aws s3 example:
```
type: S3
config:
  bucket: ""
  endpoint: ""
  region: ""
  access_key: ""
  secret_key: ""
  insecure: false
  signature_version2: false
  encrypt_sse: false
  put_user_metadata: {}
  http_config:
    idle_conn_timeout: 0s
    response_header_timeout: 0s
    insecure_skip_verify: false
  trace:
    enable: false
```

### 3. Compactor: compact and downsample data stored in remote storage

压缩远程存储中数据的数据/降低远程存储中数据的精度 

Prometheus 会在本地定期的压缩历史数据, 以提高查询效率. Compactor 实现了类似的功能.

Compactor 组件定期扫描 云存储, 并 在需要时处理数据压缩. 以此同时, 也用来创建 **低精度的历史数据**, 来提高查询效率.

```
thanos compact \
    --data-dir             /var/thanos/compact \  # Temporary workspace for data processing
    --objstore.config-file bucket_config.yaml \   # Bucket where to apply the compacting
    --http-address         0.0.0.0:19191          # HTTP endpoint for collecting metrics on the Compactor
```

Compactor 可以作为**定期任务**执行, 也可以作为 Daemon 程序运行, 无论哪种方式, 都需要提供 `100-300 GB`的本地存储空间 作为临时处理数据之用.

**注意**: 
1. Compactor 必须作为 **单例** 运行;
2. Compactor 运行时, 必须**禁止手动修改** 云存储中的数据.

### 4. Receiver: receives data from Prometheus's remote-write WAL, exposes it and/or upload it to cloud storage.
通过 Prometheus 的 remote-write WAL 接受数据 并 向外暴露数据 或者 上传数据到云存储.

### 5. Ruler: evaluates recording and alerting rules against data in Thanos for exposition and/or uploads.
基于 Thanos Query 提供的数据, 评估记录和报警规则.

In case of Prometheus with Thanos sidecar does not have enough retention, or if you want to have alerts or recording rules that requires global view, Thanos has just the component for that: the Ruler, which does rule and alert evaluation on top of a given Thanos Querier.

The rule component evaluates(评估) Prometheus recording and alerting rules against(紧靠, 依赖) chosen query API via repeated `--query` (or FileSD via `--query.sd`). If more than one query is passed, round robin balancing is performed.

Rule results are written back to disk in the Prometheus 2.0 storage format. Rule nodes at the same time participate(参与) in the system as source store nodes, which means that they expose StoreAPI and upload their generated TSDB blocks to an object store.

The data of each Rule node can be labeled to satisfy(使满足) the clusters labeling scheme. High-availability pairs can be run in parallel(并行的) and should be distinguished(区别, 区分) by the designated(指定的) replica label, just like regular Prometheus servers.

```bash
$ thanos rule \
    --data-dir             "/path/to/data" \
    --eval-interval        "30s" \
    --rule-file            "/path/to/rules/*.rules.yaml" \
    --alert.query-url      "http://0.0.0.0:9090" \ # This tells what query URL to link to in UI.
    --alertmanagers.url    "alert.thanos.io" \
    --query                "query.example.org" \
    --query                "query2.example.org" \
    --objstore.config-file "bucket.yml" \
    --label                'monitor_cluster="cluster1"'
    --label                'replica="A"
```

#### 5.1 风险

Ruler 有一些概念上的权衡, 可能不适用于所有的大多数的场景. 主要的权衡是, Ruler 依赖于 Query 的可用性. 这个缺点对 Prometheus 并不存在, 因为, Prometheus 主要用本地的数据来做 alert / record 估算.

对于 Ruler 来说, 其读取数据的路径是分布式的, Ruler 查询 QueryAPI, 而 QueryAPI 的数据来源于远端的 StoreAPI. 这意味着 查询失败 的情况, 大概率会发生. 因此, 明确的报警策略和查询失败时的报警策略, 就显得尤为重要.

#### 5.2 Partial Response

Rule 允许给特定 rule group, 指定 额外的字段来控制 `PartialResponseStrategy`, 推荐将 `partial_response_strategy` 配置为 `abort`, 这也是默认值.

```yaml
groups:
- name: "warn strategy"
  partial_response_strategy: "warn"
  rules:
  - alert: "some"
    expr: "up"
- name: "abort strategy"
  partial_response_strategy: "abort"
  rules:
  - alert: "some"
    expr: "up"
- name: "by default strategy is abort"
  rules:
  - alert: "some"
    expr: "up"
```

Essentially(本质上), for alerting, having partial response can result in symptoms(征兆, 症状) being missed by Rule's alert.


#### 5.3 必不可少的 Ruler alert rule

通过从其他 Scraper(Prometheus + sidecar) 监控 Ruler 和 alert , 确保 Thanos 报警功能的正常, 是极其重要的. 以下几个 metrics 推荐做响应的监控和报警, 这些报警对于普通的 Prometheus 集群也相当重要, 但是在分布式的环境中尤为重要:

- `thanos_alert_sender_alerts_dropped_total`: 如果 > 0, 表示 Ruler alert 有一部分并没有触发报警信息, 这可能预示着 可连接性/兼容性方面存在问题, 或者 配置错误.

- `prometheus_rule_evaluation_failures_total`. 如果 > 0, rule 计算失败. 这可能是由于 rule 本身的漏洞, 或者潜在的忽略报警. `strategy` label will tell you if failures comes from rules that tolerate [partial response](rule.md#partial-response) or not.

- `prometheus_rule_group_last_duration_seconds < prometheus_rule_group_interval_seconds`: 如果差距较大, 则表示 rule 每次的计算时间大于当前的定时 rule 计算时间. 有可能是 Query 端计算过慢所致, 也有可能是 StoreAPI 太慢, 或者 表达式太过复杂.

- `thanos_rule_evaluation_with_warnings_total`: 如果 Ruler 和 Alert 设置 `partial response strategy` 为 `warn`, 该 metrics 用于表示有多少次 表达式计算返回 warning. 可以反应出, 有多少 partial response, 和当前 metrics 的值可能是不精确的.


#### 5.4 扩展 label
强制要求 Ruler 实例添加 扩展标签 来表示数据来源 (e.g. `label='replica="A"'` or for `cluster`). 否则, 多实例运行的 Ruler 将无法启动, 因为 压缩数据是会存在冲突.

推荐 给 Ruler 实例 以 **不同于** 其数据来源的实例(如 Store, Sidecar, Prometheus 等)的 扩展标签, 因为, 扩展标签将会替换 数据原有的 标签.

For example:

- Ruler is in cluster `mon1` and we have Prometheus in cluster `eu1`
- By default we could try having consistent(一致的) labels so we have `cluster=eu1` for Prometheus and `cluster=mon1` for Ruler.
- We configure `ScraperIsDown` alert that monitors service from `work1` cluster.
- When triggered this alert results in `ScraperIsDown{cluster=mon1}` since external labels always *replace* source labels.


#### 5.5 Ruler UI
Ruler 可以通过 HTTP 暴露出一个 UI 界面, 显示当前的 rule 和 alert, 类似 Prometheus 的 Alerts page.

#### 5.6 Ruler HA
Ruler 使用外部的资源, 通过网络来获取资源计算, 在性能上会有损耗. 如果需要, 可以使用多个 ruler 分担不同的查询/告警计算任务.

多个 Ruler 之间可以使用 replica lable 实现去重.

在 Ruler HA 配置中, 需要确保每个 Ruler 实例有如下配置:
- 区别其他 Ruler HA 的 group 标签 和 replica 标签, e.g: 
`cluster="eu1", replica="A"` and `cluster=eu1, replica="B"` by using `--label` flag.
- 配置`--alert-label-drop="replica"`, 以实现在将 trigger 发送给 Alertmanager 时的去重.

其他计划添加的 relabelling 可以参考如下链接: `https://github.com/improbable-eng/thanos/issues/660`

### 6. Query Gateway: implements Prometheus’s v1 API to aggregate data from the underlying components

实现了 Prometheus’ v1 API 来从其他组件聚合数据, 使用 Thanos 全局查询层 来基于全部的 Prometheus 实例 使用 PromQL 查询监控数据.

Query Gateway 是**无状态**的, 可以**水平扩展**, 可以部署任意多个副本.

Query Gateway 一旦与 Sidecar 建立连接, 他会依据给定的 PromQL 查询语句自动探测需要连接的 Prometheus 实例.

Query Gateway 同样实现了 Prometheus 官方的 HTTP 接口, 因此, 可以被外部的第三方工具集成, 如 Grafana. 同时, 该 HTTP API 为 Prometheus UI 提供 实时的查询和 云存储的状态.

```
thanos query \
    --http-address 0.0.0.0:19192 \                                # HTTP Endpoint for Query UI
    --store        1.2.3.4:19090 \                                # Static gRPC Store API Address for the query node to query
    --store        1.2.3.5:19090 \                                # Also repeatable
    --store        dnssrv+_grpc._tcp.thanos-store.monitoring.svc  # Supports DNS A & SRV records
```

#### 6.1 数据去重

Query Gateway 可以实现将 Prometheus HA 集群中的数据, 实现去重的功能, 该功能需要 每个 Prometheus 实例配置 `global.external_labels` 参数, 来唯一的区别每个 Prometheus 实例.

一个常用的做法是配置 `replica` 参数, 例如下面的配置. 在 Kubernetes 集群中, 使用 stateful deployment 部署时, `replica` 标签可以为 Pod 的名称.

```
global:
  external_labels:
    region: eu-west
    monitor: infrastructure
    replica: A
```
在重启 Prometheus 实例之后, 在 Query Gateway 中, 我们可以指定 `replica` 标签作为去重的标志:

```
thanos query \
    --http-address        0.0.0.0:19192 \
    --store               1.2.3.4:19090 \
    --store               1.2.3.5:19090 \
    --query.replica-label replica  # Replica label for de-duplication
```

#### 6.2 组件间通信

Query Gateway 需要能够连上 StoreApi 的 gRPC API. Query Gateway 会定时调用这些接口, 来收集最新的元数据(这些元信息包含每个节点的**时间窗口信息**和 `external label` 信息), 同时, 检查 StoreApi 的健康状态.

Query Gateway 链接 StoreApi 的配置有多中配置方式:
1. 一个静态 StoreAPI 的列表(可重复)
2. 动态发现机制:
    - `dns+` 基于 DNS A 记录获取 StoreAPI 地址列表
    - `dbssrv+` 基于 SRV 获取 StoreAPI 地址列表

```
thanos query \
    --http-address 0.0.0.0:19192 \              # Endpoint for Query UI
    --grpc-address 0.0.0.0:19092 \              # gRPC endpoint for Store API
    --store        1.2.3.4:19090 \              # Static gRPC Store API Address for the query node to query
    --store        1.2.3.5:19090 \              # Also repeatable
    --store        dns+rest.thanos.peers:19092  # Use DNS lookup for getting all registered IPs as separate StoreAPIs    
```

#### 6.3 配置 query 与 sidecar/store 通信的方式, 自动发现
`--store STORE` 配置项是可重复的. 有一下配置方法:

1. 静态配置
  ```
  --store        1.2.3.4:19090 \              # Static gRPC Store API Address for the query node to query
  --store        1.2.3.5:19090 \              # Also repeatable
  ```
2. 服务发现
    - `dns+` or `dnssrv+`
        ```
        --store        dns+rest.thanos.peers:19092  # Use DNS lookup for getting all registered IPs as separate StoreAPIs    

        ```
    - 基于文件的自动发现
        ```
        --store.sd-files=/etc/thanos/file_sd/query_sidecar_*.yaml \
        --store.sd-files=/etc/thanos/file_sd/query_store_*.yaml \
        --store.sd-interval=5m
        ```

## 部署

![Thanos 部署示例](//wx4.sinaimg.cn/large/77fd5d57gy1g4fkrnrp85j21hm0lu43v.jpg)

### 1. prometheus

#### prometheus.service

```
prometheus \
  --storage.tsdb.max-block-duration=2h \
  --storage.tsdb.min-block-duration=2h \
  --web.enable-lifecycle
```

```
# prometheus.service

[Unit]
Description=Prometheus
After=network.target

[Service]
Type=simple
Environment="GOMAXPROCS=2"
User=prometheus
Group=prometheus
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/data/prometheus \
  --storage.tsdb.retention=3d \
  --storage.tsdb.min-block-duration=2h \
  --storage.tsdb.max-block-duration=2h \
  --web.console.libraries=/etc/prometheus/console_libraries \
  --web.console.templates=/etc/prometheus/consoles \
  --web.enable-lifecycle \
  --web.listen-address=0.0.0.0:9090

PrivateTmp=true
PrivateDevices=true
ProtectHome=true
NoNewPrivileges=true
LimitNOFILE=infinity
ReadWritePaths=/data/prometheus
ProtectSystem=strict
ProtectControlGroups=true
ProtectKernelModules=true
ProtectKernelTunables=true

SyslogIdentifier=prometheus
Restart=always

[Install]
WantedBy=multi-user.target
```

#### alertmanager.service
```
[Unit]
Description=Prometheus Alertmanager
After=network.target

[Service]
Type=simple
Environment="GOMAXPROCS=2"
User=prometheus
Group=prometheus
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/usr/local/bin/alertmanager \
  --config.file=/etc/prometheus/alertmanager.yml

PrivateTmp=true
PrivateDevices=true
ProtectHome=true
NoNewPrivileges=true
LimitNOFILE=infinity
ProtectSystem=strict
ProtectControlGroups=true
ProtectKernelModules=true
ProtectKernelTunables=true

SyslogIdentifier=prometheus-alertmanager
Restart=always

[Install]
WantedBy=multi-user.target
```

#### prom-node-exporter.service
```
[Unit]
Description=Prometheus node exporter
After=local-fs.target network-online.target network.target
Wants=local-fs.target network-online.target network.target

[Service]
ExecStart=/usr/local/bin/node_exporter
Type=simple
Restart=always

LimitNOFILE=1048576
LimitNPROC=1048576
LimitCORE=infinity


[Install]
WantedBy=multi-user.target
```



#### prometheus Doc
```
https://www.yangcs.net/prometheus/3-prometheus/basics.html
https://yunlzheng.gitbook.io/prometheus-book/
```

### 2. thanos

#### thanos-query.service
```
[Unit]
Description=Thanos Query
After=network.target

[Service]
Type=simple
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/usr/local/bin/thanos query \
    --http-address 0.0.0.0:19192 \
    --grpc-address 0.0.0.0:19092 \
    --query.replica-label replica \
    --store.sd-files=/etc/thanos/file_sd/query_sidecar_*.yaml \
    --store.sd-files=/etc/thanos/file_sd/query_store_*.yaml \
    --store.sd-interval=5m

PrivateTmp=true
PrivateDevices=true
ProtectHome=true
NoNewPrivileges=true
ProtectSystem=strict
ProtectControlGroups=true
ProtectKernelModules=true
ProtectKernelTunables=true

SyslogIdentifier=thanos-query
Restart=always
LimitNOFILE=1048576
LimitNPROC=1048576
LimitCORE=infinity

[Install]
WantedBy=multi-user.target
```

#### thanos-sidecar.service
```
[Unit]
Description=Thanos Sidecar
After=network.target

[Service]
Type=simple
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/usr/local/bin/thanos sidecar \
  --tsdb.path /data/prometheus \
  --objstore.config-file /etc/thanos/s3-thanos-example.yaml \
  --prometheus.url http://localhost:9090  \
  --http-address 0.0.0.0:19191 \
  --grpc-address 0.0.0.0:19090

PrivateTmp=true
PrivateDevices=true
ProtectHome=true
NoNewPrivileges=true
ProtectSystem=strict
ProtectControlGroups=true
ProtectKernelModules=true
ProtectKernelTunables=true

SyslogIdentifier=thanos-sidecar
Restart=always
LimitNOFILE=1048576
LimitNPROC=1048576
LimitCORE=infinity

[Install]
WantedBy=multi-user.target
```

#### thanos-store.service

```
[Unit]
Description=Thanos Store
After=network.target

[Service]
Type=simple
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/usr/local/bin/thanos store \
    --data-dir /data/thanos/store \
    --objstore.config-file /etc/thanos/s3-thanos-example.yaml \
    --http-address 0.0.0.0:29191 \
    --grpc-address 0.0.0.0:29090

PrivateTmp=true
PrivateDevices=true
ProtectHome=true
NoNewPrivileges=true

SyslogIdentifier=thanos-store
Restart=always
LimitNOFILE=1048576
LimitNPROC=1048576
LimitCORE=infinity

[Install]
WantedBy=multi-user.target
```
#### thanos-ruler.service
```
[Unit]
Description=Thanos Ruler
After=network.target

[Service]
Type=simple
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/usr/local/bin/thanos rule \
    --data-dir="/data/thanos/rules" \
    --eval-interval=30s \
    --rule-file="/etc/thanos/rules/*.rules.yaml" \
    --alert.query-url="10.23.21.237" \
    --alertmanagers.url="10.23.21.237" \
    --query.sd-files="/etc/thanos/file_sd/rule_query_dev.yaml" \
    --objstore.config-file=/etc/thanos/s3-thanos-example.yaml \
    --label=env="dev" \
    --label=replica="dev-thanos-002-ruler" \
    --alert.label-drop='replica'

PrivateTmp=true
PrivateDevices=true
ProtectHome=true
NoNewPrivileges=true

SyslogIdentifier=thanos-ruler
Restart=always
LimitNOFILE=1048576
LimitNPROC=1048576
LimitCORE=infinity

[Install]
WantedBy=multi-user.target
```

cmd
```
$ /usr/local/bin/thanos rule --log.level=debug --data-dir=/data/thanos/rules --eval-interval=30s --rule-file=/etc/thanos/rules/*.rules.yaml --alert.query-url=http://10.23.21.237:19192 --alertmanagers.url=http://10.23.79.238:9093 --query.sd-files=/etc/thanos/file_sd/rule_query_dev.yaml --objstore.config-file=/etc/thanos/s3-thanos-example.yaml --label='env="dev"' --label='replica="dev-thanos-002-ruler"' --alert.label-drop=replica
```

#### thanos-compactor.service
```
[Unit]
Description=Thanos Compactor
After=network.target

[Service]
Type=simple
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/usr/local/bin/thanos compact \
    --data-dir /data/thanos/compact \
    --http-address         0.0.0.0:39191 \
    --objstore.config-file=/etc/thanos/s3-thanos-example.yaml

PrivateTmp=true
PrivateDevices=true
ProtectHome=true
NoNewPrivileges=true

SyslogIdentifier=thanos-compactor
Restart=always
LimitNOFILE=1048576
LimitNPROC=1048576
LimitCORE=infinity

[Install]
WantedBy=multi-user.target
```

## 对象存储
Thanos 支持任何 可以实现 [objstore.Bucket interface](https://github.com/improbable-eng/thanos/tree/11d77980618b1df4753eb96006188ea535f3f8a7/pkg/objstore/objstore.go) 接口 的对象存储.

```
--objstore.config-file  # Yiyong peizhi wenjian 
--objstore.config # 直接传入配置参数.
```

### S3
Thanos 使用 [minio client](https://github.com/minio/minio-go) 库来上传 Prometheus 的数据到 S3.

```
type: S3
config:
  bucket: ""                        # 必选
  endpoint: ""                      # 必选, 参考地址[aws s3 endpoint](https://docs.aws.amazon.com/general/latest/gr/rande.html#s3_region)
  region: ""
  access_key: ""                    # 必选
  insecure: false                   # 使用 HTTP / HTTPS 传输
  signature_version2: false         # 可选, 当前 AWS signature 使用 v4 版本, 所以 设为 false. 如果配置错误, 返回 `Access Denied error`.
  encrypt_sse: false
  secret_key: ""                    # 必选
  put_user_metadata: {}
  http_config:
    idle_conn_timeout: 0s
    response_header_timeout: 0s
    insecure_skip_verify: false     # 是否 禁用 TLS 证书认证.
  trace:
    enable: false                   # 是否打开 minio 库的 debug 模式.
```

Thanos 默认使用一下顺序, 检索 AWS 认证信息:
1. `access_key` 和 `secret_key` 同时在 配置文件中配置.
2. `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` 环境变量
3. ` ~/.aws/credentials` 配置文件.

## 服务发现
### Thanos 中需要服务发现的位置
1. Query 发现 StoreAPI
2. Rule 发现 QueryAPI
3. Rule 发现 Alertmanagers HA.

### Thanos 配置方式

#### 1. flag

- Query
    
    ```
    --store=<store>
    ```

- Rule
    
    ```
    --query=<query>

     --alertmanager.url=<alertmanager> 
    ```

#### 2. 基于文件的服务发现
与 Prometheus 的基于文件的服务发现相同, 支持 JSON 和 YAML 格式. 默认, 重读配置文件的 interval 为 5min.

- JSON
    ```
    [
      {
        "targets": ["localhost:9090", "example.org:443"]
      }
    ]
    ```
- YAML
    
    ```
    - targets: ['localhost:9090', 'example.org:443']
    ```

##### 2.1 Query
```
--store.sd-files=<path>     # 文件路径, 支持 glob 模糊匹配
--store.sd-interval=<5m>    # 重读间隔时间
```

##### 2.2 Rule
```
--query.sd-files=<path>     # 文件路径, 支持 glob 模糊匹配
--query.sd-interval=<5m>    # 重读间隔时间
```

#### 3. 基于 DNS 的服务发现
Thanos 会定期请求一个 域名, 并发现其后面的 IP.

- `dns+` 作为 A/AAAA 记录查询, 需要配置 端口.
    ```
    --store=dns+stores.thanos.mycompany.org:9090
    ```

- `dnssrv+` 作为 SRV 查询, 无需配置 端口.
    ```
    --store=dnssrv+_thanosstores._tcp.mycompany.org
    ```

- 默认的间隔时间
    
    ```
    --store.sd-dns-interval     # for store
    --query.sd-dns-interval     # for query
    ```

## Prometheus 

![promtheus 数据收集计量](https://wx4.sinaimg.cn/large/77fd5d57gy1g4fs14axmej21gg0l1dq5.jpg)


原生数据 : 16 bytes/sample
    8 byte timestamp + 8 byte value = 1 sample
压缩后数据: 1.37 bytes/sample
    timestamp: 计算增量
    value: 与原值做 XOR 运算
    

### 数据存储格式
Prometheus 原生格式

```
# block 包含一个固定时间内的 metric 数据.
01BX6V6TY06G5MFQ0GPH7EMXRH  # block, 类UUID, (like UUID but lexicographically sortable), 加密了其创建时间.
├── chunks
│   ├── 000001
│   ├── 000002
│   └── 000003
├── index                   # 包含数据的 label 信息和 metrics 信息在 chunks 中的位置.
└── meta.json               # block 的元信息, 如 stats, time range, compaction(压缩) level
```

Thanos 在上传数据时, 保持原有的数据格式不变, 但是可能会在 `meta.json` 加入 Thanos 特有的信息, 目前只包含 `external labels`.

![image](https://wx3.sinaimg.cn/large/77fd5d57gy1g4ft3lr41zj20i9066mxb.jpg)

prometheus 中的 `meta.json` 
```
{
    "ulid": "01DEAJHD3MW22SAVSPZNEWPRCA",
    "minTime": 1561564800000,
    "maxTime": 1561572000000,
    "stats": {
        "numSamples": 1464324,
        "numSeries": 3062,
        "numChunks": 12212,
        "numBytes": 2162049
    },
    "compaction": {
        "level": 1,
        "sources": [
            "01DEAJHD3MW22SAVSPZNEWPRCA"
        ]
    },
    "version": 1
}

```
thanos 中的 `meta.json` 
```
{
    "version": 1,
    "ulid": "01DEAJHD3MW22SAVSPZNEWPRCA",
    "minTime": 1561564800000,
    "maxTime": 1561572000000,
    "stats": {
        "numSamples": 1464324,
        "numSeries": 3062,
        "numChunks": 12212,
        "numBytes": 2162049
    },
    "compaction": {
        "level": 1,
        "sources": [
            "01DEAJHD3MW22SAVSPZNEWPRCA"
        ]
    },
    "thanos": {
        "labels": {
            "env": "dev",
            "replica": "dev-thanos-004"
        },
        "downsample": {
            "resolution": 0
        },
        "source": "sidecar"
    }
}
```

### store

stores 持续不断的同步在 bucket 中的 block 数据, 同时 翻译 对 metrics 数据的请求到对象存储. Stores 实现了多种策略来减少对 对象存储的 请求次数, 如 使用 block 的元数据来过滤相关的 blocks, 缓存最频繁的请求的结果.

本质上, StoreApi 允许通过一系列的 label 和 时间序列来检索数据, 并从 blocks 中返回压缩过的 chunks samples. 他仅仅是一个数据过滤 的 API, **不提供**复杂的查询语法.

![image](https://ws4.sinaimg.cn/large/77fd5d57gy1g4ftoypv4nj20i20ah0t4.jpg)

### Query Layer 
QueryLayer 在 StoreAPI 的基础上, 实现了 PromQL , 并且是无状态和可以水平扩展的.

Queriers participate in the cluster to be able to resiliently discover all data sources and store nodes. Rule nodes in return can discover query nodes to evaluate recording and alerting rules.

Based on the metadata of store and source nodes, they attempt to minimize the request fanout to fetch data for a particular query.

![image](https://wx3.sinaimg.cn/large/77fd5d57gy1g4fts3jpsaj20fs095jrn.jpg)

### Compactor

单例, 指向一个对象存储, 并连续不断的把 小的 block 合并成大的 block, 这些操作有一下优势:
1. 减少对象存储的大小
2. 减轻 store 节点的负担
3. 减少每个查询需要从对象存储请求数据的次数.

### Scaling

**None of the Thanos components provides any means of sharding**. 

只有 query node 是无状态, 可任意扩展的. 存储能力的扩展, 依赖于对象存储供应商.

Store, rule, and compactor nodes are all expected to scale significantly within a single instance or high availability pair. Similar to Prometheus, functional sharding can be applied for rare cases in which this does not hold true.
For example, rule sets can be divided across multiple HA pairs of rule nodes. Store nodes likely are subject to functional sharding regardless by assigning dedicated buckets per region/datecenter.

## 其他组件

### 命令行工具
#### 1. bucket
用于 inspect 对象存储中的 bucket 信息. 主要用做命令行, 来帮助 troubleshooting.

可以用过在 `/cmd/thanos/bucket.go` 中添加子命令来扩展 bucket 的功能.

```
usage: thanos bucket [<flags>] <command> [<args> ...]

Bucket utility commands

Flags:
  -h, --help               Show context-sensitive help (also try --help-long and --help-man).
      --version            Show application version.
      --log.level=info     Log filtering level.
      --log.format=logfmt  Log format to use.
      --gcloudtrace.project=GCLOUDTRACE.PROJECT
                           GCP project to send Google Cloud Trace tracings to. If empty, tracing will be disabled.
      --gcloudtrace.sample-factor=1
                           How often we send traces (1/<sample-factor>). If 0 no trace will be sent periodically, unless forced by
                           baggage item. See `pkg/tracing/tracing.go` for details.
      --objstore.config-file=<bucket.config-yaml-path>
                           Path to YAML file that contains object store configuration.
      --objstore.config=<bucket.config-yaml>
                           Alternative to 'objstore.config-file' flag. Object store configuration in YAML.

Subcommands:
  bucket verify [<flags>]
    Verify all blocks in the bucket against specified issues

  bucket ls [<flags>]
    List all blocks in the bucket

  bucket inspect [<flags>]
    Inspect all blocks in the bucket in detailed, table-like way

    |            ULID            |        FROM         |        UNTIL        | RANGE  | UNTIL-COMP | #SERIES | #SAMPLES  | #CHUNKS | COMP-LEVEL | COMP-FAILED |             LABELS             | RESOLUTION | SOURCE  |
    |----------------------------|---------------------|---------------------|--------|------------|---------|-----------|---------|------------|-------------|--------------------------------|------------|---------|
    | 01DE9Q2G3KEB66TY3WXX20BSKD | 26-06-2019 16:00:00 | 26-06-2019 18:00:00 | 2h0m0s | 38h0m0s    | 3,006   | 1,421,094 | 11,795  | 1          | false       | env=dev,replica=dev-thanos-004 | 0s         | sidecar |
    | 01DE9Q2G6V1R4M7SAT133MP00H | 26-06-2019 16:00:00 | 26-06-2019 18:00:00 | 2h0m0s | 38h0m0s    | 2,983   | 1,410,705 | 10,457  | 1          | false       | env=dev,replica=dev-thanos-003 | 0s         | sidecar |
    | 01DE9Q2HHYE6FYM169XQ3N8EY9 | 26-06-2019 16:00:00 | 26-06-2019 18:00:00 | 2h0m0s | 38h0m0s    | 3,052   | 1,425,546 | 10,618  | 1          | false       | env=dev,replica=dev-thanos-002 | 0s         | sidecar |
    | 01DE9Q2HN7Z8TAEDA67J4TVBK8 | 26-06-2019 16:00:00 | 26-06-2019 18:00:00 | 2h0m0s | 38h0m0s    | 3,167   | 1,456,716 | 11,089  | 1          | false       | env=dev,replica=dev-thanos-001 | 0s         | sidecar |
    | 01DE9XY7BMZ9044FZVF50VRM0A | 26-06-2019 18:00:00 | 26-06-2019 20:00:00 | 2h0m0s | 38h0m0s    | 3,098   | 1,433,477 | 9,222   | 1          | false       | env=dev,replica=dev-thanos-004 | 0s         | sidecar |
```

#### 2. check
用于检查 Prometheus rules 的可用性.

`thanos check rules` 用于 thanos rule node 节点上, 用于检查 Prometheus rule, 功能与 `promtool check rules` 等价, 只是 Thanos rule 有扩展的语法, 包含`partial_response_strategy`字段.

```
usage: thanos check <command> [<args> ...]

Linting tools for Thanos

Flags:
  -h, --help               Show context-sensitive help (also try --help-long and
                           --help-man).
      --version            Show application version.
      --log.level=info     Log filtering level.
      --log.format=logfmt  Log format to use.
      --tracing.config-file=<tracing.config-yaml-path>
                           Path to YAML file that contains tracing
                           configuration.
      --tracing.config=<tracing.config-yaml>
                           Alternative to 'tracing.config-file' flag. Tracing
                           configuration in YAML.

Subcommands:
  check rules <rule-files>...
    Check if the rule files are valid or not. 检查成功, 返回 0; 失败 返回 1.

    $ ./thanos check rules cmd/thanos/testdata/rules-files/*.yaml
```

### compact

### query
QueryAPI 是完全兼容 Prometheus 2.x 的, 但是, 为了实现 Thanos 额外的特性, QueryAPI 在 Prometheus 智商, 增加了如下特性:

#### 1. partial response behaviour

通过 `--query.partial-response   Enable partial response for queries if no partial_response param is specified.` 参数来控制. 这个参数用来在 **可用性** 和 **精准性** 之间来保持平衡.

`partial response` 是一种可能无法返回或只返回部分查询结果的情况, 该情况可能是由于某一个或者多个 StoreAPI error 或者 超时, 但是其他 StoreAPI 正常返回. 当`partial response` 发生时, QueryAPI 返回人类可读的告警信息.

以下参数用于控制 超时时间:

- `--query.timeout`: 
- `--store.response-timeout`: 

如果更倾向于查询结果的 可用性而不是精确性, 可以设置较小的 超时时间,

##### 1.2 Partial Response Strategy

| HTTP URL/FORM parameter | Type | Default | Example |
|----|----|----|----|
| `partial_response` | `Boolean` | `query.partial-response` flag (default: True) | `1, t, T, TRUE, true, True` for "True" |
|  |  |  |  |


如果设为 `True`(默认值), 那么, 被查询的 StoreApi 节点在不可用时, 不会导致查询失败, 而只返回 warning.


#### 2. Deduplication Enable

`dedup` 参数用于控制 查询是否应该对结果使用 去重 标记.

| HTTP URL/FORM parameter | Type | Default | Example |
|----|----|----|----|
| `dedup` | `Boolean` | True, but effect depends on `query.replica` configuration flag. | `1, t, T, TRUE, true, True` for "True" |
|  |  |  |  |

#### 3. Auto downsampling

Max source resolution(决定, 决心) is max resolution in seconds we want to use for data we query for. 
This means that for value:
- `0` -> we will use only raw data.
- `5m` -> we will use max 5m downsampling.
- `1h` -> we will use max 1h downsampling.


| HTTP URL/FORM parameter | Type | Default | Example |
|----|----|----|----|
| `max_source_resolution` | `Float64/time.Duration/model.Duration` | `step / 5` or `0` if `query.auto-downsampling` is false (default: False) | `5m` |
|  |  |  |  |

#### 4. custom reponse fields 自定义响应字段

自定义的额外响应字段, 不会影响 Thanos 的兼容性, 但是, 无法保证 Grafana 或者其他第三方应用能实现兼容.

当前 Thanos 的 UI 理解如下字段:

```go
type queryData struct {
    ResultType promql.ValueType `json:"resultType"`
    Result     promql.Value     `json:"result"`

    // Additional Thanos Response field.
    Warnings   []error          `json:"warnings,omitempty"`
}

```

额外字段 `warnings` 用于包含任何非致命错误的错误信息. 

`partial_response` 参数可以控制 StoreAPI 的不稳定状态是否是致命错误信息.


#### 5. 使用自定义 Path 暴露 Thanos UI

Thanos UI 自定义 Path 有如下两种方式:

1. 静态方式: 与 Prometheus 定义方式相同.
    
    - `web.route-prefix`: 定义通用前缀.
    - `web.external-prefix`: 定义 HTML代码 中的 URL 的前缀 和 HTTP 重定向响应. `prefixes the URLs in HTML code and the HTTP redirect responces.`

2. 通过 HTTP 首部动态定义, Prometheus 暂不支持.
    
    用于 `thanos query` 被暴露在一个反向代理后面的时候, 例如 在一个 Kubernetes ingress 如 Traefix/nginx 后面.

    if `PathPrefixStrip: /some-path` options or `traefix.frontend.rule.type: PathPrefixStrip` Kubernetes Ingress Annotation is set, than `Traefik` writes the stripped prefix into X-Forwarded-Prefix header. Then, `thanos query --web.prefix-header=X-Forwarded-Prefix` will server correct HTTP redirects and links prefixed by the stripped path.

    `--web.prefix-header` 与 `--web.external-prefix` 参数**互斥**.

### rule

Prometheus 支持两种格式的 rule:
- Recording rule: 将比较耗时的查询, 预先做计算, 并将结果存储为新的时间序列, 并在查询时, 直接返回预先计算的结果. Recording rule 在做 dashboard 展示时, 十分有用, 因为 dashboard 的总是一样的.
    
    配置语法:

    `<groups>`
    ```
    groups:
      [ - <rule_group> ]

    ```

    `<rule_group>`
    ```
    # The name of the group. Must be unique within a file.
    name: <string>

    # How often rules in the group are evaluated.
    [ interval: <duration> | default = global.evaluation_interval ]

    rules:
      [ - <rule> ... ]
    ```

    `<rule>` recording rule
    ```
    # The name of the time series to output to. Must be a valid metric name.
    record: <string>

    # The PromQL expression to evaluate. Every evaluation cycle this is
    # evaluated at the current time, and the result recorded as a new set of
    # time series with the metric name as given by 'record'.
    expr: <string>

    # Labels to add or overwrite before storing the result.
    labels:
      [ <labelname>: <labelvalue> ]
    ```

    `<rule>` alerting rule
    ```
    # The name of the alert. Must be a valid metric name.
    alert: <string>

    # The PromQL expression to evaluate. Every evaluation cycle this is
    # evaluated at the current time, and all resultant time series become
    # pending/firing alerts.
    expr: <string>

    # Alerts are considered firing once they have been returned for this long.
    # Alerts which have not yet fired for long enough are considered pending.
    [ for: <duration> | default = 0s ]

    # Labels to add or overwrite for each alert.
    labels:
      [ <labelname>: <tmpl_string> ]

    # Annotations to add to each alert.
    annotations:
      [ <labelname>: <tmpl_string> ]
    ```

    Example
    ```
    groups:
      - name: example
        rules:
        - record: job:http_inprogress_requests:sum
          expr: sum(http_inprogress_requests) by (job)
    ```

- Alerting rule: 配置方式与 Recording Rule 相同, 配置语法略有差异
    
    Example
    ```
    groups:
    - name: example
      rules:
      - alert: HighErrorRate
        expr: job:request_latency_seconds:mean5m{job="myjob"} > 0.5
        for: 10m    # 错误持续时间 直到报警.
        labels:     # 支持模板, [语法](https://prometheus.io/docs/visualization/consoles/)
          severity: page
        annotations:    # 支持模板, [语法](https://prometheus.io/docs/visualization/consoles/)
          summary: High request latency
    ```


Thanos Ruler 

```
$ /usr/local/bin/thanos rule --log.level=debug --data-dir=/data/thanos/rules --eval-interval=30s --rule-file=/etc/thanos/rules/*.rules.yaml --alert.query-url=http://10.23.21.237:19192 --alertmanagers.url=http://10.23.106.152:9093 --query.sd-files=/etc/thanos/file_sd/rule_query_dev.yaml --objstore.config-file=/etc/thanos/s3-thanos-example.yaml --label='env="dev"' --label='replica="dev-thanos-002-ruler"' --alert.label-drop=replica


```

### sidecar



### store



## 压力测试

参考:

- [thanos benchmark](https://github.com/improbable-eng/thanos/tree/master/benchmark)


metrics: 205191
size: 338416    331M
web hold metrics: 25k, 30k 就卡了

```Bash
# run in dev-thanos-003

function prom_query(){
    echo "prometheus : $1"
    time prometheus-query -query $1 -server $PROM_SERVER -start '12 hours ago' -format csv | wc -l
}

function thanos_query(){
    echo "thanos : $1"
    time prometheus-query -query $1 -server $THANOS_SERVER -start '12 hours ago' -format json &> /dev/null
}

function query(){
    prom_query $1
    thanos_query $1
}

query '{__name__=~"avalanche_metric_mmmmm_100_1"}'


prometheus-query -server $PROM_SERVER -start '12 hours ago' -format csv -query 

time prometheus-query -server $THANOS_SERVER -start '12 hours ago' -format csv -query 'sum({__name__=~"avalanche_.*"}) by (instance)'

# rate({__name__=~"ts_.*"}[1m])
# sum({__name__=~”ts_.*”}) by (instance)
# Fetch 45 thousand metrics from a single timeseries 'ts_00'
```

test: 2u4g
    开始: 2019年07月08日17:35:47
    开始: 2019年07月08日17:53:41


## Other
https://www.hi-linux.com/posts/36431.html

[server]
prometheus_server=123
thanos_server=123

[config]
count: 1
output_file_name: result
time_start: as

[promql]
promql=pql1,pql3,pql3



prometheus_server = 10.23.149.6:9090
thanos_server = 10.23.21.237:19192


Congratulations, Shadowsocks-go server install completed!
Your Server IP        :  139.180.129.27
Your Server Port      :  19458
Your Password         :  123.com
Your Encryption Method:  aes-256-cfb


## statsd-exporter

[github](https://github.com/prometheus/statsd_exporter)

发送数据可以使用 nc 来进行
```
echo "foo:1|c" | nc -w 1 -u 127.0.0.1 8125
```

### 协议
statsd采用简单的行协议：
```
<bucket>:<value>|<type>[|@sample_rate]
```
1. bucket
    bucket是一个metric的标识，可以看成一个metric的变量。

2. value
    metric的值，通常是数字。

3. type

    metric的类型，通常有timer、counter、gauge和set四种。

4. sample_rate

    如果数据上报量过大，很容易溢满statsd。所以适当的降低采样，减少server负载。
    这个频率容易误解，需要解释一下。客户端减少数据上报的频率，然后在发送的数据中加入采样频率，如0.1。statsd server收到上报的数据之后，如cnt=10，得知此数据是采样的数据，然后flush的时候，按采样频率恢复数据来发送给backend，即flush的时候，数据为cnt=10/0.1=100，而不是容易误解的10*0.1=1。

5. UDP 和 TCP
    
    statsd可配置相应的server为UDP和TCP。默认为UDP。UDP和TCP各有优劣。但
    UDP确实是不错的方式。

    UDP不需要建立连接，速度很快，不会影响应用程序的性能。
    “fire-and-forget”机制，就算statsd server挂了，也不会造成应用程序crash。
    当然，UDP更适合于上报频率比较高的场景，就算丢几个包也无所谓，对于一些一天已上报的场景，任何一个丢包都影响很大。另外，对于网络环境比较差的场景，也更适合用TCP，会有相应的重发，确保数据可靠。

### statsd 指标类型

#### counter 计数器
counter类型的指标，用来计数。在一个flush区间，把上报的值累加。值可以是正数或者负数。
```
user.logins:10|c        // user.logins + 10
user.logins:-1|c        // user.logins - 1 
user.logins:10|c|@0.1   // user.logins + 100
                        // users.logins = 10-1+100=109
```

#### timer 计时器
timers用来记录一个操作的耗时，单位ms。statsd会记录平均值（mean）、最大值（upper）、最小值（lower）、累加值（sum）、平方和（sum_squares）、个数（count）以及部分百分值。
```
rpt:100|g
```
如下是在一个flush期间，发送了一个rpt的timer值100。以下是记录的值。
```
count_80: 1,    
mean_80: 100,
upper_80: 100,
sum_80: 100,    
sum_squares_80: 10000, 
std: 0,     
upper: 100,
lower: 100,
count: 1,
count_ps: 0.1,
sum: 100,
sum_squares: 10000,
mean: 100,
median: 100 

```
对于百分数相关的数据需要解释一下。以90为例。statsd会把一个flush期间上报的数据，去掉10%的峰值，即按大小取cnt*90%（四舍五入）个值来计算百分值。
举例说明，假如10s内上报以下10个值。
```
1,3,5,7,13,9,11,2,4,8
```
则只取10*90%=9个值，则去掉13。百分值即按剩下的9个值来计算。
```
$KEY.mean_90   // (1+3+5+7+9+2+11+4+8)/9
$KEY.upper_90  // 11
$KEY.lower_90  // 1
```

#### gauge 标量
gauge是任意的一维标量值。gague值不会像其它类型会在flush的时候清零，而是保持原有值。statsd只会将flush区间内最后一个值发到后端。另外，如果数值前加符号，会与前一个值累加。

```
age:10|g    // age 为 10
age:+1|g    // age 为 10 + 1 = 11
age:-1|g    // age为 11 - 1 = 10
age:5|g     // age为5,替代前一个值
```

#### set
记录flush期间，不重复的值。
```
request:1|s  // user 1
request:2|s  // user1 user2
request:1|s  // user1 user2
```

### statsite
```
[statsite]
port=8125
udp_port=8125
log_level=INFO
flush_interval=10
timer_eps=0.01
set_eps=0.02
stream_cmd=python /usr/libexec/statsite/sinks/graphite.py 10.24.1.6 2004 ""
daemonize=1
pid_file=/var/run/statsite/statsite.pid

use_type_prefix=0
extended_counters=1
extended_counters_include=rate,sum
timers_include=mean,lower,rate,median
quantiles=0.95,0.99
global_prefix=
```

### install
```Bash
$ wget https://github.com/prometheus/statsd_exporter/releases/download/v0.12.1/statsd_exporter-0.12.1.linux-amd64.tar.gz

# STATSD.READ-BUFFER 必须比 sysctl -a | grep net.core.rmem_max 小.
$ ./statsd_exporter --web.listen-address=":9102" \
      --web.telemetry-path="/metrics" \
      --statsd.listen-udp=":8125" \
      --statsd.listen-tcp=":8125" \
      --statsd.read-buffer=STATSD.READ-BUFFER   \
      --statsd.cache-size=1000 \
      --statsd.event-queue-size=10000 \
      --statsd.event-flush-threshold=1000 \
      --statsd.event-flush-interval=200ms \
      --log.level="info"

      --statsd.mapping-config=STATSD.MAPPING-CONFIG
                                Metric mapping configuration file name.


```

### Python StatD Client
参考: https://pythonhosted.org/python-statsd/

#### Timers
```Python
import statsd
timer = statsd.Timer('MyApplication')
timer.start()

# do something here
timer.stop('SomeTimer')
```

#### Cunters
```Python
import statsd
counter = statsd.Counter('MyApplication')
# do something here
counter += 1
```

#### Gauge
```Python
 import statsd

 gauge = statsd.Gauge('MyApplication')
 # do something here
 gauge.send('SomeName', value)
```

#### Raw
Raw 数据是预选计算好的加过, 需要直接传递给 carbon 的数据. Raw 格式数据需要一个时间戳(`date +%s`), 如果没有或者为 None, 则默认采用当前时间戳.

```Python
 import statsd

 raw = statsd.Raw('MyApplication', connection)
 # do something here
 raw.send('SomeName', value, timestamp)
```

#### Average
```Python
 import statsd

 average = statsd.Average('MyApplication', connection)
 # do something here
 average.send('SomeName', 'somekey:%d'.format(value))

```

#### Connection settings
```Python

 import statsd
 statsd.Connection.set_defaults(host='localhost', port=8125, sample_rate=1, disabled=False)
```
使用 `statsd.Connection.set_defaults()` 之后的所有 数据传递, 都将使用该方法定义的值 作为默认值, 除非明确定义不同的值.

#### Advanced Usage
```Python
import statsd

# Open a connection to `server` on port `1234` with a `50%` sample rate
statsd_connection = statsd.Connection(
 host='server',
 port=1234,
 sample_rate=0.5,
)

# Create a client for this application
statsd_client = statsd.Client(__name__, statsd_connection)

class SomeClass(object):
 def __init__(self):
     # Create a client specific for this class
     self.statsd_client = statsd_client.get_client(
         self.__class__.__name__)

 def do_something(self):
     # Create a `timer` client
     timer = self.statsd_client.get_client(class_=statsd.Timer)

     # start the measurement
     timer.start()

     # do something
     timer.intermediate('intermediate_value')

     # do something else
     timer.stop('total')
```
如果需要 关闭 service 或者 避免发送 UPD 消息, statsd 链接`Connection` 类, 可以设置 `disabled` 选项来关闭.
```Python
statsd_connetcion = statsd.Connection(
    host='server',
    port=1234,
    sample_rate=0.5,
    disabled=True
)
```

#### udpcopy
设想: 为防止 statsd-exporter 不可用, 将 stats-site 与 statsd-exporter 并行运行一段时间, 因此, 需要将 stats-site 的流量做镜像到 statsd-exporter.

实现: [udpcopy](https://github.com/wangbin579/udpcopy)

1. 编译安装
    
    ```
    # download the source code from github:
    $ yum install autoconf automake libtool -y
    $ git clone http://github.com/wangbin579/udpcopy
    $ sh autogen.sh
    $ ./configure
    $ make
    $ make install
    $ /usr/local/bin/udpcopy --help
    ```

2. 运行

    ```
    # on the source host (root privilege is required): udpcopy -x local_port-remote_ip:remote_port 
    $ /usr/local/bin/udpcopy -x 8125-127.0.0.1:8126

    # on the target host : iptables -I OUTPUT -p udp --sport port -j QUEUE # if not set
    $ iptables -I OUTPUT -p udp --sport 8125 -j QUEUE

    # 删除 规则
    $ iptables -L OUTPUT -n     # 查看新添加规则, 在第几条.
    $ iptables -D OUTPUT 1      # 删除 OUOUT 链上的第一条规则. 
    ```

## PromQL
```
TODO
```

## alertmanager

alert
    silencing(使安静)
    inhibition(抑制)
    aggregation(聚合)
        聚合
        分组
        路由
    notification
        email
        on-call-platform
        chat platforms
### 配置
```
./alertmanager --config.file=simple.yml
```

Alertmanager 支持运行时重载, 有一下两种方式:
1. 向主程序发送 `SIGHUP` 信号;
2. 向 `/-/reload` 接口发送 POST 请求.

如果新的配置有错, 则 Alertmanager 不会应用这些配置, 并将这些配置记录到日志中.

#### 配置段
- `<duration>`: 持续时间, 符合正则 `[0-9]+(ms|[smhdwy])` 
- `<labelname>`: 字符串, lable, `[a-zA-Z_][a-zA-Z0-9_]*`
- `<labelvalue>`: a string of unicode characters
- `<filepath>`: a valid path in the current working directory
- `<boolean>`: a boolean that can take the values true or false
- `<string>`: a regular string
- `<secret>`: a regular string that is a secret, such as a password
- `<tmpl_string>`: a string which is template-expanded(展开) before usage
- `<tmpl_secret>`: a string which is template-expanded before usage that is a secret



### 核心特性
#### 1. Groupinbg
Grouping of alerts, timing for the grouped notifications, and the receivers of those notifications are configured by a routing tree in the configuration file.


#### 2. Inhibition(抑制)

#### 3. Silences(静默)
禁止一个 alert 报出一定时间. 基于 匹配 来过滤. 通过 web 来配置.

#### 4. client behavior
#### 5. HA














