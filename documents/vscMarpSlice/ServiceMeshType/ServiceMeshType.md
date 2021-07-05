---
marp: true
theme: gaia
_class: lead
paginate: true
backgroundColor: #fff
backgroundImage: url('https://marp.app/assets/hero-background.jpg')
---

# 多环境服务网格方案讨论

---

## 目标: 

1. kubernetes 环境统一, 节省维护成本.
2. 服务网格技术方案定型, 尽可能做到多环境统一.

---
## 现状:
- `jst`: dew/stg/prd/pre/prg, k8s 使用 Aliyun ACK, ServiceMesh JST 在推 ASM
- `nta`: sth/nta, k8s 自建, ServiceMesh 可选 Istio 或 ASM
- 其他: jdc/xhs, k8s 自建, ServiceMesh 待定.

---
## ServiceMesh 可选技术方案: 
- Istio: 社区方案, 维护成本较高, 同时, JST 目前没有支持计划.
- ASM, Aliyun ServiceMesh: 兼容 istio.

可能存在问题:
1. jdc 环境如何处理? 是否采用服务网格? 网格方案自维护?
2. sth/nta 可能会存在迁移成本 --> 计划做成多集群互访问模式, 为以后可能的迁移做技术准备.

---
## TODO

1. 成本
2. SLA
3. 阶段性时间节点