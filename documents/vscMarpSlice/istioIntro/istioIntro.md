---
marp: true
theme: gaia
_class: lead
paginate: true
backgroundColor: #fff
backgroundImage: url('https://marp.app/assets/hero-background.jpg')
---
# Service Mesh
![bg left:33%](imgs/istio-logo-2.png)

1. 什么是服务网格?
2. istio 架构与核心概念
3. istio 流量管理
4. 基于 istio 的开发泳道

---
<!-- 
云计算: 以资源为中心. 关注物理设备如何虚拟化,池化,多租化. 典型代表是 计算/存储/网络 三大基础设施的云化.

云原生: 以应用为中心. 基于云环境之上的, 如何让应用更好的适应云环境, 能够在云环境下快速开发和交付应用. 

微服务: 应用的设计和开发. 从设计, 开发的视角描述应用的一种架构或开发模式.

服务网格: 应用的交付与运行时. 服务网格是微服务之间通信的控制器.
-->

# 服务网格被称为**第二代微服务架构**.

> William Morgan，Buoyant CEO , Linkerd : 
> 
> A service mesh is a dedicated **infrastructure layer** for handling service-to-service communication. It’s responsible for the reliable **delivery of requests** through the complex topology of services that comprise a modern, cloud native application. In practice, the service mesh is typically implemented as an array of **lightweight network proxies** that are deployed alongside application code, **without the application needing to be aware**.
> 

---

传统微服务痛点:
- **侵入性强**: 业务代码与治理层代码界限不清晰.
- **升级成本高, 版本碎片化严重**: 每次升级都需要业务应用修改 SDK 版本，就会导致线上不同服务引用的 SDK 版本不统一, 能力参差不齐，造成很难统一治理.
- **中间件演变困难**: 由于版本碎片化严重，导致中间件向前演进的过程中就需要在代码中兼容各种各样的老版本逻辑，无法实现快速迭代.
- **治理功能不全**: 协议转换支持, 多重授权机制, 动态请求路由, 故障注入, 灰度发布等高级功能并没有覆盖到.

---
服务网格愿景:
- **微服务治理与业务逻辑的解耦**

    服务网格把 SDK 中的大部分能力从应用中剥离出来，拆解为独立进程，以 sidecar 的模式进行部署.服务网格通过将服务通信及相关管控功能从业务程序中分离并下沉到基础设施层，使其和业务系统完全解耦，使开发人员更加专注于业务本身

- **异构系统的统一治理**

    不同语言, 不同框架的应用和服务，为了能够统一管控这些服务，以往的做法是为每种语言, 每种框架都开发一套完整的 SDK，维护成本非常之高，而且给公司的中间件团队带来了很大的挑战.

---
服务网格相对于传统微服务框架的**技术优势** : 
- **可观察性** : 服务网格是一个专用的基础设施层，所有的服务间通信都要通过它. 所以服务网格可以捕获诸如来源, 目的地, 协议, URL, 状态码, 延迟, 持续时间等线路数据.

- **流量控制** : 通过 服务网格 可以为服务提供智能路由（蓝绿部署, 金丝雀发布, A/B test）, 超时重试, 熔断, 故障注入, 流量镜像等各种控制能力.
    
- **安全** : 服务网格的安全相关体现在三个核心领域 : 服务的认证, 服务间通讯的加密, 安全相关策略的强制执行.

---
服务网格的**局限性**: 
- **增加了复杂度** : 服务网格将 sidecar 代理和其它组件引入到已经很复杂的分布式环境中，会极大地增加整体链路和操作运维的复杂性.
- **延迟** : 从链路层面来讲，服务网格是一种侵入性的, 复杂的技术，可以为系统调用增加显著的延迟.这个延迟是**毫秒级别**的，但是在特殊业务场景下，这个延迟可能也是难以容忍的.
- **平台的适配 及 维护人员需要更专业** : 服务网格的侵入性迫使开发人员和运维人员适应高度自治的平台并遵守平台的规则. 在容器编排器（如 Kubernetes）上添加 Istio 之类的服务网格，通常需要运维人员成为这两种技术的专家，以便充分使用二者的功能以及定位环境中遇到的问题.

---
服务网格 实现 : 
- Istio
- Linkerd
- AWS App Mesh
- SOFA mesh
- kuma
- Gloo Mesh
- OSM, open service mesh

---
# 服务网格 架构

Service Mesh 的基础设施层主要分为两部分 : 
- 控制平面: `istiod`
- 数据平面: `istio-proxy(envoy)`

---

![](imgs/service-mesh-model.png)

---

![bg left: 95% right: 95%](imgs/istio-arch.svg)

---
## 控制平面
- 不直接解析数据包.
- 与控制平面中的代理通信，下发策略和配置.
- 负责网络行为的可视化.
- 通常提供 API 或者命令行工具可用于配置版本化管理，便于持续集成和部署.

---
## 数据平面
- 通常是按照**无状态**目标设计的，但实际上为了提高流量转发性能，需要缓存一些数据，因此- 无状态也是有争议的.
- 直接处理入站和出站数据包，转发, 路由, 健康检查, 负载均衡, 认证, 鉴权, 产生监控数据等.
- 对应用来说**透明**，即可以做到无感知部署.

---
# Istio 服务网格实现

| 动态配置(控制平面) | 流量转发(数据平面) |
| -- | -- |
| consul + consul-template | Nginx + iptables |
| istiod | istio-proxy(Envoy xDS) + iptables |

---
### Pod 与 K8S Admission Webhook
- `MutatingAdmissionWebhook`: 可以在返回准入响应之前通过创建补丁来修改对象.
- `Init Container`: 通过 iptables 劫持所有流量到 sidecar
- `Proxy Sidecar`: 讲流量转发到 后端服务.

---
![bg left: 99% right: 99%](imgs/k8s-api-request-lifecycle.png)

---

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: gapp-c-747b697695-n842r
  namespace: lane-http
spec:
  containers:
  - name: gapp-c
    ports:
    - containerPort: 8080
      name: p8080
      protocol: TCP
  - name: istio-proxy
    ports:
    - containerPort: 15090
      name: http-envoy-prom
      protocol: TCP
  initContainers:
  - args:
    - istio-iptables -p "15001" -z "15006" -u "1337" -m REDIRECT -i '*' -x "" -b '*' -d 15090,15021,15020
    name: istio-init
```

---
###  CRD & Envoy xDS

- `Virtual Service`: 流量路由
- `Destination Rule`: 将流量路由到目标 pod, 流量策略, tls 等.
- `Service Entry`: 服务网格外的服务注册到服务网格内.
- `Gateway`: egress/ingress 控制出/入服务网格的流量.

---

| xDS | 描述 |
| -- | -- |
| LDS, Listener Discovery Service | 监听器发现服务 |
| RDS, Route Discovery Service | 路由发现服务 |
| CDS, Cluster Discovery Service | 集群发现服务 |
| EDS, Endpoint Discovery Service | 集群成员发现服务 |
| ADS, Aggregated Discovery Service | 聚合发现服务 |
| SDS, Secret Discovery Service | 密钥发现服务 |
| xDS  | 以上各种 API 的统称 |

---
```
# VirtualService 路由
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: reviews.bookinfo
spec:
  hosts:
    - reviews.bookinfo.com
  http:
  - route:
    timeout: 10s
    retries:
      attempts: 3
      perTryTimeout: 2s
    - destination:
        host: reviews
        subset: v1
      weight: 75
    - destination:
        host: reviews
        subset: v2
      weight: 25
```
---
```
# VirtualService: 故障注入, 网络层
  fault:
    delay:
      percentage:
        value: 0.1
      fixedDelay: 5s
```
```
# VirtualService: 流量镜像
  http:
  - route:
    - destination:
        host: httpbin
        subset: v1
      weight: 100
    mirror:
      host: httpbin
      subset: v2
    mirrorPercent: 100
```
---
```
# DestinationRule: 负载均衡
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: my-destination-rule
spec:
  host: my-svc
  trafficPolicy:
    loadBalancer:
      simple: RANDOM
  subsets:
  - name: v1
    labels:
      version: v1
  - name: v2
    labels:
      version: v2
    trafficPolicy:
      loadBalancer:
        simple: ROUND_ROBIN
  - name: v3
    labels:
      version: v3
```
---
```
# Gateway: 外部服务导入
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: ext-host-gwy
spec:
  selector:
    app: my-gateway-controller
  servers:
  - port:
      number: 443
      name: https
      protocol: HTTPS
    hosts:
    - ext-host.example.com
    tls:
      mode: SIMPLE
      credentialName: ext-host-cert
```

---
```
# ServiceEntry: 注册外部服务
apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: ext-google
spec:
  hosts:
  - www.google.com
  ports:
  - number: 443
    name: https
    protocol: HTTPS
  location: MESH_EXTERNAL
  resolution: DNS
```

---
# 基于服务网格的泳道实现

泳道实现层面:
1. 应用层面: --> Istio work here.

    - 流量打标/染色: 通过在 HTTP/GRCP 传递 `X-LANE-ID` 首部实现.
    - 流量路由: Virtual Service + Destination Rule

2. 数据层面: 

    参考: https://git.leyantech.com/ep/team-tasks/-/issues/100

---
# 效果图
![bg right: 99%](imgs/lane-example.png)
